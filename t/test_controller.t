#!/usr/bin/perl

# @author Bodo (Hugo) Barwich
# @version 2021-08-15
# @package Plack Twiggy REST API
# @subpackage /t/test_controller.t



use strict;
use warnings;

use FindBin;

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


my $test_web = Plack::Util::load_psgi($FindBin::Bin . '/../scripts/web.psgi');


#------------------------
#Build Test Site

my $test = Plack::Test->create($test_web);



subtest 'home' => sub {
  #------------------------
  #Test Home Page

  my $url     = "/";
  my $request = HTTP::Request->new( 'GET', $url );
  my $res     = $test->request($request);
  my $content = undef;


  ok( $res, "GET $url" );
  is( $res->code, 200, "Status Code [200] as expected" );
  is($res->header('content-type'), 'application/json', "Content-Type: 'JSON'");

  $content = decode_json( $res->content );

  print "cntnt dmp:\n" . dump($content); print "\n";

  is ref($content), 'HASH', 'response is a JSON object' ;
  is $content->{'page'}, 'Home', "field 'page' is 'Home'";

};  #subtest 'home'


subtest 'product-list' => sub {
  #------------------------
  #Test Product Data List

  my $url     = "/coffees";
  my $request = HTTP::Request->new( 'GET', $url );
  my $res     = $test->request($request);
  my $content = undef;


  ok( $res, "GET $url" );
  is( $res->code, 200, "Status Code [200] as expected" );
  is($res->header('content-type'), 'application/json', "Content-Type: 'JSON'");

  $content = decode_json( $res->content );

  print "cntnt dmp:\n" . dump($content); print "\n";

  is ref($content), 'HASH', 'response is a JSON object' ;
  is scalar(keys %{$content}), 9, "Product Data List has 9 Elements";

  subtest 'product-data' => sub {
    isnt $content->{'voluptatem'}, undef, "Product 'Voluptatem' in List";
    is ref($content->{'voluptatem'}), 'HASH', 'Product Data is an Object' ;
    isnt $content->{'voluptatem'}->{'name'}, undef, "Product Data has Field 'name'";
    isnt $content->{'voluptatem'}->{'link_name'}, undef, "Product Data has Field 'link_name'";
    isnt $content->{'voluptatem'}->{'image'}, undef, "Product Data has Field 'image'";
    is $content->{'voluptatem'}->{'name'}, 'Voluptatem', "Product Data - Field 'name' is 'Voluptatem'";
  };  #subtest 'productlist'
};  #subtest 'productlist'


subtest 'no-page' => sub {
  #------------------------
  #Test Non Existent Page

  my $url     = "/no-page";
  my $request = HTTP::Request->new( 'GET', $url );
  my $res     = $test->request($request);
  my $content = undef;


  ok( $res, "GET $url" );
  is( $res->code, 404, "Status Code [404] as expected" );
  is($res->header('content-type'), 'application/json', "Content-Type: 'JSON'");

  $content = decode_json( $res->content );

  print "cntnt dmp:\n" . dump($content); print "\n";

  is ref($content), 'HASH', 'response is a JSON object' ;
  is $content->{'page'}, 'none', "field 'page' is 'none'";
  isnt $content->{'errormessage'}, undef, "field 'errormessage' exists";
  is $content->{'errormessage'}, 'Not Found', "field 'errormessage' has 'Not Found'";

};  #subtest 'no-page'


done_testing;
