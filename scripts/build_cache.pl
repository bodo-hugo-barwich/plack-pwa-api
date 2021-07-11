#!/usr/bin/perl

# @author Bodo (Hugo) Barwich
# @version 2021-06-19
# @package Plack Twiggy REST API
# @subpackage /scripts/build_cache.pl

# This Module pre-builds the Cache on the System
#
#---------------------------------
# Requirements:
# - The Perl Module "Path::Tiny" must be installed
# - The Perl Module "Plack" must be installed
# - The Perl Module "Twiggy" must be installed
#
#---------------------------------
# Features:
#
#---------------------------------
# Example:
#
#  {
#    name: "Perspiciatis",
#    link_name: 'perspiciatis',
#    image: svmainpath + "images/coffee1.jpg"
#  },
#  {
#    name: "Voluptatem",
#    link_name: 'voluptatem',
#    image: svmainpath + "images/coffee2.jpg"
#  },
#  {
#    name: "Explicabo",
#    link_name: 'explicabo',
#    image: svmainpath + "images/coffee3.jpg"
#  },
#  {
#    name: "Rechitecto",
#    link_name: 'rechitecto',
#    image: svmainpath + "images/coffee4.jpg"
#  },
#  {
#    name: "Beatae",
#    link_name: 'beatae',
#    image: svmainpath + "images/coffee5.jpg"
#  },
#  {
#    name: "Vitae",
#    link_name: 'vitae',
#    image: svmainpath + "images/coffee6.jpg"
#  },
#  {
#    name: "Inventore",
#    link_name: 'inventore',
#    image: svmainpath + "images/coffee7.jpg"
#  },
#  {
#    name: "Veritatis",
#    link_name: 'veritatis',
#    image: svmainpath + "images/coffee8.jpg"
#  },
#  {
#    name: "Accusantium",
#    link_name: 'accusantium',
#    image: svmainpath + "images/coffee9.jpg"
#  }
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

use Cache::Files;
use Product::List;
use Product::Factory;



#----------------------------------------------------------------------------
#Executing Section


my $smaindir = path(__FILE__)->parent->parent->stringify;

my $cache = Cache::Files->new($smaindir . '/cache/');
my $prodfactory = Product::Factory->new($cache);
my $lstprods = Product::List->new();


$lstprods->setProduct('perspiciatis'
  , Product->new({'name' => 'Perspiciatis', 'link_name' => 'perspiciatis', 'image' => 'coffee1.jpg'}));
$lstprods->setProduct('voluptatem'
  , Product->new({'name' => 'Voluptatem', 'link_name' => 'voluptatem', 'image' => 'coffee2.jpg'}));
$lstprods->setProduct('explicabo'
  , Product->new({'name' => 'Explicabo', 'link_name' => 'explicabo', 'image' => 'coffee3.jpg'}));
$lstprods->setProduct('rechitecto'
  , Product->new({'name' => 'Rechitecto', 'link_name' => 'rechitecto', 'image' => 'coffee4.jpg'}));
$lstprods->setProduct('beatae'
  , Product->new({'name' => 'Beatae', 'link_name' => 'beatae', 'image' => 'coffee5.jpg'}));
$lstprods->setProduct('vitae'
  , Product->new({'name' => 'Vitae', 'link_name' => 'vitae', 'image' => 'coffee6.jpg'}));
$lstprods->setProduct('inventore'
  , Product->new({'name' => 'Inventore', 'link_name' => 'inventore', 'image' => 'coffee7.jpg'}));
$lstprods->setProduct('veritatis'
  , Product->new({'name' => 'Veritatis', 'link_name' => 'veritatis', 'image' => 'coffee8.jpg'}));
$lstprods->setProduct('accusantium'
  , Product->new({'name' => 'Accusantium', 'link_name' => 'accusantium', 'image' => 'coffee9.jpg'}));

#Save the Product List to the Cache
$prodfactory->saveProductList($lstprods, -1, 0);




