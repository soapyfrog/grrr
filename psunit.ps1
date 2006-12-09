# --------------------------
# run the test suite
#
function run-tests {
  echo "--- Starting tests ---"
  ls function:test* | foreach {
    write-host -noNewLine "--- Running: $_ ..."
    $dur = measure-command { & $_ }
    $ms = $dur.TotalMilliseconds
    write-host " done in $ms ms"
  }
  echo "--- Tests complete ---"
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

