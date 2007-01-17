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

init-console 256 130
write-host "big space invaders demo - using original graphics!!"


function main {
  $pf = create-playfield -x 0 -y 2 -width 100 -height 48 -bg "black"

  # create the space invader graphics
  $rawimages = @{
  invc0 = @"
    IIII
 IIIIIIIIII
IIIIIIIIIIII
III  II  III
IIIIIIIIIIII
   II  II
  II II II
II        II
"@


  invc1 = @"
    IIII
 IIIIIIIIII
IIIIIIIIIIII
III  II  III
IIIIIIIIIIII
  III  III
 II  II  II
  II    II
"@


  invb0 = @"
  I     I
   I   I
  IIIIIII
 II III II
I IIIIIII I
I IIIIIII I
I I     I I
   II II
"@


  invb1 = @"
  I     I
I  I   I  I
I IIIIIII I
III III III
IIIIIIIIIII
 IIIIIIIII
  I     I
 I       I
"@


  inva0 = @"
   II
  IIII
 IIIIII
II II II
IIIIIIII
 I II I
I      I
 I    I
"@


  inva1 = @"
   II
  IIII
 IIIIII
II II II
IIIIIIII
  I  I
 I II I
I I  I I
"@


  base = @"
     I
    III
 IIIIIIIII
IIIIIIIIIII
IIIIIIIIIII
IIIIIIIIIII
"@


  bomba = @"
 I
  I
 I
I
 I
"@


  bombb = @"
 I
 I
II
 II
 I
"@


  missile = @"
I
I
I
"@


  mothership = @"
     IIIIII
   IIIIIIIIII
  IIIIIIIIIIII
 II II II II II
IIIIIIIIIIIIIIII
  III  II  III
   I        I
"@
  }

  # now replace the I chars with blocks and break into lines
  # then create an image
  $t = @{}
  foreach ($key in $rawimages.keys) {
    $txt = $rawimages[$key]
    $txt = $txt.replace("I",[string][char]9608)
    $lines = $txt.replace("`r","W").replace("`n","").split("W")
    $t[$key] = (create-image $lines "green" "black")
  }

  # now create a field of aliens
  $sprites = @()
  # handlers for motion
  $dir = @{current="R"; next="R"} # shared state for all sprites
  $init = {
    $args[0].dir = $dir
  }
  $move = { 
    $s=$args[0]
    $dx = 2
    $dy = 6
    $d = $s.dir
    switch ($d.current) {
      "R" {
        $s.x+=$dx
        if ($s.x -gt 200) { $d.next="DL" }
      }
      "L" {
        $s.x-=$dx
        if ($s.x -lt 10) { $d.next="DR" }
      }
      "DL" {
        $s.y+=$dy
        $d.next="L"
      }
      "DR" {
        $s.y+=$dy
        $d.next="R"
      }
    }
  }
  $handlers = create-spritehandlers -didinit $init -willdraw $move
  $y = 5
  $xo = 2
  "inva","invb","invc" | foreach {
    $i = $_
    for ($x=0; $x -lt 5; $x++) {
      $ip = $t["$i"+"0"],$t["$i"+"1"]
      $s = create-sprite -images $ip -x ($xo+10+20*$x) -y $y -handlers $handlers
      $sprites += $s
    }
    $xo -= 1
    $y += 13
  }

  $pf = create-playfield -x 0 -y 2 -width 256 -height 126 -bg "black"

  while ($true) {
    clear-playfield $pf
    draw-sprites $pf $sprites
    $dir.current = $dir.next
    flush-playfield $pf -sync 40
  }
}

# off we go
main

