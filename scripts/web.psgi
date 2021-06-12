#!/usr/bin/perl

# @author Bodo (Hugo) Barwich
# @version 2021-06-06
# @package Plack Twiggy REST API
# @subpackage /scripts/web.psgi

# This Module creates the callable Function to respond to Plack Requests.
# This is the Entry Point of the Web Site.
#
#---------------------------------
# Requirements:
# - The Perl Module "JSON" must be installed
# - The Perl Module "Plack" must be installed
# - The Perl Module "Twiggy" must be installed
#
#---------------------------------
# Features:
#



BEGIN
{
  use FindBin;
  use lib "$FindBin::Bin/lib";
  use lib "$FindBin::Bin/../lib";
}

use warnings;
use strict;

use Cwd qw(abs_path);
use File::Basename qw(dirname);

use JSON;
use Plack::Builder;
use Plack::Request;

use Product::List;
use Product::Factory;



#----------------------------------------------------------------------------
#Executing Section


my $smaindir = dirname(dirname( abs_path(__FILE__) ));
my $svmainpath = '/';

my $app = sub {
  my $env = shift;
  my $request = Plack::Request->new($env);
  my $response = $request->new_response(200);


  $response->content_type('application/json');


	#------------------------
	#Parse the URL

  if($request->path_info() eq '/coffees')
  {
    #------------------------
    #Product List

    return sub {
      my $responder = shift;
      my $writer = $responder->([ 200, [ 'Content-Type', 'application/json' ]]);

      my $prodfactory = Product::Factory->new();
      my $lstprods = $prodfactory->buildProductList;

      my $rhshrspdata = $lstprods->getList;


      $response->content(encode_json($rhshrspdata));

    };  #sub
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


  $response->finalize;

};  #$app



#----------------------------------------------------------------------------
#URL Mapping


builder {
  #Route for the favicon.ico
  enable "Static", path => qr#\.(ico|png)#, root => $smaindir . '/images';
  #Any other Content
  $app;
}


