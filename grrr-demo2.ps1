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
  $pf = create-playfield -x 0 -y 2 -width 80 -height 40 -bg "black"

  $imga = create-image "###","###" -fg "blue" -bg "darkgreen"
  $imgb = create-image "@@@","@@@" -fg "yellow" -bg "darkmagenta"
  $imgc = create-image "///","///" -fg "white" -bg "darkgray"

  $map = @{"A"=$imga; "B"=$imgb; "C"=$imgc}

  $backlines  = "                                                                             ",
                "BBA       BBA     BBBA               BBBBBA         BBA      A      BBBA  BBB",
                "BBBBA   BBBBBA   BBBBBA             BBBBBBBA       BBBBA    BBA    BBBBBBBBBB",
                "BBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBB"

  $frontlines = "     C         C        C                  C              C              C   ", 
                "     C         C        C                  C              C              C   ",  
                "     C        CC        CC                 C              C              C   ",
                "     C        CCC      CCCC               CCC            CCCC           CCC  "

  $backtm = create-tilemap $backlines $map 3 2
  $fronttm = create-tilemap $frontlines $map 3 2

  # game loop
  [int]$fc = 0;
  while ($true) {
    $fc++
    $fx = $fc % $fronttm.mapwidth
    $bx = [Math]::Floor($fc/2) % $backtm.mapwidth

    clear-playfield $pf
    draw-tilemap $pf $backtm -offsetx $bx -offsety 0 -x 0 -y 25 -w 80 -h 12
    draw-tilemap $pf $fronttm -offsetx $fx -offsety 0 -x 0 -y 25 -w 80 -h 12
    flush-playfield $pf
    sleep -millis 2
  }
}

main

