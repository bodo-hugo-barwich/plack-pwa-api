
# @author Bodo (Hugo) Barwich
# @version 2021-06-06
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
    getProductCount => 'count',
  },
);



#----------------------------------------------------------------------------
#Administration Methods


sub setList
{
  my ($self, $rhshlist) = @_ ;


  if(scalar(keys %$rhshlist) > 0)
  {
    my $prod = undef;
    my $slnknm = undef;


    for $slnknm (keys %$rhshlist)
    {
      $prod = Product->new($rhshlist->{$slnknm});

      $self->products->set($slnknm, $prod);
    } #for $slnknm (keys %$rhshlist)
  } #if(scalar(keys %$rhshlist) > 0)

}


#----------------------------------------------------------------------------
#Consultation Methods


sub getList
{
  my $self = $_[0];
  my $rhshlist = {};


  unless($self->products->is_empty())
  {
    my $prod = undef;


    for $prod ($self->products->kv)
    {
      $rhshlist->{$prod->[0]} = {'name' => $prod->[1]->name, 'link_name' => $prod->[1]->link_name
        , 'image' => $prod->[1]->image};
    }
  } #unless($self->products->is_empty())


  return $rhshlist;
}


1;
