package main

import (
	"fmt"
	"net/http"

	"github.com/golang-jwt/jwt"
)

func permissionDenied(w http.ResponseWriter) {
	JSONSerializer(w, http.StatusForbidden, APIError{Error: "permission denied"})
	return
}

func createJWT(account *Account) (string, error) {
	claims := &jwt.MapClaims{
		"account_id": account.ID,
		"account_name": account.Name,
		"expires_at": 15000,
	}
	token := jwt.NewWithClaims(jwt.SigningMethodHS256, claims)
	return token.SignedString([]byte(secret_key))
}


func validateJWT(tokenString string) (*jwt.Token, error) {
	return jwt.Parse(tokenString, func(token *jwt.Token) (interface{}, error) {
		if _, ok := token.Method.(*jwt.SigningMethodHMAC); !ok {
			return nil, fmt.Errorf("Unexpected signing method")
		}
		return []byte(secret_key), nil
	})
}
func getUsernameFromToken(r *http.Request) string {
	tokenString := r.Header.Get("jwt-token")
	token, err := validateJWT(tokenString)
	if err != nil {
		return "err"
	}
	claims := token.Claims.(jwt.MapClaims)
	accountName:= claims["account_name"].(string)
	return accountName

	}

func getUserIDFromToken(r *http.Request) int64 {
	tokenString := r.Header.Get("jwt-token")
	token, err := validateJWT(tokenString)
	if err != nil {
		return 0
	}
	claims := token.Claims.(jwt.MapClaims)
	fmt.Println(claims)
	accountID:= int64(claims["account_id"].(float64))
	return accountID

	}

func withJWTAuth(handlerFunc http.HandlerFunc, s Storage) http.HandlerFunc {
	return func(w http.ResponseWriter, r *http.Request) {
		tokenString := r.Header.Get("jwt-token")
		token, err := validateJWT(tokenString)
		if err != nil {
			permissionDenied(w)
			return
		}
		
		if !token.Valid {
			permissionDenied(w)
			return
		}

		claims := token.Claims.(jwt.MapClaims)

		accountName := claims["account_name"].(string)

		_, err = s.GetAccountByName(accountName)
		if err != nil {
			permissionDenied(w)
			return
		}
		handlerFunc(w, r)
	}
}