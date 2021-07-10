set -e # Quit script on error
SCRIPT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
cd "${SCRIPT_DIR}"

echo "Installing gems... This may take a while..."
bundle config set --local path vendor
bundle install
echo "Done!"
echo "Run ./serve.sh to build and host the website!"
