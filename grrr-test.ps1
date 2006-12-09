# test cases for grrr.ps1
# run this as a script - do not 'source' it with '.'

$global:___globcheck___=1
$local:___globcheck___=2
if ($global:___globcheck___ -eq 2) { write-error "This should not be source in global scope"; return }


cls

# load module
. .\unittest.ps1
. .\grrr.ps1


#-------------------------------------------------------
# Test creation of images, drawing
#
function test-create-image {
  $img = create-image -frames ("<#>","/ \"),("<#>","| |") 
  assert-equal "width" 3 $img.width
  assert-equal "height" 2 $img.height
  assert-equal "numframes" 2 $img.numframes
}


#-------------------------------------------------------
# Test creation of sprites, drawing
#
function test-create-sprite {

# create a sprite and verify its properties
  $image = create-image -frames ("<#>","/ \"),("<#>","| |") 
  $b = create-sprite -x 5 -y 10 -img $image

  assert-equal "x" 5 $b.x
  assert-equal "y" 10 $b.y

# create a collection of sprites

  $sprites = @()
  0..4 | foreach {
    [int]$y = 15 + $_ * 3
    0..4 | foreach {
      [int]$x = 5 * $_
      $b = create-sprite -x $x -y $y -img $image
      $sprites += $b
    }
  }

# do some ops on the collection
  $toprow = ( $sprites | where { $_.y -lt 16 } ).count
  if ($toprow -ne 5 ) { write-error "number in top row is wrong: $toprow should be 5" }


# animate the collection
  1..5 | foreach {
    [int]$f = $_ / 4
    $sprites | foreach { update-sprite -dx 1 -dy 0 -frame $f $_ }
  }

}

#-------------------------------------------------------
# test sprite overlapping (collision detection)
function test-overlap-sprite {
 $image = create-image -frames ("UVW","XYZ"),("UVW","XYZ")
 $b1 = create-sprite -x 10 -y 20 -img $image
 $b2 = create-sprite -x 10 -y 20 -img $image
 assert-true "should overlap" (overlap-sprite $b1 $b2)
 $b2 = create-sprite -x 12 -y 22 -img $image
 assert-false "should not overlap" (overlap-sprite $b1 $b2)
}


# hand over to unit test framework
run-tests
