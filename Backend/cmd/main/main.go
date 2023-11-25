package main

import (
	"fmt"
	"log"
	_ "net/http"
)


func main() {
	store, err := NewPostgresStore()
	if err != nil {
		log.Fatal(err)
	}

	if err := store.Init(); err != nil {
		log.Fatal(err)
	}
	server := NewAPIServer(":8000", store)
	server.Run()
	fmt.Println(server)
}