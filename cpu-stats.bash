#!/usr/bin/bash

# TODO: config file
# TODO: optional setup wizard
# TODO: first run setup question
# COMBAK: check threads order and arrange them by their core bond
# IDEA: split this into multiple files

#global variables-------------------------------------------------

readonly sleepTime='.5s'
readonly clearOnExit=1
readonly arrangeThreadsByCPUBond=1

readonly cpuThreads=$(cat /proc/cpuinfo\
        | grep processor\
        | wc -l)
readonly cpuCores=$(cat /proc/cpuinfo\
        | grep "cpu cores"\
        | awk 'FNR==1{print $4}')
readonly fans=$(sensors\
        | grep fan\
        | wc -l)

readonly frequencyTresholdLow=1200;
readonly frequencyTresholdMedium=1800;
readonly frequencyTresholdHigh=2500;

readonly tempTresholdLow=42;
readonly tempTresholdMedium=50;
readonly tempTresholdHigh=65;

readonly fanTresholdLow=2700;
readonly fanTresholdMedium=3200;
#readonly fanTresholdHigh=0;


#helper variables----------------------------------------------------

readonly red='\e[1;31m'
readonly green='\e[1;32m'
readonly yellow='\e[1;33m'
readonly blue='\e[1;34m'
readonly magenta='\e[1;35m'
readonly bold='\e[1;37m'
readonly reset='\e[0;37m'

outputBuffer="output goes here" #prevents flickering
windowCols=0
windowLines=0

#functions-----------------------------------------------------------

function getThreadFreq() {
	local freq
    freq=$(cat /sys/devices/system/cpu/cpu$1/cpufreq/scaling_cur_freq)
    freq=$(( freq / 1000 ))
    echo $freq
}

getCoreBond() {
    echo $(cat /sys/devices/system/cpu/cpu$1/topology/core_id)
}

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

function getFanSpeed(){
    local fanSpeed
    fanSpeed=$(sensors | grep fan1 | awk '{print $2}')
    echo $fanSpeed
}

function assignColor() {
    if [[ $1 == "freq" ]]; then
        if [[ $2 -le $frequencyTresholdLow ]]; then
            echo "$blue$2$reset"
        elif [[ $2 -le $frequencyTresholdMedium ]]; then
            echo "$green$2$reset"
        elif [[ $2 -le $frequencyTresholdHigh ]]; then
            echo "$yellow$2$reset"
        else
            echo "$red$2$reset"
        fi

    elif [[ $1 == "temp" ]]; then
        if [[ $2 -le $tempTresholdLow ]]; then
            echo "$blue$2$reset"
        elif [[ $2 -le $tempTresholdMedium ]]; then
            echo "$green$2$reset"
        elif [[ $2 -le $tempTresholdHigh ]]; then
            echo "$yellow$2$reset"
        else
            echo "$red$2$reset"
        fi

    elif [[ $1 == "fan" ]]; then
        if [[ $2 -eq 0 ]]; then
            echo "${blue}off${reset}"
        elif [[ $2 -le $fanTresholdLow ]]; then
            echo "$green$2$reset"
        elif [[ $2 -le $fanTresholdMedium ]]; then
            echo "$yellow$2$reset"
        else
            echo "$red$2$reset"
        fi
    fi
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

function printCpuTemps() {
    echo "${bold}Temperatures:${reset}"
    for (( i = 0; i < $1; i++ )); do
        echo "Core $magenta$i$reset: $(assignColor temp $(getCoreTemp $i))°C "
    done
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

clearBuffer() {
    outputBuffer=""
}

addToBuffer() {
    outputBuffer="${outputBuffer}$1"
}

displayBuffer(){
    printf "${outputBuffer}\n"
}

detectWindowSizeChange() {
    local newCols
    local newLines
    local f1

    newCols=$(tput cols)
    newLines=$(tput lines)
    f1=0

    if [[ newCols -ne windowCols ]]; then
        windowCols=$newCols
        f1=1
    fi
    if [[ newLines -ne windowLines ]]; then
        windowLines=$newLines
        f1=1
    fi

    if [[ f1 -eq 1 ]]; then
        clear
    fi
}

moveCursorTo00() {
    #moves cursor to the X:0,Y:0 of the console
    #prevents flickering caused by using "clear"
    printf '\033[;H'
}

hideCursor() {
    printf '\e[?25l'
}

unhideCursor() {
    printf '\e[?25h'
    if [[ clearOnExit -eq 1 ]]; then
        clear
    fi
}

#main body----------------------------------------------------------

main() {
    trap unhideCursor EXIT
    hideCursor

    while true; do
        detectWindowSizeChange

        clearBuffer
        addToBuffer "$(printCpuSpeeds $cpuThreads)\n\n"
        addToBuffer "$(printCpuTemps $cpuCores)\n\n"
        addToBuffer "$(printFanSpeeds $fans)"
        moveCursorTo00
        displayBuffer
        sleep $sleepTime
    done
}

main
