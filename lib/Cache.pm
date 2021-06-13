
# @author Bodo (Hugo) Barwich
# @version 2021-06-12
# @package Plack Twiggy REST API
# @subpackage Cache.pm

# This Module defines a abstract class which defines standard Functionalities
# which specialised Subclasses must implement
#
#---------------------------------
# Requirements:
#
#---------------------------------
# Features:
#



BEGIN {
    use lib '../../lib';
}  #BEGIN



#==============================================================================
# The Cache Package


package Cache;

#----------------------------------------------------------------------------
#Dependencies

use Moose;



#----------------------------------------------------------------------------
#Administration Methods


sub setCache
{
  my ($self, $scachekey) = @_[0..1];
  my $rsdata = $_[3];

}



#----------------------------------------------------------------------------
#Consultation Methods


sub getCache
{
  my ($self, $scachekey) = @_[0..1];
  my $sdata = undef;


  return $sdata;
}




1;
