#!/bin/sh

. ./config.sh

proc_dot() {
  echo proc $1
  find $1/* -type f -name "*.t" | while read t; do
    o=$(echo $t | sed "s/\.t//")
    envsubst <$t
  done
}

echo "[$1]"
case $1 in
"")
  echo "...all"
  find . -maxdepth 1 -type d | sed "s/\.\///" | while read d; do
    case $d in
    "")
      echo "."
      ;;
    *)
      proc_dot $d
      ;;
    esac
  done
  ;;
*)
  echo "...1"
  proc_dot $1
  ;;
esac
