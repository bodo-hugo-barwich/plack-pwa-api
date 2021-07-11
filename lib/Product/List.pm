
# @author Bodo (Hugo) Barwich
# @version 2021-06-20
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

use Moose;

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
    iterateProducts => 'kv',
    clearProducts => 'clear',
    getProductCount => 'count',
  },
);



#----------------------------------------------------------------------------
#Administration Methods


sub importList
{
  my ($self, $rhshlist) = @_ ;


  #Clear old Data
  $self->clearProducts();

  if(scalar(keys %$rhshlist) > 0)
  {
    my $prod = undef;
    my $slnknm = undef;


    for $slnknm (keys %$rhshlist)
    {
      $prod = Product->new($rhshlist->{$slnknm});

      $self->setProduct($slnknm, $prod);
    } #for $slnknm (keys %$rhshlist)
  } #if(scalar(keys %$rhshlist) > 0)

}


#----------------------------------------------------------------------------
#Consultation Methods


sub exportList
{
  my $self = $_[0];
  my $rhshlist = {};


  if($self->getProductCount() != 0)
  {
    my $prod = undef;


    for $prod ($self->iterateProducts())
    {
      $rhshlist->{$prod->[0]} = {'name' => $prod->[1]->name, 'link_name' => $prod->[1]->link_name
        , 'image' => $prod->[1]->image};
    }
  } #if($self->getProductCount() != 0)


  return $rhshlist;
}


1;
