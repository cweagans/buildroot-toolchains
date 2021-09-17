#!/bin/bash

echo "--> Looking up www.buildroot.org in the certificate transparency log:"

# Get the cert info.
echo "--> Possible certificates for www.buildroot.org"
info=$(curl --silent "https://transparencyreport.google.com/transparencyreport/api/v3/httpsreport/ct/certsearch?include_subdomains=true&domain=www.buildroot.org" | tail -n +3 | jq -c '[.[] | .[] | .. | arrays | select(.[1] == "buildroot.org")]' |  jq -c '[.[] | {issued: (.[3]), expires: (.[4]), hash: (.[5])} ]')
echo $info | jq

echo
echo "--> Filtered certificates (issued before now and expires after now):"
info=$(echo $info | jq -c '[.[] | select(.issued < (now * 1000 | trunc) and (now * 1000 | trunc) < .expires)]')
echo $info | jq

echo
echo "--> Looking up the currently active cert serial on www.buildroot.org"
activeserial=$(echo | openssl s_client -showcerts -servername www.buildroot.org -connect www.buildroot.org:443 2>/dev/null | openssl x509 -inform pem -noout -serial | cut -c 8- | sed "s/^0//")
echo "--> Active cert serial: ${activeserial}"

hashes=$(echo $info | jq -r '.[].hash')
found=false
for h in $hashes; do
    echo "--> Looking up certificate identified by ${h}"
    certinfo=$(curl --silent "https://transparencyreport.google.com/transparencyreport/api/v3/httpsreport/ct/certbyhash?hash=${h}" | tail -n +3 | jq -r '.[][1][0]' | sed "s/\://g")
    echo "--> Certificate identified by ${h} has serial: ${certinfo}"

    if [ "$certinfo" == "$activeserial" ]; then
        echo
        echo " ✅ Certificate found: ${activeserial} matches cert identified by ${h}"
        exit 0
    fi
done

echo
echo " ❌ No matching certificates found. Something bad might be happening."
exit 1
