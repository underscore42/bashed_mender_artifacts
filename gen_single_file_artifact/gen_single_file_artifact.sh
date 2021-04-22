#! /bin/bash
#
# Generate a single file mender artifact
#
# Usage:
# ./gen_artifact.sh basedir target_dir_on_device hostName buildVersion
# ./gen_artifact.sh $"$(pwd)" "/tmp" "blueprint" "0001"
#
#

base_dir=($1)
destination_on_target=($2)
hostName=($3)
buildVersion=($4)

source_file=($hostName-$buildVersion.tar)

cd $base_dir
mkdir -p ./mender/data/0000
mkdir -p ./mender/headers/0000
echo -ne '{"format":"mender","version":3}' >> mender/version
cp $base_dir/$source_file mender/data/0000/.
cd mender/data/0000
####cp $(Build.ArtifactStagingDirectory)/$(hostName)-$(buildVersion).tar $(Build.ArtifactStagingDirectory)/mender/data/0000/
echo -ne $destination_on_target >> dest_dir 
echo -ne "$source_file" >> filename
echo -ne "644" >> permissions
tar -zcvf 0000.tar.gz filename permissions dest_dir $source_file
mv 0000.tar.gz ../.
cd ../..
echo -ne '{"payloads":[{"type":"single-file"}],"artifact_provides":{"artifact_name":"'$buildVersion'"},"artifact_depends":{"device_type":["blueprint"]}}' >> header-info
echo -ne '{"type":"single-file"}' >> headers/0000/type-info
tar -zcvf header.tar.gz header-info headers/0000/type-info

echo $(sha256sum data/0000/dest_dir) >> manifest_prime
echo $(sha256sum data/0000/filename) >> manifest_prime
echo $(sha256sum data/0000/permissions) >> manifest_prime
echo $(sha256sum data/0000/$source_file) >> manifest_prime
echo $(sha256sum header.tar.gz) >> manifest_prime
echo $(sha256sum version) >> manifest_prime
# mender artifacts need 2 spaces between hash and filename
sed 's/ /  /g' manifest_prime > manifest

tar -cvf $buildVersion.mender version manifest header.tar.gz data/0000.tar.gz
mv $buildVersion.mender ../.
cd ..
rm -rf ./mender
