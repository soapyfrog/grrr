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

# --------------------------
# run the test suite
#
function run-tests {
  write-host "--- Starting tests ---"
  ls function:test* | foreach {
    write-host -noNewLine "Running `"$_`" ... "
    $dur = measure-command { & $_ }
    $ms = $dur.TotalMilliseconds
    write-host " done in $ms ms"
  }
  write-host "--- Tests complete ---"
}



# --------------------------
# assert equal
#
function assert-equal ($msg, $expected, $actual) {
  if ($expected -ne $actual) {
    throw "$msg : expected $expected, got $actual"
  }
}


# --------------------------
# assert not equal
#
function assert-not-equal ($msg, $notexpected, $actual) {
  if ($notexpected -eq $actual) {
    write-error "$msg : did not expect: $actual"
  }
}

# --------------------------
# assert true
#
function assert-true ($msg, $val) {
  if (!$val) {
    write-error "$msg : value was false"
  }
}

# --------------------------
# assert false
#
function assert-false ($msg, $val) {
  if ($val) {
    write-error "$msg : value was true"
  }
}


