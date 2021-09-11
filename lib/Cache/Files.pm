
# @author Bodo (Hugo) Barwich
# @version 2021-09-04
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


sub setAsyncCache
{
  my $self = $_[0];
  my $writewatch = AnyEvent::Future->new;


  #print "'" . (caller(0))[3] . "' - go ...\n";

  $writewatch->on_fail(\&Cache::Files::_printWatchError);

  $self->_writeAsyncCache($writewatch, @_[1..$#_]);

  #print "'" . (caller(0))[3] . "' - done.\n";


  return $writewatch;
}

sub setCache
{
  return $_[0]->setAsyncCache(@_[1..$#_])->get;
}

sub _readAsyncCache
{
  my ($self, $readwatch, $scachekey, $rhshrequest) = @_;
  my $sdata = undef;


  if(defined $scachekey
    && $scachekey ne '')
  {
    my $cachefile = undef;
    my $skeymd5 = md5_hex($scachekey);
    my $irs = 0;


    $cachefile = path($self->cachemaindirectory, '/' . substr($skeymd5, 0, 1)
      , '/' . substr($skeymd5, 0, 2) . '/', $skeymd5 . '.json');
    $rhshrequest->{'file'} = $cachefile->stringify;

    if($cachefile->exists)
    {
      eval
      {
        $sdata = $cachefile->slurp;

        $readwatch->done($scachekey, $rhshrequest, $sdata);
      };

      if($@)
      {
        my $irs = 0 + $! ;


        $readwatch->fail({'key' => $scachekey, 'operation' => 'Get', 'file' => $cachefile->stringify
          , 'errorcode' => $irs, 'errormessage' => $! , 'exception' => $@ });
      } #if($@)
    }
    else  #The Cache Key does not exist
    {
      my $smsg = 'Cache Key does not exist.';


      $rhshrequest->{'error'} = {'msg' => $smsg};

      #Mark Request as done
      $readwatch->done($scachekey, $rhshrequest, $sdata);

#      $readwatch->fail({'key' => $scachekey, 'operation' => 'Get', 'file' => $cachefile->stringify
#        , 'errorcode' => 2, 'errormessage' => 'Cache Key not found!', 'exception' => {'msg' => $smsg} });
    } #if($cachefile->exists)
  }
  else  #Cache Key missing
  {
    my $smsg = 'Cache Key is empty or not set.';


    $readwatch->fail({'key' => 'undefined', 'operation' => 'Get', 'file' => ''
      , 'errorcode' => 3, 'errormessage' => 'Cache Key missing!', 'exception' => {'msg' => $smsg} });
  } #if(defined $scachekey
    # && $scachekey ne '')
}

sub _writeAsyncCache
{
  my ($self, $writewatch, $scachekey, $rsdata) = @_ ;


  #print "'" . (caller(0))[3] . "' - go ...\n";

  $$rsdata = '' unless(defined $rsdata);

  if(defined $scachekey
    && $scachekey ne '')
  {
    my $cachedirectory = undef;
    my $cachefile = undef;
    my $skeymd5 = md5_hex($scachekey);


    $cachefile = path($self->cachemaindirectory, '/' . substr($skeymd5, 0, 1)
      , '/' . substr($skeymd5, 0, 2) . '/', $skeymd5 . '.json');
    $cachedirectory = $cachefile->parent;

    eval
    {
      unless($cachedirectory->exists)
      {
        $cachedirectory->mkpath();
      }

      $cachefile->spew($$rsdata);

      $writewatch->done($scachekey, $cachefile->exists);
    };

    if($@)
    {
      my $irs = 0 + $! ;


      $writewatch->fail({'key' => $scachekey, 'operation' => 'Set', 'file' => $cachefile->stringify
        , 'errorcode' => $irs, 'errormessage' => $! , 'exception' => $@ });
    } #if($@)
  }
  else  #Cache Key missing
  {
    my $smsg = 'Cache Key is empty or not set.';

    $writewatch->fail({'key' => 'undefined', 'operation' => 'Set', 'file' => ''
      , 'errorcode' => 3, 'errormessage' => 'Cache Key missing!', 'exception' => {'msg' => $smsg} });
  } #if(defined $scachekey
    # && $scachekey ne '')
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


sub getAsyncCache
{
  my $self = $_[0];
  my $readwatch = AnyEvent::Future->new;


  $readwatch->on_fail(\&Cache::Files::_printWatchError);

  $self->_readAsyncCache($readwatch, @_[1..$#_]);


  return $readwatch;
}

sub getCache
{
  return $_[0]->getAsyncCache(@_[1..$#_])->get;
}




1;
