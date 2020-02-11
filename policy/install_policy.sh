#!/bin/sh
VERS="29"
if [ -f "policy.$VERS" ] ; then
rm policy.$VERS
rm policy.conf
fi

echo Copy shell script to targeted directory
cp -rf ./common/build_conf.sh ./targeted_$1/build_conf.sh
cp -rf ./common/replace_policy.sh ./targeted_$1/replace_policy.sh

echo Going to build policy
cd targeted_$1
sh build_conf.sh
echo Going to replace policy
sh replace_policy.sh

if [ ! -f "policy.$VERS" ]; then
exit 1
fi

echo Going to install policy
cd ../../
if [ ! -d config ]; then
mkdir -p config
fi
cd config

mkdir -p dummy/policy
mkdir -p dummy/contexts/files

cp ../policy/file_contexts dummy/contexts/files
cp ../policy/dbus_contexts dummy/contexts
cp ../policy/policy.$VERS dummy/policy
cp ../policy/policy.$VERS dummy/policy/policy

if [ ! -f config ]; then
	cat > config << EOF
SELINUX=permissive
SELINUXTYPE=dummy
EOF
fi
