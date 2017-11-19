FROM alpine:3.6

ENV V2RAY_VERSION=2.50

RUN set -ex \
    && apk --no-cache add ca-certificates \
    && apk --no-cache add --virtual .build-deps \
        curl \
        unzip \
    && curl -fSL https://github.com/v2ray/v2ray-core/releases/download/v${V2RAY_VERSION}/v2ray-linux-64.zip -o v2ray.zip \
    && [ $(sha1sum v2ray.zip | awk '{ print $1 }') '==' "e6a2f720ab8daa18d711cbba17a1486e71c11e7e" ] && echo "Valid." \
    && unzip v2ray.zip \
    && rm v2ray.zip \
    && cd v2ray-v${V2RAY_VERSION}-linux-64 \
    ./v2ctl verify v2ray \
    && mv v2ray v2ctl geoip.dat geosite.dat /usr/local/bin \
    && cd .. \
    && rm -r v2ray-v${V2RAY_VERSION}-linux-64 \
    && apk del .build-deps \
    && mkdir /var/log/v2ray

COPY config.json /etc/v2ray/

RUN v2ray -test -config=/etc/v2ray/config.json

EXPOSE 10086

CMD ["v2ray", "-config=/etc/v2ray/config.json"]
