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

# $Id: sprite.ps1 199 2007-02-08 13:11:41Z adrian $

# demo1 for grrr.ps1
# run this as a script - do not 'source' it with '.'

$global:___globcheck___=1
$local:___globcheck___=2
if ($global:___globcheck___ -eq 2) {throw "This should not be sourced in global scope"}


cls
init-console 120 50
write-host "Sprites with manual (yellow) and path based (red) movement."


function main {
  $pf = create-playfield -x 0 -y 2 -width 78 -height 48 -bg "black"

  # create the anim frames for the yellow aliens
  $l1 = [char]0x2554 + [char]0x256a + [char]0x2557
  $l2a = [char]0x255d + " " + [char]0x255a
  $l2b = [char]0x2551 + " " + [char]0x2551
  $l2c = [char]0x255a + " " + [char]0x255d
  $imga1 = create-image $l1,$l2a -fg "yellow" -bg "black"
  $imga2 = create-image $l1,$l2b -fg "yellow" -bg "black"
  $imga3 = create-image $l1,$l2c -fg "yellow" -bg "black"

  # an array of sprites
  $sprites = @()
  # motion behaviour handlers - a somewhat manual approach - see below for alternative
  $handler = create-spritehandler -didinit {$args[0].state.dx = 1 } -willdraw {
            $s = $args[0]; $st=$s.state
            if ($s.x -gt 72) { $s.y++; $s.state.dx=-1 }
            elseif ($s.x -lt 4) { $s.y--; $s.state.dx=1 }
            $s.x += $s.state.dx
          }
  $images = @($imga1,$imga2,$imga3,$imga2)
  # build a load of them
  0..15 | foreach {
    [int]$n=$_
    $x = [Math]::Floor($n / 4) * 7 + 4
    $y = ($n % 4) * 4 + 3
    $sa = create-sprite -images $images -x $x -y $y -handler $handler -animrate 8
    $sprites += $sa
  }

$script:hits = 0
  # create another one with different behaviour
  $imgb = create-image "/\","\/" -fg "red" -bg "black"
  $mp = create-motionpath "20e 6ne 20n 4ne 4e 4se 4s 4sw 8w 12s 6sw 20w 5h"
  $h = create-spritehandler -didoverlap {
    $me = $args[0]; $other=$args[1];
    $script:hits++
    $other.alive = $false
  }
  $spr = create-sprite -images @($imgb) -x 10 -y 42  -motionpath $mp -handler $h

  # game loop
  $debugline=" "
  #$hits = 0
  while ($true) {
    clear-playfield $pf
    draw-string $pf $debugline 0 0 red
    draw-sprite $pf $sprites
    draw-sprite $pf $spr
    test-spriteoverlap $spr $sprites -nooutput $true
    flush-playfield $pf -sync 20 
    $fps = $pf.FPS
    $debugline = "$fps fps (target 50) hits=$hits"
  }
}

main

