
# @author Bodo (Hugo) Barwich
# @version 2021-06-12
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



#==============================================================================
# The Product::Factory Package


package Product::Factory;

#----------------------------------------------------------------------------
#Dependencies

use Moose;

use Product;
use Product::List;



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


  $icount = -1 unless(defined $icount);
  $ioffset = 0 unless(defined $ioffset);

  if($icount == -1)
  {

  } #if($icount == -1)



  return $self->list;
}

sub saveProductList
{
  my ($self, $lstprods) = @_;
  my $irs = 0;


  if(defined blessed $lstprods
    && $lstprods->isa('Product::List'))
  {

  } #if(defined blessed $lstprods && $lstprods->isa('Product::List'))



  return $irs;
}


1;
