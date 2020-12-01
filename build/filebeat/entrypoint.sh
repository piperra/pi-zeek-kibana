#!/bin/bash

for i in {1..60}
do
  health=$(curl --silent "http://elasticsearch:9200/_cat/health" | awk '{print $4}')
  if [[ "$health" == "green" ]] || [[ "$health" == "yellow" ]]
  then
    echo "Elasticsearch ready"
    break
  fi
    echo "Waiting elasticsearch..."
  sleep 1
done

for i in {1..60}
do
  status=$(curl --silent -XGET "http://kibana:5601/api/status" | jq -r '.status.overall.state')
  if [[ "$status" == "green" ]]
  then
    echo "Kibana ready"
    break
  fi
    echo "Waiting kibana..."
  sleep 1
done

./filebeat setup --modules zeek -e -E 'setup.dashboards.enabled=true'
./filebeat -e
