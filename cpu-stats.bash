#!/usr/bin/bash

# TODO: config file
# TODO: optional setup wizard
# TODO: first run setup question
# QUESTION: was it a good idea to split this into multiple files?

#sources-----------------------------------------------------------

. libs/colors.bash
. libs/screen-and-buffer.bash
. libs/cpu-speeds.bash
. libs/core-temps.bash
. libs/fan-speeds.bash

#main body---------------------------------------------------------

main() {
    local sleepTime='.5s'
    local cpuThreads
    local cpuCores
    local fans

    cpuThreads=$(cat /proc/cpuinfo\
            | grep processor\
            | wc -l)
    cpuCores=$(cat /proc/cpuinfo\
            | grep "cpu cores"\
            | awk 'FNR==1{print $4}')
    fans=$(sensors\
            | grep fan\
            | wc -l)

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
