TOOLCHAIN_NAME="toolchain-gccarmnoneeabi"
TOOLCHAIN_VERSION="10.2"

TOOLCHAIN_ROOT="${HOME}/.platformio/packages"
TOOLCHAIN_PATH="${TOOLCHAIN_ROOT}/${TOOLCHAIN_NAME}@${TOOLCHAIN_VERSION}"

DOWNLOAD_OUTPUT="/tmp/toolchain.tar.bz2"
DOWNLOAD_SOURCE="https://developer.arm.com/-/media/Files/downloads/gnu-rm/10-2020q4/gcc-arm-none-eabi-10-2020-q4-major-x86_64-linux.tar.bz2?revision=ca0cbf9c-9de2-491c-ac48-898b5bbc0443&la=en&hash=68760A8AE66026BCF99F05AC017A6A50C6FD832A"

function downloadToTemp() {
  if [ -f "${DOWNLOAD_OUTPUT}" ]; then
    echo "Toolchain archive seems to have been downloaded, already!"
  else
    wget -O "${DOWNLOAD_OUTPUT}" "${DOWNLOAD_SOURCE}"
  fi
}

function extractToolchain() {
  echo "Extracting downloaded archive..."
  mkdir -p "${TOOLCHAIN_PATH}"
  tar -C "${TOOLCHAIN_PATH}" -xf "${DOWNLOAD_OUTPUT}" --strip-components=1
}

function generateManifest() {
  echo "Adding manifest..."

  MANIFEST="package.json"

  cat <<MANI >"${TOOLCHAIN_PATH}/${MANIFEST}"
{
    "name": "${TOOLCHAIN_NAME}",
    "version": "${TOOLCHAIN_VERSION}",
    "description": "GNU toolchain for Arm Cortex-M and Cortex-R processors",
    "homepage": "https://developer.arm.com/tools-and-software/open-source-software/developer-tools/gnu-toolchain/gnu-rm",
    "license": "GPL-2.0-or-later",
    "repository": {
        "type": "git",
        "url": "https://gcc.gnu.org/git/gcc.git"
    }
}
MANI
}

function generatePackageManagerInfo() {
  echo "Adding package manager information..."

  PM=".piopm"

  cat <<META >"${TOOLCHAIN_PATH}/${PM}"
{
    "type": "tool",
    "name": "${TOOLCHAIN_NAME}",
    "version": "${TOOLCHAIN_VERSION}",
    "spec": {
        "owner": "platformio",
        "id": 8207,
        "name": "${TOOLCHAIN_NAME}",
        "requirements": null,
        "url": null
    }
}
META
}

function fixMissingDependencies() {
  LIB_LOCATION="arm-none-eabi/lib"
  echo "Adding lacking Cortex-M libraries..."
  cp ./*.a "${TOOLCHAIN_PATH}/${LIB_LOCATION}"
}

downloadToTemp && extractToolchain && generateManifest && generatePackageManagerInfo && fixMissingDependencies

echo "Successfully installed '${TOOLCHAIN_NAME}' to '${TOOLCHAIN_PATH}'"
