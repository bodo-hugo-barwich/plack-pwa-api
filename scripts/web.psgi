#!/usr/bin/perl

# @author Bodo (Hugo) Barwich
# @version 2021-06-19
# @package Plack Twiggy REST API
# @subpackage /scripts/web.psgi

# This Module creates the callable Function to respond to Plack Requests.
# This is the Entry Point of the Web Site.
#
#---------------------------------
# Requirements:
# - The Perl Module "Path::Tiny" must be installed
# - The Perl Module "JSON" must be installed
# - The Perl Module "Plack" must be installed
# - The Perl Module "Twiggy" must be installed
#
#---------------------------------
# Features:
#
#



BEGIN
{
  use FindBin;
  use lib "$FindBin::Bin/lib";
  use lib "$FindBin::Bin/../lib";
}

use warnings;
use strict;

use Path::Tiny;

use POSIX qw(strftime);
use Data::Dump qw(dump);

use JSON;

use Plack::Builder;
use Plack::Request;
use HTTP::Headers::Fast;
use AnyEvent;
use HTTP::Status;

use Cache::Files;
use Product::List;
use Product::Factory;



#----------------------------------------------------------------------------
#Auxiliary Functions


sub dispatchIndexPage
{
  print "API Home - Dispatch go ...\n";

  my ($req, $res) = @_ ;
  #my $response = $_[0]->new_response(200);


  #$response->content_type('application/json');
  #$response->headers->push_header('connection' => 'close');

#    sleep 15;


  #------------------------
  #Project Description

  my $rhshrspdata = {'title' => 'Plack Twiggy - API'
    , 'statuscode' => 200
    , 'page' => 'Home'
    , 'description' => 'Product Data API for the Plack Twiggy PWA Project'
  };


  #$response->code(200);
  #$response->content(encode_json($rhshrspdata));


  #return $response->finalize;
  return $res->([200, [ 'Content-Type' => 'application/json']
      , [ encode_json($rhshrspdata) ]
    ]);
}

sub dispatchProductList
{
  print "API Product List - Dispatch go ...\n";

  my ($smndir, $req, $res) = @_ ;
  my $stmnow  = strftime('%F %T', localtime);

  print "$stmnow : Request '", $req->env->{'REQUEST_URI'}, "' - starting...\n";

  print "req dmp:\n", dump $req;
  print "\n";

  print "res dmp:\n", dump $res;
  print "\n";

  eval
  {
    my $cache = Cache::Files->new($smndir . '/cache/');
    my $prodfactory = Product::Factory->new($cache);
    my $lstprods = $prodfactory->buildProductList;
    my $rhshrspdata = $lstprods->exportList;


    $res->content(encode_json($rhshrspdata));

    $stmnow  = strftime('%F %T', localtime);

    print "$stmnow : Request '", $req->env->{'REQUEST_URI'}, "' - done.\n";
    print STDERR "$stmnow : Request '", $req->env->{'REQUEST_URI'}, "' - No Error.\n";
  };  #eval

  if($@)
  {
    #------------------------
    #Error Response
    #An Exception has occurred

    my $rhshrspdata = {'title' => 'Plack Twiggy - Exception'
      , 'statuscode' => 500
      , 'errormessage' => 'Exception has occurred!'
      , 'errordescription' => 'Plack Twiggy - Exception: ' . $@
    };


    $stmnow  = strftime('%F %T', localtime);

    print STDERR "$stmnow : Request '", $req->env->{'REQUEST_URI'}, "' - Exception: ", $@ ;

    $res->code(500);

    $res->content(encode_json($rhshrspdata));

  } #if($@)


  return $res->finalize;
}




#----------------------------------------------------------------------------
#Executing Section


my $smaindir = path(__FILE__)->parent->parent->stringify;
my $svmainpath = '/';

my $app = sub {
  my $env = shift;
  my $request = Plack::Request->new($env);
  my $response = $request->new_response(200);


  $response->content_type('application/json');
  #$response->headers->push_header('connection' => 'close');


	#------------------------
	#Parse the URL

  if($request->path_info() eq '/coffees')
  {
    unless(defined $env->{'psgix.io'})
    {
      #------------------------
      #Error Response
      #Extension psgix.io is required

      my $rhshrspdata = {'title' => 'Plack Twiggy - Error'
        , 'statuscode' => 501
        , 'errormessage' => 'Extension missing!'
        , 'errordescription' => 'This server does not support psgix.io extension.'
      };


      $response->code(501);
      $response->content(encode_json($rhshrspdata));

      return $response->finalize;
    } #unless(defined $env->{'psgix.io'})



    #------------------------
    #Product List


    return dispatchProductList($smaindir, $request, $response);


#    return sub {
#      my $responder = shift;
#      my $rsphdrs = undef;
#      my $writer = $responder->([200, ['content-type' => 'application/json', 'connection' => 'close']]);
#      my $socket = $env->{'psgix.io'};
#      my $cv = AE::cv;
#      my $stmnow  = strftime('%F %T', localtime);


#      print "$stmnow : Request '", $env->{REQUEST_URI}, "' - starting...\n";

#      print STDERR "AE::cv dmp:\n", dump $cv;
#      print STDERR "\n";

      #$writer = Twiggy::Writer->new($socket, $cv);
      #$cv->end;


#      print STDERR "wrtr dmp:\n", dump $writer;
#      print STDERR "\n";

#      $response->content_type('text/plain');


      #sleep 15;




#      $response->finalize;

 #    };  #sub
  }
  elsif($request->path_info() eq '/'
    || $request->path_info() eq '')
  {
    #------------------------
    #Dispatch Index Page

    print "API Home - dispatching...\n";

    return sub {
      my $responder = $_[0];
      my $timer;
      my $fdispatchIndexPage = \&dispatchIndexPage;


      $timer = AnyEvent->timer(after => 0, cb => sub {
          undef $timer;


          return $fdispatchIndexPage->($request, $responder);

        }); #$timer = AnyEvent->timer()
    };  #return sub
  }
  else  #Any other URL: Not Found Error
  {
    #------------------------
    #Error Response

    my $rhshrspdata = {'title' => 'Plack Twiggy - Error'
      , 'statuscode' => 404
      , 'errormessage' => 'Not Found.'
      , 'errordescription' => 'The Resource does not exist.'
    };


    $response->code(404);
    $response->content(encode_json($rhshrspdata));

  } #if($request->path_info() eq '/coffees')


  return $response->finalize;

};  #$app



#----------------------------------------------------------------------------
#URL Mapping


builder {
  #Route for the favicon.ico
  enable "Static", path => qr#\.(ico|png)#, root => $smaindir . '/images';
  #Any other Content
  $app;
}



