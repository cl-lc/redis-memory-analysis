#!/usr/bin/env bash

REDIS_CLI_CMD='redis-cli'
REDIS_HOST='127.0.0.1'
REDIS_PORT=9725
REDIS_PASSWD='passwd'

REDIS_LOGIN_CMD="${REDIS_CLI_CMD} -h ${REDIS_HOST} -p ${REDIS_PORT} -a ${REDIS_PASSWD}"
OUTPUT_KEYS_FILE="__rds__keys"
OUTPUT_ANALYSIS_FILE="__rds__analysis.csv"
OUTPUT_FILE="__rds__output.csv"

function export_keys() {
	`${REDIS_LOGIN_CMD} keys '*' > ${OUTPUT_KEYS_FILE}` 
}

function analysis_key() {
	key=$1
	value_size=`${REDIS_LOGIN_CMD} debug object ${key} | grep -Po "serializedlength\:[0-9]*" | cut -d ":" -f2`
	idle_time=`${REDIS_LOGIN_CMD} object idletime ${key}`
	echo "${key},${value_size},${idle_time}" >> ${OUTPUT_ANALYSIS_FILE}
}

function clean() {
	rm ${OUTPUT_KEYS_FILE}
	rm ${OUTPUT_ANALYSIS_FILE}
}

clean

# export all keys
export_keys

# analysis key
for key in `cat ${OUTPUT_KEYS_FILE}`
do
	analysis_key ${key}
done

echo "key,size,idletime" >> ${OUTPUT_FILE}
# `-k 3` means sort by idletime, desc
# `-k 2` means sort by memory size, desc
sort -nr -k 3 -t , ${OUTPUT_ANALYSIS_FILE} -o ${OUTPUT_FILE}

clean
