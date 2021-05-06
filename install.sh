#!/bin/sh

echo "system: " 
cat /etc/os-release ; 

cpanm -vn local::lib ; 

echo "Configuring Local Installation ..."
perl -Mlocal::lib ;
eval $(perl -I ~/perl5/lib/perl5/ -Mlocal::lib) ;

echo "perl environment: " ; 
perl -I ~/perl5/lib/perl5/ -Mlocal::lib ; 
echo \"user: \" $(whoami) ; echo \"working directory: \" $(pwd) && ls -lah ; 
echo \"perl packages: \" ; dpkg --get-selections|grep -i perl ; 
which perl ; perl --version ; 
which cpanm 2>&1; 
cpanm --local-lib=~/perl5 local::lib ; 
cpanm -vn Net::Server ; perl simple_echo_server.pl || node server.js ;"
