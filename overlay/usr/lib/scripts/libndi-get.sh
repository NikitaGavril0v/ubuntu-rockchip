#!/bin/bash
set -e

LIBNDI_INSTALLER_NAME="Install_NDI_SDK_v6_Linux"
LIBNDI_INSTALLER="$LIBNDI_INSTALLER_NAME.tar.gz"
LIBNDI_INSTALLER_URL=https://drive.google.com/file/d/10nI86LzA7ZgEXakEx2f0z_WO_nIClOMK/view?usp=sharing

# Use temporary directory
LIBNDI_TMP=$(mktemp --tmpdir -d ndidisk.XXXXXXX)

# Check if the temp directory exists and is a directory.
if [[ -d "$LIBNDI_TMP" ]]; then
    echo "Temporary directory created at $LIBNDI_TMP"
else
    echo "Failed to create a temporary directory."
    exit 1
fi

# While most of the command are with the folder path, this is needed for the libndi install script to run properly
pushd $LIBNDI_TMP

# Download LIBNDI
# The follwoing should work with tmp folder in the user home directory - but not always... So we do not use it.
# curl -o "$LIBNDI_TMP/$LIBNDI_INSTALLER" $LIBNDI_INSTALLER_URL -f --retry 5

# The following is required if the temp directory is not in the user home directory.
curl --header 'Host: drive.usercontent.google.com' --header 'User-Agent: Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/132.0.0.0 Safari/537.36' --header 'Accept: text/html,application/xhtml+xml,application/xml;q=0.9,image/avif,image/webp,image/apng,*/*;q=0.8,application/signed-exchange;v=b3;q=0.7' --header 'Accept-Language: ru-RU,ru;q=0.9,en-US;q=0.8,en;q=0.7' --header 'Cookie: SEARCH_SAMESITE=CgQI1ZwB; __Secure-ENID=25.SE=hBUb_yfAwyRG8gM8XdGfz_geCxa0mph22cDcWWLFvFhh1oYAA8aY_S4YCVGrQ5PWOAahpJnXr18sr9Wn-AzMzHZjeXt8BzAGenKVdWtvgdzQyM4At-WSGM7PahnJ26_6M4xUWCH5OkQZtrNtN6j5f8HFlyL-a6V5fHea4Ohshkxi8UJH1she4ybHyYp-Hb6EuoBLCtLj21ShBftYcunNzosRUKBVFYcxr0ZlYV3aWLVI--Fgiu92J4WjgiFJzeRpuaEY0Ihq9QGfckGCFaah1HYz50RsJLxQbNreO9S4thmN0T83DTZUNIxttsyt0bpzEQz7_2iqUhvRREtisuMUHfz_m3eDRbfUt6JQx5Rt1ude2b6k4bCAtKFQPtCWZaiP3OGYbSgWhKkj-jUW0V83sxpZSMTKTAFp4rc2UF1f7s40KCQ; SID=g.a000tAiPZiMyhV41u3Xd2akccZUfcVDvLs4S8fwA9xuC7VR6RDhizTmMvp4pH_RaQDG2sBksigACgYKARYSARESFQHGX2Mi2UubSl2rSwbRsz4nDUxHTxoVAUF8yKpiGo-BT1cxClvm5urR98Y30076; __Secure-1PSID=g.a000tAiPZiMyhV41u3Xd2akccZUfcVDvLs4S8fwA9xuC7VR6RDhi4FPzBULBTlapv5sC5tEVywACgYKAdMSARESFQHGX2MiNSQp61sVajW3tz4eBgjR9BoVAUF8yKqPfBXLHnEz03LgazB7Huh40076; __Secure-3PSID=g.a000tAiPZiMyhV41u3Xd2akccZUfcVDvLs4S8fwA9xuC7VR6RDhitiEyEUk34oWLJzSPYZcIlAACgYKAVQSARESFQHGX2MijuajSGj5tI3rTVDnyyKQ2BoVAUF8yKooz-HWOhXJVgjvNu3eHspK0076; HSID=AlSwmvug0gRGpRnG2; SSID=A4Xof-ORMKVPgmYZ7; APISID=YsxzLNdAjP-mAgRe/AlO_-hvBA5j7RXk_0; SAPISID=87HmyuFVQn5uFaKQ/AR_lH1O-uJ1EKfDYs; __Secure-1PAPISID=87HmyuFVQn5uFaKQ/AR_lH1O-uJ1EKfDYs; __Secure-3PAPISID=87HmyuFVQn5uFaKQ/AR_lH1O-uJ1EKfDYs; AEC=AVcja2f9rlPxhHAVEsu-A6QVMW5i7_A-W2uKt_uoKH2HYmpbvxouLl0nTg8; NID=521=aEWhgi2PqXFP8ZAo9glTjQAdYduDoBQuj7znf9QmAqXabZND2pViyZ4WhM8LUUSzI1TNWgFEtfcDXzV-b8oJab-kWvMAIlpoiNtWlPkvqfYJUN27uzGC6kXqnYF8cvkNBMnjLIbvXRaUyK3IMC6xpV6E14V9ko7MrBxLL42GazwqJqf6eyiiIARUPZ0q3oBCNqR1iUqP96MROA52sakb-zJBgnjvK0_ryBvWy7z1RxdjPi-D8y9nQV8ozL-ufP9azRVq0brTg7rb3odtGl7oMxNfY5-G6qFZp-cErLznNn6WpyK--ovtMDhRIGRRGcIOPp_7xBcgEmWABx3QWkTx0Ecf0xI1HdSFB2IaX7387WcxCZFjiJDlQvoNrmvIfjySha79WjHcjeO4-rWWZHirwBz9RHcxLukSElSiCKQDEqFCAk8xxYcSLx-eHgir0sY_EY6bxvJwUCK3ferqA4tDh-Hab28o4TWbIrxNUP88K03K2uAj7TRhI1SMmONpb4Im36iLl1UGDjQMZku5kfwS7rwWtstvHX1keozqz2IiHQa2ky2S5uBhYHrjEB1BIL5xUdUqWj3_xWlYPcfvU7DfI8RHIuzkcrDorptsqMLDOkCaUWACUPFtIkC8B8kToPREmdvKAWBSW4ul7G6z74R_yBEPue1Sbdd29B_h4qCW_5j691plQTWXbq4Zsb7XgNC9jujHSty37X38RQN35RxRJxBS6xSUaUr0wGFxX5p4Z3DQZpGl-hGuR38W6OwgKtGdNwTFTOviOvNHpnuvXgsfraETP0o6rZfHizdHKPS4OiXVy27TDMmp-Apw9LghKfS3bE_uzg; __Secure-1PSIDTS=sidts-CjIBmiPuTYv_qgH-Sw3LNmU_vwnAx0gjOZCskDWUGAbciT6t6YwBkNEM3TcWJur-b07IaBAA; __Secure-3PSIDTS=sidts-CjIBmiPuTYv_qgH-Sw3LNmU_vwnAx0gjOZCskDWUGAbciT6t6YwBkNEM3TcWJur-b07IaBAA; SIDCC=AKEyXzVLpnyyPQPHCDN0fHDuTu9mXYceG1olsh2mMwAFPfTOpgOJ06311XKVfmbQIYuPC1lYlsk; __Secure-1PSIDCC=AKEyXzWNSHDI9n8LBqhW5ZtVB7d_yJEw83snf437qqFHaStD95Pmjd92X8ZRe46Q435C8hbnA2E; __Secure-3PSIDCC=AKEyXzWCQ_BNhte4pM532yHa5vRtHvw4aRm4zQ5lKkjVYEAxRu4JGFC3GWZpuhTHJzVxhFMgLXk' --header 'Connection: keep-alive' 'https://drive.usercontent.google.com/download?id=10nI86LzA7ZgEXakEx2f0z_WO_nIClOMK&export=download&authuser=0&confirm=t&uuid=6c374a6d-446d-47d3-a964-c54b8fa6983e&at=AIrpjvPDJ9gbaNpLTol_8o-3oiGn:1738602350186' -L -o 'Install_NDI_SDK_v6_Linux.tar.gz' -f --retry 5 > "$LIBNDI_TMP/$LIBNDI_INSTALLER"


# Check if download was successful
if [ $? -ne 0 ]; then
    echo "Download failed."
    exit 1
fi

echo "Download complete."

# Step 3: Uncompress the file.
echo "Uncompressing..."
tar -xzvf "$LIBNDI_TMP/$LIBNDI_INSTALLER" -C "$LIBNDI_TMP"

# Check if uncompression was successful
if [ $? -ne 0 ]; then
    echo "Uncompression failed."
    exit 1
fi

echo "Uncompression complete."


yes | PAGER="cat" sh $LIBNDI_INSTALLER_NAME.sh


rm -rf $LIBNDI_TMP/ndisdk
echo "Moving things to a folder with no space"
mv "$LIBNDI_TMP/NDI SDK for Linux" $LIBNDI_TMP/ndisdk
echo
echo "Contents of $LIBNDI_TMP/ndisdk/lib:"
ls -la $LIBNDI_TMP/ndisdk/lib
echo
echo "Contents of $LIBNDI_TMP/ndisdk/lib/x86_64-linux-gnu:"
ls -la $LIBNDI_TMP/ndisdk/lib/x86_64-linux-gnu
echo

popd

if [ "$1" == "install" ]; then
    echo "Copying the library files to the long-term location. You might be prompted for authentication."
    sudo cp -P $LIBNDI_TMP/ndisdk/lib/x86_64-linux-gnu/* /usr/local/lib/
    sudo ldconfig

    echo "libndi installed to /usr/local/lib"
    ls -la /usr/local/lib/libndi*

    echo "Adding backward compatibility tweaks for older plugins version to work with NDI v6"
    sudo ln -s /usr/local/lib/libndi.so.6 /usr/local/lib/libndi.so.5
fi

# Allow to keep the temporary files (to use with libndi-package.sh)
if [ "$1" == "nocleanup" ]; then
    echo "No Clean-up requested."
else
    echo "Clean-up : Removing temporary folder"
    rm -rf $LIBNDI_TMP
    if [[ ! -d "$LIBNDI_TMP" ]]; then
        echo "Temporary directory $LIBNDI_TMP does not exist anymore (good!)"
    else
        echo "Failed to clean-up temporary directory."
        echo "Please clean this up manually - All should be in $LIBNDI_TMP"
        exit 1
    fi
fi
