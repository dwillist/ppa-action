#!/usr/bin/env bash

set -e
set -o pipefail

readonly PROG_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
readonly PACK_DIR="$(cd "${PROG_DIR}/../../.." && pwd)"

function main() {

    import_gpg

    TEMP_DIR="$(mktemp -d)"
    #Version used here (should come from env)
    WORK_DIR="$TEMP_DIR/test-package" #TODO: change test_package to pack-cli
    mkdir -p $WORK_DIR
    #TODO: is there an artifact we can pull here?
    rsync -av --progress "$PACK_DIR"/* $WORK_DIR --exclude .git
    pushd $PACK_DIR
    #TODO change test_package to pack-cli
    #TODO: change email to be an env var
    DEBEMAIL="thorntondwt@gmail.com"
    DEBFULLNAME="thorntondwt"
    echo "creating package: test-package_$VERSION"
    dh_make -p "test-package_$VERSION" --single --native --copyright mit --email thorntondwt@gmail.com -y

    # package edits
    rm debian/*.ex
    rm debian/*.EX
    #TODO: Change release name to be dynamic
    RELEASE_NAME="xenial"
    perl -i -pe "s/unstable/$RELEASE_NAME/" debian/changelog

    perl -i -pe 's/^(Section:).*/$1 utils/' debian/control

    # allow URI customization here
    perl -i -pe 's/^(Homepage:).*/$1 https:\/\/github.com\/dwillist/' debian/control
    perl -i -pe 's/^#(Vcs-Browser:).*/$1 https:\/\/github.com\/dwillist\/ppa-action/' debian/control
    perl -i -pe 's/^#(Vcs-Git:).*/$1 https:\/\/github.com\/dwillist\/ppa-action.git/' debian/control

    # allow input to configure descriptions
    perl -i -pe 's/^(Description:).*/$1 A ppa creation script to run in a github action/' debian/control
    perl -i -pe $'s/^ <insert long description.*/ A ppa creation script,\n cool!/' debian/control

    # should be configurable
    #perl -i -pe 's/^(Standards-Version:) 3.9.6/$1 3.9.7/' debian/control

    # changelog and control updates
    perl -i -pe 's/^(Maintainer:) unknown/$1 thorntondwt/' debian/control
    perl -i -pe "s/^ -- unknown/ -- thorntondwt/" debian/changelog

    debuild -S

    dput ppa:thorntondwt/testppa ../*.changes
    popd
    
}

function import_gpg() {
    gpg --import <(echo "$GPG_PUBLIC_KEY")
    gpg --allow-secret-key-import --import <(echo "$GPG_PRIVATE_KEY")
}

main
