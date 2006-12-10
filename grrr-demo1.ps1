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


# demo1 for grrr.ps1
# run this as a script - do not 'source' it with '.'

$global:___globcheck___=1
$local:___globcheck___=2
if ($global:___globcheck___ -eq 2) {throw "This should not be sourced in global scope"}


cls

# load modules
. .\grrr.ps1


function main {
  $pf = create-playfield -x 0 -y 2 -width 78 -height 48 -bg "black"
  $imga1 = create-image "<#>","/ \" -fg "yellow" -bg "black"
  $imga2 = create-image "<#>","| |" -fg "yellow" -bg "black"

  # an array of sprites
  $sprites = @()
  # script block to do post init
  $didinit = { $args[0].dx = 1 }
  # the script block to decide how to move the alien
  $willdraw = {
    $s = $args[0]
    if ($s.x -gt 60) { $s.y++; $s.dx=-1 }
    elseif ($s.x -lt 1) { $s.y--; $s.dx=1 }
    $s.x += $s.dx
  }
  # build a load of them
  0..15 | foreach {
    [int]$n=$_
    $x = [Math]::Floor($n / 4) * 7 + 2
    $y = ($n % 4) * 4 + 3
    $sa = create-sprite -images @($imga1,$imga2) -x $x -y $y -didinit $didinit -willdraw $willdraw
    $sprites += $sa
  }

  # create another one with different behaviour
  $imgb = create-image "/\","\/" -fg "red" -bg "black"
  $spr = create-sprite -images @($imgb) -x 10 -y 42 
  $sprites += $spr

  # game loop
  [int]$fc = 0;
  while ($true) {
    $fc++
    clear-playfield $pf
    draw-sprites $pf $sprites
    flush-playfield $pf
  }
}

main

