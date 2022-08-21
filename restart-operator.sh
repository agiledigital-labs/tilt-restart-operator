#!/bin/bash
set -euo pipefail
IFS=$'\n\t'

dependency=$1
dependee=$2

function wait_for_restart() {
    mostRecentLastUpTime="";
    tilt get uiresource --watch -o name | while read -r name; do
        short=${name#uiresource.tilt.dev/}
        if [ "$short" == "$dependency" ]; then
            status=$(tilt get uiresource -o jsonpath='{$.status.runtimeStatus}' "${short}")
            if [ "$status" == "ok" ]; then
                lastUpTime=$(tilt get uiresource -o jsonpath='{$.status.lastDeployTime}' "${short}")
                if [ "$lastUpTime" == "$mostRecentLastUpTime" ]; then
                    echo "Dependency [${short}] is now [${status}], but hasn't been redeployed. No action."
                else
                    echo "Dependency [${short}] is now [${status}], triggering [${dependee}]."
                    mostRecentLastUpTime=${lastUpTime}
                    tilt trigger "${dependee}"
                fi  
            else 
                echo "Dependency [${short}] is now [${status}]. No action."
            fi
        fi
    done
}

wait_for_restart