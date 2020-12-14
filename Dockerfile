# and do "docker build ." to create image

FROM ubuntu:latest
MAINTAINER swc <tinybrace@swc.toshiba.co.jp>

EXPOSE 4813
ENV http_proxy http://proxy-jp.toshiba.co.jp:8080
ENV https_proxy http://proxy-jp.toshiba.co.jp:8080
RUN mkdir -p /tmp/ddsfw
RUN apt-get update

#libreadline-dev zlib1g-dev can be skipped if postgres is built without these
# libsqlite3-dev sqlite3 libmysqlclient20 
RUN apt-get -y install make apt-utils libedit2 libreadline-dev zlib1g-dev 
#RUN ln -s /usr/lib/x86_64-linux-gnu/libmysqlclient.so.20 /usr/lib/x86_64-linux-gnu/libmysqlclient.so
RUN useradd -m swc -d /home/swc -s /bin/bash

USER swc
WORKDIR /home/swc
RUN mkdir -p /home/swc/pgsql
COPY ./ /home/swc/pgsql/
ENV PATH ${PATH}:/home/swc/pgsql/bin

ENV LD_LIBRARY_PATH /home/swc/pgsql/lib
RUN (cd ~; /home/swc/pgsql/bin/initdb -D db -E utf8)
RUN (pg_ctl -D /home/swc/db start && sleep 5 &&\
psql --command "ALTER USER swc WITH PASSWORD 'swc';" postgres && \
pg_ctl -D /home/swc/db stop)

# if docker build --squash is available.
# USER root
# RUN rm -fr /tmp/ddsfw

USER swc
ENV PATH ${PATH}:/home/swc/pgsql/bin
ENV PGDATA /home/swc/db



RUN echo "export PATH=${PATH}:/home/swc/pgsql/bin" > ~/.bashrc
RUN echo "host all all 0.0.0.0/0 md5" >> /home/swc/db/pg_hba.conf
RUN echo "listen_addresses='*'" >> /home/swc/db/postgresql.conf

CMD ["postgres"]

