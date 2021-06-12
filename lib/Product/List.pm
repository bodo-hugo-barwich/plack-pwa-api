
# @author Bodo (Hugo) Barwich
# @version 2020-03-21
# @package Plack Twiggy REST API
# @subpackage Product/List.pm

# This Module defines a Class which manages Product Objects with the Moose "Hash" Trait
#
#---------------------------------
# Requirements:
# - The Perl Module "Moose" must be installed
# - The Perl Module "Product.pm" must be installed
#
#---------------------------------
# Features:
#



BEGIN {
    use lib '../../lib';
}  #BEGIN



#==============================================================================
# The Product::List Package


package Product::List;

#----------------------------------------------------------------------------
#Dependencies

use Moose; # automatically turns on strict and warnings

use Product;



#----------------------------------------------------------------------------
#Properties


has 'products' => (
  traits => ['Hash'],
  isa => 'HashRef[Product]',
  'default' => sub { {} },
  handles => {
    setProduct => 'set',
    getProduct => 'get',
    hasProduct => 'exists',
  },
);



#----------------------------------------------------------------------------
#Administration Methods


sub setList
{
  my ($self, $rhshlist) = @_ ;


}


#----------------------------------------------------------------------------
#Consultation Methods


sub getList
{
  my $self = $_[0];
  my $rhshlist = {};


}


1;
