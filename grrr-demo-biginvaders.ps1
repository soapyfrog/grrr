#------------------------------------------------------------------------------
# Copyright 2006 Adrian Milliner (ps1 at soapyfrog dot com)
# http://ps1.soapyfrog.com
#
# This work is licenced under the Creative Commons 
# Attribution-NonCommercial-ShareAlike 2.5 License. 
# To view a copy of this licence, visit 
# http://creativecommons.org/licenses/by-nc-sa/2.5/ 
# or send a letter to 
# Creative Commons, 559 Nathan Abbott Way, Stanford, California 94305, USA.
#------------------------------------------------------------------------------

# $Id$

# demo for grrr.ps1
# run this as a script - do not 'source' it with '.'

$global:___globcheck___=1
$local:___globcheck___=2
if ($global:___globcheck___ -eq 2) {throw "This should not be sourced in global scope"}


# load modules
. .\grrr.ps1

init-console 256 130
write-host "big space invaders demo - using original graphics!!"

#------------------------------------------------------------------------------
# Create the invader sprites
# Returns a tuple of the direction object and the sprite array
#
function create-invadersprites($images) {
  $sprites = @()
  # handlers for motion
  $dir = @{current="R"; next="R"} # shared state for all sprites
  $init = {
    $args[0].dir = $dir
  }
  $move = { 
    $s=$args[0]
    $dx = 1
    $dy = 6
    $d = $s.dir
    switch ($d.current) {
      "R" {
        $s.x+=$dx
        if ($s.x -gt 200) { $d.next="DL" }
      }
      "L" {
        $s.x-=$dx
        if ($s.x -lt 10) { $d.next="DR" }
      }
      "DL" {
        $s.y+=$dy
        $d.next="L"
      }
      "DR" {
        $s.y+=$dy
        $d.next="R"
      }
    }
  }
  $handlers = create-spritehandlers -didinit $init -willdraw $move
  $y = 5
  $xo = 2
  "inva","invb","invc" | foreach {
    $i = $_
    for ($x=0; $x -lt 5; $x++) {
      $ip = $images["$i"+"0"],$images["$i"+"1"]
      $s = create-sprite -images $ip -x ($xo+10+20*$x) -y $y -handlers $handlers
      $sprites += $s
    }
    $xo -= 1
    $y += 13
  }
  return $dir,$sprites
}

function main {
  $images = get-images "grrr-demo-biginvaders-images.txt"
  $dir,$sprites = create-invadersprites $images

  # now create a field of aliens
  $pf = create-playfield -x 0 -y 2 -width 256 -height 128 -bg "black"

  while ($true) {
    clear-playfield $pf
    draw-sprites $pf $sprites
    $dir.current = $dir.next
    flush-playfield $pf -sync 40
  }
}

# off we go
main

