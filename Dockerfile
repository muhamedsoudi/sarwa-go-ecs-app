# Alpine is chosen for its small footprint compared to Ubuntu
FROM golang:1.16-alpine
# Create our working directory
WORKDIR /app
# Download necessary Go modules
COPY go.mod ./
COPY go.sum ./
RUN go mod download
# Copy our source code to the container
COPY ./src ./
## build step to include all the necessary go libraries included.
RUN go build -o /assignment
## kicks off the newly created binary executable upon startup
CMD ["/assignment"]