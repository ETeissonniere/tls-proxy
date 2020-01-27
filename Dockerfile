# Override to use another go version
ARG GO_VERSION=1.12

# First stage: build the executable.
FROM golang:${GO_VERSION}-alpine AS builder

# Install the Certificate-Authority certificates for the app to be able to make
# calls to HTTPS endpoints and git for golang.
RUN apk add --no-cache ca-certificates git

ENV CGO_ENABLED=0
ENV GO11MODULE=enable

# Set the working directory outside $GOPATH to enable the support for modules.
WORKDIR /src

# First fetch dependencies and cache this layer
COPY go.mod .
COPY go.sum .
RUN go mod download

# Import the code from the context.
COPY . .

# Build the executable to `/app`. Mark the build as statically linked.
RUN go build -installsuffix 'static' -o /app

# Final stage: the running container.
FROM scratch AS final

# Import the Certificate-Authority certificates for enabling HTTPS.
COPY --from=builder /etc/ssl/certs/ca-certificates.crt /etc/ssl/certs/

# Import the compiled executable from the second stage.
COPY --from=builder /app /app

EXPOSE 8443
EXPOSE 8080

# Run the compiled binary.
ENTRYPOINT ["/app"]