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

# test cases for grrr.ps1
# run this as a script - do not 'source' it with '.'

$global:___globcheck___=1
$local:___globcheck___=2
if ($global:___globcheck___ -eq 2) {throw "This should not be sourced in global scope"}

$ErrorActionPreference="Stop" # endless errors annoy me

# load modules
. .\psunit.ps1
. .\grrr.ps1

# init console
init-console -w 120 -h 50 


#----------------------------------------------------------------
# Tests various modes of creating a playfield
#
function test-create-playfield {
  $pf = create-playfield -width 30 -height 20 
  assert-equal "vx" 0 $pf.vpcoord.X
  assert-equal "vy" 0 $pf.vpcoord.Y
  assert-equal "vr" (30-1) $pf.vprect.Right
  assert-equal "vb" (20-1) $pf.vprect.Bottom
  assert-equal "background" "black" $pf.fillcell.BackgroundColor

  $pf = create-playfield -width 30 -height 20 -x 5 -y 6 -bg "red"
  assert-equal "vx" 5 $pf.vpcoord.X
  assert-equal "vy" 6 $pf.vpcoord.Y
  assert-equal "vr" (5+30-1) $pf.vprect.Right
  assert-equal "vb" (6+20-1) $pf.vprect.Bottom
  assert-equal "background" "red" $pf.fillcell.BackgroundColor

  # TODO: tests for the viewport being different
}


#----------------------------------------------------------------
# this is more of a visual test, so really only tests syntax 
# TODO: put checks in to verify colours on screen
#
function test-clear-playfield {
  # create playfield over to the right
  $pf = create-playfield -x 70 -y 30 -width 30 -height 20 -bg "red"
  clear-playfield $pf
  flush-playfield $pf
  $pf = create-playfield -x 72 -y 32 -width 30 -height 20 # default colour
  clear-playfield $pf
  flush-playfield $pf
  $pf = create-playfield -x 74 -y 34 -width 30 -height 20 -bg "green"
  clear-playfield $pf
  flush-playfield $pf
}


#----------------------------------------------------------------
# test creation of an image
#
function test-create-image {
  $img = create-image "ABC","DEF" 
  assert-equal "width" 3 $img.width
  assert-equal "height" 2 $img.height
  $img = create-image "short","verylong" 
  assert-equal "uneven width" ("verylong".length) $img.width
}

#----------------------------------------------------------------
# test drawing of an image
#
function test-draw-image {
  $pf = create-playfield -x 50 -y 36 -width 16 -height 20 -bg "darkgray"
  clear-playfield $pf

  $img = create-image "hello","world!"
  draw-image $pf $img 0 0
  draw-image $pf $img 5 4

  flush-playfield $pf 
}

#----------------------------------------------------------------
# test sprite overlapping
#
function test-overlap-sprite {
  $img = create-image "ABC","DEF" # 3x2 image
  $s1 = create-sprite @($img) -x 1 -y 1 
  $s2 = create-sprite @($img) -x 1 -y 1 
  assert-true "full overlap" (overlap-sprite? $s1 $s2)

  $s2 = create-sprite @($img) -x 3 -y 1 
  assert-true "partial x overlap" (overlap-sprite? $s1 $s2)

  $s2 = create-sprite @($img) -x 1 -y 2 
  assert-true "partial y overlap" (overlap-sprite? $s1 $s2)

  $s2 = create-sprite @($img) -x 4 -y 1 
  assert-false "no overlap" (overlap-sprite? $s1 $s2)

}

#----------------------------------------------------------------
# test drawing of a sprite
#
function test-draw-sprite {
  $pf = create-playfield -x 70 -y 36 -width 20 -height 20 -bg "black"

  $img = create-image "ABC","DEF" -bg "red" -fg "yellow"
  $h = create-spritehandlers -willdraw { $s=$args[0]; $s.x++; $s.y++ }
  $spr = create-sprite @($img) -x 1 -y 1 -handlers $h

  1..8 | foreach {
    clear-playfield $pf
    draw-sprite $pf $spr 
    flush-playfield $pf 
    sleep -millis 40
  }
}


#----------------------------------------------------------------
# test drawing a tilemap
#
function test-draw-tilemap {

  $pf = create-playfield -x 10 -y 36 -width 20 -height 20 -bg "black"
  $imgA = create-image "ABC","XYZ" -bg "darkgreen" -fg "black"
  $imgB = create-image "ABC","XYZ" -bg "darkmagenta" -fg "white"

  $lines = "AB  AB   BA",
           "AAA AAB AAA",
           "AAAAAAAAAAA"
  $tilemap = create-tilemap -lines $lines -imagemap @{"A"=$imgA;"B"=$imgB} 3 2 

  0..10 | foreach {
    clear-playfield $pf
    draw-tilemap $pf $tilemap -offsetx $_ -offsety 0 -x 0 -y 0 -w 20 -h 20
    flush-playfield $pf
    sleep -millis 40
  }
}

#----------------------------------------------------------------
# test creating a motion path sprite handler
#
function test-create-spritehandlers-for-motionpath {
  $h = create-spritehandlers-for-motionpath "e4 s3 w1 n3"
  assert-true "numdeltas" 11 $h.numdeltas
}

#----------------------------------------------------------------
# test creating a large playfield with smaller viewport
#
function test-set-playfield-viewport {
  # create a 36x20 playfield with a 18x10 viewport
  $pf = create-playfield -x 20 -y 25 -width 36 -height 20 -bg "black" -vpwidth 18 -vpheight 10
  clear-playfield $pf
  # fill playfield with graphics
  $c=0
  for ($y=0; $y -lt 20; $y++) {
    for ($x=0; $x -lt 36; $x+=6) {
      $s = [string]::Format("{0:0#}:{0:0#} ",$y,$x)
      $img = create-image @($s) -bg ($c++ % 7) -fg ($c % 7 + 9)
      draw-image $pf $img $x $y
    }
  }
  for ($i=0; $i -lt 7; $i++) {
    set-playfield-viewport $pf $i $i
    flush-playfield $pf
    sleep -millis 40
  }

}

#----------------------------------------------------------------
# test drawing lines
function test-draw-line {
  $pf = create-playfield -x 40 -y 25 -width 36 -height 20 -bg "black" 
  clear-playfield $pf

  # simple horizontal and vertical lines
  draw-line $pf 0 0 35 0 "red" "black"
  draw-line $pf 0 1 0 19 "yellow" "black"

  # pure diaganals
  draw-line $pf 20 10 25 15 "white" "black"
  draw-line $pf 25 10 20 15 "white" "black"

  # mostly horizontal
  draw-line $pf 2 2 30 5 "magenta" "black"
  draw-line $pf 2 5 30 2 "cyan" "black"
 
  # mostly vertical
  draw-line $pf 10 8 14 19 "magenta" "black"
  draw-line $pf 14 8 10 19 "cyan" "black"

  flush-playfield $pf
}



#----------------------------------------------------------------
# hand over to unit test framework
run-tests
