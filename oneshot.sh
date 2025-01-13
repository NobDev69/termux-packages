#!/usr/bin/env bash

# Configuration
ARCHITECTURE="aarch64"
PACKAGE_NAME="vim"
#TG_TOKEN="<YOUR_TELEGRAM_BOT_TOKEN>"  # Replace with your Telegram bot token
#TG_CHAT_ID="<YOUR_TELEGRAM_CHAT_ID>"  # Replace with your Telegram chat ID
BOOTSTRAP_FILE="bootstrap-${ARCHITECTURE}.zip"

# Telegram Functions
tg_post_msg() {
  curl -s -X POST "https://api.telegram.org/bot${TG_TOKEN}/sendMessage" \
    -d chat_id="${TG_CHAT_ID}" \
    -d "disable_web_page_preview=true" \
    -d "parse_mode=html" \
    -d text="$1"
}

tg_post_file() {
  curl -F document=@$1 "https://api.telegram.org/bot${TG_TOKEN}/sendDocument" \
    -F chat_id="${TG_CHAT_ID}" \
    -F "disable_web_page_preview=true" \
    -F "parse_mode=html" \
    -F caption="$2"
}

# Ensure necessary commands exist
check_commands() {
  for cmd in curl ./build-package.sh ./scripts/build-bootstrap.sh; do
    if ! command -v $cmd &>/dev/null; then
      echo "[ERROR] Command $cmd not found. Exiting."
      exit 1
    fi
  done
}

# Build the package
build_package() {
  tg_post_msg "<b>Starting package build:</b> ${PACKAGE_NAME}%0A<b>Architecture:</b> ${ARCHITECTURE}"

  if ./build-package.sh -a "${ARCHITECTURE}" "${PACKAGE_NAME}"; then
    tg_post_msg "<b>Package build completed:</b> ${PACKAGE_NAME}"
  else
    tg_post_msg "<b>Package build failed:</b> ${PACKAGE_NAME}"
    exit 1
  fi
}

# Build the bootstrap file
build_bootstrap() {
  tg_post_msg "<b>Starting bootstrap build</b>%0A<b>Architecture:</b> ${ARCHITECTURE}"

  if ./scripts/build-bootstrap.sh --architectures "${ARCHITECTURE}"; then
    tg_post_msg "<b>Bootstrap build completed</b>"
    tg_post_file "${BUILD_DIR}/${BOOTSTRAP_FILE}" "Built bootstrap file for architecture: ${ARCHITECTURE}"
  else
    tg_post_msg "<b>Bootstrap build failed</b>"
    exit 1
  fi
}

# Main
main() {
  cd "${BUILD_DIR}" || exit 1
  check_commands
  tg_post_msg "<b>Termux Build Script Initialized</b>"
  build_package
  build_bootstrap
  tg_post_msg "<b>All tasks completed successfully</b>"
}

main
