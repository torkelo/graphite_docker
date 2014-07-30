import os

listen_host = '0.0.0.0'  # defaults to "all interfaces"
listen_port = 8081
opsreport_start = '01/01/2013 12:00:00 AM'
timezone = "UTC"
es_url = 'http://' + os.environ['ES_PORT_9200_TCP_ADDR'] + ':9200'
es_index = 'anthracite'

recommended_tags = [
]

from model import Attribute

extra_attributes = [
]
helptext = {
}

plugins = []
