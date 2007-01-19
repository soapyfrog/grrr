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

$ErrorActionPreference="Stop"

# load modules
. ..\..\lib\grrr.ps1

[int]$script:pfwidth = 256
[int]$script:pfheight = 130

init-console 256 130
write-host "big space invaders demo - using original graphics!!"

#------------------------------------------------------------------------------
# Create the invader sprites
# Returns a tuple of the shared direction controller object and the 
# sprite array
#
function create-invadersprites($images) {
  $sprites = @()
  # handlers for motion
  $controller = @{current="R"; next="R"} # shared controller for all sprites
  $init = {
    $args[0].controller = $controller
    $args[0].tagged = $false # only the tagged invader moves
  }
  $move = { 
    $s=$args[0]
    $dx = 1
    $dy = 6
    $d = $s.controller
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
  return $controller,$sprites
}


#------------------------------------------------------------------------------
# create base ship sprite
#
function create-basesprite {
  param($images)
  $handlers = create-spritehandlers -didinit {
    $s=$args[0]
    $s.x = 30; $s.y=100
    $s.dx = 0
  } -willdraw {
    $s=$args[0]
    $s.x += $s.dx
  }
  $base = create-sprite -images $images.base -handlers $handlers
  return $base
}


#------------------------------------------------------------------------------
# demo starts here
#
function main {
  # create a plafield to put it all on
  $pf = create-playfield -x 0 -y 2 -width 256 -height 128 -bg "black"

  # load the alien images from the file
  $images = get-images "images.txt"
  # create an alien hoard (well, a small gathering) 
  $aliens_controller,$aliens = create-invadersprites $images
  # create a base ship
  $base = create-basesprite $images


  while ($true) {
    clear-playfield $pf
    draw-sprites $pf $aliens
    $aliens_controller.current = $aliens_controller.next
    draw-sprite $pf $base
    draw-string $pf "$duhidx  $duh   " 0 0
    flush-playfield $pf -sync 40
  }
}

# off we go
main

