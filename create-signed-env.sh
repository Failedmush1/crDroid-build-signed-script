#!/bin/bash

# Default values
DEFAULT_COUNTRY="US"
DEFAULT_STATE="California"
DEFAULT_LOCALITY="Mountain View"
DEFAULT_ORGANIZATION="crDroid"
DEFAULT_ORG_UNIT="crDroid"
DEFAULT_COMMON_NAME="crDroid"
DEFAULT_EMAIL="contact@crdroid.net"

# Prompt the user for each part of the subject line with defaults
read -p "Enter country code [${DEFAULT_COUNTRY}] (C): " country
country=${country:-$DEFAULT_COUNTRY}

read -p "Enter state or province name [${DEFAULT_STATE}] (ST): " state
state=${state:-$DEFAULT_STATE}

read -p "Enter locality [${DEFAULT_LOCALITY}] (L): " locality
locality=${locality:-$DEFAULT_LOCALITY}

read -p "Enter organization name [${DEFAULT_ORGANIZATION}] (O): " organization
organization=${organization:-$DEFAULT_ORGANIZATION}

read -p "Enter organizational unit [${DEFAULT_ORG_UNIT}] (OU): " organizational_unit
organizational_unit=${organizational_unit:-$DEFAULT_ORG_UNIT}

read -p "Enter common name [${DEFAULT_COMMON_NAME}] (CN): " common_name
common_name=${common_name:-$DEFAULT_COMMON_NAME}

read -p "Enter email address [${DEFAULT_EMAIL}] (emailAddress): " email
email=${email:-$DEFAULT_EMAIL}

# Construct the subject line
subject="/C=${country}/ST=${state}/L=${locality}/O=${organization}/OU=${organizational_unit}/CN=${common_name}/emailAddress=${email}"

# Print the subject line
echo ""
echo "Using Subject Line:"
echo "$subject"
echo ""

# Prompt the user to verify if the subject line is correct
read -p "Is the subject line correct? [Y/n]: " confirmation
confirmation=${confirmation:-Y}

# Check the user's response
if [[ $confirmation != "y" && $confirmation != "Y" ]]; then
    echo "Exiting without changes."
    exit 1
fi
clear


# Create Key
echo "Press ENTER TWICE to skip password (about 10-15 enter hits total). Cannot use a password for inline signing!"
mkdir -p ~/.android-certs

for x in bluetooth cyngn-app media networkstack nfc platform releasekey sdk_sandbox shared testcert testkey verity; do \
    ./development/tools/make_key ~/.android-certs/$x "$subject"; \
done


## Create vendor for keys
mkdir -p vendor/lineage-priv
mv ~/.android-certs vendor/lineage-priv/keys
echo "PRODUCT_DEFAULT_DEV_CERTIFICATE := vendor/lineage-priv/keys/releasekey" > vendor/lineage-priv/keys/keys.mk
cat <<EOF > vendor/lineage-priv/keys/BUILD.bazel
filegroup(
    name = "android_certificate_directory",
    srcs = glob([
        "*.pk8",
        "*.pem",
    ]),
    visibility = ["//visibility:public"],
)
EOF

echo ""
echo "✓ Done! Now build as usual."
echo "✓ If builds aren't being signed, add '-include vendor/lineage-priv/keys/keys.mk' to your device mk file"
echo ""
echo "⚠ IMPORTANT: Make copies of your vendor/lineage-priv folder as it contains your keys!"
sleep 3
