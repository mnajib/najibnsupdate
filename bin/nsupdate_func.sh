#!/bin/sh
# vim:ts=8:sw=2 et:sta background=dark:
#
# Copyright (c) 2011 Mohd Najib Bin Ibrahim 
#        (mnajib@gmail.com)
# All rights reserved.
#
# Redistribution and use in source and binary forms, with or without
# modification, are permitted provided that the following conditions
# are met:
# 1. Redistributions of source code must retain the above copyright
#    notice, this list of conditions and the following disclaimer.
# 2. Redistributions in binary form must reproduce the above copyright
#    notice, this list of conditions and the following disclaimer in the
#    documentation and/or other materials provided with the distribution.
#
# THIS SOFTWARE IS PROVIDED BY THE AUTHOR AND CONTRIBUTORS ``AS IS'' AND
# ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE
# IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE
# ARE DISCLAIMED.  IN NO EVENT SHALL THE AUTHOR OR CONTRIBUTORS BE LIABLE
# FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL
# DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS
# OR SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION)
# HOWEVER CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT
# LIABILITY, OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY
# OUT OF THE USE OF THIS SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF
# SUCH DAMAGE.
#
# 201110
# 201111
#

# arg1: host
_genkey() {
  local HOST="$1"

  cd "$ROOTDIR/key/"

  #dnssec-keygen -a HMAC-MD5 -b 128 -n USER najib.dyndns.magnifix.com.my.
  #dnssec-keygen -a HMAC-MD5 -b 128 -n HOST iza.dyndns.magnifix.com.my.
  dnssec-keygen -a HMAC-MD5 -b 512 -n HOST ${HOST}.

  cd -

  echo ""
}

_enabledHost() {
  # Return list of enabled host - name of config files in ./conf/enabled/*
  #local files=(
  CONFFILES=(
  	`find "${ROOTDIR}/etc/enabled" | egrep -v "^.$" |  egrep -i "\.conf$" | sort`
  )

  #...
}

# arg1: hostname
# example usage: _loadconf "najib.dyndns.magnifix.com.my"
_loadConf() {
  local filename="${ROOTDIR}/etc/enabled/${1}.conf"

  # Source the info/config file
  #. $filename
  if [ ! -f "$filename" ]; then
    exit 1
  fi
  . "$filename"
}

_newIP() {
  #local IPNEW="`curl -s "http://whatismyip.org/"`"
  #local IPNEW="`curl whatismyip.org`"
  local IPNEW="`curl -s whatismyip.org`"
  #local IPNEW="`curl -s "http://whatismyip.magnifix.com.my`" # TODO: 
  #local IPNEW="`curl -s "http://najib.dyndns.magnifix.com.my/whatismyip/"`" # ready to be test

  sleep 1

  # Check if we got the valid IP (syntax)
  #...

  echo -en "${IPNEW}"
}
# We dont want to query whatismyip.org multiple times for same ...
# array of ...
# a[najib.dyndns.magnifix.com.my]="202.188.1.111"
# a[mnajib.dyndns.magnifix.com.my]="202.188.1.111"
# a[firdauz.dyndns.magnifix.com.my]="202.188.3.333"
# a[iza.dyndns.magnifix.com.my]="202.188.0.222"
_newIP_test() {
  local IPNEW=""

  if [ `_isip ${a[$HOST]}` == 1 ]; then
    IPNEW="`curl -s whatismyip.org`"
  fi

  # Check if we got the valid IP (syntax)
  if [ `_isip ${IPNEW}` == 0 ]; then
    a[${HOST}]="${IPNEW}"
  fi

  echo -en "${IPNEW}"
}

_currentIP() {
  #local DYNDNSSVR="${1}"
  #local MYHOST="${2}"

  #local IPCURRENT=`dig -4 +short @${DYNDNSSVR} ${MYHOST}`
  local IPCURRENT=`dig -4 +short @${SERVER} ${HOST}.`

  # Check if we got the valid IP (syntax)
  #...

  echo -en "${IPCURRENT}"
}

# XXX:
_is_validip() {
  case "$*" in
    ""|*[!0-9.]*|*[!0-9]) return 1 ;;
  esac

  local IFS=.  ## local is bash-specific
  set -- $*

  [ $# -eq 4 ] && [ ${1:-666} -le 255 ] && [ ${2:-666} -le 255 ] && [ ${3:-666} -le 255 ] && [ ${4:-666} -le 254 ]
}

# XXX:
_isip() {
  if [[ $1 =~ ^[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}$ ]]; then
    #echo "IP is $1"
    #ret=0
    echo -en 0
  else
    #echo "$1 is not IP"
    #ret=1
    echo -en 1
  fi

  #return $ret
}

# Check if current modem IP same with current set in DNS
# arg1: IP1
# arg2: IP2
_sameIP() {
  local ip1="${1}"
  local ip2="${2}"

  if [ "$ip1" == "`echo $ip2`" ]; then
    #return 0
    echo  -en "0" # yes, the ip same
  else
    #return 1
    echo -en "1"  # no, the ip different
  fi
}

# TODO: will log/list all tm IPs in a file
# uniq; but do not sort
# arg1: filename, content list of IPs
# arg2: IP to be added, if not already in the file/list
_logIP(){
  local filename="$1"
  local ip="$2"
  local numoflines=0
  local numoflines2=0
  local dtext=""
  local linebefore=0
  local lineafter=0
  local status=0

  #IPS=(
  #	`sort -u "${ROOTDIR}/var/log/ip-list.txt"`
  #)

  numoflines=`cat "${filename}" | wc -l`

  #echo -en "`cat ${filename}`\n${ip}\n"
  #echo -en "`cat ${filename}`\n${ip}\n" | sort -n
  #echo -en "`cat ${filename}`\n${ip}\n" | sort -n
  dtext="`cat ${filename}`"
  #numoflines2=`echo -en "${dtext}\n${ip}\n" | sort -n | wc -l`
  #numoflines2=`echo -en "${dtext}\n${ip}\n" | sort -u | wc -l`
  numoflines2=`echo -en "${dtext}\n${ip}\n" | sort -u | wc -l`

  echo "linebefore: $numoflines"
  echo "lineafter: $numoflines2"
  linebefore=$numoflines
  lineafter=$numoflines2

  # (only)if the number of lines is difference; append the new ip into the file (without sorting)
  #$status="`echo $linebefore - $lineafter | bc`
  if [ "$linebefore" != "$lineafter" ]; then # XXX:
  #a=4; if [[ `echo "$a - 2" | bc` == 0 ]]; then echo "eq eq eq"; fi
  #if [[ `echo "$linebefore - $lineafter" | bc` ]]; then # XXX:
  #if [ `echo "$linebefore - $lineafter" | bc` ]; then # XXX:
  #if [ $status -eq 0 ]; then # XXX:
    echo "!!!diff!!diff!!"
    #echo "same" >> /dev/null
    echo "${ip}" >> "${filename}"
    #echo -en "${dtext}\n${ip}\n" | sort
    #echo -en "${dtext}\n${ip}\n"
  #elif [ "$linebefone" == "$lineafter" ]; then # XXX:
  #else
  #  echo "!!!diff!!diff!!"
    #echo "${ip}" >> "${filename}"
  #  echo -en "${dtext}\n" | sort
  fi

  cat ${filename} | sort

}

# arg1: file
_print_ip_from_file() {
  local file="$1"
  local i=0

  for i in $( awk '{print}' < "$file" ); do
    echo $i
  done

  return 0
}

# arg1: host/name of server 1
# arg2: host/name of server 2
_sameServer() {
  local server1="$1"
  local server2="$2"

  echo "TODO: ..."


}

_createConfig(){
  local dyndnssvr="$1"
  local myhost="$2"
  local myzone="$3"
  local myip="${IPNEW}"

echo "server ${dyndnssvr}
zone ${myzone}
update delete ${myhost}. A
update add ${myhost}. 86400 A ${myip}
show
send" > "${TMPFILE}"
}
# 21600
# echo "" > "${TMPFILE1}"

_doUpdate(){
  #nsupdate -k Kmnajib.dyndns.magnifix.com.my.+157+64247.private -v "${FILENAME}"
  #nsupdate -d -k Kmnajib.dyndns.magnifix.com.my.+157+64247.private -v "${TMPFILE}"
  #nsupdate -d -v -k "Kmnajib.dyndns.magnifix.com.my.+157+64247.private" -v "${TMPFILE}"
  #nsupdate -d -k "Kmnajib.dyndns.magnifix.com.my.+157+64247.private" -v "${TMPFILE}"
  #nsupdate -D -k "Kmnajib.dyndns.magnifix.com.my.+157+64247.private" -v "${TMPFILE}"
  #nsupdate -d -k "key.conf" -v "${TMPFILE1}"
  #nsupdate -d -k "key.conf" -v "${TMPFILE}"
  nsupdate -d -k "${ROOTDIR}/key/${KEYFILE}" -v "${TMPFILE}"
}
# without using temp file
# 2913 seconds = 48.55 minutes # used by dyndns.com for dyndns ns server
# 1800 seconds = 30 minutes
# 600 seconds = 10 minutes
# 300 seconds = 5 minutes
# 36 seconds = 0.6 minutes # used by dyndns.com for dyndns host
_doUpdate2(){
  local dyndnssvr="$1"
  local myhost="$2"
  local myzone="$3"
  local myip="${IPNEW}"

  nsupdate -d -k "${ROOTDIR}/key/${KEYFILE}" <<-EOF
server ${dyndnssvr}
zone ${myzone}
update delete ${myhost}. A
update add ${myhost}. 36 A ${myip}
show
send
EOF
}

_datentime() {
  #local d=`date +%Y%m%d%H%M%S`
  local d=`date +%Y-%m-%d\ %H%M%S`
  echo -n "$d"
}

