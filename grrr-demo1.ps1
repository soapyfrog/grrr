# demo1 for grrr.ps1
# run this as a script - do not 'source' it with '.'

$global:___globcheck___=1
$local:___globcheck___=2
if ($global:___globcheck___ -eq 2) {throw "This should not be source in global scope"}


cls

# load modules
. .\grrr.ps1


function main {
  $pf = create-playfield -width 80 -height 30 -bg "black"
  $imga1 = create-image "<#>","/ \" 
  $imga2 = create-image "<#>","| |"

  $sa = create-sprite -images @($imga1,$imga2) -x 10 -y 10


  clear-playfield $pf
  draw-sprite $pf $sa
  flush-playfield $pf
}

main

