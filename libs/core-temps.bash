#!/usr/bin/bash

function getCoreTemp() {
    local temp
    temp=$(sensors | grep "Core $1" | awk '{print $3}')

    local dot
    dot=${temp:3:1}
    if [[ $dot == '.' ]]; then
        echo ${temp:1:2}
    else
        echo ${temp:1:3}
    fi
}

function printCpuTemps() {
    echo "${bold}Temperatures:${reset}"
    for (( i = 0; i < $1; i++ )); do
        echo "Core $magenta$i$reset: $(assignColor temp $(getCoreTemp $i))°C "
    done
}
