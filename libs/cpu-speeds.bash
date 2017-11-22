#!/usr/bin/bash

readonly arrangeThreadsByCPUBond=0

function getThreadFreq() {
    local freq
    freq=$(cat /sys/devices/system/cpu/cpu$1/cpufreq/scaling_cur_freq)
    freq=$(( freq / 1000 ))
    echo $freq
}

getCoreBond() {
    echo $(cat /sys/devices/system/cpu/cpu$1/topology/core_id)
}

function printCpuSpeeds(){
    echo "${bold}Thread speeds:${reset}"
    local speed
    local core
    local coreBond
    core=0


    # TODO: Clean this mess up somehow. Low priority though :(
    if [[ arrangeThreadsByCPUBond -eq 1 ]]; then
        while [[ core -le cpuCores ]]; do
            for (( i = 0; i < $1; i++ )); do
                coreBond=$(getCoreBond $i)
                if [[ coreBond -eq core ]]; then
                    speed=$(getThreadFreq $i)
                    if [[ $speed -lt 1000 ]]; then
                        echo "Thread $magenta$i$reset: $(assignColor freq $speed)  MHz "
                    else
                        echo "Thread $magenta$i$reset: $(assignColor freq $speed) MHz  "
                    fi
                fi
            done
            echo ""
            core=$(($core+1))
        done
    else
        for (( i = 0; i < $1; i++ )); do
            speed=$(getThreadFreq $i)
            if [[ $speed -lt 1000 ]]; then
                echo "Thread $magenta$i$reset: $(assignColor freq $speed)  MHz "
            else
                echo "Thread $magenta$i$reset: $(assignColor freq $speed) MHz  "
            fi
        done
    fi
}
