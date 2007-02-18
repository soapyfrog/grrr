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

# needs a bit screen. best to use 6x8 bitmap font
[int]$script:maxwidth = 180
[int]$script:maxheight = 100
init-console $maxwidth $maxheight 

$script:endreason = $null; # will be set to a reason later
$script:rnd = new-object Random


#------------------------------------------------------------------------------
# Create the invader sprites.  Returns a tuple of the shared direction
# controller object and the sprite array.
#
function create-invadersprites($images) {
  $b = new-object Soapyfrog.Grrr.Core.Rect 2,0,($maxwidth-4),$maxheight
  $sprites = new-object collections.arraylist # @()
  [hashtable]$ctl = @{  # shared controller for all sprites
    mp1=(create-motionpath "e2") # initially just right
    mpdl=(create-motionpath "2s2 200w2" 1) # down and left
    mpdr=(create-motionpath "2s2 200e2" 1) # down and right
    mpnext = $null
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
    $s=$args[0] # sprite
    $delta=$args[1] # Delta
    [soapyfrog.grrr.core.edge]$edges=$args[2] # Edge bitwise set
    $d = $s.state.controller
    if ($d.mpnext -ne $null) { return;} # aleady dealt with the event

    if ($delta.dy -ge 0 -and $edges -band [soapyfrog.grrr.core.edge]::bottom) { 
      $script:endreason="aliens have landed"
    }
    elseif ($delta.dx -gt 0 -and $edges -band [soapyfrog.grrr.core.edge]::right) {
      $d.mpnext=$d.mpdl;
    }
    elseif ($delta.dx -lt 0 -and $edges -band [soapyfrog.grrr.core.edge]::left) {
      $d.mpnext=$d.mpdr;
    }
  }

  $handlers = Create-SpriteHandler -DidInit $init -DidOverlap $overlap -DidExceedBounds $oob
  $y = 12
  "inva","invb","invc","invc" | foreach {
    $i = $_
    for ($x=0; $x -lt 6; $x++) {
      $ip = $images["$i"+"0"],$images["$i"+"1"]
      $s = create-sprite -images $ip -x (10+18*$x) -y $y -handler $handlers -bounds $b
      $sprites += $s
    }
    $y += 10
  }
  return $ctl,$sprites
}


#------------------------------------------------------------------------------
# create base ship sprite
#
function create-basesprite {
  param($images)
  $b = new-object Soapyfrog.Grrr.Core.Rect 2,0,($maxwidth-4),$maxheight
  $handlers = create-spritehandler -DidInit {
    $s=$args[0]
    $s.x = 30; $s.y=$script:maxheight-6
    $s.state.mpleft = (create-motionpath "w")
    $s.state.mpright = (create-motionpath "e")
  } -DidExceedBounds {
    $s=$args[0].motionpath = $null
  }
  $base = create-sprite -images $images.base -handler $handlers -tag "base" -bounds $b
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
  $mp = create-motionpath "n2" # just head north
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
  $mp = create-motionpath "s" # just head south 
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
  $images = (gc ./images.txt | get-image )
  # create an alien hoard (well, a small gathering) 
  $aliens_controller,[array]$aliens = create-invadersprites $images
  # create a base ship
  $base = create-basesprite $images
  # prepare a missile
  $missile = create-missilesprite $images
  # prepare some bombs
  $bombs = create-bombsprites $images

  # create a keyevent map
  $keymap = create-keyeventmap
  register-keyevent $keymap 37 -keydown {$base.motionpath=$base.state.mpleft} -keyup {$base.motionpath=$null}
  register-keyevent $keymap 39 -keydown {$base.motionpath=$base.state.mpright} -keyup {$base.motionpath=$null}  
  register-keyevent $keymap 32 -keydown {
    if (! $missile.alive ) {
      $missile.X = $base.X
      $missile.Y = $base.Y+1
      $missile.alive = $true
    }
  } 
  register-keyevent $keymap 27 -keydown { $script:endreason="user quit" }
  register-keyevent $keymap ([int][char]"F") -keydown { $pf.showfps = ! $pf.showfps; }

  # game loop
  while ($script:endreason -eq $null) {
    foreach ($alien in $aliens) {
      if (! $alien.alive) { continue; }
      clear-playfield $pf

      # process key events
      process-keyevents $keymap

      # move everything
      move-sprite $base,$missile
      move-sprite $bombs 
      move-sprite $alien # just the current alien

      # draw everything
      draw-sprite $pf $base,$missile
      draw-sprite $pf $bombs 
      draw-sprite $pf $aliens -NoAnim
      animate-sprite $alien # only animate the current one

      # flush the playfield to the console
      flush-playfield $pf -sync 20 # to get 50 fps

      # test for collisions - note, if this is done to ensure sprites are not
      # out of bounds, you might want to do it before drawing
      test-spriteoverlap $aliens $base,$missile # check if aliens have hit base or missile
      test-spriteoverlap $bombs $base,$missile

      # cull dead aliens
      $aliens = ($aliens | where {$_.alive})
      if ($aliens -eq $null) { $script:endreason="all aliens dead!" }
      if ($script:endreason) { break }
      
      # lets drop a bomb!
      if ($rnd.next(50) -eq 0) {
        foreach ($b in $bombs) {
          if (!$b.alive) {
            $s = $aliens[$rnd.next($aliens.length)]
            $b.X = $s.X
            $b.Y = $s.Y + ($s.Height/2)
            $b.alive = $true
            break
          }
        }
      }
    }
    # processed block, so update aliens controller state
    if ($aliens_controller.mpnext) {
      foreach ($alien in $aliens) {
        $alien.motionpath = $aliens_controller.mpnext;
      }
      $aliens_controller.mpnext = $null
    }
     
  }
  draw-string $pf "Demo ended: $script:endreason" 20 10 -fg "white" -bg "red"
  flush-playfield $pf 
}

# off we go
main

