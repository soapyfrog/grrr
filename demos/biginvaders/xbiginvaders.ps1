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
$script:endreason = $null; # will be set to a reason later
$script:rnd = new-object Random

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
  } 
  # handlers for motion
  $init = {
    $s=$args[0]
    $s.state.controller = $ctl
  }
  $overlap= {
    $s=$args[0] 
    $o=$args[1] # what we hit
    if ($o -eq $base) {
      $script:endreason="Aliens hit base";
    }
    # we may hit a missile, but the missile will handle it
  }
  $move = { 
    $s=$args[0]
    $dx = 1
    $dy = 1
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
        if ($s.y -ge $d.bottom) { $endreason="aliens have landed" }
        $d.next="L"
      }
      "DR" {
        $s.y+=$dy
        if ($s.y -ge $d.bottom) { $endreason="aliens have landed" }
        $d.next="R"
      }
    }
    # lets drop a bomb!
    if ($rnd.next(500) -eq 0) {
      foreach ($b in $d.bombs) {
        if (!$b.alive) {
          $b.X = $s.X + 5
          $b.Y = $s.Y + $s.Height
          $b.alive = $true
          break
        }
      }
    }
  }

  $handlers = Create-SpriteHandler -DidInit $init -DidMove $move -DidOverlap $overlap
  $y = 0
  $xo = 2
  "inva","invb","invc" | foreach {
    $i = $_
    for ($x=0; $x -lt 4; $x++) {
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
  $handlers = create-spritehandler -DidInit {
    $s=$args[0]
    $s.x = 30; $s.y=$script:maxheight-6
    $s.state.dx = 0
  } -DidMove {
    $s=$args[0]
    $s.x += $s.state.dx
  }
  $base = create-sprite -images $images.base -handler $handlers -tag "base"
  return $base
}

#------------------------------------------------------------------------------
# create missile sprite
#
function create-missilesprite {
  param($images)
  # test boundary condition with a DidMove handler
  # TODO replace this with boundary handler when supported
  $handlers = create-spritehandler  -DidMove {
    $s=$args[0]
    if ($s.Y -lt 0) {
      $s.alive = $false
    }
  } -DidOverlap {
    $s=$args[0]
    $inv = $args[1] # the thing we hit (will be an invader)
    $inv.alive = $false 
    $s.alive = $false
  }
  $mp = create-motionpath "n" # just head north
  $s = create-sprite -images $images.missile -handler $handlers -motionpath $mp -tag "missile"
  # start it off dead; it gets set to alive when it's fired.
  $s.alive = $false
  return $s
}

#------------------------------------------------------------------------------
# create bomb sprites
#
function create-bombsprites {
  param($images)
  # test boundary condition with a DidMove handler
  # TODO replace this with boundary handler when supported
  $handlers = create-spritehandler  -DidMove {
    $s=$args[0]
    if ($s.Y -ge $maxheight) {
      $s.alive = $false
    }
  } -DidOverlap {
    $s=$args[0]
    $b = $args[1]
    if ($b.tag -eq "base") {
      $s.alive = $false
      $script:endreason="bombed by alien"
    }
    elseif ($b.tag -eq "missile") {
      # cancel each other out
      $b.alive = $false;
      $s.alive = $false;
    }
  }
  $mp = create-motionpath "s h" # just head south slowly
  # create a few
  1..3 | foreach {
    $s = create-sprite -images $images.bomba0,$images.bomba1 -handler $handlers -motionpath $mp -animrate 4 -tag "bomb"
    # start it off dead; it gets set to alive when it's fired.
    $s.alive = $false
    $s
  }
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
  # prepare a missile
  $missile = create-missilesprite $images
  # prepare some bombs
  $aliens_controller.bombs = create-bombsprites $images

  # create a keyevent map
  $keymap = create-keyeventmap
  register-keyevent $keymap 37 -keydown {$base.state.dx=-1} -keyup {$base.state.dx=0}
  register-keyevent $keymap 39 -keydown {$base.state.dx=1} -keyup {$base.state.dx=0}
  register-keyevent $keymap 32 -keydown {
    if (! $missile.alive ) {
      $missile.X = $base.X + 5
      $missile.Y = $base.Y - 1
      $missile.alive = $true
    }
  } 

  $debugline = "big invaders!"

  # game loop
  while ($script:endreason -eq $null) {
    clear-playfield $pf

    # process key events
    process-keyevents $keymap

    # move everything
    move-sprite $aliens
    move-sprite $base
    move-sprite $missile
    move-sprite $aliens_controller.bombs 

    # draw everything
    draw-sprite $pf $aliens 
    draw-sprite $pf $base
    draw-sprite $pf $missile 
    draw-sprite $pf $aliens_controller.bombs 

    # update aliens controller state
    $aliens_controller.current = $aliens_controller.next
   
    # draw a status line
    draw-string $pf $debugline 0 0 -fg "red"

    # flush the playfield to the console
    flush-playfield $pf -sync 20 # to get 50 fps

    # test for collisions - note, if this is done to ensure sprites are not
    # out of bounds, you might want to do it before drawing
    test-spriteoverlap $aliens $base,$missile # check if aliens have hit base or missile
    test-spriteoverlap $aliens_controller.bombs $base,$missile

    # update debug line for next frame
    $debugline = "$($pf.fps) fps (target 50)"
    
    # cull dead aliens
    $aliens = ($aliens | where {$_.alive})
    if ($aliens -eq $null) { $script:endreason="all aliens dead!" }
  }
  draw-string $pf "Demo ended: $script:endreason" 20 10 -fg "white" -bg "red"
  flush-playfield $pf 
}

# off we go
main

