# Stage 1: Build
FROM golang:1.25-alpine AS builder

WORKDIR /app

COPY go.mod go.sum ./
RUN go mod download

COPY . .

RUN CGO_ENABLED=0 GOOS=linux go build -o app .

# Stage 2: Run
FROM alpine:latest

WORKDIR /app

RUN apk add --no-cache tzdata && touch .env

COPY --from=builder /app/app .
COPY --from=builder /app/templates ./templates

EXPOSE 8080

CMD ["./app"]