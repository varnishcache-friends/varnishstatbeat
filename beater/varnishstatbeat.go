package beater

import (
	"fmt"
	"strings"
	"time"

	"github.com/elastic/beats/libbeat/beat"
	"github.com/elastic/beats/libbeat/common"
	"github.com/elastic/beats/libbeat/logp"
	"github.com/elastic/beats/libbeat/publisher"

	"github.com/phenomenes/vago"
	"github.com/phenomenes/varnishstatbeat/config"
)

type Varnishstatbeat struct {
	done    chan struct{}
	config  config.Config
	client  publisher.Client
	varnish *vago.Varnish
}

// New creates a new Beater
func New(b *beat.Beat, cfg *common.Config) (beat.Beater, error) {
	config := config.DefaultConfig
	if err := cfg.Unpack(&config); err != nil {
		return nil, fmt.Errorf("Error reading config file: %v", err)
	}

	vb := &Varnishstatbeat{
		done:   make(chan struct{}),
		config: config,
	}

	return vb, nil
}

func (vb *Varnishstatbeat) Run(b *beat.Beat) error {
	logp.Info("varnishstatbeat is running! Hit CTRL-C to stop it.")

	var err error

	vb.varnish, err = vago.Open(vb.config.Path)
	if err != nil {
		return err
	}

	vb.client = b.Publisher.Connect()
	ticker := time.NewTicker(vb.config.Period)
	counter := 1
	for {
		select {
		case <-vb.done:
			return nil
		case <-ticker.C:
		}

		event := common.MapStr{
			"@timestamp": common.Time(time.Now()),
			"type":       "stats",
			"count":      counter,
		}

		for k, v := range vb.varnish.Stats() {
			key := strings.Replace(k, ".", "_", -1)
			event[key] = v
		}

		vb.client.PublishEvent(event)
		logp.Info("Event sent")
		counter++
	}

	return nil
}

func (vb *Varnishstatbeat) Stop() {
	vb.varnish.Stop()
	vb.varnish.Close()
	vb.client.Close()
	close(vb.done)
}
