
# @author Bodo (Hugo) Barwich
# @version 2021-06-06
# @package Plack Twiggy REST API
# @subpackage Product.pm

# This Module defines the Data Structures for the REST API
#
#---------------------------------
# Requirements:
# - The Perl Module "Moose" must be installed
#
#---------------------------------
# Features:
#



#==============================================================================
# The Product Package


package Product;

#----------------------------------------------------------------------------
#Dependencies

use Moose;




#----------------------------------------------------------------------------
#Properties


has 'type' => (isa => 'Str', is => 'ro', 'default' => 'Coffee');
has 'name' => (isa => 'Str', is => 'rw');
has 'link_name' => (isa => 'Str', is => 'rw');
has 'image' => (isa => 'Str', is => 'rw');



#----------------------------------------------------------------------------
#Administration Methods


sub Clear
{
  my $self = $_[0];


  $self->name('');
  $self->link_name('');
  $self->image('');
}


1;
