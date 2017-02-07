package main

import (
	"os"

	"github.com/elastic/beats/libbeat/beat"

	"github.com/phenomenes/varnishstatbeat/beater"
)

func main() {
	err := beat.Run("varnishstatbeat", "", beater.New)
	if err != nil {
		os.Exit(1)
	}
}
