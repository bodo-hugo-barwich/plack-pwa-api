
# @author Bodo (Hugo) Barwich
# @version 2021-06-20
# @package Plack Twiggy REST API
# @subpackage Product/Factory.pm

# This Module defines a class which manages Product objects
# It de/serializes the objects to the persistent storage
#
#---------------------------------
# Requirements:
# - The Perl Module "Product.pm" must be installed
#
#---------------------------------
# Features:
#



BEGIN {
    use lib '../../lib';
}  #BEGIN

use Scalar::Util qw(blessed);

use JSON;



#==============================================================================
# The Product::Factory Package


package Product::Factory;

#----------------------------------------------------------------------------
#Dependencies

use Moose;

use Product;
use Product::List;

use constant URLLISTKEY => 'list-product-urls';
use constant PRODUCTKEY => 'product';



#----------------------------------------------------------------------------
#Properties


has 'cache' => (
  isa => 'Cache',
  is  => 'rw',
);

has 'list' => (
  isa => 'Product::List',
  is  => 'rw',
  'default' => sub { Product::List->new() },
);



#----------------------------------------------------------------------------
#Constructors


around BUILDARGS => sub {
  my ($orig, $class) = @_[0..1];


  if(scalar(@_) > 2)
  {
    if(defined blessed $_[2])
    {
      #Cache Objects must be derived from the Cache Package
      if($_[2]->isa('Cache'))
      {
        return $class->$orig('cache' => $_[2]);
      }
      else
      {
        return $class->$orig(@_[2..$#_]);
      }
    }
    else  #Third Parameter is not an object
    {
      return $class->$orig(@_[2..$#_]);
    }
  }
  else  #No additional Parameters given
  {
    return $class->$orig();
  }
};



#----------------------------------------------------------------------------
#Administration Methods


sub buildProductList
{
  my ($self, $icount, $ioffset) = @_;
  my $rhshdata = {};


  $icount = -1 unless(defined $icount);
  $ioffset = 0 unless(defined $ioffset);

  if(defined $self->cache)
  {
    my $rarrurls = [];
    my $surlsjson = $self->cache->getCache(Product::Factory::URLLISTKEY
      . '_' . $icount . '_' . $ioffset);
    my $sprodurl = '';
    my $sprodjson = undef;


    $rarrurls = JSON::decode_json($surlsjson) if(defined $surlsjson && $surlsjson ne '');

    foreach $sprodurl (@$rarrurls)
    {
      $sprodjson = $self->cache->getCache(Product::Factory::PRODUCTKEY
        . '_' . $sprodurl);

      if(defined $sprodjson)
      {
        $rhshdata->{$sprodurl} = JSON::decode_json($sprodjson);
      }
      else
      {
        $rhshdata->{$sprodurl} = {};
      } #if(defined $sprodjson)

    } #foreach $sprodurl (@arrurls)

  } #if(defined $self->cache)

  #Import Data Hash
  $self->list->importList($rhshdata);


  return $self->list;
}

sub saveProductList
{
  my ($self, $lstprods, $icount, $ioffset) = @_;
  my $irs = 0;


  $icount = -1 unless(defined $icount);
  $ioffset = 0 unless(defined $ioffset);

  if(defined blessed $lstprods
    && $lstprods->isa('Product::List'))
  {
    my $rhshdata = $lstprods->exportList;


    $self->list->importList($rhshdata);

    if(defined $self->cache)
    {
      #------------------------
      #Pre-cache the Data

      my @arrurls = ();
      my $surlsjson = undef;
      my $sprodurl = undef;
      my $sprodjson = undef;


      @arrurls = keys %$rhshdata if(defined $rhshdata);

      $surlsjson = JSON::encode_json(\@arrurls);

      $self->cache->setCache(Product::Factory::URLLISTKEY
        . '_' . $icount . '_' . $ioffset, \$surlsjson);

      foreach $sprodurl (@arrurls)
      {
        $sprodjson = JSON::encode_json($rhshdata->{$sprodurl});

        $self->cache->setCache(Product::Factory::PRODUCTKEY
          . '_' . $sprodurl, \$sprodjson);
      } #foreach $sprodurl (@arrurls)
    } #if(defined $self->cache)
  } #if(defined blessed $lstprods && $lstprods->isa('Product::List'))


  return $irs;
}


1;
