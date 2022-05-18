#!/bin/bash
SNAP_HEIGHT=$(wget -q https://snapshots-wtf.sensecapmx.cloud/latest-snap.json -O - | grep -Po '\"height\":[0-9]*' | sed 's/\"height\"://')
 echo "Snapshot height ${SNAP_HEIGHT}"
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
