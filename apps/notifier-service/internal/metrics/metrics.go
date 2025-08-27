package metrics

import (
	"net/http"

	"github.com/prometheus/client_golang/prometheus"
	"github.com/prometheus/client_golang/prometheus/promhttp"
)

var (
	NotificationsTotal = prometheus.NewCounterVec(
		prometheus.CounterOpts{
			Name: "notifications_total",
			Help: "Total notifications processed",
		},
		[]string{"channel", "result"},
	)
)

func MustSetupRegistry() *prometheus.Registry {
	reg := prometheus.NewRegistry()
	reg.MustRegister(NotificationsTotal)
	// you can add process and go collectors if desired
	reg.MustRegister(prometheus.NewProcessCollector(prometheus.ProcessCollectorOpts{}))
	reg.MustRegister(prometheus.NewGoCollector())
	return reg
}

func HandlerFor(reg *prometheus.Registry) http.Handler {
	return promhttp.HandlerFor(reg, promhttp.HandlerOpts{EnableOpenMetrics: true})
}