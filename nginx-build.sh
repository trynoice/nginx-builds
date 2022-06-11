#!/usr/bin/env bash

set -euxo pipefail

# #### NGINX Builscript ####
#
# Requires wget, gcc, strip, make, libpcre3-dev, libssl-dev and libghc-zlib-dev.
#
# Usage: ./nginx-build.sh ABSOLUTE_OUTPUT_BINARY_PATH
# Example: ./nginx-build.sh /usr/local/sbin/nginx


NGINX_VERSION=1.22.0
NGX_DEVEL_KIT_VERSION=0.3.1
NGX_SET_MISC_MOD_VERSION=0.33
NGX_HEADERS_MORE_MOD_VERSION=0.33

NGINX_SRC_URL=http://nginx.org/download/nginx-${NGINX_VERSION}.tar.gz
NGX_DEVEL_KIT_SRC_URL=https://github.com/vision5/ngx_devel_kit/archive/refs/tags/v${NGX_DEVEL_KIT_VERSION}.tar.gz
NGX_SET_MISC_MOD_SRC_URL=https://github.com/openresty/set-misc-nginx-module/archive/refs/tags/v${NGX_SET_MISC_MOD_VERSION}.tar.gz
NGX_HEADERS_MORE_MOD_SRC_URL=https://github.com/openresty/headers-more-nginx-module/archive/refs/tags/v${NGX_HEADERS_MORE_MOD_VERSION}.tar.gz

if [ -z "$1" ]; then
  echo "missing required argument: absolute path of the output binary"
  exit 1
fi

OUTPUT_BIN="$1"

# download NGINX source.
wget -O nginx.tar.gz ${NGINX_SRC_URL}
tar zxf nginx.tar.gz
rm -f nginx.tar.gz

# download NGINX development kit module source.
wget -O ngx_devel_kit.tar.gz ${NGX_DEVEL_KIT_SRC_URL}
tar zxf ngx_devel_kit.tar.gz
rm -f ngx_devel_kit.tar.gz

# download nginx set misc module source.
wget -O set-misc-nginx-module.tar.gz ${NGX_SET_MISC_MOD_SRC_URL}
tar zxf set-misc-nginx-module.tar.gz
rm -f set-misc-nginx-module.tar.gz

# download headers more module source.
wget -O headers-more-nginx-module.tar.gz ${NGX_HEADERS_MORE_MOD_SRC_URL}
tar zxf headers-more-nginx-module.tar.gz
rm -f headers-more-nginx-module.tar.gz

cd nginx-${NGINX_VERSION} || exit 1
./configure \
  --prefix=/etc/nginx \
  --sbin-path="${OUTPUT_BIN}" \
  --conf-path=/etc/nginx/nginx.conf \
  --http-log-path=/var/log/nginx/access.log \
  --error-log-path=/var/log/nginx/error.log \
  --http-client-body-temp-path=/tmp/nginx-client-body-temp \
  --http-proxy-temp-path=/tmp/nginx-proxy-temp \
  --with-http_ssl_module \
  --with-http_gzip_static_module \
  --with-http_auth_request_module \
  --without-mail_pop3_module \
  --without-mail_imap_module \
  --without-mail_smtp_module \
  --add-module=../ngx_devel_kit-${NGX_DEVEL_KIT_VERSION} \
  --add-module=../set-misc-nginx-module-${NGX_SET_MISC_MOD_VERSION} \
  --add-module=../headers-more-nginx-module-${NGX_HEADERS_MORE_MOD_VERSION}

make -j"$(nproc)"
make install -j"$(nproc)"
strip "${OUTPUT_BIN}"
