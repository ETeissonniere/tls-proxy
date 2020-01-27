package main

import (
	"crypto/tls"
	"flag"
	"log"
	"net/http"
	"net/http/httputil"
	"net/url"

	"golang.org/x/crypto/acme/autocert"
)

func main() {
	target, err := url.Parse(flag.Arg(0))
	if err != nil {
		log.Fatal(err)
	}
	proxy := httputil.NewSingleHostReverseProxy(target)

	certManager := autocert.Manager{
		Prompt:     autocert.AcceptTOS,
		Cache:      autocert.DirCache("/certs"),
		HostPolicy: autocert.HostWhitelist(flag.Arg(1)),
	}

	server := &http.Server{
		Addr:    ":8443",
		Handler: proxy,
		TLSConfig: &tls.Config{
			GetCertificate: certManager.GetCertificate,
		},
	}

	go http.ListenAndServe(":8080", certManager.HTTPHandler(nil))
	server.ListenAndServeTLS("", "")
}
