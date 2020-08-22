ARG IMG_BASE=node:12.10.0-alpine
FROM ${IMG_BASE}


RUN apk update \
 && apk add --no-cache bash tzdata nginx\
 && cp -r -f /usr/share/zoneinfo/Asia/Shanghai /etc/localtime \
 && mkdir -p /run/nginx

WORKDIR /src
COPY public /src/public
COPY docker /docker
RUN mv /docker/default.conf /etc/nginx/conf.d \
 && chmod +x /docker/docker-entrypoint.sh \
 && mkdir -p /src/public
   
ENTRYPOINT ["/docker/docker-entrypoint.sh"]
EXPOSE 1313


