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

# $Id: grrr-perftest.ps1 143 2007-01-20 11:24:57Z adrian $

# performance test cases for grrr.ps1
# run this as a script - do not 'source' it with '.'

$global:___globcheck___=1
$local:___globcheck___=2
if ($global:___globcheck___ -eq 2) {throw "This should not be sourced in global scope"}

$ErrorActionPreference="Stop" # endless errors annoy me

# load modules
. ..\lib\psunit.ps1

$Kwidth = 120
$Kheight = 50
$Kiters = 150

# init console
cls
init-console -w $Kwidth -h $Kheight 

#----------------------------------------------------------------
# test playfield alone
function test-playfield-alone {
  $pf = create-playfield -x 0 -y 24 -width 34 -height 20 -bg "black" 
  for ([int]$iter=$Kiters; $iter -gt 0; $iter--) {
    clear-playfield $pf
    flush-playfield $pf
  }
}


#----------------------------------------------------------------
# build a dragon image source
function build-dragonlines {
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
  return $dragonlines
}

#----------------------------------------------------------------
# test drawing opaque images
function test-draw-image-opaque {
  $pf = create-playfield -x 0 -y 24 -width 34 -height 20 -bg "black" 
  $opaquedragon = create-image (build-dragonlines) -fg "red" -bg "darkred"

  for ([int]$iter=$Kiters; $iter -gt 0; $iter--) {
    clear-playfield $pf
    draw-image $pf $opaquedragon 1 6
    flush-playfield $pf
  }
}
#----------------------------------------------------------------
# test drawing transparent images
function test-draw-image-transparent {
  $pf = create-playfield -x 0 -y 24 -width 34 -height 20 -bg "black" 
  $transparentdragon = create-image (build-dragonlines) -fg "yellow" -bg "darkgreen" -transparent 32

  for ([int]$iter=$Kiters; $iter -gt 0; $iter--) {
    clear-playfield $pf
    draw-image $pf $transparentdragon 1 6
    flush-playfield $pf
  }
}


#----------------------------------------------------------------
# hand over to unit test framework
run-tests | format-table -autosize -wrap

