FROM golang:1.16 as builder
WORKDIR /builder
COPY go.* .
RUN go mod download
COPY main.go .
RUN go build -o hello

FROM gcr.io/distroless/base-debian10
COPY --from=builder /builder/hello /
CMD ["/hello"]
