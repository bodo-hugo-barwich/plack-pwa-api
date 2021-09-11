
# @author Bodo (Hugo) Barwich
# @version 2021-06-20
# @package Plack Twiggy REST API
# @subpackage Product/Factory.pm

# This Module defines a class which manages Product objects
# It de/serializes the objects to the persistent storage
#
#---------------------------------
# Requirements:
# - The Perl Module "Product.pm" must be installed
#
#---------------------------------
# Features:
#



BEGIN {
    use lib '../../lib';
}  #BEGIN



#==============================================================================
# The Product::Factory Package


package Product::Factory;

#----------------------------------------------------------------------------
#Dependencies

use Moose;

use Product;
use Product::List;

use Scalar::Util qw(blessed);

use JSON;
use AnyEvent::Future;

use Data::Dump qw(dump);

use constant URLLISTKEY => 'list-product-urls';
use constant PRODUCTKEY => 'product';



#----------------------------------------------------------------------------
#Properties


has 'cache' => (
  isa => 'Cache',
  is  => 'rw',
);

has 'list' => (
  isa => 'Product::List',
  is  => 'rw',
  'default' => sub { Product::List->new() },
);



#----------------------------------------------------------------------------
#Constructors


around BUILDARGS => sub {
  my ($orig, $class) = @_[0..1];


  if(scalar(@_) > 2)
  {
    if(defined blessed $_[2])
    {
      #Cache Objects must be derived from the Cache Package
      if($_[2]->isa('Cache'))
      {
        return $class->$orig('cache' => $_[2]);
      }
      else
      {
        return $class->$orig(@_[2..$#_]);
      }
    }
    else  #Third Parameter is not an object
    {
      return $class->$orig(@_[2..$#_]);
    }
  }
  else  #No additional Parameters given
  {
    return $class->$orig();
  }
};



#----------------------------------------------------------------------------
#Administration Methods

sub buildProductList
{
  my $self = $_[0];
  my $buildwatch = undef;
  my $rhshrequest = undef;
  my $rhshdata = {};


  $buildwatch = $self->_getAsyncProductList(@_[1..$#_])
    ->then_with_f(sub {
      my ( $f_cond, @arrresult ) = @_;
      my $rarrurls = $arrresult[2];


      $rhshrequest = $arrresult[1];

#      print "f_cond: '$f_cond'\n";
#      print "arr rs dmp:\n" . dump(@arrresult);
#      print "\n";

      if(defined $rarrurls)
      {
        if(ref($rarrurls) eq '')
        {
          if($rarrurls ne '')
          {
            $rarrurls = JSON::decode_json($rarrurls) ;
          }
          else
          {
            #Create an empty Array
            $rarrurls = [];
          }
        } #if(ref($rarrurls) eq '')


        return $self->_lookupAsyncProductList($rarrurls);
      }
      else  #Product List was not found
      {
        #The missing Product List is fatal

        return $f_cond->then_fail({'key' => $rhshrequest->{'key'}, 'operation' => 'Get', 'file' => $rhshrequest->{'file'}
          , 'errorcode' => 2, 'errormessage' => 'Cache Key not found!', 'exception' => $rhshrequest->{'error'}});

      } #if(defined $rarrurls)
    }); #$self->_getAsyncProductList(@_[1..$#_])


  my @arrrslookup = $buildwatch->get;
  my $rslookup = undef;
  my @arrrsproduct = undef;
  my $rhshproduct = undef;


#  print "arr lkp (cnt: '", scalar(@arrrslookup), "') join: '",  join('|', @arrrslookup), "'\n";
#  print "arr lkp dmp:\n" . dump(@arrrslookup);
#  print "\n";

  if(scalar(@arrrslookup) > 0)
  {
    foreach $rslookup (@arrrslookup)
    {
#      print "lkp dmp:\n" . dump($rslookup);
#      print "\n";

      if(defined $rslookup)
      {
        @arrrsproduct = $rslookup->result;
        $rhshrequest = $arrrsproduct[1];
        $rhshproduct = $arrrsproduct[2];


        if(defined $rhshproduct
          && defined ref $rhshrequest
          && ref($rhshrequest) eq 'HASH')
        {
          $rhshdata->{$rhshrequest->{'link'}} = {};

          if(defined $rhshproduct)
          {
            if(ref($rhshproduct) eq '')
            {
              if($rhshproduct ne '')
              {
                $rhshproduct = JSON::decode_json($rhshproduct) ;
              }
              else
              {
                #Create an empty Hash
                $rhshproduct = {};
              }
            } #if(ref($rhshproduct) eq '')

            $rhshdata->{$rhshrequest->{'link'}} = $rhshproduct;
          } #if(defined $rhshproduct)
        } #if(defined ref $rhshrequest && ref($rhshrequest) eq 'HASH')
      } #if(defined $rslookup)
    } #foreach $rarrrsproduct (@arrrslookup)
  } #if(scalar(@arrrslookup) > 0)

  #Import Data Hash
  $self->list->importList($rhshdata);


  return $self->list;
}

sub saveProductList
{
  my ($self, $lstprods, $icount, $ioffset) = @_;
  my $irs = 0;


  $icount = -1 unless(defined $icount);
  $ioffset = 0 unless(defined $ioffset);

  if(defined blessed $lstprods
    && $lstprods->isa('Product::List'))
  {
    my $rhshdata = $lstprods->exportList;


    $self->list->importList($rhshdata);

    if(defined $self->cache)
    {
      #------------------------
      #Pre-cache the Data

      my @arrurls = ();
      my $surlsjson = undef;
      my $sprodurl = undef;
      my $sprodjson = undef;


      @arrurls = keys %$rhshdata if(defined $rhshdata);

      $surlsjson = JSON::encode_json(\@arrurls);

      $self->cache->setCache(Product::Factory::URLLISTKEY
        . '_' . $icount . '_' . $ioffset, \$surlsjson);

      foreach $sprodurl (@arrurls)
      {
        $sprodjson = JSON::encode_json($rhshdata->{$sprodurl});

        $self->cache->setCache(Product::Factory::PRODUCTKEY
          . '_' . $sprodurl, \$sprodjson);
      } #foreach $sprodurl (@arrurls)
    } #if(defined $self->cache)
  } #if(defined blessed $lstprods && $lstprods->isa('Product::List'))


  return $irs;
}

sub _printWatchError
{
  my $rhsherr = $_[0];


  print STDERR "Product '", $rhsherr->{'key'}, "': ", $rhsherr->{'operation'}, " Product failed with Exception ["
    , $rhsherr->{'errorcode'}, "]: '", $rhsherr->{'errormessage'} , "'\n";
  print STDERR "File '", $rhsherr->{'file'}, "' - Exception Message: '"
    , $rhsherr->{'exception'}->{'msg'}  , "'\n";
}



#----------------------------------------------------------------------------
#Inspection Methods


sub _getAsyncProduct
{
  my ($self, $sprodurl) = @_;
  my $productwatch = undef;


  $sprodurl = '' unless(defined $sprodurl);

  if($sprodurl ne '')
  {
    my %hshprodreq = ('key' => Product::Factory::PRODUCTKEY. '_' . $sprodurl
      , 'link' => $sprodurl, 'operation' => 'Get');


    if(defined $self->cache)
    {
      $productwatch = $self->cache->getAsyncCache($hshprodreq{'key'}, \%hshprodreq);
    }
    else  #Cache is not initialized
    {
      #Return an empty Result
      $productwatch = AnyEvent::Future->done($hshprodreq{'key'}, \%hshprodreq, '');
    } #if(defined $self->cache)
  }
  else  #Product Link missing
  {
    my $smsg = 'Product Link is empty or not set.';

    $productwatch = AnyEvent::Future->fail({'key' => 'undefined', 'operation' => 'Get', 'file' => ''
      , 'errorcode' => 3, 'errormessage' => 'Product Link missing!', 'exception' => {'msg' => $smsg} });
  } #if($sprodurl ne '')


  return $productwatch;
}

sub _getAsyncProductList
{
  my ($self, $icount, $ioffset) = @_;
  my $listwatch = undef;
  my %hshlistreq = ();


  $icount = -1 unless(defined $icount);
  $ioffset = 0 unless(defined $ioffset);

  %hshlistreq = ('key' => Product::Factory::URLLISTKEY . '_' . $icount . '_' . $ioffset
    , 'operation' => 'Get');

  if(defined $self->cache)
  {
    $listwatch = $self->cache->getAsyncCache($hshlistreq{'key'}, \%hshlistreq);
  }
  else  #Cache is not initialized
  {
    #Return an empty Result
    $listwatch = AnyEvent::Future->done($hshlistreq{'key'}, \%hshlistreq, '');
  } #if(defined $self->cache)


  return $listwatch;
}

sub _lookupAsyncProductList
{
  my ($self, $rarrurls) = @_;
  my $lookupwatch = AnyEvent::Future->wait_all( map { $self->_getAsyncProduct($_) } @$rarrurls );


  $lookupwatch->on_fail(\&Product::Factory::_printWatchError);


  return $lookupwatch;
}





1;
