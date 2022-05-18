#!/bin/bash
MINER_HEIGHT=$(curl -d '{"jsonrpc":"2.0","id":"id","method":"block_height","params":[]}' -s -o - http://localhost:4467/ | jq .result.height)
echo "Miner Height ${MINER_HEIGHT}"
SNAP_HEIGHT=$(curl -s https://snapshots-wtf.sensecapmx.cloud/latest-snap.json | jq .height)
 echo "Snapshot height ${SNAP_HEIGHT}"
if [ "${MINER_HEIGHT}" -lt "${SNAP_HEIGHT}" ] ; then
        echo "Downloading snapshot ${SNAP_HEIGHT}"
        docker exec miner wget https://snapshots-wtf.sensecapmx.cloud/snap-${SNAP_HEIGHT} -O /var/data/snap/snap-${SNAP_HEIGHT}.scratch
		echo "Pausing Sync"
        docker exec miner miner repair sync_pause
		echo "Canceling Sync"
        docker exec miner miner repair sync_cancel
        docker exec miner mv /var/data/snap/snap-${SNAP_HEIGHT}.scratch /var/data/snap/snap-${SNAP_HEIGHT}
		echo "Loading Snapshot ${SNAP_HEIGHT} You will see timeout error but its OK"
        docker exec miner miner snapshot load /var/data/snap/snap-${SNAP_HEIGHT}
        sleep 5
		echo "Resuming Sync You will see timeout error but its OK"
        docker exec miner miner repair sync_resume
		echo "Done! Now just wait"
else
        echo "Current miner height of ${MINER_HEIGHT} greater than the latest snapshot at ${SNAP_HEIGHT}"
        exit 1
fi
