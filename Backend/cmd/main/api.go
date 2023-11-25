package main

import (
	"encoding/json"
	"fmt"
	"io"
	"net/http"
	"os"
	"path/filepath"
	"strconv"
	"time"

	"github.com/gorilla/mux"
)

func JSONSerializer(w http.ResponseWriter, status int, v ...any) error {
	w.Header().Add("Content-Type", "application/json")
	w.WriteHeader(status)
	return json.NewEncoder(w).Encode(v)
}


func (s *APIServer) UploadFileHandler(w http.ResponseWriter, r *http.Request) error {
	if r.Method != "POST" {
		http.Error(w, "Method is not allowed", http.StatusMethodNotAllowed)
	}
	file, handler, err := r.FormFile("file")
	if err != nil {
		http.Error(w, err.Error(), http.StatusInternalServerError)
		return err
	}
	accountName := getUsernameFromToken(r)
	err = ifDirectoryExists(fmt.Sprintf("%s/%s", fileFolder, accountName))
		if err != nil {
		return err
	}

	dst, err := os.Create(fmt.Sprintf("%s%s/%d%s", fileFolder, accountName, time.Now().UnixNano(), filepath.Ext(handler.Filename)))
	if err != nil {
		http.Error(w, err.Error(), http.StatusInternalServerError)
		return err
	}

	defer file.Close()

	// Copy the uploaded file to the created file on the filesystem
	if _, err := io.Copy(dst, file); err != nil {
		http.Error(w, err.Error(), http.StatusInternalServerError)
		return err
	}

	accountID := getUserIDFromToken(r)
	fileToDB := NewFile(handler.Filename, handler.Size, accountID)
	if err = s.store.AddFileToDB(accountID, fileToDB); err != nil {
		return err
	}
	fmt.Printf("File %s succesfully uploaded\n", file)
	return JSONSerializer(w, http.StatusOK, file)
}

func (s *APIServer) GetFilesHandler(w http.ResponseWriter, r *http.Request) error {
	files, err := s.store.GetFiles()
	if err != nil {
		return err
	}
	return JSONSerializer(w, http.StatusOK, files)
}

func (s *APIServer) GetFilesOfAccountHandler(w http.ResponseWriter, r *http.Request) error {
	tokenID := getUserIDFromToken(r)
	files, err := s.store.GetFilesOfAccount(tokenID)
	if err != nil {
		return err
	}
	return JSONSerializer(w, http.StatusOK, files)
}

func (s *APIServer) CreateAccountHandler(w http.ResponseWriter, r *http.Request) error {
	if r.Method != "POST" {
		http.Error(w, "Method is not allowed", http.StatusMethodNotAllowed)
	}
		req := new(CreateAccountRequest)
		if err := json.NewDecoder(r.Body).Decode(req); err != nil {
			return err
		}
		account, err := NewAccount(req.Name, req.Email, req.Password1, req.Password2)
		if err != nil {
			return err
		}
		if err := s.store.CreateAccount(account); err != nil {
			return err
		}

		return JSONSerializer(w, http.StatusOK, account)
}

func (s *APIServer) LoginHandler(w http.ResponseWriter, r *http.Request) error {
	var req LoginAccountRequest
	if err := json.NewDecoder(r.Body).Decode(&req); err != nil {
		return err
	}

	acc, err := s.store.GetAccountByName(req.Name)
	if err != nil {
		return err
	}

	if !acc.ValidPassword(req.Password) {
		return fmt.Errorf("Invalid password")
	}
	
	token, err := createJWT(acc)
	if err != nil {
		return err
	}

	resp := LoginResponse{
		Name: acc.Name,
		Token: token,
	}

	return JSONSerializer(w, http.StatusOK, resp)
}

func (s *APIServer) GetAccountByNameHandler(w http.ResponseWriter, r *http.Request) error {
	name := GetNameFromRequest(r)
	usernameFromToken := getUsernameFromToken(r)

	err := compareReqNameAndToken(name, usernameFromToken)
	if err != nil {
		return err
	}
	
	account, err := s.store.GetAccountByName(name)
	if err != nil {
		return err
	}
	files, err := s.store.GetFilesOfAccount(account.ID)
	if err != nil {
		return err
	}
	if err != nil {
		return err
	}
	return JSONSerializer(w, http.StatusOK, account, files)
}

func ChangeRatingHandler(w http.ResponseWriter, r *http.Request) error {
	return fmt.Errorf("error")
}


func GetNameFromRequest(r *http.Request) string {
	StringID := mux.Vars(r)["name"]
	return StringID
}

func GetIDFromRequest(r *http.Request) (int, error) {
	StringID := mux.Vars(r)["id"]
	id, err := strconv.Atoi(StringID)
	if err != nil {
		return id, fmt.Errorf("Invalid id")
	}
	return id, nil
}