#------------------------------------------------------------------------------
# Copyright 2006-2007 Adrian Milliner (ps1 at soapyfrog dot com)
# http://ps1.soapyfrog.com
#
# This work is licenced under the Creative Commons 
# Attribution-NonCommercial-ShareAlike 2.5 License. 
# To view a copy of this licence, visit 
# http://creativecommons.org/licenses/by-nc-sa/2.5/ 
# or send a letter to 
# Creative Commons, 559 Nathan Abbott Way, Stanford, California 94305, USA.
#------------------------------------------------------------------------------

# $Id: biginvaders.ps1 199 2007-02-08 13:11:41Z adrian $

# demo for grrr.ps1
# run this as a script - do not 'source' it with '.'

$global:___globcheck___=1
$local:___globcheck___=2
if ($global:___globcheck___ -eq 2) {throw "This should not be sourced in global scope"}

$ErrorActionPreference="Stop"

[int]$script:maxwidth = 120
[int]$script:maxheight = 60

cls
init-console $maxwidth $maxheight

#------------------------------------------------------------------------------
# Create the invader sprites
# Returns a tuple of the shared direction controller object and the 
# sprite array
#
function create-invadersprites($images) {
  $sprites = new-object collections.arraylist # @()
  [hashtable]$ctl = @{  # shared controller for all sprites
    current="R"         # current block direction
    next="R"            # next block direction
    left=1              # left edge
    right=$maxwidth-12  # right edge
    bottom=$maxheight-8 # bottom edge
    landed=$false       # becomes true if aliens reach the bottom
  } 
  # handlers for motion
  $init = {
    $s=$args[0]
    $s.state.controller = $ctl
  }
  $move = { 
    $s=$args[0]
    $dx = 1
    $dy = 2
    $d = $s.state.controller
    switch ($d.current) {
      "R" {
        $s.x+=$dx

        if ($s.x -ge $d.right) { $d.next="DL" }
      }
      "L" {
        $s.x-=$dx
        if ($s.x -le $d.left) { $d.next="DR" }
      }
      "DL" {
        $s.y+=$dy
        if ($s.y -ge $d.bottom) { $d.landed=$true }
        $d.next="L"
      }
      "DR" {
        $s.y+=$dy
        if ($s.y -ge $d.bottom) { $d.landed=$true }
        $d.next="R"
      }
    }
  }
  $handlers = create-spritehandler -didinit $init -willdraw $move
  $y = 0
  $xo = 2
  "inva","invb","invc" | foreach {
    $i = $_
    for ($x=0; $x -lt 3; $x++) {
      $ip = $images["$i"+"0"],$images["$i"+"1"]
      $s = create-sprite -images $ip -x ($xo+10+18*$x) -y $y -handler $handlers -animrate 8
      $sprites += $s
    }
    $xo -= 1
    $y += 11
  }
  return $ctl,$sprites
}


#------------------------------------------------------------------------------
# create base ship sprite
#
function create-basesprite {
  param($images)
  $handlers = create-spritehandler -didinit {
    $s=$args[0]
    $s.x = 30; $s.y=$script:maxheight-6
    $s.state.dx = 0
  } -willdraw {
    $s=$args[0]
    $s.x += $s.state.dx
  }
  $base = create-sprite -images $images.base -handler $handlers
  return $base
}


#------------------------------------------------------------------------------
# demo starts here
#
function main {
  # create a plafield to put it all on
  $pf = create-playfield -x 0 -y 0 -width $maxwidth -height $maxheight -bg "black"

  # load the alien images from the file
  $images = (gc images.txt | get-image )
  # create an alien hoard (well, a small gathering) 
  $aliens_controller,$aliens = create-invadersprites $images
  # create a base ship
  $base = create-basesprite $images

  # create a keyevent map
#  $keymap = create-keymap
#  register-keyevent $keymap 37 -down {$base.dx=-1} -up {$base.dx=0}
#  register-keyevent $keymap 39 -down {$base.dx=1} -up {$base.dx=0}

  $debugline = "big invaders!"

  # game loop
  while (-not $aliens_controller.landed) {
#    process-keyevents $keymap
    clear-playfield $pf
    draw-sprite $pf $aliens
    $aliens_controller.current = $aliens_controller.next
    draw-sprite $pf $base
    draw-string $pf $debugline 0 0 -fg "red"
    # 40 = 25fps
    flush-playfield $pf -sync 20 
    # lets see what we actually get
    $fps = $pf.FPS
    $debugline = "$fps fps (target 50)"
  }
}

# off we go
main

