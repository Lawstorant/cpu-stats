#!/usr/bin/bash

readonly clearOnExit=1
outputBuffer="output goes here" #prevents flickering
windowCols=0
windowLines=0

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
