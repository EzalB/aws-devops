package logging

import (
	"log"
)

type Logger struct{}

func New(level string) *Logger { // level kept for future filtering
	log.SetFlags(log.LstdFlags | log.Lmicroseconds)
	return &Logger{}
}

func (l *Logger) Infow(msg string, kv ...interface{})  { log.Println("INFO:", msg, kv) }
func (l *Logger) Errorw(msg string, kv ...interface{}) { log.Println("ERROR:", msg, kv) }
func (l *Logger) Fatalw(msg string, kv ...interface{}) { log.Fatalln("FATAL:", msg, kv) }