# demo1 for grrr.ps1
# run this as a script - do not 'source' it with '.'

$global:___globcheck___=1
$local:___globcheck___=2
if ($global:___globcheck___ -eq 2) {throw "This should not be sourced in global scope"}


cls

# load modules
. .\grrr.ps1

#--------------------------------------------------------------------
# Parallelax scrolling demo
#
function main {
  $pf = create-playfield -x 0 -y 2 -width 78 -height 33 -bg "black" #78? multiple of 3

  $imga = create-image "'''","'''" -fg "blue" -bg "darkmagenta"
  $imgb = create-image "@@@","@@@" -fg "darkblue" -bg "darkmagenta"

  $imgc = create-image "{|}","{:}" -fg "red" -bg "darkred"
  $imgd = create-image "/=\","\=/" -fg "yellow" -bg "red"
  $imge = create-image "\=/","/=\" -fg "yellow" -bg "red"
  
  $imgx = create-image "<=>"," W " -fg "magenta" -bg "black"
  $imgy = create-image " | ","/%\" -fg "yellow" -bg "black"

  $map = @{"A"=$imga; "B"=$imgb; "C"=$imgc; "D"=$imgd; "E"=$imge; "X"=$imgx; "Y"=$imgy}

  $backlines  = "                   BA                                        BA     ",
                "BBA        BA      BBA                BBBBBBA        BA      BBA    ",
                "BBBBA    BBBBA   BBBBBA              BBBBBBBBBA    BBBBA   BBBBBA   ",
                "BBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBB"

  $frontlines = "     C         D       E                     C         D       E  ", 
                "    CCC       YC       C                    CCC       YC       C  ",  
                "     C        CC    Y  CC     Y              C        CC    Y  CC ",
                "     CCC  X   CCC   CCCCCC X CCC  Y          CCC  X   CCC   CCCCCC",
                "CCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCC"

  $backtm = create-tilemap $backlines $map 3 2
  $fronttm = create-tilemap $frontlines $map 3 2

  #wrap points
  [int]$backwp = $backtm.tilewidth * $backtm.mapwidth-78
  [int]$frontwp = $backtm.tilewidth * $fronttm.mapwidth-78

  # create sprites to complete the look
  $thrustimg1 = create-image @(">") -fg "yellow" -bg "black"
  $thrustimg2 = create-image @("=") -fg "red" -bg "black"
  $rocketimg = create-image " o  ","D#>-" -fg "white" -bg "black"

  $thrustsprite = create-sprite -images $thrustimg1,$thrustimg2 -x 4 -y 9
  $rocketsprite = create-sprite -images @($rocketimg) -x 5 -y 8

  $sprites = $thrustsprite,$rocketsprite

  # game loop
  [int]$fc = 0;
  while ($true) {
    $fc++
    $fx = $fc % $frontwp
    $bx = [Math]::Floor($fc/2) % $backwp

    clear-playfield $pf
    draw-tilemap $pf $backtm -offsetx $bx -offsety 0 -x 0 -y 25 -w 78 -h 12
    draw-tilemap $pf $fronttm -offsetx $fx -offsety 0 -x 0 -y 24 -w 78 -h 15
    draw-sprites $pf $sprites
    flush-playfield $pf
    sleep -millis 2 # wish this could be negative :-)
  }
}

main

