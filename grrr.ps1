#-------------------------------------------------------
# grrr.ps1 
#
# Support for sprites 
#
# To use this in a script:
# . grrr.ps1
#
# All functions etc will be created in the calling scope.
#
#-------------------------------------------------------





#-------------------------------------------------------
# Create a sprite image
# A sprite image has width and height (a number of lines)
# and a colour
# It is used by a sprite
#
# If frames is: ("ABC","DEF"),("123","456")
# this will produce a 3x2 image that is ABC for first frame then 123
#                                       DEF                      456
#
# -frames     an array of array of string (described above)
# -fg         foreground colour (default "white")
# -bg         background colour (default "black")
#
function create-image {
  param(  [object[]] $frames, [string]$fg, [string]$bg ) # TODO should make frames a 3-rank string array

  if ($fg -eq "") { $fg = "white" }
  if ($bg -eq "") { $bg = "black" }
  $numframes = [int]$frames.length
  $width = $frames[0][0].length
  $height = [int]$frames[0].length

  # create a buffercellarray for each frame
  $bcaa = [object[,]]@()
  for ([int]$i = 0; $i -lt $frames.length; $i++) {
    $bca = $host.ui.RawUI.NewBufferCellArray( $frames[$i], $fg, $bg )
    $bcaa += 1  # += doesn't work when adding subarrays
    $bcaa[-1] = $bca
  }

  # create a buffercellarray for a blank
  [string]$blank = " " * $width
  [string[]]$blankarray = @()
  for ($i=0; $i -lt $height; $i++ ) {
    $blankarray += $blank 
  }
  $ebca = $host.ui.RawUI.NewBufferCellArray( $blankarray, $fg, $bg )

  return @{
    "frames"    = $bcaa     # array of buffercell arrays
    "width"     = $width
    "height"    = $height
    "eraser"    = $ebca     # eraser bca
    "numframes" = $numframes
  }
}


#-------------------------------------------------------
# create a basic sprite 
# takes x,y coords and an image
#
# the img bit is an object returned by create-image
# Takes lots of params - probably best to use them named so you can pick and choose:
#
# -x -y -z    Initial position. z is used for layering
# -img        An image created by create-image
#
function create-sprite {
  param([int]$x, [int]$y, [object]$img)
  return @{
    "x"       = $x
    "y"       = $y
    "z"       = [int]0
    "img"     = $img
    "oldx"    = [int]-1                 # used to remember where it was last drawn
    "oldy"    = [int]-1
  }
}


#-------------------------------------------------------
# render the specified sprite in its specified position
# optionally moved dx,dy first
# frame is used to show which anim frame to use
# erases it from any previous position
#
# -sprite   sprite to update
# -dx       amount to move x before updating (default 0)
# -dy       amount to move y before updating (default 0)
# -frame    which frame to draw (default 0)
#
function update-sprite ($sprite,[int]$dx,[int]$dy,[int]$frame) {
  [int]$f = $frame % $sprite.img.numframes
  $ui = $host.UI.RawUI
  # move if dx/dy given
  $sprite.x += $dx
  $sprite.y += $dy
  # erase old pos (if any)
  if ($sprite.oldx -ge 0) {
    [int]$y = $sprite.oldy
    $coord = new-object Management.Automation.Host.Coordinates -argumentList $sprite.oldx,$sprite.oldy
    $ui.SetBufferContents($coord, $sprite.img.eraser)
  }
  # draw in new position
  $coord = new-object Management.Automation.Host.Coordinates -argumentList $sprite.x,$sprite.y
  $ui.SetBufferContents($coord,$sprite.img.frames[$f])
  # update old with current
  $sprite.oldx = $sprite.x
  $sprite.oldy = $sprite.y
}


#-------------------------------------------------------
# returns $true if the two sprites overlap else $false
#
# -s1   first sprite
# -s2   second sprite
#
function overlap-sprite ($s1,$s2) {
  [int]$s1right = $s1.x + $s1.img.width - 1
  [int]$s2right = $s2.x + $s2.img.width - 1
  [int]$s1bottom = $s1.y + $s1.img.height - 1
  [int]$s2bottom = $s2.y + $s2.img.height - 1
  return ! ($s2.x -gt $s1right -or $s2right -lt $s1.x -or $s2.y -gt $s1bottom -or $s2bottom -lt $s1.y )
}
