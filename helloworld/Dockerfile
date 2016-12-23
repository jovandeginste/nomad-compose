FROM alpine
MAINTAINER Jo Vandeginste "jo.vandeginste@gmail.com"

EXPOSE 80
CMD /bin/sh -c '/bin/sed -i "s/$/@$HOSTNAME/" /index.html; /caddy'

COPY /caddy /Caddyfile /
ARG VERSION=unknown
RUN echo "Hello, world! I am ${VERSION}." > /index.html
