#------------------------------------------------------------------------------
# Copyright 2006 Adrian Milliner (adrian dot milliner at soapyfrog dot com)
#
# This work is licenced under the Creative Commons 
# Attribution-NonCommercial-ShareAlike 2.5 License. 
# To view a copy of this licence, visit 
# http://creativecommons.org/licenses/by-nc-sa/2.5/ 
# or send a letter to 
# Creative Commons, 559 Nathan Abbott Way, Stanford, California 94305, USA.
#------------------------------------------------------------------------------

# $Id$

# demo1 for grrr.ps1
# run this as a script - do not 'source' it with '.'

$global:___globcheck___=1
$local:___globcheck___=2
if ($global:___globcheck___ -eq 2) {throw "This should not be sourced in global scope"}


# load modules
. .\grrr.ps1

init-console 80 50


function main {
  $pf = create-playfield -x 0 -y 0 -width 80 -height 50 -bg "black"

  $pi = [Math]::Pi
  $pd2 = $pi/2
  $twopi = 2*$pi

  $secsRadius = 36

  while ($true) {
    clear-playfield $pf
    $n = get-date

    $secsAngle = $twopi * ($n.Seconds / 60) - $pd2
    $secsX = $secsRadius * [Math]::Cos($secsAngle)
    $secsY = $secsRadius * [Math]::Sin($secsAngle)

    draw-line $pf 40 25 (40+$secsX) (25+$secsY) "yellow" "black"
    flush-playfield $pf
    sleep -millis 500
  }
}

main

