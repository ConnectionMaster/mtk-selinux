#!/bin/bash

output_file=$(pwd)/mtk-selinux.tgz

die() { code=$1; shift; echo $*; exit $code; }

# compile policy
#---------------
mypath=$(realpath $(dirname $0))
cd $mypath
pushd ../policy >/dev/null

#add rules for su only in debug mode
cp -f ./common/su.template ./su.te
if [ "$REMOVE_SU" != "true" ] ; then
  echo "domain_auto_trans(semi_root_process,su_exec, su);" >> ./su.te
fi

m4 -s \
./targeted_linux-4.19/security_classes \
./common/initial_sids \
./targeted_linux-4.19/access_vectors \
./common/global_macros \
./common/te_macros \
./common/attributes \
./common/*.te \
./su.te \
./targeted_linux-4.19/*.te \
./common/roles \
./common/users \
./common/initial_sid_contexts \
./common/fs_use \
./common/genfs_contexts \
> ./my-policy.conf \
    || die 1 "m4 failed; can't gen policy.conf"

popd >/dev/null

checkpolicy -c 29 -o my-policy ../policy/my-policy.conf \
    || die 1 "checkpolicy failed; can't compile policy"

# stage policy
#-------------
rm -rf ./stage

mkdir -p ./stage/etc/selinux/dummy/contexts/files
cp ../policy/common/file_contexts ./stage/etc/selinux/dummy/contexts/files

mkdir -p ./stage/etc/selinux/dummy/policy
cp my-policy ./stage/etc/selinux/dummy/policy/policy
cp my-policy ./stage/etc/selinux/dummy/policy/policy.29

# create firmware package files
#------------------------------
mkdir -p ./stage/policy
cp ../policy/common/file_contexts ./stage/policy
grep /application ./stage/policy/file_contexts \
    | grep -v /cast_root \
    | sed 's,(s)?,,' \
    | sed 's,/application(/.*)?,/application/.*,' \
    > ./stage/policy/app_ext4_contexts
sed 's,/application,,g' ./stage/policy/app_ext4_contexts \
    > ./stage/policy/app_squash_contexts
echo "/        user_u:object_r:application_file" \
    >> ./stage/policy/app_squash_contexts

# create tarball
#---------------
tar czf $output_file -C ./stage . || die 1 "Can't create tgz"
echo ">>> Created $(basename $output_file)"
