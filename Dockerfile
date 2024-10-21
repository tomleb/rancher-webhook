FROM golang:1.22 as build
WORKDIR /build
ENV CGO_ENABLED 0
ENV GOCACHE /root/.cache/go/build
ENV GOMODCACHE /root/.cache/go/mod
COPY go.mod go.sum .
RUN --mount=type=cache,target=/root/.cache go mod download
COPY *.go .
COPY pkg pkg
RUN --mount=type=cache,target=/root/.cache go build -o /usr/bin/webhook

FROM scratch
COPY --from=build /usr/bin/webhook /usr/bin/webhook
ENTRYPOINT ["/usr/bin/webhook"]
