FROM alpine:3.8

LABEL maintainer="Sebastian Ramirez <tiangolo@gmail.com>"

# Versions of Nginx and nginx-rtmp-module to use
ENV NGINX_VERSION nginx-1.15.8
ENV NGINX_RTMP_MODULE_VERSION 1.2.1

# Install dependencies
RUN apk update && \
    apk add openssl ca-certificates pcre gettext && \
    rm -rf /var/lib/apt/lists/*

# Download and decompress Nginx
RUN mkdir -p /tmp/build/nginx && \
    cd /tmp/build/nginx && \
    wget -O ${NGINX_VERSION}.tar.gz https://nginx.org/download/${NGINX_VERSION}.tar.gz && \
    tar -zxf ${NGINX_VERSION}.tar.gz

# Download and decompress RTMP module
RUN mkdir -p /tmp/build/nginx-rtmp-module && \
    cd /tmp/build/nginx-rtmp-module && \
    wget -O nginx-rtmp-module-${NGINX_RTMP_MODULE_VERSION}.tar.gz https://github.com/arut/nginx-rtmp-module/archive/v${NGINX_RTMP_MODULE_VERSION}.tar.gz && \
    tar -zxf nginx-rtmp-module-${NGINX_RTMP_MODULE_VERSION}.tar.gz && \
    cd nginx-rtmp-module-${NGINX_RTMP_MODULE_VERSION}

# Build and install Nginx
# The default puts everything under /usr/local/nginx, so it's needed to change
# it explicitly. Not just for order but to have it in the PATH
RUN apk add --virtual .build-dependencies \
        gcc binutils build-base \
        libgcc make pkgconf pkgconfig \
        openssl-dev musl-dev \
        libc-dev pcre-dev zlib-dev && \
    cd /tmp/build/nginx/${NGINX_VERSION} && \
    ./configure \
        --sbin-path=/usr/local/sbin/nginx \
        --conf-path=/etc/nginx/nginx.conf \
        --error-log-path=/var/log/nginx/error.log \
        --pid-path=/var/run/nginx/nginx.pid \
        --lock-path=/var/lock/nginx/nginx.lock \
        --http-log-path=/var/log/nginx/access.log \
        --http-client-body-temp-path=/tmp/nginx-client-body \
        --with-http_ssl_module \
        --with-threads \
        --with-ipv6 \
        --add-module=/tmp/build/nginx-rtmp-module/nginx-rtmp-module-${NGINX_RTMP_MODULE_VERSION} && \
    make -j $(getconf _NPROCESSORS_ONLN) && \
    make install && \
    mkdir /var/lock/nginx && \
    rm -rf /tmp/build && \
    apk del .build-dependencies

# Forward logs to Docker
RUN ln -sf /dev/stdout /var/log/nginx/access.log && \
    ln -sf /dev/stderr /var/log/nginx/error.log

# Download latest ffmpeg x64 release binary
RUN mkdir -p /tmp/build/ffmpeg && \
    cd /tmp/build/ffmpeg && \
    wget https://johnvansickle.com/ffmpeg/releases/ffmpeg-release-amd64-static.tar.xz && \
    tar xf ffmpeg-release-amd64-static.tar.xz && \
    cd $(ls) && \
    cp ffmpeg /usr/bin/ && \
    cp ffprobe /usr/bin/ && \
    rm -rf https://johnvansickle.com/ffmpeg/releases/ffmpeg-release-amd64-static.tar.xz && \
    rm -rf ffmpeg-release-amd64-static.tar.xz

# Set up config template
COPY nginx.conf.template /etc/nginx/nginx.conf.template

# Script for replacing env variables on container startup
COPY docker-entrypoint.sh /
ENTRYPOINT ["/docker-entrypoint.sh"]

EXPOSE 1935
CMD ["nginx", "-g", "daemon off;"]
