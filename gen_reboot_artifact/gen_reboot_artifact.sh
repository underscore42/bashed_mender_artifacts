#! /bin/bash
#
# Generate a mender artifact the uses the reboot module
#
# Usage:
# ./gen_reboot_artifact.sh basedir device
# ./gen_reboot_artifact.sh $"$(pwd)" "blueprint"
#
#

base_dir=($1)
target_device=($2)

cd $base_dir
mkdir -p ./mender/data/0000
mkdir -p ./mender/headers/0000
echo -ne '{"format":"mender","version":3}' >> mender/version
cd mender/data/0000
tar -zcvf 0000.tar.gz --files-from /dev/null
mv 0000.tar.gz ../.
cd ../..
echo -ne '{"payloads":[{"type":"reboot"}],"artifact_provides":{"artifact_name":"reboot-blueprint.artifact"},"artifact_depends":{"device_type":["blueprint"]}}' >> header-info
echo -ne '{"type":"reboot","artifact_provides":{"rootfs-image.reboot.version":"reboot-blueprint.artifact"},"clears_artifact_provides":["rootfs-image.reboot.*"]}' >> headers/0000/type-info
tar -zcvf header.tar.gz header-info headers/0000/type-info

echo $(sha256sum header.tar.gz) >> manifest_prime
echo $(sha256sum version) >> manifest_prime
# mender artifacts need 2 spaces between hash and filename
sed 's/ /  /g' manifest_prime > manifest

tar -cvf reboot.mender version manifest header.tar.gz data/0000.tar.gz
mv reboot.mender ../.
cd ..
rm -rf ./mender
