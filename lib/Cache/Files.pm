
# @author Bodo (Hugo) Barwich
# @version 2021-06-12
# @package Plack Twiggy REST API
# @subpackage Cache/Files.pm

# This Module defines a class which manages Data Cache as Files Storage
# The Cache handles only Text Data and stores it in Files
#
#---------------------------------
# Requirements:
# - The Perl Module "Digest::MD5" must be installed
# - The Perl Module "Path::Tiny" must be installed
#
#---------------------------------
# Features:
#



use Path::Tiny;



#==============================================================================
# The Cache::Files Package


package Cache::Files;

#----------------------------------------------------------------------------
#Dependencies

use Moose;



#----------------------------------------------------------------------------
#Properties


has 'cachemaindirectory' => (
    is        => 'ro',
    isa       => 'Str',
    'default' => sub { path(__FILE__)->parent->parent->parent->stringify . '/cache/'; },
);



#----------------------------------------------------------------------------
#Constructors


around BUILDARGS => sub {
  my ($orig, $class) = @_[0..1];


  if(scalar(@_) > 2)
  {
    if(! ref $_[2])
    {
      return $class->$orig('cachemaindirectory' => $_[2]);
    }
    else
    {
      return $class->$orig(@_[2..$#_]);
    }
  }
  else
  {
    return $class->$orig();
  }
};



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
