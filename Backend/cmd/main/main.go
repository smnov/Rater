package main

import (
	"fmt"
	"log"
	_ "net/http"
	"github.com/smnov/Rater/Backend/cmd/server"
	"github.com/smnov/Rater/Backend/cmd/storage"
)


func main() {
	store, err := storage.NewPostgresStore()
	if err != nil {
		log.Fatal(err)
	}

	if err := store.Init(); err != nil {
		log.Fatal(err)
	}
	server := server.NewAPIServer(":8000", store)
	server.Run()
	fmt.Println(server)
}