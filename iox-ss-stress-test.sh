#!/bin/sh

CAF_SS_ENV_FILE="/data/.env"
if [ -f $CAF_SS_ENV_FILE ]; then
  source $CAF_SS_ENV_FILE
fi

LOGF=""
if [[ ! -z ${CAF_APP_LOG_DIR} ]]; then
  LOGF=${CAF_APP_LOG_DIR}"/"
fi
LOGF=${LOGF}"secure_storage_stress_test.log"

echo "Starting..." > ${LOGF}

while true

do

# get token (verified)
echo "Getting the TOKEN from SSS service using http://$CAF_SS_IP_ADDR:$CAF_SS_PORT/SS/TOKEN/$CAF_APP_ID/$CAF_SYSTEM_UUID..." >> ${LOGF}
export CAF_SS_TOKEN=`curl  --silent "http://$CAF_SS_IP_ADDR:$CAF_SS_PORT/SS/TOKEN/$CAF_APP_ID/$CAF_SYSTEM_UUID"` >> ${LOGF}
echo "Got it: $CAF_SS_TOKEN" >> ${LOGF}

# store secure object (verified)
echo "Storing an object in SS..." >> ${LOGF}
curl -X POST "http://$CAF_SS_IP_ADDR:$CAF_SS_PORT/SS/$CAF_APP_ID/Object" -H "content-type: multipart/form-data" -F "ss-Token=$CAF_SS_TOKEN" -F "Object-type=Object" -F "object-Name=testKey" -F "ss-Content=testKeyContent" >> ${LOGF}
echo "Storing done." >> ${LOGF}

# get key content (verified)
echo "Getting the object from SS..." >> ${LOGF}
curl -X GET "http://$CAF_SS_IP_ADDR:$CAF_SS_PORT/SS/$CAF_APP_ID/Object?ss-Token=$CAF_SS_TOKEN&object-name=testKey" >> ${LOGF}
echo "done" >> ${LOGF}

# get list of SS object stored
echo "List of objects in SS:" >> ${LOGF}
curl -X GET "http://$CAF_SS_IP_ADDR:$CAF_SS_PORT/SS/$CAF_APP_ID/list?ss-Token=$CAF_SS_TOKEN" >> ${LOGF}
echo "[end]" >> ${LOGF}

# delete object
echo "Deleting object in SS..." >> ${LOGF}
curl -X DELETE "http://$CAF_SS_IP_ADDR:$CAF_SS_PORT/SS/$CAF_APP_ID/Object?ss-Token=$CAF_SS_TOKEN&object-name=testKey" >> ${LOGF}
echo "Delete done." >> ${LOGF}

sleep 5

done
