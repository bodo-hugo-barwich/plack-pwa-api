#!/bin/sh

# @author Bodo (Hugo) Barwich
# @version 2021-09-02
# @package Plack Twiggy REST API
# @subpackage entrypoint.sh


set -e

SERVER=`cat /etc/hostname`

MDNM=`basename $0`

echo "Container '${SERVER}.${COMPONENT}': '$MDNM' go ..."

echo "Container '${SERVER}.${COMPONENT}' - Network:"

echo `cat -A /etc/hosts`


if [ "$1" = "plackup" ]; then
  icpanm=0

  echo "Command: '$@'"

  echo "Configuring Local Installation ..."
  eval $(perl -Mlocal::lib -I ~/perl5/lib/perl5/)


  #Checking Plack Version

  echo -n "Plack Version: "

  perl -MPlack -e 'print $Plack::VERSION;' 2>/dev/null 1>log/perl_plack.log ||\
    iresult=$?

  if [ -z "$iresult" ]; then
    iresult=0
  fi

  iplack=`cat log/perl_plack.log`

  if [ -n "$iplack" ]; then
    echo "$iplack [Code: '$iresult']"
  else
    echo "NONE [Code: '$iresult']"

    #Trigger cpanm Installation
    icpanm=1
  fi  #if [ -n "$iplack" ]; then


  #Checking Twiggy Version

  echo -n "Web Server Version: "

  perl -MTwiggy -e 'print $Twiggy::VERSION;' 2>/dev/null 1>log/perl_twiggy.log ||\
    iresult=$?

  if [ -z "$iresult" ]; then
    iresult=0
  fi

  itwiggy=`cat log/perl_twiggy.log`

  if [ -n "$itwiggy" ]; then
    echo "$itwiggy [Code: '$iresult']"
  else
    echo "NONE [Code: '$iresult']"

    #Trigger cpanm Installation
    icpanm=1
  fi  #if [ -n "$itwiggy" ]; then


  #Checking JSON Version

  echo -n "JSON Version: "

  perl -MJSON -e 'print $JSON::VERSION;' 2>/dev/null 1>log/perl_json.log ||\
    iresult=$?

  if [ -z "$iresult" ]; then
    iresult=0
  fi

  ijson=`cat log/perl_json.log`

  if [ -n "$ijson" ]; then
    echo "$ijson [Code: '$iresult']"
  else
    echo "NONE [Code: '$iresult']"

    #Trigger cpanm Installation
    icpanm=1
  fi  #if [ -n "$ijson" ]; then


  #Checking JSON Version

  echo -n "Moose Version: "

  perl -MMoose -e 'print $Moose::VERSION;' 2>/dev/null 1>log/perl_moose.log ||\
    iresult=$?

  if [ -z "$iresult" ]; then
    iresult=0
  fi

  imoose=`cat log/perl_moose.log`

  if [ -n "$imoose" ]; then
    echo "$imoose [Code: '$iresult']"
  else
    echo "NONE [Code: '$iresult']"

    #Trigger cpanm Installation
    icpanm=1
  fi  #if [ -n "$imoose" ]; then


  if [ $icpanm -eq 1 ]; then
    #Run cpanm Installation
    echo "Installing Dependencies with cpanm ..."

    date +"%s" > log/web_cpanm_install_$(date +"%F").log
    cpanm -vn --installdeps . 2>&1 >> log/web_cpanm_install_$(date +"%F").log
    cpanmrs=$?
    date +"%s" >> log/web_cpanm_install_$(date +"%F").log

    echo "Installation finished with [$cpanmrs]"
  fi  #if [ $icpanm -eq 1 ]; then


  #Checking File Cache

  icache=`find cache -name "*.json" | wc -l`

  if [ -z "$icache" ]; then
    icache=0
  fi

	#Cache Directory will contain at least the '.keep' file
  if [ $icache -le 1 ]; then
    #Run Cache Population
    echo "Running Pre-Caching ..."

		if [ ! -d cache ]; then
		  echo "Cache Directory: creating ..."

		  mkdir cache
		fi  #if [ ! -d cache ]; then

    date +"%s" > log/web_cache_build_$(date +"%F").log
    scripts/build_cache.pl 2>&1 >> log/web_cache_build_$(date +"%F").log
    cachers=$?
    date +"%s" >> log/web_cache_build_$(date +"%F").log

    echo "Pre-Caching finished with [$cachers]"
  fi  #if [ $icache -le 1 ]; then


  echo "Service '$1': Launching ..."

  #Executing the Plack Application
  exec $@

fi  #if [ "$1" = "plackup" ]; then


#Launching any other Command
exec $@
