#------------------------------------------------------
#
#
#      result
#
#
#------------------------------------------------------
# 2003/12/08 - $Date: 2003/12/08 16:27:33 $
# (C) Daniel Peder & Infoset s.r.o., all rights reserved
# http://www.infoset.com, Daniel.Peder@infoset.com
#------------------------------------------------------
# $Revision: 1.7 $
# $Date: 2003/12/08 16:27:33 $
# $Id: result.pm_rev 1.7 2003/12/08 16:27:33 root Exp root $

# --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- 

package result;


# --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- 

	use vars qw( $VERSION $REVISION $REVISION_DATETIME );

	$VERSION           = '1.00';
	
	$REVISION          = ( qw$Revision: 1.7 $ )[1];
	$REVISION_DATETIME = join(' ',( qw$Date: 2003/12/08 16:27:33 $ )[1,2]);

# --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- 
#
#	POD SECTION
#
# --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- 

=head1 NAME

result - simple but powerfull error handling support

=head1 SYNOPSIS

  use result;

  # use result qw( messages=/etc/messages ); # intended to use i18l messages addressed by errKey ...
  
  sub mySub1 { 
  
    my $param = shift;

	unless( defined( $param ))
    { return result::err( errAsSimpleMsg => 'undefined parameter' ) }
	
	if( ref( $param ))
	{ return result::err( errAsFormatMsg => ['parameter as reference "%s"', ref($param) ] ) }
	
	return $param;
	
  }
  
  sub mySub2_chain_test {
    my $rv = mySub1();
	if( result::iserr($rv) )
	{
	  return $rv->errChain( errBubbled => 'use dump to see error history' ) ;
	}
	else
	{
	  return 'ok, no chained errors';
	}
  }
  
  my $val;

  $val = mySub1(); 
  if( result::iserr( $val )) { PrintErrReport( $val ) }
  else                       { PrintOkReport( $val ) }
  
  $val = mySub1( [1] );
  if( result::iserr( $val )) { PrintErrReport( $val ) }
  else                       { PrintOkReport( $val ) }

  $val = mySub1( 'ok value' );
  if( result::iserr( $val )) { PrintErrReport( $val ) }
  else                       { PrintOkReport( $val ) }

  $val = mySub2_chain_test();
  if( result::iserr( $val )) { PrintErrReport( $val ) }
  else                       { PrintOkReport( $val ) }

  sub PrintErrReport {
  	my $val = shift;
	print join( "\n", '---', $val->msg, $val->dump, '' );
  }
	
  sub PrintOkReport {
  	my $val = shift;
	print "\n---\n non-err-result: ", $val, "\n";
  }
  
  
  
=head1 DESCRIPTION


=head2 EXPORT

nothing

=cut



# --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- 


	require 5.005_62;

	use strict            ;
	use warnings          ;
	
	use Data::Dump        ();
	

=head1 METHODS

=over 4

=cut


=item err (class method)

  $ResultValue_or_ErrObject = result::err( errKey => \@errParameters )

Returns the detectable error object. See SYNOPSIS.

=cut
	
sub err
{
	my(		$key, $param		)=@_;
	
	return
	bless { 
	    'type'    => 'ERROR',
		'stack'   => [[ $key, $param, [caller(1)] ]],
	}, __PACKAGE__;
	
}










=item errChain (object method)

  $ResultValue_or_ErrObject = $ResultValue_or_ErrObject->errChain( errKey => \@errParameters )

Adds chain item to the detectable error object. Used to add higher level err messagess,
while the ErrorObject bubbles backwards the calls until catched and processed.

It could be understand as B<< error history >> or as B<< err stack >>.

=cut
	
sub errChain
{
	my(		$self, $key, $param		)=@_;
	
	unshift @{$self->{'stack'}}, [ $key, $param, [caller(1)] ];
	return $self
	
}









=item iserr (class method)

  $bool = result::iserr( $ResultValue_or_ErrObject )

Returns true if the B<< $ResultValue_or_ErrObject >> contains ErrorObject. See SYNOPSIS.

=cut
	
sub iserr
{
	my(		$obj		)=@_;
	ref( $obj ) eq __PACKAGE__ && $obj->{'type'} eq 'ERROR';
}








=item msg (object method)

  $string = $ResultValue_or_ErrObject->msg

Returns the string value of contained ErrorMessage. See SYNOPSIS.

=cut
	
sub msg
{
	my(		$self		)=@_;
	
	my $msg          = $self->{'stack'}->[0];
	my $key          = $msg->[0];
	my $param        = (ref($msg->[1]) eq 'ARRAY')?[@{$msg->[1]}]:[$msg->[1]];
	my $format       = $#$param>0 ? shift(@$param):'%s';
	$format          = sprintf 'ERR[%s] %s', $key, $format;
	
	return sprintf( $format, @$param );
}

=item dump (object method)

  $string = $ResultValue_or_ErrObject->dump

Denerates complete dump using Data::Dump. See SYNOPSIS.
Intended for further diagnostical use by bubbling/stacking errors.

=cut
	
sub dump { Data::Dump::dump( shift ) }

1;


# --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- 
#
#	POD SECTION
#
# --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- 

=back

=cut

=head1 FILES

none

=head1 REVISION

B<<  project started: 2003/05/09 >>

 $Id: result.pm_rev 1.7 2003/12/08 16:27:33 root Exp root $


=head1 AUTHOR

 Daniel Peder

 <Daniel.Peder@Infoset.COM>
 http://www.infoset.com

 Czech Republic national flag: 
 LeftSideBlueTriangleRightSideHorizontalSplitTopWhiteBottomRed

=head1 SEE ALSO

L<< Class::ReturnValue >>
	
=cut

