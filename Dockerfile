FROM alpine:3.6

ENV V2RAY_VERSION=2.50

RUN set -ex \
    && sed -i 's/dl-cdn.alpinelinux.org/mirrors.ustc.edu.cn/g' /etc/apk/repositories \
    && apk --no-cache add ca-certificates \
    && apk --no-cache add --virtual .build-deps \
        curl \
        unzip \
    && curl -fS https://static.bohan.co/downloads/v2/v${V2RAY_VERSION}/v2-linux-64.zip -o v2ray.zip \
    && [ $(sha1sum v2ray.zip) == "03a6acc4d4d612a3c3de0d12b56a30bcb76a314d" ] && echo "Valid." \
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
