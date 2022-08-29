#!/bin/bash
set -euo pipefail
IFS=$'\n\t'

dependee=$1
shift 1
dependencies=("${@}")

echo "[${dependee}] depends upon: "
for dependency in "${dependencies[@]}"; do
   echo "  [$dependency]"
done

function all_ok() {
    for dependency in "${dependencies[@]}"; do
        echo "Checking [$dependency] status..."
        status=$(tilt get uiresource -o jsonpath='{$.status.runtimeStatus}' "${dependency}")
        echo "Dependency [${dependency}] is now [${status}]."
        if [ "$status" != "ok" ]; then
            echo "Dependency [${dependency}] is now [${status}]. No action."
            return 1;
        fi
    done
    echo "Dependencies are now all 'ok'."
    return 0;
}

function last_up_time() {
    mostRecentUpTime=""
    for dependency in "${dependencies[@]}"; do
        lastUpTime=$(tilt get uiresource -o jsonpath='{$.status.lastDeployTime}' "${dependency}")
        if [ "$lastUpTime" \> "$mostRecentUpTime" ]; then
            mostRecentUpTime=$lastUpTime
        fi
    done
    echo "$mostRecentUpTime"
}

function wait_for_restart() {
    mostRecentLastUpTime="";
    tilt get uiresource --watch -o name | while read -r name; do
        short=${name#uiresource.tilt.dev/}
        for dependency in "${dependencies[@]}"; do
            if [ "$short" == "$dependency" ]; then
                status=$(tilt get uiresource -o jsonpath='{$.status.runtimeStatus}' "${short}")

                if all_ok; then
                    lastUpTime=$(last_up_time)
                    echo "Last up time [${lastUpTime}], most recent up time [${mostRecentLastUpTime}]."
                    if [ "$lastUpTime" == "$mostRecentLastUpTime" ]; then
                        echo "Dependency [${short}] is now [${status}], but hasn't been redeployed. No action."
                    else
                        echo "Dependency [${short}] is now [${status}], triggering [${dependee}]."
                        mostRecentLastUpTime=${lastUpTime}
                        tilt trigger "${dependee}"
                    fi
                fi
            fi
        done
    done
}

wait_for_restart
