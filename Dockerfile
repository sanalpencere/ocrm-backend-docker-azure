FROM ubuntu:16.04
MAINTAINER ovidos

RUN apt-get -qq update
RUN apt-get -qq -y install curl
RUN apt-get -qq -y install sudo
RUN apt-get -qq -y install wget

RUN curl --silent --location https://deb.nodesource.com/setup_6.x | sudo bash -
RUN apt-get install --yes nodejs
RUN apt-get install --yes build-essential


RUN apt install -y build-essential git cmake pkg-config \ 
libbz2-dev libstxxl-dev libstxxl1v5 libxml2-dev \ 
libzip-dev libboost-all-dev lua5.2 liblua5.2-dev libtbb-dev

COPY init_container.sh /bin/


RUN  npm install -g pm2 \
     && mkdir /pm2home     \
     && chmod 777 /pm2home \
     && rm -rf /pm2home/logs \
     && ln -s /home/LogFiles /pm2home/logs \
     && echo "root:Docker!" | chpasswd \
     && apt update \
     && apt install -y --no-install-recommends openssh-server \
     && chmod 755 /bin/init_container.sh 

COPY sshd_config /etc/ssh/

EXPOSE 2222

CMD ["/bin/init_container.sh"]

RUN git clone https://github.com/Project-OSRM/osrm-backend.git && cd osrm-backend && ls && echo "GIT ENT"
RUN cd osrm-backend && ls && mkdir -p build && \
cd build && \
cmake .. && \
cmake --build . && \
cmake --build . --target install

RUN cd /usr/local/share/osrm/ && wget http://download.geofabrik.de/europe/turkey-latest.osm.pbf && \
osrm-extract turkey-latest.osm.pbf -p profiles/car.lua && \
osrm-contract turkey-latest.osrm &&

EXPOSE 5000

ENTRYPOINT cd /usr/local/share/osrm/ && osrm-routed turkey-latest.osrm &

