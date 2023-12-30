# Rater
## _Rater is an iOS app that allows users to rate photos of each other anonymously._
 <img src="https://github.com/smnov/Rater/assets/101511388/8899f3be-ef0b-441a-9f29-222802f0eb54" width=400>
 <img src="https://github.com/smnov/Rater/assets/101511388/b02c8591-ed91-47a3-8d1d-d7a7e4d988b0" width=400>
 <img src="https://github.com/smnov/Rater/assets/101511388/cc3706a0-76a7-48d5-bedc-116dec8b1275" width=400>

## Features

- Backend created with Golang and PostgreSQL
- Authorization with JWT

  

## Installation

First of all you need to run backend server. For that purpose we user golang and postgres.
To run server with docker use these commands.

```
docker-compose up
```

Then go to cmd/main directory 
```
cd cmd/main
```

And compile and run the server

```
go run main.go
```

Server is ready for work. Now you can run xcode and start the app.
## License

[MIT](https://choosealicense.com/licenses/mit/)
