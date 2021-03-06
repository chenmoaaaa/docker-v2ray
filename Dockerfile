FROM alpine

ENV V2RAY_VERSION=3.9

RUN GPG_KEYS=8B0C5E32536032F79A3DCED9E1AFA550C7D3C49A \
    && apk --no-cache add ca-certificates \
    && apk --no-cache add --virtual .build-deps \
        curl \
        gnupg \
        unzip \
    && curl -fSL https://github.com/v2ray/v2ray-core/releases/download/v${V2RAY_VERSION}/v2ray-linux-64.zip -o v2ray.zip \
    && unzip v2ray.zip \
    && rm v2ray.zip \
    && cd v2ray-v${V2RAY_VERSION}-linux-64 \
    && found=''; \
    for server in \
        pgp.mit.edu \
    ; do \
        echo "Fetching GPG key $GPG_KEYS from $server"; \
        gpg --keyserver "$server" --keyserver-options timeout=10 --recv-keys "$GPG_KEYS" && found=yes && break; \
    done; \
    test -z "$found" && echo >&2 "error: failed to fetch GPG key $GPG_KEYS" && exit 1; \
    gpg --batch --verify v2ctl.sig v2ctl \
    && ./v2ctl verify v2ray \
    && mv v2ray v2ctl geoip.dat geosite.dat /usr/local/bin \
    && cd .. \
    && rm -r v2ray-v${V2RAY_VERSION}-linux-64 \
    && apk del .build-deps \
    && mkdir /var/log/v2ray

COPY config.json /etc/v2ray/

RUN v2ray -test -config=/etc/v2ray/config.json

EXPOSE 10086

CMD ["v2ray", "-config=/etc/v2ray/config.json"]
