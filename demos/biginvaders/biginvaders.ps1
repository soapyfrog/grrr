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
# Create sounds for the game
#
function prepare-sounds {
  if ( [soapyfrog.grrr.core.sound]::SoundAvailable ) {
    $script:sounds = @{}
    foreach ($i in 0..3) {
      $sounds["duh${i}"] = create-sound (resolve-path "duh${i}.wav")
    }
    $sounds.firemissile=create-sound (resolve-path "firemissile.wav")
    $sounds.invaderexplode=create-sound (resolve-path "invaderexplode.wav")
    $sounds.baseexplode=create-sound (resolve-path "baseexplode.wav")
  }
  else
  {
    $script:sounds = $null
  }
}


#------------------------------------------------------------------------------
# Create the invader sprites.  Returns a tuple of the shared direction
# controller object and the sprite array.
#
function create-invadersprites {
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
      $s = create-sprite -images $ip -x (10+18*$x) -y $y -handler $handlers -bounds $b -tag "invader"
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
  $b = new-object Soapyfrog.Grrr.Core.Rect 2,0,($maxwidth-4),$maxheight
  $handlers = create-spritehandler -DidInit {
    $s=$args[0]
    $s.x = 30; $s.y=$script:maxheight-6
    # set motionpaths for left/right - used by event map key handlers
    $s.state.mpleft = (create-motionpath "w")
    $s.state.mpright = (create-motionpath "e")
  } -DidExceedBounds {
    # just null the motionpath
    $s=$args[0].motionpath = $null
  }
  $base = create-sprite -images $images.base -handler $handlers -tag "base" -bounds $b
  return $base
}

#------------------------------------------------------------------------------
# create missile sprite
#
function create-missilesprite {
  # test boundary condition with a DidMove handler
  $b = new-object Soapyfrog.Grrr.Core.Rect 0,0,$maxwidth,$maxheight
  $h = create-spritehandler -DidExceedBounds {
    $args[0].Active = $false
  } -DidOverlap {
    $s=$args[0]
    $other = $args[1]
    switch ($other.tag) {
      "invader" {
        # change images to explode sequence (just one frame, but could be more)
        $other.Images = $images.invexplode
        # replace handler with one that just sets inactive at end of anim sequence
        $other.handler = (create-spritehandler -DidEndAnim { $args[0].Active = $false })
        # play sound
        if ($sounds) { play-sound $sounds.invaderexplode }
        break
      }
      "bomb" {
        $other.Active = $false 
      }
    }
    $s.Active = $false
  }
  $mp = create-motionpath "n2" # just head north
  $s = create-sprite -images $images.missile -handler $h -motionpath $mp -tag "missile" -bound $b
  # start it off inactive; it gets set to Active when it's fired.
  $s.active = $false
  return $s
}

#------------------------------------------------------------------------------
# create bomb sprites
#
function create-bombsprites {
  # test boundary condition with a DidMove handler
  $b = new-object Soapyfrog.Grrr.Core.Rect 0,0,$maxwidth,$maxheight
  $h = create-spritehandler -DidExceedBounds {
    $args[0].Active = $false
  } -DidOverlap {
    $s=$args[0]
    $other = $args[1]
    if ($other.tag -eq "base") {
      # change images to explode sequence (just one frame, but could be more)
      $other.Images = $images.baseexplode
      # replace handler with one that just sets inactive at end of anim sequence
      $other.handler = (create-spritehandler -DidEndAnim { $args[0].Active = $false; $script:endreason="bombed!" })
      # play sound
      if ($sounds) { play-sound $sounds.baseexplode }
      $s.Active = $false
    }
  }
  $mp = create-motionpath "s" # just head south 
  # create a few
  1..5 | foreach {
    $s = create-sprite -images $images.bomba0,$images.bomba1 -handler $h -motionpath $mp -animrate 4 -tag "bomb" -bound $b
    # start it off inactive; it gets set to Active when it's fired.
    $s.active = $false
    $s
  }
}


#------------------------------------------------------------------------------
# create shield sprites
#
function create-shieldsprites {
  $h = create-spritehandler -DidOverlap {
    $s=$args[0] # me
    $o=$args[1] # the other
    switch ($o.tag) {
      "invader" { $s.Active=$false; break }
      "bomb" { animate-sprite $s; $o.Active=$false; break }
      "missile" { animate-sprite $s; $o.Active=$false; break }
    }
  } -DidEndAnim {
    $args[0].Active=$false
  }
  # we want 4x2 block shields about 36 cells apart
  # this is a bit hacky, but this is only a demo :-)
  $oy=80
  for ($ox=10; $ox -lt $maxwidth; $ox+=36) {
    for ($c=0; $c -lt 4; $c++) {
      for ($r=0; $r -lt 2; $r++) {
        if ($r -eq 1 -and 1,2 -eq $c) { continue; } # gap on underside
        create-sprite -images $images.shield0,$images.shield1,$images.shield2 -handler $h -X ($ox+$c*4) -Y ($oy+$r*4)
      }
    }
  }
}



#------------------------------------------------------------------------------
# demo starts here
#
function main {

  # create a plafield to put it all on
  $pf = create-playfield -x 0 -y 0 -width $maxwidth -height $maxheight -bg "black"

  prepare-sounds

  # load the alien images from the file
  $script:images = (gc ./images.txt | get-image )
  # create an alien hoard (well, a small gathering) 
  $aliens_controller,[array]$aliens = create-invadersprites 
  # create a base ship
  $base = create-basesprite 
  # prepare a missile
  $missile = create-missilesprite 
  # prepare some bombs
  $bombs = create-bombsprites 
  # create shields
  $shields = create-shieldsprites

  # create an event map
  $eventmap = create-eventmap
  register-event $eventmap -keydown 37 {$base.motionpath=$base.state.mpleft} 
  register-event $eventmap -keyup 37  {$base.motionpath=$null}
  register-event $eventmap -keydown 39 {$base.motionpath=$base.state.mpright} 
  register-event $eventmap -keyup 39 {$base.motionpath=$null}  
  register-event $eventmap -keydown 32 {
    if (! $missile.Active ) {
      $missile.X = $base.X
      $missile.Y = $base.Y+1
      $missile.Active = $true
      if ($sounds) { play-sound $sounds.firemissile }
    }
  } 
  register-event $eventmap -keydown 27 { $script:endreason="user quit" }
  register-event $eventmap -keydown ([int][char]"F") { $pf.showfps = ! $pf.showfps; }

  # game loop
  [int]$duhidx=0; [int]$duhcnt=0;
  while ($script:endreason -eq $null) {
    foreach ($alien in $aliens) {
      if (! $alien.Active) { continue; }
      clear-playfield $pf

      # process events
      process-event $eventmap

      # move everything
      move-sprite $base,$missile
      move-sprite $bombs 
      move-sprite $alien # just the current alien

      # draw everything
      draw-sprite $pf $base,$missile
      draw-sprite $pf $shields -NoAnim
      draw-sprite $pf $bombs 
      draw-sprite $pf $aliens -NoAnim
      animate-sprite $alien # only animate the current one

      # flush the playfield to the console
      flush-playfield $pf -sync 20 # to get 50 fps


      # test for collisions - note, if this is done to ensure sprites are not
      # out of bounds, you might want to do it before drawing
      test-spriteoverlap $aliens $base,$missile # check if aliens have hit base or missile
      test-spriteoverlap $bombs $base,$missile
      test-spriteoverlap $shields $bombs
      test-spriteoverlap $shields $missile
      test-spriteoverlap $shields $aliens

      # cull inactive aliens
      $aliens = ($aliens | where {$_.Active})
      if ($aliens -eq $null) { $script:endreason="all invaders dead!" }
      if ($script:endreason) { break }
      
      # lets drop a bomb!
      if ($rnd.next(50) -eq 0) {
        foreach ($b in $bombs) {
          if (!$b.Active) {
            $s = $aliens[$rnd.next($aliens.length)]
            $b.X = $s.X
            $b.Y = $s.Rect.Y
            $b.Active = $true
            break
          }
        }
      }
    }
    #todo should try to find a better algorithm for sound speed
    if ( (++$duhcnt)%2 -eq 1) { if ($sounds) { play-sound $script:sounds["duh"+(++$duhidx % 4)] -stop} }
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
  start-sleep 1
}

# off we go
main

