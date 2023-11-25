package main

import (
	"errors"
	"os"
)

func compareReqNameAndToken(reqName, tokenName string) error {
	if reqName != tokenName {
		return errors.New("Invalid username")
	}
	return nil
}

func ifDirectoryExists(directory string) error {
	err := os.MkdirAll(directory, os.ModePerm)
	if err != nil {
		return err
	}
	return nil
}