#!/usr/bin/env bash
#/ Usage: secrets.sh <operation> [<key> [<value]]
#/
#/ Simple secrets manager in bash using GPG
#/
#/   Store a secret:    secrets.sh set my_secret_key my_secret
#/   Retrieve a secret: secrets.sh get my_secret_key
#/   List all secrets:  secrets.sh list
#/   Dump database:     secrets.sh dump
#/
# Copyright (c) 2018 Jordan Webb
#
# Permission is hereby granted, free of charge, to any person obtaining a copy
# of this software and associated documentation files (the "Software"), to deal
# in the Software without restriction, including without limitation the rights
# to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
# copies of the Software, and to permit persons to whom the Software is
# furnished to do so, subject to the following conditions:
#
# The above copyright notice and this permission notice shall be included in all
# copies or substantial portions of the Software.
#
# THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
# IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
# FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
# AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
# LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
# OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
# SOFTWARE.

set -e
set -o pipefail

#/ By default, the file $HOME/.secrets will be used to store secrets. If
#/ you prefer, set the SECRETS_PATH in your environment to a different path.
#/
SECRETS_PATH=${SECRETS_PATH:-"$HOME/.secrets"}

#/ To use a specific gpg binary, set SECRETS_GPG_PATH.
if [ -z "$SECRETS_GPG_PATH" ] ; then
  if [ -n "$(type -P gpg2)" ] ; then
    SECRETS_GPG_PATH="$(type -P gpg2)"
  elif [ -n "$(type -P gpg2)" ] ; then
    SECRETS_GPG_PATH="$(type -P gpg)"
  else
    echo "ERROR: couldn't find gpg on PATH, do you need to set SECRETS_GPG_PATH?" >&2
    usage
    exit 1
  fi
fi

#/ To pass extra arguments to GPG, set SECRETS_GPG_ARGS.
SECRETS_GPG_ARGS=${SECRETS_GPG_ARGS:-""}

#/ To use a specific GPG key, set SECRETS_GPG_KEY to the key ID.
if [ -n "$SECRETS_GPG_KEY" ] ; then
  SECRETS_GPG_ARGS="$SECRETS_GPG_ARGS --default-key $SECRETS_GPG_KEY"
fi

usage()
{
  grep "^#/" <"$0" | cut -c4-
}

require_args()
{
  local operation=$1
  local want=$2
  local have=$3

  if [ "$want" -ne "$have" ] ; then
    echo "ERROR: incorrect number of arguments for '$operation'" >&2
    exit 1
  fi
}

read_secrets()
{
  if [ -e "$SECRETS_PATH" ] ; then
    $SECRETS_GPG_PATH -q $SECRETS_GPG_ARGS --decrypt < "$SECRETS_PATH"
  fi
}

write_secrets()
{
  $SECRETS_GPG_PATH $SECRETS_GPG_ARGS --default-recipient-self --armor --encrypt -z 9 > $SECRETS_PATH
}

list_secrets()
{
  local this_key this_date this_value
  while read this_key this_date this_value
  do
    echo "'$this_key' set on $(date --date="@$this_date")"
  done
}

extract_secret()
{
  local key=$1
  local this_key this_date this_value

  while read this_key this_date this_value
  do
    if [ "$this_key" = "$key" ] ; then
      echo "$this_value"
      break
    fi
  done
}

filter_secret()
{
  local key=$1
  local this_key this_date this_value

  while read this_key this_date this_value
  do
    if [ -z "$this_key" ] ; then
      break
    elif [ "$this_key" != "$key" ] ; then
      printf "%q %q %q\n" "$this_key" "$this_date" "$this_value"
    fi
  done
}

case $1 in
  help)
    usage
    exit 0
    ;;
  del|set)
    if [ "$1" = "del" ] ; then
      require_args "$1" "$#" 2
    elif [ "$1" = "set" ] ; then
      require_args "$1" "$#" 3
    fi
    secrets=$(read_secrets)
    (
      filter_secret "$2" <<< "$secrets"
      if [ "$1" = "set" ] ; then
        printf "%q %q %q\n" "$2" "$(date '+%s')" "$3"
      fi
    ) | write_secrets
    ;;
  get)
    require_args "$1" "$#" 2
    read_secrets | extract_secret "$2"
    ;;
  list)
    require_args "$1" "$#" 1
    read_secrets | list_secrets | sort
    ;;
  dump)
    require_args "$1" "$#" 1
    read_secrets
    ;;
  *)
    echo "ERROR: operation must be 'set', 'get', 'list' or 'dump'" >&2
    usage
    exit 1
    ;;
esac

#/
#/ If you run into any problems or have a contribution you'd like to make,
#/ open issues or pull requests at https://github.com/jordemort/secrets.sh
