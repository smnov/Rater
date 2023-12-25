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
	GetFileById(file_id int64) (*File, error)
	DeleteFileById(file_id int64) error
	GetFilesOfAccount(id int64) ([]*File, error)
	GetRandomFile(account_id int64) (*File, error)
	GetStatOfFile(fileId int64) (*FileStat, error)
	RateFile(req *FileStat) error
	GetRatedFiles() ([]*FileStat, error)
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
		votes integer DEFAULT 0, 
		created_at timestamp,
		account_id integer NOT NULL REFERENCES account(id)
	)`
	_, err := s.db.Exec(query)
	return err
}

func (s *PostgresStore) CreateAccountFileTable() error {
	query := `CREATE TABLE IF NOT EXISTS account_file (
		account_id integer NOT NULL REFERENCES account(id) ON DELETE CASCADE,
		file_id integer NOT NULL REFERENCES file(id) ON DELETE CASCADE,
		attractiveness_rating numeric DEFAULT 0.0,
		smart_rating numeric DEFAULT 0.0,
		trustworthy_rating numeric DEFAULT 0.0,
		PRIMARY KEY (account_id, file_id)
);`
	_, err := s.db.Query(query)
	return err
}

func (s *PostgresStore) CreateAccountTable() error {
	query := `CREATE TABLE IF NOT EXISTS account (
		id serial primary key,
		name varchar(100) unique,
		email varchar(100) unique,
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
	defer rows.Close()
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
	defer rows.Close()
	for rows.Next() {
		return ScanIntoAccount(rows)
	}
	return nil, fmt.Errorf("account %d not found", id)
}

func (s *PostgresStore) GetStatOfFile(id int64) (*FileStat, error) {
	rows, err := s.db.Query(`
		SELECT * from account_file WHERE file_id = $1
	`, id)

	if err != nil {
		return nil, err
	}
	defer rows.Close()
	for rows.Next() {
		return ScanIntoAccountFile(rows)
	}

	return nil, fmt.Errorf("file stat not found")
}

func (s *PostgresStore) AddFileToDB(accountID int64, f *File) error {
	tx, err := s.db.Begin()
	if err != nil {
		return fmt.Errorf("%s",err)
	}
	queryFile := (`INSERT INTO file (name, url, size, tags, created_at, account_id) 
					VALUES ($1, $2, $3, $4, $5, $6)
					RETURNING id`)

	var fileId int64
	err = tx.QueryRow(queryFile,
		f.Name,
		f.Url,
		f.Size,
		f.Tags,
		f.CreatedAt,
		accountID).Scan(&fileId)	
	if err != nil {
		return err
	}
	
	if err := tx.Commit(); err != nil {
		return fmt.Errorf("failed to commit transaction: %s", err)
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
	defer rows.Close()
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
	defer rows.Close()
	for rows.Next() {
		file, err := ScanIntoFile(rows)
		if err != nil {
			return nil, err
		}
		files = append(files, file)
	}
	return files, nil
}

func (s *PostgresStore) GetFileById(id int64) (*File, error) {
	rows, err := s.db.Query(`SELECT * FROM file WHERE id = $1`, id)
	if err != nil {
		return nil, err
	}

	defer rows.Close()

	for rows.Next() {
		return ScanIntoFile(rows)
	}
	return nil, err
}

func (s *PostgresStore) DeleteFileById(id int64) error {
	_, err := s.db.Query(`DELETE FROM file WHERE id = $1`, id)
	if err != nil {
		return err
	}
	return nil
}

func (s *PostgresStore) GetRandomFile(account_id int64) (*File, error) {
	rows, err := s.db.Query(`SELECT * from file
				WHERE id NOT IN (
					SELECT file_id
					FROM account_file
					WHERE account_id = $1
				) ORDER BY RANDOM()
				LIMIT 1`, account_id)
	if err != nil {
		return nil, err
	}

	defer rows.Close() // this prevents error "sorry, too many clients already"

	for rows.Next() {
		return ScanIntoFile(rows)
	}
	return nil, err
}

func (s *PostgresStore) RateFile(req *FileStat) error {
	query := (`
	INSERT INTO account_file (attractiveness_rating, smart_rating, trustworthy_rating, account_id, file_id)
		VALUES ($1, $2, $3, $4, $5)
		ON CONFLICT (account_id, file_id)
		DO UPDATE SET
			attractiveness_rating = attractiveness_rating + $1,
			smart_rating = smart_rating + $2,
			trustworthy_rating = trustworthy_rating + $3;
	`)
	_, err := s.db.Exec(query, 
	req.AttractivenessRating,
	req.SmartRating,
	req.TrustworthyRating,
	req.AccountId,
	req.FileId,
	)
	if err != nil {
		return fmt.Errorf("%s",err)
	}
	return nil
}

func (s *PostgresStore) GetRatedFiles() ([]*FileStat, error) {
	// rows, err := s.db.Query(`
	// SELECT file.*
    // FROM file
    // JOIN account_file ON file.id = account_file.file_id
    // WHERE account_file.account_id = $1;`, id)
	rows, err := s.db.Query(`
		SELECT * from account_file 
	`)
	if err != nil {
		return nil, err
	}
	defer rows.Close()
	files := []*FileStat{}
	for rows.Next() {
		file, err := ScanIntoAccountFile(rows)
		if err != nil {
			return nil, err
		}
		files = append(files, file)
		fmt.Println(files)
	}
	return files, nil
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

func ScanIntoAccountFile(rows *sql.Rows) (*FileStat, error) {
	account_file := new(FileStat)
	err := rows.Scan(
		&account_file.AccountId,
		&account_file.FileId,
		&account_file.AttractivenessRating,
		&account_file.TrustworthyRating,
		&account_file.SmartRating,
	)
	return account_file, err
}