
# @author Bodo (Hugo) Barwich
# @version 2020-03-21
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



#==============================================================================
# The Product::Factory Package


package Product::Factory;

#----------------------------------------------------------------------------
#Dependencies

use Moose; # automatically turns on strict and warnings

use Product;
use Product::List;



#----------------------------------------------------------------------------
#Properties


has 'list' => (
    isa => 'Product::List',
    'default' => sub { Product::List->new() },
);



#----------------------------------------------------------------------------
#Administration Methods


sub buildProductList
{
  my ($self, $icount, $ioffset) = @_;


  $icount = -1 unless(defined $icount);
  $ioffset = 0 unless(defined $ioffset);


  return $self->list;
}


1;
