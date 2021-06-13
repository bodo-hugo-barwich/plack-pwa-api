#!/bin/sh



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


  #Checking Template Toolkit Version

  echo -n "Template Toolkit Version: "

  perl -MTemplate -e 'print $Template::VERSION;' 2>/dev/null 1>log/perl_template.log ||\
    iresult=$?

  if [ -z "$iresult" ]; then
    iresult=0
  fi

  itt=`cat log/perl_template.log`

  if [ -n "$itt" ]; then
    echo "$itt [Code: '$iresult']"
  else
    echo "NONE [Code: '$iresult']"

    #Trigger cpanm Installation
    icpanm=1
  fi  #if [ -n "$itt" ]; then


  if [ $icpanm -eq 1 ]; then
    #Run cpanm Installation
    echo "Installing Dependencies with cpanm ..."

    date +"%s" > log/web_cpanm_install_$(date +"%F").log
    cpanm -vn --installdeps . 2>&1 >> log/web_cpanm_install_$(date +"%F").log
    cpanmrs=$?
    date +"%s" >> log/web_cpanm_install_$(date +"%F").log

    echo "Installation finished with [$cpanmrs]"
  fi  #if [ $icpanm -eq 1 ]; then


  echo "Service '$1': Launching ..."

  #Executing the Plack Application
  exec $@

fi  #if [ "$1" = "plackup" ]; then


#Launching any other Command
exec $@
