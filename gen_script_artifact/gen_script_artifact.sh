#! /bin/bash
#
# Generate a mender v3 script artifact, will run the script as root
#
# Usage:
# ./gen_script_artifact.sh basedir script version
# ./gen_script_artifact.sh $"$(pwd)" "/tmp" "a_script.sh" "0.1.1.1"
#
#

base_dir=($1)
scriptName=($3)
buildVersion=($4)

source_file=($scriptName)

cd $base_dir
mkdir -p ./mender/data/0000
mkdir -p ./mender/headers/0000
echo -ne '{"format":"mender","version":3}' >> mender/version
cp $base_dir/$source_file mender/data/0000/.
cd mender/data/0000
tar -zcvf 0000.tar.gz $source_file
mv 0000.tar.gz ../.
cd ../..
echo -ne '{"payloads":[{"type":"script"}],"artifact_provides":{"artifact_name":"'$buildVersion'-'$scriptName'"},"artifact_depends":{"device_type":["blueprint"]}}' >> header-info
echo -ne '{"type":"script","artifact_provides":{"rootfs-image.script.version":"'$buildVersion'-'$scriptName'"},"clears_artifact_provides":["rootfs-image.script.*"]}' >> headers/0000/type-info
tar -zcvf header.tar.gz header-info headers/0000/type-info

echo $(sha256sum data/0000/$source_file) >> manifest_prime
echo $(sha256sum header.tar.gz) >> manifest_prime
echo $(sha256sum version) >> manifest_prime
# mender artifacts need 2 spaces between hash and filename
sed 's/ /  /g' manifest_prime > manifest

tar -cvf $scriptName.mender version manifest header.tar.gz data/0000.tar.gz
mv $scriptName.mender ../.
cd ..
rm -rf ./mender
