#!/usr/bin/env bash

# Add Guix to PATH
export GUIX_PROFILE="/root/.config/guix/current"
export PATH="$GUIX_PROFILE/bin:$PATH"
export GUIX_LOCPATH="$GUIX_PROFILE/lib/locale"
export SSL_CERT_DIR="$GUIX_PROFILE/etc/ssl/certs"
export SSL_CERT_FILE="$GUIX_PROFILE/etc/ssl/certs/ca-certificates.crt"
export GIT_SSL_CAINFO="$SSL_CERT_FILE"
