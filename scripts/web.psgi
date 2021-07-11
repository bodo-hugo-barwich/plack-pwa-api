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

use Cache::Files;
use Product::List;
use Product::Factory;



#----------------------------------------------------------------------------
#Auxiliary Functions

sub printHomePage
{
  my ($req, $wtr) = @_ ;


  #------------------------
  #Project Description

  my $rhshrspdata = {'title' => 'Plack Twiggy - API'
    , 'statuscode' => 200
    , 'page' => 'Home'
    , 'description' => 'Product Data API for the Plack Twiggy PWA Project'
  };


  $wtr->write(encode_json($rhshrspdata));

  $wtr->close();
}

sub dispatchHomePage
{
  my ($req, $res) = @_ ;


  #------------------------
  #Project Description

  my $rhshrspdata = {'title' => 'Plack Twiggy - API'
    , 'statuscode' => 200
    , 'page' => 'Home'
    , 'description' => 'Product Data API for the Plack Twiggy PWA Project'
  };


  $res->code(200);
  $res->content(encode_json($rhshrspdata));


  return $res->finalize;
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

  unless(defined $req->env->{'psgix.io'})
  {
    #------------------------
    #Error Response
    #Extension psgix.io is required

    my $rhshrspdata = {'title' => 'Plack Twiggy - Error'
      , 'statuscode' => 501
      , 'errormessage' => 'Extension missing!'
      , 'errordescription' => 'This server does not support psgix.io extension.'
    };


    $stmnow  = strftime('%F %T', localtime);

    print STDERR "$stmnow : Request '", $req->env->{'REQUEST_URI'}, "' - Extension missing: "
      , $rhshrspdata->{'errordescription'};

    $res->code(501);
    $res->content(encode_json($rhshrspdata));


    return $res->finalize;
  } #unless(defined $req->env->{'psgix.io'})


  eval
  {
    #------------------------
    #Build Product List

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
  my $headers = undef;

  $response->content_type('application/json');
  $response->headers->push_header('Access-Control-Allow-Origin' => "*");
  $response->headers->push_header('Content-Security-Policy' => "default-src 'self' localhost *.glitch.me; img-src *; style-src 'unsafe-inline'");
  #$response->headers->push_header('Content-Security-Policy' => "default-src *; img-src *; style-src 'unsafe-inline'");
  $response->headers->push_header('connection' => 'close');


	#------------------------
	#Parse the URL

  if($request->path_info() eq '/coffees')
  {
    #------------------------
    #Dispatch Product List

    return dispatchProductList($smaindir, $request, $response);
  }
  elsif($request->path_info() eq '/'
    || $request->path_info() eq '')
  {
    #------------------------
    #Dispatch Home Page

    return sub {
      my $responder = shift;
      my $writer = $responder->([ 200, $response->headers->psgi_flatten() ]);
      my $timer;

      my $fprintHomePage = \&printHomePage;

       $timer = AnyEvent->timer(
          after => 0,
          cb => sub {
            undef $timer; # cancel circular-ref
            $fprintHomePage->($request, $writer);
       });  #$timer
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



