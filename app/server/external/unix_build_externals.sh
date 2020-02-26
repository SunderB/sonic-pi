#!/bin/bash
set -e # Quit script on error
SCRIPT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"

echo "Building server external dependencies..."
mkdir -p "${SCRIPT_DIR}/build"
cd "${SCRIPT_DIR}/build"
cmake -G "Unix Makefiles" ..

cmake --build . --target osmid

if [ $1 = "--build-aubio" ]; then
  cmake --build . --target aubio
fi

#dont remove ruby-aubio-prerelease  as needed in linux build
#it is removed in the windows-prebuild
