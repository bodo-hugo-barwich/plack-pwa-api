#!/usr/bin/perl

# @author Bodo (Hugo) Barwich
<<<<<<< HEAD
# @version 2021-08-15
=======
# @version 2021-08-08
>>>>>>> branch 'master' of https://github.com/bodo-hugo-barwich/plack-pwa-api
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
# - Load Host Service Configuration from Configuration File
#



BEGIN
{
  use FindBin;
  use lib "$FindBin::Bin/lib";
  use lib "$FindBin::Bin/../lib";
}

use strict;
use warnings;

use Path::Tiny;

use POSIX qw(strftime);
use Data::Dump qw(dump);

use JSON;
use YAML;

use Plack::Builder;
use Plack::Request;

use Cache::Files;
use Product::List;
use Product::Factory;



#----------------------------------------------------------------------------
#Auxiliary Functions

sub  loadConfiguration
{
  my ($smndir, $rqenv) = @_ ;
  my $scnfdir = $smndir . '/config/';
  my $shost = $rqenv->{'HTTP_HOST'};
  my $splkenv = $ENV{'PLACK_ENV'} || 'deployment';
  my $scnfhstnm = '';
  my $scnfflnm = '';
  my $scnfext = '.yml';
  my $rscnf = undef;


  $shost =~ s/:[0-9]+//;
  $scnfhstnm = $shost;
  $scnfhstnm =~ tr/\./-/;

  $scnfdir = $smndir . '/' unless(-d $scnfdir);

  $scnfflnm = $scnfhstnm . '-' . $splkenv . $scnfext;

  $scnfflnm = $scnfhstnm . $scnfext unless(-f $scnfdir . $scnfflnm);

  $scnfflnm = 'default' . $scnfext unless(-f $scnfdir . $scnfflnm);

  if(-f $scnfdir . $scnfflnm)
  {
    eval
    {
      $rscnf = YAML::LoadFile($scnfdir . $scnfflnm);

      $rscnf->{'maindirectory'} = $smndir;
    };

    if($@)
    {
      $rscnf = undef;

      print STDERR "Project '$shost': Configuration could not be loaded!\n"
        , "Configuration File '${scnfdir}${scnfflnm}': Read Open failed.\n"
        , "File '${scnfdir}${scnfflnm}' - Message: '", $@, "'\n";
    } #if($@)
  }
  else  #Configuration File does not exist
  {
    print STDERR "Project '$shost': Configuration could not be loaded!\n"
      , "Configuration File '${scnfdir}${scnfflnm}': File does not exist.\n";
  } #if(-f $scnfdir . $scnfflnm)


  return $rscnf;
}

sub dispatchHomePage
{
  my ($cnf, $req, $res) = @_ ;


  #------------------------
  #Project Description

  my $rhshrspdata = {'title' => $cnf->{'project'}
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

  my ($cnf, $req, $res) = @_ ;
  my $stmnow  = strftime('%F %T', localtime);

  print "$stmnow : Request '", $req->env->{'REQUEST_URI'}, "' - starting...\n";

  print STDERR "req dmp:\n", dump $req;
  print STDERR "\n";

  print STDERR "res dmp:\n", dump $res;
  print STDERR "\n";

#  unless(defined $req->env->{'psgix.io'})
#  {
    #------------------------
    #Error Response
    #Extension psgix.io is required

#    my $rhshrspdata = {'title' => $cnf->{'project'} . ' - Error'
#      , 'statuscode' => 501
#      , 'page' => 'none'
#      , 'errormessage' => 'Extension missing'
#      , 'errordescription' => 'This server does not support psgix.io extension.'
#    };


#    $stmnow  = strftime('%F %T', localtime);

#    print STDERR "$stmnow : Request '", $req->env->{'REQUEST_URI'}, "' - Extension missing: "
#      , $rhshrspdata->{'errordescription'}. "\n";

#    $res->code(501);
#    $res->content(encode_json($rhshrspdata));


#    return $res->finalize;
#  } #unless(defined $req->env->{'psgix.io'})


  eval
  {
    #------------------------
    #Build Product List

    my $cache = Cache::Files->new($cnf->{'maindirectory'} . '/cache/');
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

    my $rhshrspdata = {'title' => $cnf->{'project'} . ' - Exception'
      , 'statuscode' => 500
      , 'page' => 'none'
      , 'errormessage' => 'An Exception has occurred'
      , 'errordescription' => 'Plack Twiggy - Exception: ' . $@
    };


    $stmnow  = strftime('%F %T', localtime);

    print STDERR "$stmnow : Request '", $req->env->{'REQUEST_URI'}, "' - Exception: ", $@ ;

    $res->code(500);
    $res->content(encode_json($rhshrspdata));

  } #if($@)


  return $res->finalize;
}

sub dispatchErrorResponse
{
  my ($cnf, $res, $rhshrsdata) = @_ ;


  #------------------------
  #Error Response
  #Finalize Request with Error Message

  $rhshrsdata = {} unless defined $rhshrsdata ;
  $rhshrsdata->{'title'} = 'Error' unless defined $rhshrsdata->{'title'};
  $rhshrsdata->{'status'} = 500 unless defined $rhshrsdata->{'status'};
  $rhshrsdata->{'message'} = 'An Error has occurred!' unless defined $rhshrsdata->{'message'};
  $rhshrsdata->{'description'} = '' unless defined $rhshrsdata->{'description'};


  my $rhshrspdata = {'title' => $cnf->{'project'} . ' - ' . $rhshrsdata->{'title'}
    , 'statuscode' => $rhshrsdata->{'status'}
    , 'page' => 'none'
    , 'errormessage' => $rhshrsdata->{'message'}
    , 'errordescription' => $rhshrsdata->{'description'}
  };


  $res->code($rhshrsdata->{'status'});
  $res->content(encode_json($rhshrspdata));


  return $res->finalize;
}



#----------------------------------------------------------------------------
#Executing Section


my $smaindir = path(__FILE__)->parent->parent->stringify;


print STDERR "env dmp:\n" . dump %ENV; print "\n";


my $app = sub {
  my $env = shift;
  my $config = loadConfiguration($smaindir, $env);
  my $request = Plack::Request->new($env);
  my $response = $request->new_response(200);
  my $headers = undef;


  $response->content_type('application/json');
  $response->headers->push_header('Access-Control-Allow-Origin' => "*");
  $response->headers->push_header('Content-Security-Policy' => "default-src 'self' localhost *.glitch.me; img-src *; style-src 'unsafe-inline'");
  #$response->headers->push_header('Content-Security-Policy' => "default-src *; img-src *; style-src 'unsafe-inline'");
  $response->headers->push_header('connection' => 'close');


  #Exit on missing Configuration
  return dispatchErrorResponse($response, {'description' => 'Server Configuration could not be loaded.'})
    unless defined $config;


	#------------------------
	#Parse the URL

  if($request->path_info() eq '/coffees')
  {
    #------------------------
    #Dispatch Product List

    return dispatchProductList($config, $request, $response);
  }
  elsif($request->path_info() eq '/'
    || $request->path_info() eq '')
  {
    #------------------------
    #Dispatch Home Page

    return dispatchHomePage($config, $request, $response);
  }
  else  #Any other URL: Not Found Error
  {
    #------------------------
    #Error Response

    my $rhshrspdata = {'title' => $config->{'project'} . ' - Error'
      , 'statuscode' => 404
      , 'page' => 'none'
      , 'errormessage' => 'Not Found'
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
  enable "Plack::Middleware::AccessLog::Timed"
    , format => '%{HTTP_X_FORWARDED_PROTO}i:%V (%h,%{HTTP_X_FORWARDED_FOR}i) %{%F:%T}t [%D] '
      . '"Mime:%{Content-Type}o" "%r" %>s %b "%{Referer}i" "%{User-agent}i"';
  #Route for the favicon.ico
  enable "Static", path => qr#\.(ico|png)#, root => $smaindir . '/images';
  #Any other Content
  $app;
}



