#!/usr/bin/bash

readonly red='\e[1;31m'
readonly green='\e[1;32m'
readonly yellow='\e[1;33m'
readonly blue='\e[1;34m'
readonly magenta='\e[1;35m'
readonly bold='\e[1;37m'
readonly reset='\e[0;37m'

readonly frequencyTresholdLow=1200;
readonly frequencyTresholdMedium=1800;
readonly frequencyTresholdHigh=2500;

readonly tempTresholdLow=42;
readonly tempTresholdMedium=50;
readonly tempTresholdHigh=65;

readonly fanTresholdLow=2700;
readonly fanTresholdMedium=3200;
#readonly fanTresholdHigh=0;

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
