package main

import (
	"fmt"
	"time"
	"github.com/lib/pq"
	"golang.org/x/crypto/bcrypt"
)

type File struct {
	ID				int				`json:"id"`
	Name 			string 			`json:"name`
	Url 			string			`json:"url"`
	Size 			int64 			`json:"size"`
	Tags			pq.StringArray	`json:"tags"`
	CreatedAt 		time.Time 		`json:"created_at"`
	AccountID		int64			`json:"account_id"`
}

func createFileUrl(fileName string) string {
	return fileFolder + fileName
}


func NewFile(name string, size, accountID int64) *File {
	return &File{
		Name: name,
		Url: createFileUrl(name),
		Size: size,
		// Tags: pq.StringArray,
		CreatedAt: time.Now().UTC(),
		AccountID: accountID,
	}
}

type Account struct {
	ID 	 				int64 		`json:"id"`
	Name 				string 		`json:"name"`
	Email				string		`json:"email"`
	EncryptedPassword 	string 		`json:"-"`
	Files 				[]*File 	`json:"files"`
	CreatedAt 			time.Time 	`json:"created_at"`
}

func ComparePasswords(password1, password2 string) error {
	if password1 != password2 {
		return fmt.Errorf("Passwords don't match!")
	}
	return nil
}

func (a *Account) ValidPassword(pw string) bool {
	return bcrypt.CompareHashAndPassword([]byte(a.EncryptedPassword), []byte(pw)) == nil
}

func NewAccount(name, email, password1, password2 string) (*Account, error) {
	if err := ComparePasswords(password1, password2); err != nil {
		return nil, err
	}
	encpw, err := bcrypt.GenerateFromPassword([]byte(password1), bcrypt.DefaultCost)
	if err != nil {
		return nil, err
	}
	return &Account{
		Name: name,
		Email: email,
		EncryptedPassword: string(encpw),
		CreatedAt: time.Now().UTC(),
	}, nil
}

type CreateAccountRequest struct {
	Name 		string `json:"name"`
	Email 		string `json:"email"`
	Password1 	string `json:"password1"`
	Password2 	string `json:"password2"`
}

type LoginAccountRequest struct {
	Name string `json:"name"`
	Password string `json:"password"`
}

type LoginResponse struct {
	Name string `json:"name"`
	Token string `json:"token"`
}