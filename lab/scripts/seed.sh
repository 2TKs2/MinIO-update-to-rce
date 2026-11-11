#!/bin/sh
set -e
BUCKET="${LAB_BUCKET:-lab-bucket}"

mc alias set lab http://minio:9000 "$MINIO_ROOT_USER" "$MINIO_ROOT_PASSWORD"
mc mb --ignore-existing "lab/$BUCKET"
echo "minio lab target - $(date -u)" > /tmp/hello.txt
mc cp /tmp/hello.txt "lab/$BUCKET/hello.txt"

echo "---------------- lab ready ----------------"
mc admin info lab || true
mc ls "lab/$BUCKET"
