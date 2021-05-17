FROM postgres:13.2-alpine

COPY . /opt/message-db
COPY docker-init-message-db.sh /docker-entrypoint-initdb.d/init-message-db.sh

# Install uuidgen
RUN apk update && apk add util-linux
