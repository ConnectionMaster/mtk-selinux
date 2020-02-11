#!/bin/bash
if [ -f "policy.29" ];
then
cp policy.29 ../policy.29
cp ../common/file_contexts ../file_contexts
cp policy.conf ../policy.conf
fi
