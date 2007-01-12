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


# load modules
. .\grrr.ps1

init-console 120 60
write-host "scary dragon thing"


function main {
  $pf = create-playfield -x 0 -y 2 -width 120 -height 58 -bg "black"

$dragontxt = @"
      .==.        .==.
     //'^\\      //^'\\
    // ^ ^\(\__/)/^ ^^\\
   //^ ^^ ^/6  6\ ^^ ^^\\
  //^ ^^ ^ ( .. ) ^ ^^^ \\
 // ^^ ^/\//v""v\\/\^ ^ ^\\
// ^^/\/  / '~~' \  \/\^ ^\\
\\^ /    / ,    , \    \^ //
 \\/    ( (      ) )    \//
  ^      \ \.__./ /      ^
         ((('  ')))
"@
  $dragonlines = $dragontxt.replace("`r","X").replace("`n","").split("X")
  $yellowdragon = create-image $dragonlines -fg "yellow" -bg "black"
  $reddragon = create-image $dragonlines -fg "red" -bg "black"
  $bluedragon = create-image $dragonlines -fg "blue" -bg "black"

  $rnd = new-object Random

  $init = {
    $s=$args[0]
    $s.xoff=60-15;$s.yoff=28-6-2; $s.xamp=45;$s.yamp=18; 
    $s.xangle=$rnd.nextdouble(); $s.yangle=$rnd.nextdouble() 
    $s.xspeed = $rnd.nextdouble()/10 + 0.02
    $s.yspeed = $rnd.nextdouble()/10 + 0.01
  }
  $move = { 
    $s=$args[0]
    $s.x = [Math]::cos($s.xangle) * $s.xamp + $s.xoff
    $s.y = [Math]::cos($s.yangle) * $s.yamp + $s.yoff
    $s.xangle += $s.xspeed #0.08
    $s.yangle += $s.yspeed #0.07
  }
    
  $handlers = create-spritehandlers -didinit $init -willdraw $move

  $sprites = @()
  foreach ($img in ($yellowdragon,$reddragon,$bluedragon) ) {
    $s = create-sprite -images @($img) -x 10 -y 10 -handlers $handlers
    $sprites += $s
  }

  # game loop
  [int]$fc = 0
  while ($true) {
    $fc++
    clear-playfield $pf
    draw-sprites $pf $sprites
    flush-playfield $pf
    sleep -millis 40
  }
}

main

