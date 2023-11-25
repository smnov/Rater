package main

import (
	"database/sql"
	"fmt"

	_ "github.com/lib/pq"
)

type PostgresStore struct {
	db *sql.DB
}

type Storage interface {
	CreateAccount(*Account) error
	GetAccountByName(name string) (*Account, error)
	GetAccountByID(id int64) (*Account, error)
	GetFiles() ([]*File, error)
	// GetFileOfAccount(int64) (*File, error)
	GetFilesOfAccount(id int64) ([]*File, error)
	AddFileToDB(int64, *File) error
}

func (s *PostgresStore) Init() error {
	err := s.CreateAccountTable()
	if err != nil {
		return err
	}
	err = s.CreateFileTable()
	if err != nil {
		return err
	}
	return s.CreateAccountFileTable()
}

func (s *PostgresStore) CreateFileTable() error {
	query := `CREATE TABLE IF NOT EXISTS file (
		id serial primary key,
		name varchar(100),
		url varchar(150) unique,
		size serial,
		tags varchar[],
		created_at timestamp,
		account_id integer NOT NULL REFERENCES account(id)
	)`
	_, err := s.db.Exec(query)
	return err
}

func (s *PostgresStore) CreateAccountFileTable() error {
	query := `CREATE TABLE IF NOT EXISTS account_file (
		account_id integer NOT NULL REFERENCES account(id),
		file_id integer NOT NULL REFERENCES file(id),
		attractiveness_rating numeric,
		smart_rating numeric,
		trustworthy_rating numeric,
		PRIMARY KEY (account_id, file_id)
);`
	_, err := s.db.Query(query)
	return err
}

func (s *PostgresStore) CreateAccountTable() error {
	query := `CREATE TABLE IF NOT EXISTS account (
		id serial primary key,
		name varchar(100),
		email varchar(100),
		encrypted_password varchar(150),
		created_at timestamp
	)`

	_, err := s.db.Query(query)
	return err
}

func NewPostgresStore() (*PostgresStore, error) {
	connectString := "user=postgres dbname=rater_db password=rater_password sslmode=disable"
	db, err := sql.Open("postgres", connectString)
	if err != nil {
		return nil, err
	}
	if err := db.Ping(); err != nil {
		return nil, err
	}
	return &PostgresStore{
		db: db,
	}, nil
}

func (s *PostgresStore) CreateAccount(acc *Account) error {
	query := (`
	insert into account (name, email, encrypted_password, created_at)
	values 
	($1, $2, $3, $4)
	`)
	_, err := s.db.Query(query, 
		acc.Name, 
		acc.Email, 
		acc.EncryptedPassword,
		acc.CreatedAt)
	if err != nil {
		return err
	}
	return nil
}

func (s *PostgresStore) GetAccountByName(name string) (*Account, error) {
	rows, err := s.db.Query("select * from account where name = $1", name)
	if err != nil {
		return nil, err
	}
	for rows.Next() {
		return ScanIntoAccount(rows)
	}
	return nil, fmt.Errorf("account %s not found", name)
}

func (s *PostgresStore) GetAccountByID(id int64) (*Account, error) {
	rows, err := s.db.Query("select * from account where id = $1", id)
	if err != nil {
		return nil, err
	}
	for rows.Next() {
		return ScanIntoAccount(rows)
	}
	return nil, fmt.Errorf("account %d not found", id)
}

func (s *PostgresStore) AddFileToDB(accountID int64, f *File) error {
	query := (`INSERT INTO file (name, url, size, tags, created_at, account_id) values ($1, $2, $3, $4, $5, $6)`)
	_, err := s.db.Query(query, 
		f.Name, 
		f.Url,
		f.Size,
		f.Tags,
		f.CreatedAt,
		accountID,
)	
	if err != nil {
		return fmt.Errorf("%s",err)
	}
	return nil
}


func (s *PostgresStore) GetFiles() ([]*File, error) {
	query := (`SELECT * from file`)
	rows, err := s.db.Query(query)
	if err != nil {
		return nil,err
	}

	files := []*File{}
	for rows.Next() {
		file, err := ScanIntoFile(rows)
		if err != nil {
			return nil, err
		}
		files = append(files, file)
	}
	return files, nil
}

func (s *PostgresStore) GetFilesOfAccount(id int64) ([]*File, error) {
	rows, err := s.db.Query(`SELECT * FROM file WHERE account_id = $1`, id)
	if err != nil {
		return nil, err
	}
	files := []*File{}
	for rows.Next() {
		file, err := ScanIntoFile(rows)
		if err != nil {
			return nil, err
		}
		files = append(files, file)
	}
	return files, nil
}

func (s *PostgresStore) GetFileOfById(id int64) (*File, error) {
	rows, err := s.db.Query(`SELECT * FROM file WHERE id = $1`, id)
	if err != nil {
		return nil, err
	}
	for rows.Next() {
		return ScanIntoFile(rows)
	}
	return nil, err
}

func (s *PostgresStore) DeleteFile(id int64) error {
	_, err := s.db.Query(`DELETE * FROM file WHERE id = $1`, id)
	if err != nil {
		return err
	}
	return nil
}

func (s *PostgresStore) RateFile(account_id, file_id int64, rate_type string, ratenumber float64) error {
	query := (`UPDATE account_file
	SET $1 = $4
	WHERE account_id = $2 AND file_id = $3;`)
	_, err := s.db.Query(query, 
	rate_type,
	account_id,
	file_id,
	ratenumber,
	)
	if err != nil {
		return fmt.Errorf("%s",err)
	}
	return nil
}

func ScanIntoAccount(rows *sql.Rows) (*Account, error) {
	account := new(Account)
	err := rows.Scan(
		&account.ID,
		&account.Name,
		&account.Email,
		&account.EncryptedPassword,
		&account.CreatedAt,
	)
	return account, err
}

func ScanIntoFile(rows *sql.Rows) (*File, error) {
	file := new(File)
	err := rows.Scan(
		&file.ID,
		&file.Name,
		&file.Url,
		&file.Size,
		&file.Tags,
		&file.CreatedAt,
		&file.AccountID,
	)
	return file, err
}