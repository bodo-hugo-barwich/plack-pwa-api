
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

use Moose; # automatically turns on strict and warnings




#----------------------------------------------------------------------------
#Properties


has 'type' => (is => 'ro', isa => 'Str', 'default' => 'Coffee');
has 'name' => (is => 'rw', isa => 'Str');
has 'link_name' => (is => 'rw', isa => 'Str');
has 'image' => (is => 'rw', isa => 'Str');



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
