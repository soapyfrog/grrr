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

# $Id$

# --------------------------
# run the test suite
#
function run-tests {
  $results = @()
  ls function:test* | foreach {
    $script:r="passed"
    $script:n=$_.name
    $script:er=$null
    trap [object] {
      $script:er = $_
      write-warning "`"$script:n`" failed : $_"
      $script:r="failed"
      continue
    }
    $dur = measure-command { & $_ }
    $ms = $dur.TotalMilliseconds
    # put results in to an object with properties so makes sense in pipeline
    # pity lists of hashes can be treated this way :-(
    $res = add-member -i (new-object object) -type "noteproperty" -name "name" -value $_.name -force -passthru
    $res = add-member -i $res -type "noteproperty" -name "duration" -value $ms -force -passthru
    $res = add-member -i $res -type "noteproperty" -name "result" -value "$script:r" -force -passthru
    $err = $( if ($r -ne "passed") { $script:er } else { "" } )
    $res = add-member -i $res -type "noteproperty" -name "error" -value $err -force -passthru
    $results += $res
  }
  # put results in pipe - receiver can do what it likes with it.
  $results | select name,duration,result,error
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


# --------------------------
# assert null
#
function assert-null ($msg, $val) {
  if ($val -ne $null) {
    write-error "$msg : value was not null"
  }
}


# --------------------------
# assert not null
#
function assert-notnull ($msg, $val) {
  if (! $val) {
    write-error "$msg : value was null"
  }
}

