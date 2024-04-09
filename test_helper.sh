# Helper for run-unit-tests and integration-tests/*.

# Abort on first error.
set -e
# Do not overwrite files.
set -C
# Complain on unset varibles
set -u
# Useful when debugging tests (but autopkgtests should not write to stderr).

fake_changelog () {
    echo 'foo (1.0-1) unstable; urgency=low

  * Initial release. (Closes: #XXXXXX)

 -- Test <testing@nowhere>  Mon, 11 Jul 2016 18:10:59 +0200'
}

fake_control_header () {
    build_depends="$1"
    echo "Source: foo
Section: misc
Priority: optional
Maintainer: Test <testing@nowhere>
Standards-Version: 4.6.2
Rules-Requires-Root: no
Build-Depends: debhelper-compat (= 13), $build_depends"
}

fake_control_package () {
    package=$1
    architecture=$2
    built_using="$3"
    echo "
Package: $package
Architecture: $architecture
Depends: \${misc:Depends}
Built-Using: $built_using
Description: bla
 Bla."
}

re_verinfo=' (= [0-9A-Za-z.+:~-]\+)'

complain () {
    test $# = 1

    echo "FAIL: $1" 1>&2
    exit 1
}

# Use $3 = "foo$re_verinfo, bar" for multiple values.
# $4 is either unset or 'static'
check_substvar () {
    test $# = 3 -o $# = 4
    file=debian/$1.substvars
    key="dh-${4:-}builtusing:$2"
    value="$3$re_verinfo"

    test -r $file \
        || complain "$file should exist"
    grep -q "^$key=" $file \
        || complain "$file should define $key"
    grep -q "^$key=$value\$" $file \
        || complain "$key in $file should match $value, got: $(grep "^$key=" $file)"
    echo "  $file defines $key"
}

check_substvars_absent () {
    test 2 -le $#
    file=debian/$1.substvars
    shift

    if test -e $file; then
        for arg; do
            key="dh-builtusing:$arg"
            grep -q "^$key=" $file \
                && complain "$file should not define $key, got: $(grep "^$key=" $file)"
            echo "  $file does not define $key"
        done
    else
        echo "  $file is absent, hence does not define $@"
    fi
}

check_control () {
    test $# = 2
    file=debian/$1/DEBIAN/control
    value="$2$re_verinfo"

    test -r $file \
        || complain "$file should exist"
    grep -q "^Built-Using:" $file \
        || complain "$file should contain a Built-Using field"
    grep -q "^Built-Using:.* $value" $file \
         || complain "$key in $file should match $value, got: $(grep "^dh-builtusing:" $file)"
    echo "  Built-Using field in $file contains $value"
}
