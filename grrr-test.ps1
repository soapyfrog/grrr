# test cases for grrr.ps1
# run this as a script - do not 'source' it with '.'

$global:___globcheck___=1
$local:___globcheck___=2
if ($global:___globcheck___ -eq 2) { write-error "This should not be source in global scope"; return }


cls

# load modules
. .\psunit.ps1
. .\grrr.ps1



#----------------------------------------------------------------
# Tests various modes of creating a playfield
#
function test-create-playfield {
  $pf = create-playfield -width 30 -height 20 
  assert-equal "vx" 0 $pf.vcoord.X
  assert-equal "vy" 0 $pf.vcoord.Y
  assert-equal "vr" (30-1) $pf.vrect.Right
  assert-equal "vb" (20-1) $pf.vrect.Bottom
  assert-equal "background" "black" $pf.fillcell.BackgroundColor

  $pf = create-playfield -width 30 -height 20 -x 5 -y 6 -colour "red"
  assert-equal "vx" 5 $pf.vcoord.X
  assert-equal "vy" 6 $pf.vcoord.Y
  assert-equal "vr" (5+30-1) $pf.vrect.Right
  assert-equal "vb" (6+20-1) $pf.vrect.Bottom
  assert-equal "background" "red" $pf.fillcell.BackgroundColor
}


#----------------------------------------------------------------
# this is more of a visual test, so really only tests syntax 
# TODO: put checks in to verify colours on screen
#
function test-clear-playfield {
  # create playfield over to the right
  $pf = create-playfield -x 70 -y 0 -width 30 -height 20 -colour "red"
  clear-playfield $pf
  flush-playfield $pf
  $pf = create-playfield -x 72 -y 2 -width 30 -height 20 # default colour
  clear-playfield $pf
  flush-playfield $pf
  $pf = create-playfield -x 74 -y 4 -width 30 -height 20 -colour "green"
  clear-playfield $pf
  flush-playfield $pf
}




#----------------------------------------------------------------
# hand over to unit test framework
run-tests
