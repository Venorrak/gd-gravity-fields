#!/usr/bin/env bash
# Publishes a new version of a Godot addon to the Asset Store.
#
# Requires the GODOT_STORE_SESSION env var (the browser 'session' cookie
# value from a logged-in account). This is a workaround for the store using
# GitHub OAuth login with no scriptable equivalent — see conversation notes.
#
# USAGE:
#   ./publish_godot_asset.sh <path-to-zip> <version-name> <changelog-text>
#
# NOTE: The JSON field names marked "VERIFY" below are inferred from a partial
# HAR trace that only captured requests, not responses. Confirm the real
# response shape from your browser's Network tab before relying on this in CI.

set -euo pipefail

: "${GODOT_STORE_SESSION:?Set GODOT_STORE_SESSION (the store session cookie)}"
: "${ASSET_USER:?Set ASSET_USER (e.g. venorrak)}"
: "${ASSET_SLUG:?Set ASSET_SLUG (e.g. gd-cctv)}"

ZIP_PATH="${1:?Usage: $0 <zip-path> <version> <changelog>}"
VERSION="${2:?version name required, e.g. v1.2}"
CHANGELOG="${3:-Automated release}"
MIN_GODOT_VERSION="${MIN_GODOT_VERSION:-Godot 4.5}"
MAX_GODOT_VERSION="${MAX_GODOT_VERSION:-Godot 4.7.2}"

BASE_URL="https://store.godotengine.org/asset/${ASSET_USER}/${ASSET_SLUG}"
COOKIE="session=${GODOT_STORE_SESSION}"
UA="Mozilla/5.0 (X11; Linux x86_64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/148.0.0.0 Safari/537.36"

echo "==> Fetching manage page to grab a fresh CSRF token"
MANAGE_HTML=$(curl -sS "${BASE_URL}/manage/" \
  -b "$COOKIE" \
  -H "user-agent: $UA" \
  -H "referer: ${BASE_URL}/manage/")

CSRF_TOKEN=$(echo "$MANAGE_HTML" | grep -oP 'name="csrf_token"[^>]*value="\K[^"]+' | head -1 || true)

if [ -z "$CSRF_TOKEN" ]; then
  echo "!! Could not extract CSRF token." >&2
  echo "!! Most likely cause: GODOT_STORE_SESSION has expired or is invalid." >&2
  echo "!! Fix: log into store.godotengine.org in a browser, copy the fresh" >&2
  echo "!! 'session' cookie value, and update the GODOT_STORE_SESSION secret." >&2
  exit 1
fi
echo "==> Got CSRF token"

echo "==> Requesting upload URL"
UPLOAD_URL_RESP=$(curl -sS "${BASE_URL}/version/upload_url/" \
  -b "$COOKIE" \
  -H "user-agent: $UA" \
  -H "origin: https://store.godotengine.org" \
  -H "referer: ${BASE_URL}/manage/" \
  -H "x-csrftoken: ${CSRF_TOKEN}" \
  -F "csrf_token=${CSRF_TOKEN}" \
  -F "filename=$(basename "$ZIP_PATH")" \
  -F "checksum=" \
  -F "name=${VERSION}" \
  -F "changelog=${CHANGELOG}" \
  -F "stable=y" \
  -F "min_godot_version=${MIN_GODOT_VERSION}" \
  -F "max_godot_version=${MAX_GODOT_VERSION}" \
  -F "version_notes=" \
  -F "upload_chunks=1")

QUEUE_ID=$(echo "$UPLOAD_URL_RESP" | jq -r '.queue_id')
UPLOAD_ID=$(echo "$UPLOAD_URL_RESP" | jq -r '.upload_id')
PART_URL=$(echo "$UPLOAD_URL_RESP" | jq -r '.upload_urls[0]')

if [ "$QUEUE_ID" = "null" ] || [ -z "$QUEUE_ID" ]; then
  echo "!! upload_url request was rejected. Raw response:" >&2
  echo "$UPLOAD_URL_RESP" >&2
  echo "!! Common cause: version name (\"$VERSION\") must be at least 3 characters." >&2
  exit 1
fi

if [ -z "$PART_URL" ] || [ "$PART_URL" = "null" ]; then
  echo "!! Could not find the presigned upload URL in the response above." >&2
  echo "!! Paste that JSON back so the field names can be corrected." >&2
  exit 1
fi

echo "==> Uploading zip to storage (queue_id=$QUEUE_ID upload_id=$UPLOAD_ID)"
ETAG=$(curl -sS -X PUT "$PART_URL" \
  -H "content-type: application/octet-stream" \
  -H "origin: https://store.godotengine.org" \
  --data-binary "@${ZIP_PATH}" \
  -D - -o /dev/null | grep -i '^etag:' | sed -E 's/^[Ee][Tt][Aa][Gg]: *"?([^"\r\n]+)"?.*/\1/')

if [ -z "$ETAG" ]; then
  echo "!! Did not receive an ETag from the storage upload." >&2
  exit 1
fi
echo "==> Uploaded, ETag=$ETAG"

PARTS_JSON=$(jq -nc --arg etag "$ETAG" '[{"PartNumber":1,"ETag":("\"" + $etag + "\"")}]')

echo "==> Finalizing version"
CREATE_RESP=$(curl -sS "${BASE_URL}/version/create/" \
  -b "$COOKIE" \
  -H "user-agent: $UA" \
  -H "origin: https://store.godotengine.org" \
  -H "referer: ${BASE_URL}/manage/" \
  -H "x-csrftoken: ${CSRF_TOKEN}" \
  -F "csrf_token=${CSRF_TOKEN}" \
  -F "filename=" \
  -F "checksum=" \
  -F "name=${VERSION}" \
  -F "changelog=${CHANGELOG}" \
  -F "stable=y" \
  -F "min_godot_version=${MIN_GODOT_VERSION}" \
  -F "max_godot_version=${MAX_GODOT_VERSION}" \
  -F "version_notes=" \
  -F "queue_id=${QUEUE_ID}" \
  -F "upload_id=${UPLOAD_ID}" \
  -F "parts=${PARTS_JSON}")

echo "$CREATE_RESP"
echo "==> Done. Check ${BASE_URL}/manage/ to confirm the new version shows up."
