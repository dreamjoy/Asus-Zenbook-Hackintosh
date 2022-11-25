#!/bin/bash

oc_version="0.8.3"

curl_options="--retry 5 --location --progress-bar"
curl_options_silent="--retry 5 --location --silent"

# download latest release from github
function download_github()
# $1 is sub URL of release page
# $2 is partial file name to look for
# $3 is file name to rename to
{
    echo "downloading `basename $3 .zip`:"
    curl $curl_options_silent --output /tmp/com.hieplpvip.download.txt "https://github.com/$1/releases/latest"
    local url=https://github.com`grep -o -m 1 "/.*$2.*\.zip" /tmp/com.hieplpvip.download.txt`
    echo $url
    curl $curl_options --output "$3" "$url"
    rm /tmp/com.hieplpvip.download.txt
    echo
}

# download latest release from github
function download_github1()
# $1 is sub URL of release page
# $2 is partial file name to look for
# $3 is file name to rename to
{
    echo "downloading `basename $3 .zip`:"
    echo $2
    curl $curl_options --output "$3" "$1"
    echo
}

function download_raw()
{
    echo "downloading $2"
    echo $1
    curl $curl_options --output "$2" "$1"
    echo
}


rm -rf download && mkdir ./download
cd ./download

# download resources FOR OpenCanopy (Themes)
mkdir ./resources && cd ./resources
download_raw https://github.com/acidanthera/OcBinaryData/archive/refs/heads/master.zip OcBinaryData.zip


echo "unzipping resources"
unzip -q OcBinaryData.zip 'OcBinaryData-master/Resources/**/*' -d "" 
cd ..

# download OpenCore
mkdir ./oc && cd ./oc
download_github1 "acidanthera/OpenCorePkg" "$oc_version-RELEASE" "OpenCore.zip"
unzip -o -q -d OpenCorePkg OpenCore.zip 
cd ..

# download kexts
mkdir ./zips && cd ./zips
download_github "https://github.com/acidanthera/Lilu/releases/download/1.6.2/Lilu-1.6.2-RELEASE.zip" "RELEASE" "acidanthera-Lilu.zip"
download_github "https://github.com/acidanthera/AppleALC/releases/download/1.7.6/AppleALC-1.7.6-RELEASE.zip" "RELEASE" "acidanthera-AppleALC.zip"
download_github "https://github.com/acidanthera/AirportBrcmFixup/releases/download/2.1.6/AirportBrcmFixup-2.1.6-RELEASE.zip" "RELEASE" "acidanthera-AirportBrcmFixup.zip"
download_github "https://github.com/acidanthera/BrcmPatchRAM/releases/download/2.6.4/BrcmPatchRAM-2.6.4-RELEASE.zip" "RELEASE" "acidanthera-BrcmPatchRAM.zip"
download_github "https://github.com/acidanthera/CPUFriend/releases/download/1.2.6/CPUFriend-1.2.6-RELEASE.zip" "RELEASE" "acidanthera-CPUFriend.zip"
download_github "https://github.com/acidanthera/CpuTscSync/releases/download/1.0.9/CpuTscSync-1.0.9-RELEASE.zip" "RELEASE" "acidanthera-CpuTscSync.zip"
download_github "https://github.com/acidanthera/HibernationFixup/releases/download/1.4.6/HibernationFixup-1.4.6-RELEASE.zip" "RELEASE" "acidanthera-HibernationFixup.zip"
download_github "https://github.com/acidanthera/VirtualSMC/releases/download/1.3.0/VirtualSMC-1.3.0-RELEASE.zip" "RELEASE" "acidanthera-VirtualSMC.zip"
download_github "https://github.com/acidanthera/VoodooPS2/releases/download/v2.3.1/VoodooPS2Controller-2.3.1-RELEASE.zip" "RELEASE" "acidanthera-VoodooPS2.zip"
download_github "https://github.com/acidanthera/WhateverGreen/releases/download/1.6.1/WhateverGreen-1.6.1-RELEASE.zip" "RELEASE" "acidanthera-WhateverGreen.zip"
download_github "https://github.com/hieplpvip/AsusSMC/releases/download/1.4.1/AsusSMC-1.4.1-RELEASE.zip" "RELEASE" "hieplpvip-AsusSMC.zip"
#download_github "https://github.com/hieplpvip/AppleBacklightSmoother/releases/download/1.0.2/AppleBacklightSmoother-1.0.2-RELEASE.zip" "RELEASE" "hieplpvip-AppleBacklightSmoother.zip"
download_github "https://github.com/VoodooI2C/VoodooI2C/releases/download/2.7/VoodooI2C-2.7.zip" "VoodooI2C-" "VoodooI2C-VoodooI2C.zip"
cd ..

# download drivers
mkdir ./drivers && cd ./drivers
download_raw https://github.com/acidanthera/OcBinaryData/raw/master/Drivers/HfsPlus.efi HfsPlus.efi
cd ..


KEXTS="AppleALC|AppleBacklightSmoother|AsusSMC|BrcmPatchRAM3|BrcmFirmwareData|BlueToolFixup|WhateverGreen|CPUFriend|CPUFriendDataProvider|Lilu|VirtualSMC|SMCBatteryManager|SMCProcessor|VoodooI2C.kext|VoodooI2CHID.kext|VoodooPS2Controller|CpuTscSync|AirportBrcmFixup|HibernationFixup"

function check_directory
{
    for x in $1; do
        if [ -e "$x" ]; then
            return 1
        else
            return 0
        fi
    done
}



function unzip_kext
{
    out=${1/.zip/}
    rm -Rf $out/* && unzip -q -d $out $1
    check_directory $out/Release/*.kext
    if [ $? -ne 0 ]; then
        for kext in $out/Release/*.kext; do
            kextname="`basename $kext`"
            if [[ "`echo $kextname | grep -w -E $KEXTS`" != "" ]]; then
                cp -R $kext ../kexts
            fi
        done
    fi
    check_directory $out/*.kext
    if [ $? -ne 0 ]; then
        for kext in $out/*.kext; do
            kextname="`basename $kext`"
            if [[ "`echo $kextname | grep -w -E $KEXTS`" != "" ]]; then
                cp -R $kext ../kexts
            fi
        done
    fi
    check_directory $out/Kexts/*.kext
    if [ $? -ne 0 ]; then
        for kext in $out/Kexts/*.kext; do
            kextname="`basename $kext`"
            if [[ "`echo $kextname | grep -w -E $KEXTS`" != "" ]]; then
                cp -R $kext ../kexts
            fi
        done
    fi
}

mkdir ./kexts

check_directory ./zips/*.zip
if [ $? -ne 0 ]; then
    echo Unzipping kexts...
    cd ./zips
    for kext in *.zip; do
        unzip_kext $kext
    done

    cd ..
fi

cd ..
