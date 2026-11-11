# Build MinIO from source at a release tag (dl.min.io is 410, no Docker Hub tags,
# no GitHub assets). The ldflags cmd.Version is required: without it the update
# handler refuses every request.
#
# CommitID/ShortCommitID are taken from the cloned tag, so the binary carries the
# real upstream commit and its provenance is verifiable from the artifact itself
# (GOFLAGS=-buildvcs=false keeps Go from embedding VCS info of the shallow clone).
ARG GO_IMAGE=golang:1.25.3-alpine
FROM ${GO_IMAGE} AS builder
ARG MINIO_TAG=RELEASE.2025-10-15T17-29-55Z
ENV GOFLAGS=-buildvcs=false
WORKDIR /src
RUN command -v git >/dev/null 2>&1 || \
    apk add --no-cache git || \
    (apt-get update && apt-get install -y --no-install-recommends git && rm -rf /var/lib/apt/lists/*)
RUN git clone --depth 1 --branch "${MINIO_TAG}" https://github.com/minio/minio.git .
RUN COMMIT="$(git rev-parse HEAD)"; SHORT="$(git rev-parse --short=12 HEAD)"; \
    echo "[build] ${MINIO_TAG} -> ${COMMIT}"; \
    CGO_ENABLED=0 go build -tags kqueue -trimpath \
      --ldflags "-s -w \
        -X github.com/minio/minio/cmd.Version=${MINIO_TAG} \
        -X github.com/minio/minio/cmd.ReleaseTag=${MINIO_TAG} \
        -X github.com/minio/minio/cmd.CommitID=${COMMIT} \
        -X github.com/minio/minio/cmd.ShortCommitID=${SHORT}" \
      -o /minio ./ \
 && /minio --version

FROM debian:bookworm-slim
RUN apt-get update && apt-get install -y --no-install-recommends ca-certificates curl \
 && rm -rf /var/lib/apt/lists/*
COPY --from=builder /minio /usr/bin/minio
RUN mkdir -p /data
EXPOSE 9000 9001
ENTRYPOINT ["/usr/bin/minio"]
CMD ["server","/data","--console-address",":9001"]
