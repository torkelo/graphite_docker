#! /bin/bash

# this script is just to automate some stuff for play.grafana.org

cp	./graphite/local_settings.py /opt/graphite/webapp/graphite/local_settings.py
cp	./graphite/carbon.conf /opt/graphite/conf/carbon.conf
cp	./graphite/storage-schemas.conf /opt/graphite/conf/storage-schemas.conf

cp -f ./dashboards/*.json /src/root/app/dashboards