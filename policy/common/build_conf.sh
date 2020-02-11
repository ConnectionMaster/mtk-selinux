#!/bin/bash
if [ -f "policy.29" ] ; then
rm policy.29
rm policy.conf
fi
#add rules for su only in debug mode
cp -f ../common/su.template ../common/su.te
if [ "$REMOVE_SU" != "true" ] ; then
echo "domain_auto_trans(semi_root_process,su_exec, su);" >> ../common/su.te
fi

m4 -D target_build_variant=user \
     -s security_classes ../common/initial_sids access_vectors ../common/global_macros \
        ../common/te_macros ../common/attributes\
        ../common/*.te *.te ../common/roles ../common/users ../common/initial_sid_contexts \
        ../common/fs_use ../common/genfs_contexts > policy.conf

checkpolicy -c 29 -o policy.29 policy.conf 2>policy_error.txt
cp -rf ./policy_error.txt ../policy_error.txt

