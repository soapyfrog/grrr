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

# $Id$

# demo for grrr.ps1
# run this as a script - do not 'source' it with '.'

$global:___globcheck___=1
$local:___globcheck___=2
if ($global:___globcheck___ -eq 2) {throw "This should not be sourced in global scope"}

$ErrorActionPreference="Stop"

[int]$script:maxwidth = 120
[int]$script:maxheight = 60
init-console $maxwidth $maxheight 

$script:endreason = $null; # will be set to a reason later
$script:rnd = new-object Random


#------------------------------------------------------------------------------
# Create the invader sprites.  Returns a tuple of the shared direction
# controller object and the sprite array.
#
function create-invadersprites($images) {
  $b = new-object Soapyfrog.Grrr.Core.Rect 0,0,$maxwidth,$maxheight
  $sprites = new-object collections.arraylist # @()
  [hashtable]$ctl = @{  # shared controller for all sprites
    mp1=(create-motionpath "e") # initially just right
    mpdl=(create-motionpath "s2 200w" 1) # down and left
    mpdr=(create-motionpath "s2 200e" 1) # down and right
    current = $null
    next = $null
  } 
  # handlers for motion
  $init = {
    $s=$args[0]
    $s.state.controller = $ctl
    $s.motionpath = $ctl.mp1
  }
  $overlap= {
    $s=$args[0] 
    $o=$args[1] # what we hit
    if ($o -eq $base) {
      $script:endreason="Aliens hit base";
    }
    # we may hit a missile, but the missile will handle it
  }
  $oob = { 
    $s=$args[0]
    $d = $s.state.controller
    if ($s.Y -ge $maxheight) { $endreason="aliens have landed" }
    else {
      if ($s.X -gt 60) {
        $s.x--
        $d.next=$d.mpdl;
      }
      else {
        $s.x++
        $d.next=$d.mpdr;
      }
    }
  }
  $move = { 
    $s=$args[0]
    $d = $s.state.controller
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

  $handlers = Create-SpriteHandler -DidInit $init -DidMove $move -DidOverlap $overlap -DidExceedBounds $oob
  $y = 0
  $xo = 2
  "inva","invb","invc" | foreach {
    $i = $_
    for ($x=0; $x -lt 4; $x++) {
      $ip = $images["$i"+"0"],$images["$i"+"1"]
      $s = create-sprite -images $ip -x ($xo+10+18*$x) -y $y -handler $handlers -animrate 8 -bounds $b
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
  $b = new-object Soapyfrog.Grrr.Core.Rect 0,0,$maxwidth,$maxheight
  $h = create-spritehandler -DidExceedBounds {
    $args[0].Alive = $false
  } -DidOverlap {
    $s=$args[0]
    $inv = $args[1] # the thing we hit (will be an invader)
    $inv.alive = $false 
    $s.alive = $false
  }
  $mp = create-motionpath "n" # just head north
  $s = create-sprite -images $images.missile -handler $h -motionpath $mp -tag "missile" -bound $b
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
  $b = new-object Soapyfrog.Grrr.Core.Rect 0,0,$maxwidth,$maxheight
  $h = create-spritehandler -DidExceedBounds {
    $args[0].Alive = $false
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
    $s = create-sprite -images $images.bomba0,$images.bomba1 -handler $h -motionpath $mp -animrate 4 -tag "bomb" -bound $b
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
  register-keyevent $keymap 37 -keydown {$script:zzz++; $base.state.dx=-1} -keyup {$base.state.dx=0}
  register-keyevent $keymap 39 -keydown {$base.state.dx=1} -keyup {$base.state.dx=0}
  register-keyevent $keymap 32 -keydown {
    if (! $missile.alive ) {
      $missile.X = $base.X + 5
      $missile.Y = $base.Y - 1
      $missile.alive = $true
    }
  } 

  $debugline = "big invaders!"
  $script:zzz=0

  # game loop
  while ($script:endreason -eq $null) {
    foreach ($alien in $aliens) {
      if (! $alien.alive) { continue; }
      clear-playfield $pf

      # process key events
      process-keyevents $keymap

      # move everything
      move-sprite $alien # just the current alien
      move-sprite $base
      move-sprite $missile
      move-sprite $aliens_controller.bombs 

      # draw everything
      draw-sprite $pf $aliens 
      draw-sprite $pf $base
      draw-sprite $pf $missile 
      draw-sprite $pf $aliens_controller.bombs 

      # draw a status line
      draw-string $pf $debugline 0 0 -fg "red"

      # flush the playfield to the console
      flush-playfield $pf -sync 20 # to get 50 fps

      # test for collisions - note, if this is done to ensure sprites are not
      # out of bounds, you might want to do it before drawing
      test-spriteoverlap $aliens $base,$missile # check if aliens have hit base or missile
      test-spriteoverlap $aliens_controller.bombs $base,$missile

      # update debug line for next frame
      $debugline = "$($pf.fps) fps (target 50)   $($script:zzz)"
      
      # cull dead aliens
      $aliens = ($aliens | where {$_.alive})
      if ($aliens -eq $null) { $script:endreason="all aliens dead!" }
      if ($script:endreason) { break }
    }
    # update aliens controller state
    if ($aliens_controller.next) {
      foreach ($alien in $aliens) {
        $alien.motionpath = $aliens_controller.next;
      }
      $aliens_controller.next = $null
    }
     
  }
  draw-string $pf "Demo ended: $script:endreason" 20 10 -fg "white" -bg "red"
  flush-playfield $pf 
}

# off we go
main

