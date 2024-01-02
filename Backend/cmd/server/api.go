package server

import (
	"encoding/json"
	"fmt"
	"io"
	"net/http"
	"os"
	"path"
	"path/filepath"
	"strconv"
	"strings"
	"time"
	"github.com/gorilla/mux"
	"github.com/smnov/Rater/Backend/cmd/storage"
	"github.com/smnov/Rater/Backend/consts"
	"github.com/smnov/Rater/Backend/cmd/auth"
	"github.com/smnov/Rater/Backend/utils"
	"github.com/smnov/Rater/Backend/types"

)


type APIServer struct {
	ListenAddr string
	store storage.Storage
}

type APIFunc func(http.ResponseWriter, *http.Request) error


func (s *APIServer) UploadFileHandler(w http.ResponseWriter, r *http.Request) error {
	if r.Method != "POST" {
		http.Error(w, "Method is not allowed", http.StatusMethodNotAllowed)
	}
	file, handler, err := r.FormFile("file")
	if err != nil {
		http.Error(w, err.Error(), http.StatusInternalServerError)
		return err
	}
	accountName := auth.GetUsernameFromToken(r)
	err = utils.IfDirectoryExists(fmt.Sprintf("%s/%s", consts.FileFolder, accountName))
		if err != nil {
		return err
	}
	fileName := fmt.Sprintf("%d%s", time.Now().UnixNano(), filepath.Ext(handler.Filename))
	fileUrl := fmt.Sprintf("%s/%s/%s", consts.FileFolder, accountName, fileName)
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

	accountID := auth.GetUserIDFromToken(r)
	fileToDB := types.NewFile(handler.Filename, fileName, handler.Size, accountID)
	if err = s.store.AddFileToDB(accountID, fileToDB); err != nil {
		return err
	}
	fmt.Printf("File %s succesfully uploaded\n", file)
	return utils.JSONSerializer(w, http.StatusOK, file)
}

func (s *APIServer) GetFilesHandler(w http.ResponseWriter, r *http.Request) error {
	files, err := s.store.GetFiles()
	if err != nil {
		return err
	}
	return utils.JSONSerializer(w, http.StatusOK, files)
}

func (s *APIServer) GetFilesOfAccountHandler(w http.ResponseWriter, r *http.Request) error {
	tokenID := auth.GetUserIDFromToken(r)
	files, err := s.store.GetFilesOfAccount(tokenID)
	if err != nil {
		return err
	}
	return utils.JSONSerializer(w, http.StatusOK, files)
}

func (s *APIServer) CreateAccountHandler(w http.ResponseWriter, r *http.Request) error {
	if r.Method != "POST" {
		return utils.JSONSerializer(w, http.StatusMethodNotAllowed, "Method is not allowed")
	}
		req := new(types.CreateAccountRequest)
		if err := json.NewDecoder(r.Body).Decode(req); err != nil {
			return err
		}

		if req == nil {
			return utils.JSONSerializer(w, http.StatusBadRequest, "Request body cannot be empty")
		}

		if req.Name == "" || req.Email == "" || req.Password1 == "" {
			return utils.JSONSerializer(w, http.StatusBadRequest, "Name, Email, and Password are required fields")
		}	

		err := types.IfUsernameOrPasswordTooShort(req.Name, req.Password1)		
		if err != nil {
			return err
		}

		account, err := types.NewAccount(req.Name, req.Email, req.Password1, req.Password2)
		if err != nil {
			return err
		}
		if err := s.store.CreateAccount(account); err != nil {
			return err
		}

		return utils.JSONSerializer(w, http.StatusOK, account)
}

func (s *APIServer) LoginHandler(w http.ResponseWriter, r *http.Request) error {
	var req types.LoginAccountRequest
	if err := json.NewDecoder(r.Body).Decode(&req); err != nil {
		return err
	}

	acc, err := s.store.GetAccountByName(req.Name)
	if err != nil {
		return err
	}
	
	token, err := auth.CreateJWT(acc)
	if err != nil {
		return err
	}

	resp := types.LoginResponse{
		Token: token,
	}

	return utils.JSONSerializer(w, http.StatusOK, resp)
}

func (s *APIServer) GetAccountByNameHandler(w http.ResponseWriter, r *http.Request) error {
	usernameFromToken := auth.GetUsernameFromToken(r)
	
	account, err := s.store.GetAccountByName(usernameFromToken)
	if err != nil {
		return err
	}
	return utils.JSONSerializer(w, http.StatusOK, account)
}

func (s * APIServer) GetFileHandler(w http.ResponseWriter, r *http.Request) error {
	if r.Method == "GET" {
		file_id, err := strconv.ParseInt(mux.Vars(r)["id"], 10, 64)
		if err != nil {
			return err
		}
		file, err := s.store.GetFileById(file_id)
		return utils.JSONSerializer(w, http.StatusOK, file)

	} else if r.Method == "DELETE" {
		fileId, err := strconv.ParseInt(mux.Vars(r)["id"], 10, 64)
		accountName := auth.GetUsernameFromToken(r)
		file, err := s.store.GetFileById(fileId)
		if err != nil {
			return err
		}
		filePath := path.Join(consts.FileFolder, accountName, file.Name)
		os.Remove(filePath)

		err = s.store.DeleteFileById(fileId)
		if err != nil {
			return err
		}
		fmt.Println("File was successfully deleted", file)
		return utils.JSONSerializer(w, http.StatusOK)
	}
	return nil
}

func (s *APIServer) GetStatOfFileHandler(w http.ResponseWriter, r *http.Request) error {
	fileId, err := strconv.ParseInt(mux.Vars(r)["id"], 10, 64)
	if err != nil {
		return err
	}

	fileStat, err := s.store.GetStatOfFile(fileId)
	if err != nil {
		return err
	}
	return utils.JSONSerializer(w, http.StatusOK, fileStat)
}

func (s *APIServer) GetRandomFileHandler(w http.ResponseWriter, r *http.Request) error {
	accountId := auth.GetUserIDFromToken(r)
	randomFile, err := s.store.GetRandomFile(accountId) 
	if err != nil {
		return err
	}
	return utils.JSONSerializer(w, http.StatusOK, randomFile)
}

func (s *APIServer) RateFileHandler(w http.ResponseWriter, r *http.Request) error {
	if r.Method != "POST" {
		http.Error(w, "Method is not allowed", http.StatusMethodNotAllowed)
	}
	accountId := auth.GetUserIDFromToken(r)
	fileId, err := strconv.ParseInt(mux.Vars(r)["file_id"], 10, 64)
	if err != nil {
		return err
	}
	req := new(types.FileStat)
		if err := json.NewDecoder(r.Body).Decode(req); err != nil {
			return err
		}
	req.AccountId = accountId
	req.FileId = fileId
	fmt.Println(req)
	err = s.store.RateFile(req)
	if err != nil {
		return err
	}
	return utils.JSONSerializer(w, http.StatusOK)
}

func (s *APIServer) RatedFilesHandler(w http.ResponseWriter, r *http.Request) error {
	// accountId := getUserIDFromToken(r)

	files, err := s.store.GetRatedFiles()
	if err != nil {
		return err
	}
	return utils.JSONSerializer(w, http.StatusOK, files)
}

func (s *APIServer) GetImageByURL(w http.ResponseWriter, r *http.Request) error {
	fileName := mux.Vars(r)["filename"]
	accountName := auth.GetUsernameFromToken(r)
	filePath := path.Join(consts.FileFolder, accountName, fileName)
	filePath = strings.TrimRight(filePath, "\n") // For some reason filePath adds "\n" in the end. Here we remove it.
	if _, err := os.Stat(filePath); os.IsNotExist(err) {
		fmt.Println(filePath)
		fmt.Println(fileName)
		fmt.Println("uploads no exist")
	}
	if _, err := os.Stat(filePath); os.IsNotExist(err) {		
		fmt.Println("File does not exist:", filePath)
		return err
	}

	imageFile, err := http.Dir("").Open(filePath)
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