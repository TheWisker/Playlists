#!/bin/bash
#Hosts all the colors declarations

#Declares fg, bg and sp as associative arrays
declare -A fg
declare -A bg
declare -A sp

#Foreground color names to escape codes
fg[black]=30
fg[red]=31
fg[green]=32
fg[yellow]=33
fg[blue]=34
fg[purple]=35
fg[cyan]=36
fg[gray]=90
fg[white]=97

#Background color names to escape codes
bg[black]=40
bg[red]=41
bg[green]=42
bg[yellow]=43
bg[blue]=44
bg[purple]=45
bg[cyan]=46
bg[gray]=100
bg[white]=107

#Special names to escape codes
sp[reset]=0
sp[bold]=1
sp[dim]=2
sp[italic]=3
sp[underlined]=4