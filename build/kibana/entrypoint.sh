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

kibana --allow-root
