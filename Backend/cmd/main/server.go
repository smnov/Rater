package main

import (
	"fmt"
	"net/http"
	"github.com/gorilla/mux"
)

type APIServer struct {
	ListenAddr string
	store Storage
}

type APIFunc func(http.ResponseWriter, *http.Request) error

type APIError struct {
	Error string `json:"error"`
}

func NewAPIServer(ListenAddr string, store Storage) *APIServer {
	return &APIServer{
		ListenAddr: ListenAddr,
		store: store,
	}
}

func makeHTTPHandleFunc(f APIFunc) http.HandlerFunc {
	return func(w http.ResponseWriter, r *http.Request) {
		if err := f(w, r); err != nil {
			JSONSerializer(w, http.StatusBadRequest, APIError{Error: err.Error()})
		}
	}
}


func (s *APIServer) Run() {
	router := mux.NewRouter()
	router.HandleFunc("/upload", withJWTAuth(makeHTTPHandleFunc(s.UploadFileHandler), s.store))
	router.HandleFunc("/files", makeHTTPHandleFunc(s.GetFilesHandler))
	router.HandleFunc("/files/random", withJWTAuth(makeHTTPHandleFunc(s.GetRandomFileHandler), s.store))
	router.HandleFunc("/files/{file_id}/rate", withJWTAuth(makeHTTPHandleFunc(s.RateFileHandler), s.store))
	router.HandleFunc("/account", makeHTTPHandleFunc(s.CreateAccountHandler))
	router.HandleFunc("/account/profile", withJWTAuth(makeHTTPHandleFunc(s.GetAccountByNameHandler), s.store))
	router.HandleFunc("/account/profile/files", withJWTAuth(makeHTTPHandleFunc(s.GetFilesOfAccountHandler), s.store))
	router.HandleFunc("/account/profile/files/{id}", withJWTAuth(makeHTTPHandleFunc(s.GetFileHandler), s.store))
	router.HandleFunc("/account/profile/files/image/{filename}", withJWTAuth(makeHTTPHandleFunc(s.GetImageByURL), s.store))
	router.HandleFunc("/login", makeHTTPHandleFunc(s.LoginHandler))
	fmt.Printf("Server succesfully started at port %s\n", s.ListenAddr)
	http.ListenAndServe(s.ListenAddr, router)
}