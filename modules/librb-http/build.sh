#!/bin/bash

source build_common.sh

COMMIT=${COMMIT:="b5dc6128058c53b9be0f8244db143cd34cfb32fe"}
VERSION=${VERSION:="1.2.0"}
PACKNAME=${PACKNAME:="librb-http"}
CACHEDIR=${CACHEDIR:="/tmp/sdk7_cache/custom_rpms"}
REPODIR=${REPODIR:="/tmp/sdk7_repo"}
VSHORT=$(c=${COMMIT}; echo ${c:0:7})

# First we need to download source
mkdir SOURCES
wget --no-check-certificate https://gitlab.redborder.lan/core-developers/${PACKNAME}/repository/archive.tar.gz?ref=${VERSION} --header='PRIVATE-TOKEN:oDRezN5gFLgBB6nWsMZU' -O SOURCES/${PACKNAME}-${VERSION}-${VSHORT}.tar.gz

# Now it is time to create the source rpm
/usr/bin/mock -r sdk7 --resultdir=pkgs --buildsrpm --spec=${PACKNAME}.spec --sources=SOURCES

# with it, we can create rest of packages
/usr/bin/mock -r sdk7 --resultdir=pkgs --rebuild pkgs/${PACKNAME}*.src.rpm

# cleaning
rm -rf SOURCES

# sync to cache and repo
rsync -a pkgs/${PACKNAME}*.el7.centos.x86_64.rpm ${CACHEDIR}
rsync -a pkgs/${PACKNAME}*.rpm ${REPODIR}
rm -rf pkgs

# Update sdk7 repo
f_updaterepo ${REPODIR}

