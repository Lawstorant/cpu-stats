#!/usr/bin/bash

function getFanSpeed(){
    local fanSpeed
    fanSpeed=$(sensors | grep fan1 | awk '{print $2}')
    echo $fanSpeed
}

function printFanSpeeds() {
    echo "${bold}Fan speeds:${reset}"
    local speed
    for (( i = 1; i <= $1; i++ )); do
        speed=$(getFanSpeed $i)
        if [[ $speed -ne "off" ]]; then
            echo "Fan $magenta$i$reset: $(assignColor fan $speed) RPM "
        else
            echo "Fan $magenta$i$reset: $(assignColor fan $speed)     "
        fi
    done
}
