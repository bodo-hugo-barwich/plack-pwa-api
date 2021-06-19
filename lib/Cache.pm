
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
  die("Method '" . (caller(0))[3] . "' - Implementation missing!");
}



#----------------------------------------------------------------------------
#Consultation Methods


sub getCache
{
  die("Method '" . (caller(0))[3] . "' - Implementation missing!");
}




1;
