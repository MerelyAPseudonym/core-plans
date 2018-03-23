pkg_name=mysql57-seeded
pkg_origin=signafire_josh_spike-01
pkg_version=0.1
pkg_maintainer='Josh <josh+habspike@signafire.com>'
#pkg_license=('GPL-2.0')
#pkg_source=http://dev.mysql.com/get/Downloads/MySQL-5.7/${pkg_name}-${pkg_version}.tar.gz
#pkg_shasum=cebf23e858aee11e354c57d30de7a079754bdc2ef85eb684782458332a4b9651
#pkg_upstream_url=https://www.mysql.com/
#pkg_description
pkg_deps=(
  #core/coreutils
  #core/gawk
  #core/gcc-libs
  #core/glibc
  #core/grep
  #core/inetutils
  #core/ncurses
  #core/openssl
  #core/pcre
  #core/perl
  #core/procps-ng
  #core/sed
  core/mysql
)
pkg_build_deps=(
  #core/bison
  #core/boost159
  #core/cmake
  #core/diffutils
  #core/gcc
  #core/make
  #core/patch
)
pkg_svc_user="hab"
pkg_bin_dirs=(bin)
pkg_include_dirs=(include)
pkg_lib_dirs=(lib)

pkg_exports=(
  [port]=port
  [password]=app_password
  [username]=app_username
)

do_build() {
  cmake . -DLOCAL_BOOST_DIR="$(pkg_path_for core/boost159)" \
          -DBOOST_INCLUDE_DIR="$(pkg_path_for core/boost159)/include" \
          -DWITH_BOOST="$(pkg_path_for core/boost159)" \
          -DCURSES_INCLUDE_PATH="$(pkg_path_for core/ncurses)/include" \
          -DCURSES_LIBRARY="$(pkg_path_for core/ncurses)/lib/libcurses.so" \
          -DWITH_SSL=yes \
          -DOPENSSL_INCLUDE_DIR="$(pkg_path_for core/openssl)/include" \
          -DOPENSSL_LIBRARY="$(pkg_path_for core/openssl)/lib/libssl.so" \
          -DCRYPTO_LIBRARY="$(pkg_path_for core/openssl)/lib/libcrypto.so" \
          -DCMAKE_INSTALL_PREFIX="$pkg_prefix" \
          -DWITH_EMBEDDED_SERVER=no \
          -DWITH_EMBEDDED_SHARED_LIBRARY=no
  make
}

do_install() {
  do_default_install

  # Remove static libraries, tests, and other things we don't need
  rm -rf "$pkg_prefix/docs" "$pkg_prefix/man" "$pkg_prefix/mysql-test" \
    "$pkg_prefix"/lib/*.a

  fix_interpreter "$pkg_prefix/bin/mysqld_multi" core/perl bin/perl
  fix_interpreter "$pkg_prefix/bin/mysqldumpslow" core/perl bin/perl
}

do_check() {
  ctest
}