### migrate

1. [install go](INSTALL.md)

### install migrate
```bash
go install -tags 'mysql' github.com/golang-migrate/migrate/v4/cmd/migrate@latest
```

### create migrate
```bash
migrate create -ext sql -dir ./db/migrations -seq add_order_table
```

### migrate up
```bash
migrate -path ./db/migrations -database "mysql://root:root@tcp(127.0.0.1:3306)/go_rest_api" up
```

### migrate down
```bash
migrate -path ./db/migrations -database "mysql://root:root@tcp(127.0.0.1:3306)/go_rest_api" down
```

### migrate force
```bash
migrate -path ./db/migrations -database "mysql://root:root@tcp(127.0.0.1:3306)/go_rest_api" force 1
```