#!/usr/bin/env bash

# Elasticsearch Endpoint
ES_URL="http://localhost:9200"

# Filter keyword (set to empty string "" if you want to inspect all indices)
FILTER="logs"

echo "=================================================="
echo "          ELASTICSEARCH CLUSTER REPORT            "
echo "=================================================="

# 1. Elasticsearch Cluster Status
echo -e "\n--- 1. CLUSTER HEALTH ---"
curl -s -X GET "${ES_URL}/_cluster/health?pretty"

# 2. Indices Breakdown
echo -e "\n--- 2. INDICES METRICS (Filtered by '${FILTER}') ---"

# Total indices matching filter
TOTAL_INDICES=$(curl -s -X GET "${ES_URL}/_cat/indices?h=index" | grep "${FILTER}" | wc -l)
echo "Total Indices: ${TOTAL_INDICES}"

# Index Health Counts
GREEN_COUNT=$(curl -s -X GET "${ES_URL}/_cat/indices?h=health,index" | grep "${FILTER}" | grep -w "green" | wc -l)
YELLOW_COUNT=$(curl -s -X GET "${ES_URL}/_cat/indices?h=health,index" | grep "${FILTER}" | grep -w "yellow" | wc -l)
RED_COUNT=$(curl -s -X GET "${ES_URL}/_cat/indices?h=health,index" | grep "${FILTER}" | grep -w "red" | wc -l)

echo "Health Status -> Green: ${GREEN_COUNT} | Yellow: ${YELLOW_COUNT} | Red: ${RED_COUNT}"

# Index State Counts
OPEN_COUNT=$(curl -s -X GET "${ES_URL}/_cat/indices?h=status,index" | grep "${FILTER}" | grep -w "open" | wc -l)
CLOSE_COUNT=$(curl -s -X GET "${ES_URL}/_cat/indices?h=status,index" | grep "${FILTER}" | grep -w "close" | wc -l)

echo "Index State   -> Open: ${OPEN_COUNT} | Closed: ${CLOSE_COUNT}"

# 3. Number of Shards Breakdown
echo -e "\n--- 3. SHARD STATUS (Filtered by '${FILTER}') ---"
curl -s -X GET "${ES_URL}/_cat/shards?h=index,state" | grep "${FILTER}" | awk '{print $2}' | sort | uniq -c | awk '{printf "  %-12s : %s\n", $2, $1}'

# 4. Replica Count
echo -e "\n--- 4. REPLICA COUNT (Sample) ---"
REPLICA_INFO=$(curl -s -X GET "${ES_URL}/_cat/indices?h=rep,index" | grep "${FILTER}" | head -n 1)

if [ -n "${REPLICA_INFO}" ]; then
  REPLICAS=$(echo "${REPLICA_INFO}" | awk '{print $1}')
  INDEX_NAME=$(echo "${REPLICA_INFO}" | awk '{print $2}')
  echo "Replicas per index: ${REPLICAS} (Sample Index: ${INDEX_NAME})"
else
  echo "No indices found matching '${FILTER}'."
fi

echo -e "\n=================================================="
