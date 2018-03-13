#!/bin/bash -l
set -e

function cleanup {
  chmod -R 777 "$TEMP_DIR"
  rm -rf "$TEMP_DIR"
}

TIMEZONE=$(sed -e 's/[\/&]/\\&/g' /etc/timezone)
SCRIPT=`realpath $0`
SCRIPTPATH=`dirname $SCRIPT`
TEMP_DIR=$(mktemp -d)
trap cleanup EXIT

echo "Using temp directory: $TEMP_DIR"
echo ""

read -ep "Path to mounted iso: " ISO_PATH
if [ ! -d "$ISO_PATH" ]; then
  echo "Unable to find $ISO_PATH"
  exit 1
fi

read -p "Admin username: " USERNAME
read -sp "Admin password: " PASSWORD
echo ""
read -sp "Admin password (again): " PASSWORD_AGAIN
echo ""
if [ ! "$PASSWORD" == "$PASSWORD_AGAIN" ]; then
  echo "Passwords do not match"
  exit 1
fi
read -ep "Admin authorized ssh pub key path: " PUBKEY_PATH
PUBKEY_PATH="${PUBKEY_PATH/#\~/$HOME}"

if [ ! -f "$PUBKEY_PATH" ]; then
  echo "Unable to find $PUBKEY_PATH"
  exit 1
fi
read -p "Domain name (default to localhost if blank: " DOMAIN_NAME
if [ "$DOMAIN_NAME" == "" ]; then
  DOMAIN_NAME=localhost
fi

echo "Copying files from iso"
cp -rT "$ISO_PATH" "$TEMP_DIR"
chmod -R u+w "$TEMP_DIR"

PUBKEY=$(sed -e 's/[\/&]/\\&/g' "$PUBKEY_PATH")
CPASS=$(mkpasswd -m sha-512 -S "$(pwgen -ns 16 1)" "$PASSWORD" | sed -e 's/[\/&]/\\&/g')

PRESEED_DEST="$TEMP_DIR/preseed.cfg"
cp "$SCRIPTPATH/preseed-template.cfg" "$PRESEED_DEST"
cp "$SCRIPTPATH/txt.cfg" "$TEMP_DIR/isolinux/"

sed -i "s/USERNAME/${USERNAME}/g" "$PRESEED_DEST"
sed -i "s/CRYPTED_PASSWORD/${CPASS}/g" "$PRESEED_DEST"
sed -i "s/SSH_PUB_KEY/${PUBKEY}/g" "$PRESEED_DEST"
sed -i "s/TIMEZONE/${TIMEZONE}/g" "$PRESEED_DEST"
sed -i "s/DOMAIN_NEM/${DOMAIN_NAME}/g" "$PRESEED_DEST"

ISO_DEST="debian-9.x.x-amd64-$USERNAME.iso"
echo "Writing updated ISO to $ISO_DEST"
genisoimage -r -J -b isolinux/isolinux.bin -c isolinux/boot.cat -no-emul-boot -boot-load-size 4 -boot-info-table -o "$ISO_DEST" "$TEMP_DIR" > /dev/null
