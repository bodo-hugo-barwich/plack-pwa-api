package SimpleEchoServer;
    use warnings;
    use strict;
     
    use base 'Net::Server';
    my $EOL   = "\015\012";
     
    sub process_request {
        print "Welcome to the Echo server, please type in some text and press enter. Say 'bye' if you want to leave$EOL";
     
        while( my $line = <STDIN> ) {
            $line =~ s/\r?\n$//;
            print qq(You said "$line"$EOL);
            last if $line eq "bye";
        }
    }
     
    1;