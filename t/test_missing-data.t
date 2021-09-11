#!/usr/bin/perl

# @author Bodo (Hugo) Barwich
# @version 2021-08-15
# @package Plack Twiggy REST API
# @subpackage /t/test_controller.t



use strict;
use warnings;

use FindBin;
use Path::Tiny;

use Test::More;
use Plack::Test;
use Plack::Util qw(load_psgi);
use HTTP::Request;

use JSON qw(decode_json);

use Data::Dump qw(dump);



#------------------------
#Load Controller

#Mark for using Test Environment
$ENV{'PLACK_ENV'} = 'test';


my $smaindir = path($FindBin::Bin)->parent->stringify;
my $scachedir = $smaindir . '/cache';
my $test_web = Plack::Util::load_psgi($smaindir . '/scripts/web.psgi');


#------------------------
#Build Test Site

my $test = Plack::Test->create($test_web);


#------------------------
#Test Cache Files

my $slistcachefilename = '/4/4b/4b3f1a1e0b4d11f7d9c20bcf3c9f2d93.json';
my $sfirstcachefilename = '/f/f1/f1ddbd562f93d3bad3d5ef09fe20f928.json';
my $ssomecachefilename = '/3/3d/3d9cde70ce435c14f94a3b3eca8aba86.json';
my $slastcachefilename = '/a/ae/ae6268524893b96851fb87cd73c696e2.json';



subtest 'list-empty' => sub {
  #------------------------
  #Test empty List Cache

  my $url     = "/coffees";
  my $request = HTTP::Request->new( 'GET', $url );
  my $res     = undef;
  my $content = undef;
  my $cachefile = undef;
  my $scachecontent = undef;


  #Build Cache File
  $cachefile = path($scachedir . $slistcachefilename);
  #Save the Cache Content
  $scachecontent = $cachefile->slurp;
  #Delete the List Cache
  $cachefile->remove;

  #Perform the Request
  $res     = $test->request($request);

  ok( $res, "GET $url" );
  is( $res->code, 404, "Status Code [404] as expected" );
  is($res->header('content-type'), 'application/json', "Content-Type: 'JSON'");

  $content = decode_json( $res->content );

  print "cntnt dmp:\n" . dump($content); print "\n";

  is ref($content), 'HASH', 'response is a JSON object' ;
  is $content->{'page'}, 'none', "field 'page' is 'none'";
  is $content->{'errormessage'}, 'Not Found', "field 'errormessage' is 'Not Found'";

  #Restore Cache File
  $cachefile->spew($scachecontent);

};  #subtest 'home'


subtest 'first-empty' => sub {
  #------------------------
  #Test first Cache Key missing Data

  my $url     = "/coffees";
  my $request = HTTP::Request->new( 'GET', $url );
  my $res     = undef;
  my $content = undef;
  my $cachefile = undef;
  my $scachecontent = undef;


  #Build Cache File
  $cachefile = path($scachedir . $sfirstcachefilename);
  #Save the Cache Content
  $scachecontent = $cachefile->slurp;
  #Delete the List Cache
  $cachefile->remove;

  #Perform the Request
  $res     = $test->request($request);

  ok( $res, "GET $url" );
  is( $res->code, 200, "Status Code [200] as expected" );
  is($res->header('content-type'), 'application/json', "Content-Type: 'JSON'");

  $content = decode_json( $res->content );

  print "cntnt dmp:\n" . dump($content); print "\n";

  is ref($content), 'HASH', 'response is a JSON object' ;
  is scalar(keys %{$content}), 8, "Product Data List has 8 Elements";

  subtest 'product-first-empty' => sub {
    is $content->{'accusantium'}, undef, "Product 'Accusantium' not in List";
  };  #subtest 'productlist'

  subtest 'product-last-ok' => sub {
    isnt $content->{'voluptatem'}, undef, "Product 'Voluptatem' in List";
    is ref($content->{'voluptatem'}), 'HASH', 'Product Data is an Object' ;
    isnt $content->{'voluptatem'}->{'name'}, undef, "Product Data has Field 'name'";
    isnt $content->{'voluptatem'}->{'link_name'}, undef, "Product Data has Field 'link_name'";
    isnt $content->{'voluptatem'}->{'image'}, undef, "Product Data has Field 'image'";
    is $content->{'voluptatem'}->{'name'}, 'Voluptatem', "Product Data - Field 'name' is 'Voluptatem'";
  };  #subtest 'productlist'

  #Restore Cache File
  $cachefile->spew($scachecontent);

};  #subtest 'productlist'


subtest 'some-empty' => sub {
  #------------------------
  #Test some Cache Key missing Data

  my $url     = "/coffees";
  my $request = HTTP::Request->new( 'GET', $url );
  my $res     = undef;
  my $content = undef;
  my $cachefile = undef;
  my $scachecontent = undef;


  #Build Cache File
  $cachefile = path($scachedir . $ssomecachefilename);
  #Save the Cache Content
  $scachecontent = $cachefile->slurp;
  #Delete the List Cache
  $cachefile->remove;

  #Perform the Request
  $res     = $test->request($request);

  ok( $res, "GET $url" );
  is( $res->code, 200, "Status Code [200] as expected" );
  is($res->header('content-type'), 'application/json', "Content-Type: 'JSON'");

  $content = decode_json( $res->content );

  print "cntnt dmp:\n" . dump($content); print "\n";

  is ref($content), 'HASH', 'response is a JSON object' ;
  is scalar(keys %{$content}), 8, "Product Data List has 8 Elements";

  subtest 'product-some-empty' => sub {
    is $content->{'veritatis'}, undef, "Product 'Veritatis' not in List";
  };  #subtest 'productlist'

  subtest 'product-last-ok' => sub {
    isnt $content->{'voluptatem'}, undef, "Product 'Voluptatem' in List";
    is ref($content->{'voluptatem'}), 'HASH', 'Product Data is an Object' ;
    isnt $content->{'voluptatem'}->{'name'}, undef, "Product Data has Field 'name'";
    isnt $content->{'voluptatem'}->{'link_name'}, undef, "Product Data has Field 'link_name'";
    isnt $content->{'voluptatem'}->{'image'}, undef, "Product Data has Field 'image'";
    is $content->{'voluptatem'}->{'name'}, 'Voluptatem', "Product Data - Field 'name' is 'Voluptatem'";
  };  #subtest 'productlist'

  #Restore Cache File
  $cachefile->spew($scachecontent);

};  #subtest 'no-page'


subtest 'last-empty' => sub {
  #------------------------
  #Test last Cache Key missing Data

  my $url     = "/coffees";
  my $request = HTTP::Request->new( 'GET', $url );
  my $res     = undef;
  my $content = undef;
  my $cachefile = undef;
  my $scachecontent = undef;


  #Build Cache File
  $cachefile = path($scachedir . $slastcachefilename);
  #Save the Cache Content
  $scachecontent = $cachefile->slurp;
  #Delete the List Cache
  $cachefile->remove;

  #Perform the Request
  $res     = $test->request($request);

  ok( $res, "GET $url" );
  is( $res->code, 200, "Status Code [200] as expected" );
  is($res->header('content-type'), 'application/json', "Content-Type: 'JSON'");

  $content = decode_json( $res->content );

  print "cntnt dmp:\n" . dump($content); print "\n";

  is ref($content), 'HASH', 'response is a JSON object' ;
  is scalar(keys %{$content}), 8, "Product Data List has 8 Elements";

  subtest 'product-last-empty' => sub {
    is $content->{'voluptatem'}, undef, "Product 'Voluptatem' not in List";
  };  #subtest 'productlist'

  subtest 'product-first-ok' => sub {
    isnt $content->{'accusantium'}, undef, "Product 'Accusantium' in List";
    is ref($content->{'accusantium'}), 'HASH', 'Product Data is an Object' ;
    isnt $content->{'accusantium'}->{'name'}, undef, "Product Data has Field 'name'";
    isnt $content->{'accusantium'}->{'link_name'}, undef, "Product Data has Field 'link_name'";
    isnt $content->{'accusantium'}->{'image'}, undef, "Product Data has Field 'image'";
    is $content->{'accusantium'}->{'name'}, 'Accusantium', "Product Data - Field 'name' is 'Accusantium'";
  };  #subtest 'productlist'

  #Restore Cache File
  $cachefile->spew($scachecontent);

};  #subtest 'no-page'


done_testing;
