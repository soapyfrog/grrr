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


# load modules
. ..\lib\grrr.ps1

init-console 100 50
write-host "dragon sprites with transparancy (ie not opaque rectangles)"


function main {
  $pf = create-playfield -x 0 -y 2 -width 100 -height 48 -bg "black"

  # we use a 'here' string for ease of typing.
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
  # replace the lower case x with small dots
  $dragontxt = $dragontxt.replace("x",[string][char]0x00b7)
  # split into lines
  $dragonlines = $dragontxt.replace("`r","W").replace("`n","").split("W")
  # -transparent 32 means that a space will be transparent
  $yellowdragon = create-image $dragonlines -fg "white" -bg "darkgray" -transparent 32
  $reddragon = create-image $dragonlines -fg "yellow" -bg "darkred" -transparent 32
  $bluedragon = create-image $dragonlines -fg "cyan" -bg "darkmagenta" -transparent 32

  $rnd = new-object Random

  # handlers for the dragon sprites
  # init just sets up the basic vars in the sprite
  $init = {
    $s=$args[0]
    $s.xoff=50-15;$s.yoff=23-6-2; $s.xamp=43;$s.yamp=16; 
    $s.xangle=$rnd.nextdouble(); $s.yangle=$rnd.nextdouble() 
    $s.xspeed = $rnd.nextdouble()/10 + 0.02
    $s.yspeed = $rnd.nextdouble()/10 + 0.02
  }
  # move varies the angle and computes the x,y position
  $move = { 
    $s=$args[0]
    $s.x = [Math]::cos($s.xangle) * $s.xamp + $s.xoff
    $s.y = [Math]::cos($s.yangle) * $s.yamp + $s.yoff
    $s.xangle += $s.xspeed
    $s.yangle += $s.yspeed
  }
  
  # wrap the two handlers in to a single handlers object
  $handlers = create-spritehandlers -didinit $init -willdraw $move

  # create 3 dragon sprites in an array
  $sprites = @()
  foreach ($img in ($yellowdragon,$reddragon,$bluedragon) ) {
    $s = create-sprite -images @($img) -x 10 -y 10 -handlers $handlers
    $sprites += $s
  }

  # game loop - ctrl+c to quit
  while ($true) {
    clear-playfield $pf
    draw-sprites $pf $sprites
    flush-playfield $pf -sync 40 # so frame rate is 25 (1000/40)
  }
}

# off we go
main

