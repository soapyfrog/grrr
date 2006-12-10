#------------------------------------------------------------------------------
# grrr.ps1 
#
# A source-able PowerShell module to handle playfields,
# sprites, tiles, scrolling, eventing and other stuff
# that can be useful in writing games.
#
# To use this in a script:
# . grrr.ps1
#
# All functions etc will be created in the calling scope.
#
#------------------------------------------------------------------------------



#------------------------------------------------------------------------------
# Creates a play field.
#
# A play field is rectangular piece of console in the
# visible window, with a backing buffer of the same
# size outside the visible window.
#
# Drawing is always done in the backing buffer, then
# flushed to the visual buffer to give the illusion
# of instant rendering.
#
# See clear-playfield, flush-playfield, etc.
#
# The console should be set up appropriately before
# calling this (ie number of rows/cols, windows size
# and position).
#
# TODO: this semi-assumes that the visual part of the 
# console is at the top - likely in most uses, but
# perhaps should not do so.
#
function create-playfield {
  param(
      [int]$width=80,               # width of playfield
      [int]$height=25,              # height of playfield
      [int]$x,[int]$y,              # top left of the visual part
      [string]$bg="black"           # background colour (default black)
      )

  # back buffer goes at the bottom of the console buffer
  # TODO: need to handle different back buffers
  [int]$by = ($host.ui.rawui.BufferSize.Height - $height - 10) # 10 to give room for tile printing
  [int]$bx = 10

  return @{
    # vcoord and vrect are for the visual bit
    "vcoord" = new-object Management.Automation.Host.Coordinates -argumentList $x,$y
    "vrect"  = new-object Management.Automation.Host.Rectangle -argumentList $x,$y,($x+$width-1),($y+$height-1)
    # bcoord and brect are for the back buffer bit
    "bcoord" = new-object Management.Automation.Host.Coordinates -argumentList $bx,$by
    "brect"  = new-object Management.Automation.Host.Rectangle -argumentList $bx,$by,($bx+$width-1),($by+$height-1)

    # default background fill cell
    "fillcell" = new-object Management.Automation.Host.BufferCell -argumentList ' ',"white",$bg,"Complete" 
  }
}

#------------------------------------------------------------------------------
# Clears the back buffer of the playfield
#
# To see the results, flush-playfield
#
function clear-playfield {
  param(
      $playfield = $(throw "you must supply a playfield"),
      [string]$bg           # optional colour - if ommitted, uses playfield default
      )
  if ($bg -eq "") { $fillcell = $playfield.fillcell }
  else { $fillcell = new-object Management.Automation.Host.BufferCell -argumentList ' ',"white",$bg,"Complete" }
  $host.ui.rawui.SetBufferContents($playfield.brect,$fillcell)
}


#------------------------------------------------------------------------------
# Flushes a play field to visual buffer
#
# This copies the content of the back buffer to the
# visual buffer
#
function flush-playfield {
  param(
      $playfield = $(throw "you must supply a playfield")
      )
  $blitcells = $host.ui.rawui.GetBufferContents($playfield.brect)
  $host.ui.rawui.SetBufferContents($playfield.vcoord,$blitcells)
}



#------------------------------------------------------------------------------
# Create an image
#
# An image is made of of one or more lines of text with a specific
# foreground and background colour.
#
# Internally, it is converted into a BufferCell array
#
# The lines in the array do not need to be the same length; the resulting
# rectangle will be as wide as the largest string, with spaces padding
# the shorter ones on the right.
#
function create-image {
  param(
    [string[]] $lines=@("X"), # an array of text lines (should be same length)
    [string]$fg = "white",    # foreground colour (default white) 
    [string]$bg = "black"     # background colour (default black)
    ) 

  $lines | foreach {[int]$width=0}{$width = [Math]::Max($_.length,$width)}
  $height = $lines.count

  # create a buffercellarray 
  $bca = $host.ui.RawUI.NewBufferCellArray( $lines, $fg, $bg )

  return @{
    "bca"     = $bca     # array of buffercell arrays
    "width"   = $width
    "height"  = $height
  }
}


#------------------------------------------------------------------------------
# Draw an image into the back buffer of a playfield
#
function draw-image {
  param(
      $playfield = $(throw "you must supply a playfield"),
      $image = $(throw "you must supply an image"),
      [int]$x,
      [int]$y
      )
  $coord = new-object Management.Automation.Host.Coordinates -argumentList ($playfield.bcoord.X+$x),($playfield.bcoord.Y+$y)  
  $host.ui.rawui.SetBufferContents($coord,$image.bca)
  
}


#------------------------------------------------------------------------------
# Create a sprite.
#
# A sprite is set of animated images frames with a position (x,y) a depth
# and assorted other meta data, such as liveness.
#
# All the script blocks take the sprite as the first param ($args[0]).
#
function create-sprite {
  param(
    [object[]]$images = $(throw "you must supply an array of images"),
    [int]$x = 0,                  # initial x position
    [int]$y = 0,                  # initial y position
    [int]$z = 0,                  # initial z position
    [boolean]$alive = $true,      # initial live status (won't be drawn if not alive)
    [scriptblock]$didinit=$null,  # optional block to be called after initialising
    [scriptblock]$willdraw=$null, # optional block to be called before drawing
    [scriptblock]$diddraw=$null   # optional block to be called before drawing
    )
  
  $sprite = @{
    "images"      = $images
    "x"           = $x
    "y"           = $y
    "z"           = $z
    "alive"       = $alive
    "numframes"   = ($images.count)
    "fseq"        = 0               # frame sequence
    # script blocks used to control sprite
    "didinit"     = $didinit
    "willdraw"    = $willdraw
    "diddraw"     = $diddraw
  }
  if ($didinit) { & $didinit $sprite }
  return $sprite
}


#------------------------------------------------------------------------------
# Draw a sprite in the back buffer of the play field, using the next
# frame of animation, or the specified frame.
#
# TODO: deal with alive, and states
#
function draw-sprite {
  param(
      $playfield = $(throw "you must supply a playfield"),
      $sprite = $(throw "you must supply a sprite"),
      [int]$frame = -1     # which frame to draw (default is auto)
      )
  if ($sprite.willdraw) { &($sprite.willdraw) $sprite }
  if ($frame -eq -1) {
    $sprite.fsec = (($sprite.fsec+1) % ($sprite.numframes))
  }
  else {
    $sprite.fsec = ($frame % ($sprite.numframes))
  }
  draw-image $playfield ($sprite.images[$sprite.fsec]) $sprite.x $sprite.y
  if ($sprite.postdraw) { &($sprite.postdraw) $sprite }
}

    
#------------------------------------------------------------------------------
# Determine if two sprites are overlapping
#
# Returns $true if they are, $false if not.
#
function overlap-sprite {
  param(
    $s1 = $(throw "you must supply sprite s1"),
    $s2 = $(throw "you must supply sprite s2")
    )
  # TODO: this is fairly efficient except for all the derefs :(
  $s1image = $s1.images[$s1.fseq]
  $s2image = $s2.images[$s2.fseq]
  [int]$s1right = $s1.x + $s1image.width 
  [int]$s2right = $s2.x + $s2image.width 
  [int]$s1bottom = $s1.y + $s1image.height 
  [int]$s2bottom = $s2.y + $s2image.height 
  return ! ($s2.x -ge $s1right -or $s2right -lt $s1.x -or $s2.y -ge $s1bottom -or $s2bottom -lt $s1.y ) 
}


#------------------------------------------------------------------------------
# Draw a set of sprites on the playfield
#
# TODO: only draw sprites that are on the playfield
#
function draw-sprites {
  param(
      $playfield = $(throw "you must supply a playfield"),
      $sprites = $(throw "you must supply a sprite array, sprites")
      )
  $sprites | where { $_.alive} | foreach {
    draw-sprite -playfield $playfield -sprite $_
  }
}



#------------------------------------------------------------------------------
# Create a tilemap - used for drawing large tile-based maps from a char based
# mapping to images.
#
function create-tilemap {
  param(
    [string[]] $lines = $(throw "lines missing: array of strings"),
    $imagemap = $(throw "imagemap missing: hash of char to image"),
    [int]$tilewidth = 3,
    [int]$tileheight = 2
  ) 
 
  return @{
    "lines"     = $lines
    "imagemap"  = $imagemap
    "tileheight"= $tileheight
    "tilewidth" = $tilewidth
    "mapheight" = $lines.length
    "mapwidth"  = $lines[0].length
  }
}

#------------------------------------------------------------------------------
# Draw the tilemap into the playfield with specified cell offset.
#
function draw-tilemap {
  param(
      $playfield = $(throw "you must supply a playfield"),
      $tilemap = $(throw "you must supply a tilemap"),
      $offsetx = 0,         # x offset into the tilemap
      $offsety = 0,         # y offset into the tilemap
      $x = 0, $y = 0,       # x,y pos in playfield to draw
      $w = 0, $h = 0        # width, height to draw in playfield (default is available width)
    )

  # tw,th is an optimisation to avoid requerying the hash
  [int]$tw = $tilemap.tilewidth
  [int]$th = $tilemap.tileheight
  # other optimisations
  [int]$numlines=$tilemap.lines.length

  # make a negative offset in the playfield to start drawing tiles
  $x -= ($offsetx % $tw)
  $y -= ($offsety % $th)
  
  # tx,ty is the index into the tile character map
  [int]$tx = [Math]::Floor($offsetx / $tw)
  [int]$ty = [Math]::Floor($offsety / $th)

  # these vars get reset after the inner loop, so we save them here
  [int]$txsaved = $tx
  [int]$xsaved = $x

  # boundary x/y
  [int]$bx = $x + $w + $tw
  [int]$by = $y + $h + $th

  # draw the tiles
  while ($y -lt $by -and $ty -lt $numlines) {
    $line = $tilemap.lines[$ty]
    while ($x -lt $bx -and $tx -lt $line.length) {
      [string]$ch = $line[$tx]
      $img = $tilemap.imagemap[$ch]
      if ($img) { draw-image $playfield $img $x $y }
      $tx++
      $x += $tw
    }
    $ty++
    $y += $th
    #reset outer loop vars
    $tx = $txsaved
    $x = $xsaved
  }
}
