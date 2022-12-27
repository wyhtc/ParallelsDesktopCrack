#!/usr/bin/env bash

BASE_PATH=$(
  cd $(dirname "$0");
  pwd
)

COLOR_INFO='\033[0;34m'
COLOR_ERR='\033[0;35m'
NOCOLOR='\033[0m'

PDFM_DIR="/Applications/Parallels Desktop.app"
PDFM_LOC="/Library/Preferences/Parallels/parallels-desktop.loc"
PDFM_VER="18.1.1-53328"

PDFM_DISP_CRACK="${BASE_PATH}/prl_disp_service"
PDFM_DISP_DST="${PDFM_DIR}/Contents/MacOS/Parallels Service.app/Contents/MacOS/prl_disp_service"
PDFM_DISP_ENT="${BASE_PATH}/ParallelsService.entitlements"

LICENSE_FILE="${BASE_PATH}/licenses.json"
LICENSE_DST="/Library/Preferences/Parallels/licenses.json"

PDFM_DISP_ORIGIN_HASH="70dcdf678c3af759134e1b3dffba40b4ae671a0e297a4c1b83a04e45d5c271be"
PDFM_DISP_HASH="a9678c5edd4afc203253b23baaa5344d77ceb939ca8f5023c4bbc4bc91605cb1"
LICENSE_HASH="ac735f3ee7ac815539f07e68561baceda858cf7ac5887feae863f10a60db3d79"

# read location from parallels-desktop.loc
if [ -f "${PDFM_LOC}" ]; then
  PDFM_DIR=$(cat "${PDFM_LOC}")
fi

# check parallels desktop install
if [ ! -d "${PDFM_DIR}" ]; then
  echo -e "${COLOR_ERR}[-] Not found ${PDFM_DIR}, are you installed Parallels Desktop ${PDFM_VER}?${NOCOLOR}"
  echo "    Download from here: https://download.parallels.com/desktop/v18/${PDFM_VER}/ParallelsDesktop-${PDFM_VER}.dmg"
  exit 1
fi

# check parallels desktop version
VERSION_1=$(defaults read "${PDFM_DIR}/Contents/Info.plist" CFBundleShortVersionString)
VERSION_2=$(defaults read "${PDFM_DIR}/Contents/Info.plist" CFBundleVersion)
INSTALL_VER="${VERSION_1}-${VERSION_2}"
if [ "${PDFM_VER}" != "${VERSION_1}-${VERSION_2}" ]; then
  echo -e "${COLOR_ERR}[-] This crack is for ${PDFM_VER}, but you installed is ${INSTALL_VER}.${NOCOLOR}"
  echo "    Download from here: https://download.parallels.com/desktop/v18/${PDFM_VER}/ParallelsDesktop-${PDFM_VER}.dmg"
  exit 2
fi

# check original prl_disp_service hash
FILE_HASH=$(shasum -a 256 -b "${PDFM_DISP_DST}" | awk '{print $1}')
if [ "${FILE_HASH}" != "${PDFM_DISP_ORIGIN_HASH}" ]; then
  echo -e "${COLOR_ERR}[-] ${FILE_HASH} != ${PDFM_DISP_ORIGIN_HASH}${NOCOLOR}"
  echo -e "${COLOR_ERR}[-] verify original file (prl_disp_service) hash error.${NOCOLOR}"
  echo -e "${COLOR_ERR}[-] file has been modified, maybe already cracked.${NOCOLOR}"
  exit 3
fi

# check prl_disp_service hash
FILE_HASH=$(shasum -a 256 -b "${PDFM_DISP_CRACK}" | awk '{print $1}')
if [ "${FILE_HASH}" != "${PDFM_DISP_HASH}" ]; then
  echo -e "${COLOR_ERR}[-] ${FILE_HASH} != ${PDFM_DISP_HASH}${NOCOLOR}"
  echo -e "${COLOR_ERR}[-] verify crack file (prl_disp_service) hash error.${NOCOLOR}"
  echo -e "${COLOR_ERR}[-] please re-download crack files.${NOCOLOR}"
  exit 3
fi

# check licenses.json hash
FILE_HASH=$(shasum -a 256 -b "${LICENSE_FILE}" | awk '{print $1}')
if [ "${FILE_HASH}" != "${LICENSE_HASH}" ]; then
  echo -e "${COLOR_ERR}[-] ${FILE_HASH} != ${LICENSE_HASH}${NOCOLOR}"
  echo -e "${COLOR_ERR}[-] verify crack file (licenses.json) hash error.${NOCOLOR}"
  echo -e "${COLOR_ERR}[-] please re-download crack files.${NOCOLOR}"
  exit 4
fi

# check root permission
if [ "$EUID" -ne 0 ]; then
  echo -e "${COLOR_ERR}[-] Not have root permission, run sudo.${NOCOLOR}"
  exec sudo "$0" "$@"
  exit 5
fi

# if prl_disp_service running, stop it
if pgrep -x "prl_disp_service" &> /dev/null; then
  echo -e "${COLOR_INFO}[*] Stop Parallels Desktop${NOCOLOR}"
  pkill -9 prl_client_app &>/dev/null
  # ensure prl_disp_service stop
  "${PDFM_DIR}/Contents/MacOS/Parallels Service" service_stop &>/dev/null
  sleep 1
  launchctl stop /Library/LaunchDaemons/com.parallels.desktop.launchdaemon.plist &>/dev/null
  sleep 1
  pkill -9 prl_disp_service &>/dev/null
  sleep 1
  rm -f "/var/run/prl_*"
fi

echo -e "${COLOR_INFO}[*] Copy prl_disp_service${NOCOLOR}"

chflags -R 0 "${PDFM_DISP_DST}" || { echo -e "${COLOR_ERR}error $? at line $LINENO.${NOCOLOR}"; exit $?; }
rm -f "${PDFM_DISP_DST}" || { echo -e "${COLOR_ERR}error $? at line $LINENO.${NOCOLOR}"; exit $?; }
cp "${PDFM_DISP_CRACK}" "${PDFM_DISP_DST}" || { echo -e "${COLOR_ERR}error $? at line $LINENO.${NOCOLOR}"; exit $?; }
chown root:wheel "${PDFM_DISP_DST}" || { echo -e "${COLOR_ERR}error $? at line $LINENO.${NOCOLOR}"; exit $?; }
chmod 755 "${PDFM_DISP_DST}" || { echo -e "${COLOR_ERR}error $? at line $LINENO.${NOCOLOR}"; exit $?; }
chflags -R 0 "${PDFM_DISP_CRACK}" || { echo -e "${COLOR_ERR}error $? at line $LINENO.${NOCOLOR}"; exit $?; }

# check hash
FILE_HASH=$(shasum -a 256 -b "${PDFM_DISP_DST}" | awk '{print $1}')
if [ "${FILE_HASH}" != "${PDFM_DISP_HASH}" ]; then
  echo -e "${COLOR_ERR}[-] ${FILE_HASH} != ${PDFM_DISP_HASH}${NOCOLOR}"
  echo -e "${COLOR_ERR}[-] verify target file (prl_disp_service) hash error.${NOCOLOR}"
  exit 6
fi

echo -e "${COLOR_INFO}[*] Sign prl_disp_service${NOCOLOR}"

codesign -f -s - --timestamp=none --all-architectures --entitlements "${PDFM_DISP_ENT}" "${PDFM_DISP_DST}" || { echo -e "${COLOR_ERR}error $? at line $LINENO.${NOCOLOR}"; exit $?; }

echo -e "${COLOR_INFO}[*] Copy fake licenses.json${NOCOLOR}"

if [ -f "${LICENSE_DST}" ]; then
  chflags -R 0 "${LICENSE_DST}" || { echo -e "${COLOR_ERR}error $? at line $LINENO.${NOCOLOR}"; exit $?; }
  rm -f "${LICENSE_DST}" > /dev/null || { echo -e "${COLOR_ERR}error $? at line $LINENO.${NOCOLOR}"; exit $?; }
fi

cp -f "${LICENSE_FILE}" "${LICENSE_DST}" || { echo -e "${COLOR_ERR}error $? at line $LINENO.${NOCOLOR}"; exit $?; }
chown root:wheel "${LICENSE_DST}" || { echo -e "${COLOR_ERR}error $? at line $LINENO.${NOCOLOR}"; exit $?; }
chmod 444 "${LICENSE_DST}" || { echo -e "${COLOR_ERR}error $? at line $LINENO.${NOCOLOR}"; exit $?; }
chflags -R 0 "${LICENSE_DST}" || { echo -e "${COLOR_ERR}error $? at line $LINENO.${NOCOLOR}"; exit $?; }
chflags uchg "${LICENSE_DST}" || { echo -e "${COLOR_ERR}error $? at line $LINENO.${NOCOLOR}"; exit $?; }
chflags schg "${LICENSE_DST}" || { echo -e "${COLOR_ERR}error $? at line $LINENO.${NOCOLOR}"; exit $?; }

# check hash
FILE_HASH=$(shasum -a 256 -b "${LICENSE_DST}" | awk '{print $1}')
if [ "${FILE_HASH}" != "${LICENSE_HASH}" ]; then
  echo -e "${COLOR_ERR}[-] ${FILE_HASH} != ${LICENSE_HASH}${NOCOLOR}"
  echo -e "${COLOR_ERR}[-] verify target file (${LICENSE_DST}) hash error.${NOCOLOR}"
  exit 7
fi

# is prl_disp_service not running, start it
if ! pgrep -x "prl_disp_service" &>/dev/null; then
  echo -e "${COLOR_INFO}[*] Start Parallels Service${NOCOLOR}"
  "${PDFM_DIR}/Contents/MacOS/Parallels Service" service_restart &>/dev/null
  for (( i=0; i < 10; ++i ))
  do
    if pgrep -x "prl_disp_service" &>/dev/null; then
      break
    fi
    sleep 1
  done
  if ! pgrep -x "prl_disp_service" &>/dev/null; then
    echo -e "${COLOR_ERR}[x] Start Service fail.${NOCOLOR}"
  fi
fi

VALID_INFO="License: state='valid' restricted='false'"
"${PDFM_DIR}/Contents/MacOS/prlsrvctl" info | grep "${VALID_INFO}" &>/dev/null
if [ $? != 0 ]; then
  echo -e "${COLOR_ERR}[x] Crack fail, please retry it.${NOCOLOR}"
  exit 9
fi

echo -e "${COLOR_INFO}[*] Exit Parallels Desktop account ...${NOCOLOR}"
"${PDFM_DIR}/Contents/MacOS/prlsrvctl" web-portal signout &>/dev/null

echo -e "${COLOR_INFO}[*] Disable CEP ...${NOCOLOR}"
"${PDFM_DIR}/Contents/MacOS/prlsrvctl" set --cep off &>/dev/null
"${PDFM_DIR}/Contents/MacOS/prlsrvctl" set --allow-attach-screenshots off &>/dev/null

echo -e "${COLOR_INFO}[*] Crack success.${NOCOLOR}"

