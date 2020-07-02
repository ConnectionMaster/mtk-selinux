#!/bin/bash
###############################################################################
#
###############################################################################
me=$(basename $0)
mypath=$(realpath $(dirname $0))

oldstuffdir=release/apollo/linux_core/rootfs/common/sepolicy/policy
newstuffdir=$mypath/../policy

#------------------------------------------------------------------------------
# functions
#------------------------------------------------------------------------------
usage()
{
  echo "
Usage: $me SDK_tarball [--skip-untar]
"
  exit 1
}

die()
{
  exit_code=$1
  shift
  echo $*
  exit $exit_code
}

#==============================================================================
# start of execution
#==============================================================================
test -n "$1" || usage
test -r "$1" || usage
sdk=$(realpath $1)

do_tar=true
if [ -n "$2" ]; then
  test "$2" != "--skip-untar" && usage
  do_tar=false
fi

sdk_name=$(basename $sdk .tar.xz)
patch_name="[Vizio ODM Patch][5691][VIZO][$sdk_name].patch"
patchtgz_name="[Vizio ODM Patch][5691][VIZO][$sdk_name].tgz"
#echo "== Creating $patch_name"

# don't overwrite pre-existing ./old, ./new
test -d ./new && die 3 "./new already exists. Exiting."

if $do_tar; then
  # extract Apollo SELinux to ./old
  test -d ./old && die 2 "./old already exists. Exiting."
  echo "== Extracting old files from $sdk"
  mkdir ./old
  tar xf $sdk -C ./old $oldstuffdir \
    || die 4 "Unable to extract $oldstuffdir from $sdk"
fi
pushd ./old/$oldstuffdir >/dev/null
keep_list=$(ls)
popd >/dev/null

# copy new stuff to ./new
echo "== Copying new files from $newstuffdir"
mkdir -p ./new/$oldstuffdir
for item in $keep_list; do
  cp -R $newstuffdir/$item ./new/$oldstuffdir \
    || die 5 "Unable to copy $newstuffdir/$item to ./new"
done

# clean up

# create patch
echo "== Generating patch"
diff -ruN old/ new/ > "$patch_name"
echo "== Created $patch_name"

# create tgz
tar czf "$patchtgz_name" $(grep ^diff "$patch_name" | sed 's/diff -ruN//g')
echo "== Created $patchtgz_name"
