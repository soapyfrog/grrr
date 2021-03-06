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

# test cases for grrr.ps1
# run this as a script - do not 'source' it with '.'

$global:___globcheck___=1
$local:___globcheck___=2
if ($global:___globcheck___ -eq 2) {throw "This should not be sourced in global scope"}

set-psdebug -strict           # why not
$ErrorActionPreference="Stop" # endless errors annoy me

# load modules
. ..\lib\psunit.ps1

# init console
cls
init-console -w 120 -h 50 


#----------------------------------------------------------------
# Tests various modes of creating a playfield
#
function test-create-playfield {
  $pf = create-playfield -width 30 -height 20 
  assert-equal "x" 0 $pf.X
  assert-equal "y" 0 $pf.Y
  assert-equal "w" 30 $pf.Width
  assert-equal "h" 20 $pf.Height
  assert-equal "background" "black" $pf.Background

  $pf = create-playfield -width 30 -height 20 -x 5 -y 6 -bg "red"
  assert-equal "x" 5 $pf.X
  assert-equal "y" 6 $pf.Y
  assert-equal "w" 30 $pf.Width
  assert-equal "h" 20 $pf.Height
  assert-equal "background" "red" $pf.Background

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
  assert-notnull "full overlap" (Test-SpriteOverlap $s1 $s2 -OutputPairs)

  $s2 = create-sprite @($img) -x 3 -y 1 
  assert-notnull "partial x overlap" (test-spriteoverlap $s1 $s2 -outputpairs)

  $s2 = create-sprite @($img) -x 1 -y 2 
  assert-notnull "partial y overlap" (test-spriteoverlap $s1 $s2 -outputpairs)

  $s2 = create-sprite @($img) -x 4 -y 1 
  assert-null "no overlap" (test-spriteoverlap $s1 $s2 -outputpairs)

}

#----------------------------------------------------------------
# test drawing of a sprite
#
function test-draw-sprite {
  $pf = create-playfield -x 70 -y 36 -width 20 -height 20 -bg "black"

  $img = create-image "ABC","DEF" -bg "red" -fg "yellow"
  $h = create-spritehandler -willdraw { $s=$args[0]; $s.x++; $s.y++ }
  $spr = create-sprite @($img) -x 1 -y 1 -handler $h

  1..8 | foreach {
    clear-playfield $pf
    draw-sprite $pf $spr 
    flush-playfield $pf 
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
  $tilemap = create-tilemap -lines $lines -imagemap @{"A"=$imgA;"B"=$imgB}  

  0..10 | foreach {
    clear-playfield $pf
    draw-tilemap $pf $tilemap -offsetx $_ -offsety 0 -x 0 -y 0 -w 20 -h 20
    flush-playfield $pf
  }
}


#----------------------------------------------------------------
# test drawing lines
function test-draw-line {
  $pf = create-playfield -x 40 -y 25 -width 36 -height 20 -bg "black" 
  clear-playfield $pf
  $img = create-image @("O") -bg "black" -fg "yellow"

  # simple horizontal and vertical lines
  draw-line $pf 0 0 35 0 $img
  draw-line $pf 0 1 0 19 $img

  # pure diaganals
  draw-line $pf 20 10 25 15 $img
  draw-line $pf 25 10 20 15 $img

  # mostly horizontal
  draw-line $pf 2 2 30 5 $img
  draw-line $pf 2 5 30 2 $img
 
  # mostly vertical
  draw-line $pf 10 8 14 19 $img
  draw-line $pf 14 8 10 19 $img

  flush-playfield $pf
}

#----------------------------------------------------------------
# test drawing transparent images
function test-drawing-transparent-images {
  $pf = create-playfield -x 60 -y 24 -width 34 -height 20 -bg "darkblue" 
  $dragontxt = @"
      .==.        .==.
     //'^\\      //^'\\
    //x^x^\(\__/)/^x^^\\
   //^x^^x^/6xx6\x^^x^^\\
  //^x^^x^x(x..x)x^x^^^x\\
 //x^^x^/\//v""v\\/\^x^x^\\
//x^^/\/  /x'~~'x\  \/\^x^\\
\\^x/    /x,xxxx,x\    \^x//
 \\/    (x(xxxxxx)x)    \//
  ^      \x\.__./x/      ^
         ((('  ')))
"@
  # replace the x with spaces, well dots
  $dragontxt = $dragontxt.replace("x",[string][char]0x00b7)
  # split into lines
  $dragonlines = $dragontxt.replace("`r","W").replace("`n","").split("W")
  $opaquedragon = create-image $dragonlines -fg "red" -bg "darkred"
  $transparentdragon = create-image $dragonlines -fg "yellow" -bg "darkgreen" -transparent 32


  clear-playfield $pf
  draw-image $pf $opaquedragon 1 6
  draw-image $pf $transparentdragon 6 3
  flush-playfield $pf
}

#----------------------------------------------------------------
# test string drawing
function test-draw-string {
  $str = "Hello, world!"
  $pf = create-playfield -x 0 -y 24 -width ($str.length+2) -height 3 -bg "darkred" 
  clear-playfield $pf
  draw-string $pf "Hello, world!" -x 1 -y 1 -fg "white" -bg "black"
  flush-playfield $pf
}

#----------------------------------------------------------------
# test scan-image
function test-scan-image {
  $tpf = create-playfield -x 0 -y 0 -width 10 -height 10 -bg "darkblue"
  $timg = create-image "ABC","DEF" "yellow" "red"
  assert-equal "timg width" 3 $timg.width
  assert-equal "timg height" 2 $timg.height
  clear-playfield $tpf
  draw-image $tpf $timg -x 2 -y 2
  # now scan an image with space around that one
  $img = scan-image $tpf -x 1 -y 1 -width 5 -height 4
  assert-equal "img width" 5 $img.width
  assert-equal "img height" 4 $img.height
  # now create a new playfield to draw it
  $pf = create-playfield -x 10 -y 24 -width 10 -height 10 -bg "gray"
  clear-playfield $pf
  draw-image $pf $img -x 1 -y 1
  flush-playfield $pf
}


#----------------------------------------------------------------
# test sound preparation and playing
function test-playing-sounds {
  $path = join-path $env:SystemRoot "media\tada.wav"
  prepare-sound "tada" $path
  play-sound "tada"
}

#----------------------------------------------------------------
# hand over to unit test framework
run-tests | format-table -autosize -wrap


# alternate form to htmll
# run-tests | convertto-html -body @("Test results at $(get-date)") > results.html ; ii results.html
