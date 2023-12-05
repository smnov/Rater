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
	fileName := fmt.Sprintf("%d%s", time.Now().UnixNano(), filepath.Ext(handler.Filename))
	fileUrl := fmt.Sprintf("%s%s/%s", fileFolder, accountName, fileName)
	dst, err := os.Create(fileUrl)
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
	fileToDB := NewFile(handler.Filename, fileName, handler.Size, accountID)
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
		Token: token,
	}

	return JSONSerializer(w, http.StatusOK, resp)
}

func (s *APIServer) GetAccountByNameHandler(w http.ResponseWriter, r *http.Request) error {
	usernameFromToken := getUsernameFromToken(r)
	
	account, err := s.store.GetAccountByName(usernameFromToken)
	if err != nil {
		return err
	}
	return JSONSerializer(w, http.StatusOK, account)
}

func (s * APIServer) GetFileHandler(w http.ResponseWriter, r *http.Request) error {
	if r.Method == "GET" {
	file_id, err := strconv.ParseInt(mux.Vars(r)["id"], 10, 64)
	if err != nil {
		return err
	}
	file, err := s.store.GetFileById(file_id)
	return JSONSerializer(w, http.StatusOK, file)

	} else if r.Method == "DELETE" {
		file_id, err := strconv.ParseInt(mux.Vars(r)["id"], 10, 64)
		if err != nil {
			return err
	}
		err = s.store.DeleteFileById(file_id)
		if err != nil {
			return err
		}
		print("Deleted")
		return JSONSerializer(w, http.StatusOK)
	}
	return nil
}

func (s *APIServer) GetRandomFileHandler(w http.ResponseWriter, r *http.Request) error {
	accountId := getUserIDFromToken(r)
	randomFile, err := s.store.GetRandomFile(accountId) 
	if err != nil {
		return err
	}
	return JSONSerializer(w, http.StatusOK, randomFile)
}

func (s *APIServer) RateFileHandler(w http.ResponseWriter, r *http.Request) error {
	if r.Method != "POST" {
		http.Error(w, "Method is not allowed", http.StatusMethodNotAllowed)
	}
	accountId := getUserIDFromToken(r)
	fileId, err := strconv.ParseInt(mux.Vars(r)["file_id"], 10, 64)
	if err != nil {
		return err
	}
	req := new(RateRequest)
		if err := json.NewDecoder(r.Body).Decode(req); err != nil {
			return err
		}
	req.AccountId = accountId
	req.FileId = fileId
	err = s.store.RateFile(req)
	if err != nil {
		return err
	}
	return JSONSerializer(w, http.StatusOK)
}

func (s *APIServer) GetImageByURL(w http.ResponseWriter, r *http.Request) error {
	fileName := mux.Vars(r)["filename"]
	fmt.Println(fileName)
	accountName := getUsernameFromToken(r)
	filePath := fileFolder + accountName + "/" + fileName
	fmt.Println(filePath)

	imageFile, err := http.Dir(".").Open(filePath)
	if err != nil {
		fmt.Println(err)
		return err
	}

	fileInfo, err := imageFile.Stat()
	fmt.Println(fileInfo)
	if err != nil {
		fmt.Println(err)
		return err
	}
	defer imageFile.Close()

	w.Header().Set("Content-Type", "image/jpeg")
	http.ServeContent(w, r, filePath, fileInfo.ModTime(), imageFile)
	return nil

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