package server

import (
	"fmt"
	"net/http"
	"github.com/gorilla/mux"
	"github.com/smnov/Rater/Backend/cmd/storage"
	"github.com/smnov/Rater/Backend/cmd/auth"
	"github.com/smnov/Rater/Backend/types"
	"github.com/smnov/Rater/Backend/utils"
)



func NewAPIServer(ListenAddr string, store storage.Storage) *APIServer {
	return &APIServer{
		ListenAddr: ListenAddr,
		store: store,
	}
}

func makeHTTPHandleFunc(f APIFunc) http.HandlerFunc {
	return func(w http.ResponseWriter, r *http.Request) {
		if err := f(w, r); err != nil {
			utils.JSONSerializer(w, http.StatusBadRequest, types.APIError{Error: err.Error()})
		}
	}
}


func (s *APIServer) Run() {
	router := mux.NewRouter()
	router.HandleFunc("/upload", auth.WithJWTAuth(makeHTTPHandleFunc(s.UploadFileHandler), s.store))
	router.HandleFunc("/files", makeHTTPHandleFunc(s.GetFilesHandler))
	router.HandleFunc("/files/random", auth.WithJWTAuth(makeHTTPHandleFunc(s.GetRandomFileHandler), s.store))
	router.HandleFunc("/files/{file_id}/rate", auth.WithJWTAuth(makeHTTPHandleFunc(s.RateFileHandler), s.store))
	router.HandleFunc("/files/rated", auth.WithJWTAuth(makeHTTPHandleFunc(s.RatedFilesHandler), s.store))
	router.HandleFunc("/account", makeHTTPHandleFunc(s.CreateAccountHandler))
	router.HandleFunc("/account/profile", auth.WithJWTAuth(makeHTTPHandleFunc(s.GetAccountByNameHandler), s.store))
	router.HandleFunc("/account/profile/files", auth.WithJWTAuth(makeHTTPHandleFunc(s.GetFilesOfAccountHandler), s.store))
	router.HandleFunc("/account/profile/files/{id}", auth.WithJWTAuth(makeHTTPHandleFunc(s.GetFileHandler), s.store))
	router.HandleFunc("/account/profile/files/{id}/stat", auth.WithJWTAuth(makeHTTPHandleFunc(s.GetStatOfFileHandler), s.store))
	router.HandleFunc("/account/profile/files/image/{filename}", auth.WithJWTAuth(makeHTTPHandleFunc(s.GetImageByURL), s.store))
	router.HandleFunc("/login", makeHTTPHandleFunc(s.LoginHandler))
	fmt.Printf("Server succesfully started at port %s\n", s.ListenAddr)
	http.ListenAndServe(s.ListenAddr, router)
}