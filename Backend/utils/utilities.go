package utils

import (
	"errors"
	"os"
	// "github.com/smnov/Rater/Backend/cmd/storage"
	"net/http"
	"encoding/json"
)

func compareReqNameAndToken(reqName, tokenName string) error {
	if reqName != tokenName {
		return errors.New("Invalid username")
	}
	return nil
}

func IfDirectoryExists(directory string) error {
	err := os.MkdirAll(directory, os.ModePerm)
	if err != nil {
		return err
	}
	return nil
}

func JSONSerializer(w http.ResponseWriter, status int, v ...any) error {
	w.Header().Add("Content-Type", "application/json")
	w.WriteHeader(status)
	return json.NewEncoder(w).Encode(v)
}

