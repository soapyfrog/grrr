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

# $Id: dragon.ps1 146 2007-01-21 12:21:35Z adrian $

# demo for grrr.ps1
# run this as a script - do not 'source' it with '.'

$global:___globcheck___=1
$local:___globcheck___=2
if ($global:___globcheck___ -eq 2) {throw "This should not be sourced in global scope"}


init-console 100 50
cls
write-host "dragon sprites with transparancy (ie not opaque rectangles)"


function main {
  $pf = create-playfield -x 0 -y 2 -width 100 -height 48 -background "black"

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
  $yellowdragon = create-image $dragonlines -foreground "white" -background "darkgray" -transparent 32
  $reddragon = create-image $dragonlines -foreground "yellow" -background "darkred" -transparent 32
  $bluedragon = create-image $dragonlines -foreground "cyan" -background "darkmagenta" -transparent 32

  $rnd = new-object Random

  # handlers for the dragon sprites
  # init just sets up the basic vars in the sprite
  $init = {
    $s=$args[0]; $st=$s.state
    $st.xoff=50-15;$st.yoff=23-6-2; $st.xamp=43;$st.yamp=16; 
    $st.xangle=$rnd.nextdouble(); $st.yangle=$rnd.nextdouble() 
    $st.xspeed = $rnd.nextdouble()/10 + 0.02
    $st.yspeed = $rnd.nextdouble()/10 + 0.02
  }
  # move varies the angle and computes the x,y position
  $move = { 
    $s=$args[0]; $st=$s.state
    $s.X = [Math]::cos($st.xangle) * $st.xamp + $st.xoff
    $s.Y = [Math]::cos($st.yangle) * $st.yamp + $st.yoff
    $st.xangle += $st.xspeed
    $st.yangle += $st.yspeed
  }
  
  # wrap the two handlers in to a single handlers object
  $handler = create-spritehandler -didinit $init -didmove $move

  # create 3 dragon sprites in an array
  $sprites = @()
  foreach ($img in ($yellowdragon,$reddragon,$bluedragon) ) {
    $s = create-sprite -images @($img) -x 10 -y 10 -handler $handler
    $sprites += $s
  }

  $debugline=" "
  # game loop - ctrl+c to quit
  while ($true) {
    clear-playfield $pf
    move-sprite $sprites
    draw-sprite $pf $sprites
    draw-string $pf $debugline 0 0 "red"
    flush-playfield $pf -sync 33 
    $fps = $pf.FPS
    $debugline = "$fps fps (target 50)"
  }
}

# off we go
main

