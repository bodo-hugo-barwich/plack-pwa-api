
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



#==============================================================================
# The Cache::Files Package


package Cache::Files;

#----------------------------------------------------------------------------
#Dependencies

use Moose;

extends 'Cache';


# Functional style
use Digest::MD5 qw(md5_hex);

use Path::Tiny;
use AnyEvent::Future;



#----------------------------------------------------------------------------
#Properties


has 'cachemaindirectory' => (
    isa       => 'Str',
    is        => 'ro',
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
  my ($self, $scachekey, $rsdata) = @_ ;
  my $irs = 0;


  if(defined $scachekey
    && defined $rsdata
    && $scachekey ne '')
  {
    my $writewatch = AnyEvent::Future->new;


    $writewatch->on_fail(\&Cache::Files::_printWatchError);

    $self->_doWriteCache($writewatch, $scachekey, $rsdata);

    $irs = $writewatch->get;

  } #if(defined $scachekey && defined $rsdata
    # && $scachekey ne '')


  return $irs;
}

sub _doWriteCache
{
  my ($self, $writewatch, $scachekey, $rsdata) = @_ ;
  my $cachedirectory = undef;
  my $cachefile = undef;
  my $skeymd5 = md5_hex($scachekey);


  $cachefile = path($self->cachemaindirectory, '/' . substr($skeymd5, 0, 1)
    , '/' . substr($skeymd5, 0, 2) . '/', $skeymd5 . '.json');
  $cachedirectory = $cachefile->parent;

  eval
  {
    #unless($cachedirectory->exists)
    #{
    #  $cachedirectory->mkpath();
    #}

    $cachefile->spew(($$rsdata));

    $writewatch->done($cachefile->exists);
  };

  if($@)
  {
    my $irs = 0 + $! ;

    $writewatch->fail({'key' => $scachekey, 'operation' => 'Set', 'file' => $cachefile->stringify
      , 'errorcode' => $irs, 'errormessage' => $! , 'exception' => $@ });

    $irs = 0;
  } #if($@)
}

sub _printWatchError
{
  my $rhsherr = $_[0];


  print STDERR "Cache '", $rhsherr->{'key'}, "': ", $rhsherr->{'operation'}, " Cache failed with Exception ["
    , $rhsherr->{'errorcode'}, "]: '", $rhsherr->{'errormessage'} , "'\n";
  print STDERR "File '", $rhsherr->{'file'}, "' - Exception Message: '"
    , $rhsherr->{'exception'}->{'msg'}  , "'\n";
}



#----------------------------------------------------------------------------
#Consultation Methods


sub getCache
{
  my ($self, $scachekey) = @_[0..1];
  my $sdata = undef;


  if(defined $scachekey
    && $scachekey ne '')
  {
    my $cachefile = undef;
    my $skeymd5 = md5_hex($scachekey);
    my $irs = 0;


    $cachefile = path($self->cachemaindirectory, '/' . substr($skeymd5, 0, 1)
      , '/' . substr($skeymd5, 0, 2) . '/', $skeymd5 . '.json');

    if($cachefile->exists)
    {
      eval
      {
        $sdata = $cachefile->slurp;
      };

      if($@)
      {
        $irs = 0 + $! ;

        print STDERR "Cache '$scachekey': Get Cache failed with Exception [$irs]: '" . $! . "'\n";
        print STDERR "File '" . $cachefile->stringify . "' - Exception Message: '" . $@ . "'\n";

        $irs = 0;
      } #if($@)
    } #if($cachefile->exists)
  } #if(defined $scachekey && defined $rsdata
    # && $scachekey ne '')


  return $sdata;
}




1;
