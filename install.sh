#!/bin/sh

echo "Setting up Make for z/OS"

INSTALL_DIR="$( cd "$(dirname "$0")" >/dev/null 2>&1 && pwd -P )"

# Add full path of installation directory to the PATH environment variable and create script to set environment variables required 
cat <<EOF > ${INSTALL_DIR}/.env
export _BPXK_AUTOCVT=ON
export _CEE_RUNOPTS="\$_CEE_RUNOPTS FILETAG(AUTOCVT,AUTOTAG) POSIX(ON)"
export _TAG_REDIR_IN=txt
export _TAG_REDIR_ERR=txt
export _TAG_REDIR_OUT=txt
export PATH="${INSTALL_DIR}/bin:\$PATH"
EOF

echo "Make location: ${INSTALL_DIR}/bin/make"
echo "\nIMPORTANT: Source the environment script prior to running perl using the dot (.) command:"
echo ". ${INSTALL_DIR}/.env"
