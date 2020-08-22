ARG IMG_BASE=node:12.10.0-alpine
FROM ${IMG_BASE}


RUN sed -i "s/dl-cdn.alpinelinux.org/mirrors.cloud.tencent.com/g" /etc/apk/repositories \
 && apk update \
 && apk add --no-cache bash tzdata nginx\
 && cp -r -f /usr/share/zoneinfo/Asia/Shanghai /etc/localtime \
 && mkdir -p /run/nginx

WORKDIR /src
COPY public /src/public
RUN mv /src/docker/default.conf /etc/nginx/conf.d \
 && chmod +x /src/docker/docker-entrypoint.sh \
 && mkdir -p /src/public
   
ENTRYPOINT ["/src/docker/docker-entrypoint.sh"]
EXPOSE 1313


