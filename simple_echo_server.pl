#!/usr/bin/perl
use strict;
use warnings;
     
use FindBin;
use lib "$FindBin::Bin/lib";
use lib "$FindBin::Bin/../lib";

    
    
print "Net::Server Version: ";

print $Net::Server::VERSION . "\n";



use SimpleEchoServer;
     
SimpleEchoServer->run(port => 3000);