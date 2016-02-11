from	ubuntu:14.04

run	echo 'deb http://us.archive.ubuntu.com/ubuntu/ precise universe' >> /etc/apt/sources.list
run	apt-get -y update

run apt-get -y install software-properties-common

run	apt-get -y install python-software-properties &&\
	add-apt-repository ppa:chris-lea/node.js &&\
	apt-get -y update

run     apt-get -y install  python-django-tagging python-simplejson python-memcache \
			    python-ldap python-cairo python-django python-twisted   \
			    python-pysqlite2 python-support python-pip gunicorn     \
			    supervisor nginx-light nodejs git wget curl

# Elastic Search

# fake fuse
run  apt-get install libfuse2 &&\
     cd /tmp ; apt-get download fuse &&\
     cd /tmp ; dpkg-deb -x fuse_* . &&\
     cd /tmp ; dpkg-deb -e fuse_* &&\
     cd /tmp ; rm fuse_*.deb &&\
     cd /tmp ; echo -en '#!/bin/bash\nexit 0\n' > DEBIAN/postinst &&\
     cd /tmp ; dpkg-deb -b . /fuse.deb &&\
     cd /tmp ; dpkg -i /fuse.deb

# Install statsd
run	mkdir /src && git clone https://github.com/etsy/statsd.git /src/statsd

run cd /usr/local/src && git clone https://github.com/graphite-project/graphite-web.git
run cd /usr/local/src && git clone https://github.com/graphite-project/carbon.git
run cd /usr/local/src && git clone https://github.com/graphite-project/whisper.git

run cd /usr/local/src/whisper && git checkout master && python setup.py install
run cd /usr/local/src/carbon && git checkout 0.9.13-pre1 && python setup.py install
run cd /usr/local/src/graphite-web && git checkout 0.9.13-pre1 && python check-dependencies.py; python setup.py install

# statsd
add	./statsd/config.js /src/statsd/config.js

# Add graphite config
add	./graphite/initial_data.json /opt/graphite/webapp/graphite/initial_data.json
add	./graphite/local_settings.py /opt/graphite/webapp/graphite/local_settings.py
add	./graphite/carbon.conf /opt/graphite/conf/carbon.conf
add	./graphite/storage-schemas.conf /opt/graphite/conf/storage-schemas.conf
add	./graphite/storage-aggregation.conf /opt/graphite/conf/storage-aggregation.conf
add     ./graphite/events_views.py /opt/graphite/webapp/graphite/events/views.py

run	mkdir -p /opt/graphite/storage/whisper
run	touch /opt/graphite/storage/graphite.db /opt/graphite/storage/index
run	chown -R www-data /opt/graphite/storage
run	chmod 0775 /opt/graphite/storage /opt/graphite/storage/whisper
run	chmod 0664 /opt/graphite/storage/graphite.db
run	cd /opt/graphite/webapp/graphite && python manage.py syncdb --noinput

# grafana
run echo "deb https://packagecloud.io/grafana/stable/debian/ wheezy main" >> /etc/apt/sources.list
run apt-get install apt-transport-https
run curl https://packagecloud.io/gpg.key | sudo apt-key add -
run apt-get update && apt-get install grafana && apt-get install sqlite3
# startup the grafana server so that it makes the initial database
run timeout 1 /usr/sbin/grafana-server -homepath /usr/share/grafana || true
run sqlite3 /usr/share/grafana/data/grafana.db "insert into data_source (org_id,version,type,name,access,url,basic_auth,is_default,json_data,created,updated,with_credentials) values (1,0,'graphite','graphite','proxy','http://localhost',0,1,'{}',DateTime('now'),DateTime('now'),0)"

# fake data generator
add ./fake-data-gen /src/fake-data-gen
run cd /src/fake-data-gen && npm install

# Add system service config
add	./nginx/nginx.conf /etc/nginx/nginx.conf
add	./supervisord.conf /etc/supervisor/conf.d/supervisord.conf
# Nginx
#
# graphite
expose	80
# grafana
expose  81

# Carbon line receiver port
expose	2003
# Carbon cache query port
expose	7002

# Statsd UDP port
expose	8125/udp
# Statsd Management port
expose	8126

VOLUME ["/opt/graphite/storage/whisper"]
VOLUME ["/var/lib/log/supervisor"]

cmd	["/usr/bin/supervisord"]
# vim:ts=8:noet:
