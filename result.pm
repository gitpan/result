#------------------------------------------------------
#
#
#      result - simple and powerfull error handling
#
#
#------------------------------------------------------
# 2003/12/08 - $Date: 2003/12/11 11:06:04 $
# (C) Daniel Peder & Infoset s.r.o., all rights reserved
# http://www.infoset.com, Daniel.Peder@infoset.com
#------------------------------------------------------
# $Revision: 1.14 $
# $Date: 2003/12/11 11:06:04 $
# $Id: result.pm_rev 1.14 2003/12/11 11:06:04 root Exp root $

# --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- 


package result;


# --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- 

	use vars qw( $VERSION $REVISION $REVISION_DATETIME );

	$VERSION           = '1.1';
	
	$REVISION          = ( qw$Revision: 1.14 $ )[1];
	$REVISION_DATETIME = join(' ',( qw$Date: 2003/12/11 11:06:04 $ )[1,2]);

# --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- 
#
#	POD SECTION
#
# --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- 

=head1 NAME

result - simple and powerfull error handling support

=head1 SYNOPSIS

  use result qw(:ERR);
  
  ...
  sub mySub {
    ...
	return err 'some err message' if errorDetectedUsingAnyCustomWay();
	... continue
	return 'the value that should be returned normal way';
  }
  ...
  my $ResultValue_or_ErrObject = mySub;
  doSomethingProbablyDie() if iserr $ResultValue_or_ErrObject;
  
see also B<DEMO CODE> which is the fully functional demo example.

=head1 DEMO CODE

  use result qw(:ERR);

  sub mySub1 { 
  
    my $param = shift;

	unless( defined( $param ))
    { return err errAsSimpleMsg => 'undefined parameter' }
	
	if( ref( $param ))
	{ return err errAsFormatMsg => ['parameter is "%s" reference', ref($param) ] }

	if( $param eq 'force-err' )
	{ return err 'As Standalone Key or Message' }
	
	return $param;
	
  }
  
  sub mySub2_chain_test {
    my $rv = mySub1();
	if( iserr($rv) )
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
  if( iserr( $val )) { PrintErrReport( $val ) }
  else               { PrintOkReport( $val ) }
  
  $val = mySub1( ['force-err'] );
  if( iserr( $val )) { PrintErrReport( $val ) }
  else               { PrintOkReport( $val ) }

  $val = mySub1( 'force-err' );
  if( iserr( $val )) { PrintErrReport( $val ) }
  else               { PrintOkReport( $val ) }

  $val = mySub1( 'ok value' );
  if( iserr( $val )) { PrintErrReport( $val ) }
  else               { PrintOkReport( $val ) }

  $val = mySub2_chain_test();
  if( iserr( $val )) { PrintErrReport( $val ) }
  else               { PrintOkReport( $val ) }

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

B<by default :> none

B<by tag ':ERR' :> err, iserr

B<by tag ':ALL' :> err, iserr

=cut



# --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- 


	require 5.005_62;

	use strict            ;
	use warnings          ;
	
	use Data::Dump        ();
	

# --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- 


	use vars qw( @EXPORT @EXPORT_OK %EXPORT_TAGS @ISA );

    require Exporter;
	@ISA = qw(Exporter);
	
	%EXPORT_TAGS = ( 
		'ALL'  => [qw( &err &iserr )],
		'ERR'  => [qw( &err &iserr )],
	);
	@EXPORT_OK = @{$EXPORT_TAGS{'ALL'}};


# --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- 


=head1 METHODS

=over 4

=cut


=item err (class method, exported)

  $ResultValue_or_ErrObject = result::err( errKey [ => \@errParameters ] )

Returns the detectable error blessed object. See SYNOPSIS.

=cut
	
sub err ($;$)
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









=item iserr (class method, exported)

  $bool = result::iserr( $ResultValue_or_ErrObject )

Returns true if the B<< $ResultValue_or_ErrObject >> contains ErrorObject. See SYNOPSIS.

=cut
	
sub iserr 
{
	my(		$obj		)=@_;
	return
		defined($obj) 
		&& (ref($obj) eq __PACKAGE__) 
		&& ($obj->{'type'} eq 'ERROR')
	;
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
	my $param        = (ref($msg->[1]) eq 'ARRAY') ? [@{$msg->[1]}] : [$msg->[1]];
	my $format       = @$param>1 ? shift(@$param) : defined($param->[0]) ? '%s' : '' ;
	$format          = sprintf 'ERR[%s] %s', $key, $format;
	
	return sprintf( $format, @$param );
}

=item dump (object method)

  $string = $ResultValue_or_ErrObject->dump

Dumps the whole object using Data::Dump. See SYNOPSIS.
Intended for further diagnostical use with bubbling/stacking errors.

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

B<<  project started: 2003/12/08 >>

 $Id: result.pm_rev 1.14 2003/12/11 11:06:04 root Exp root $


=head1 AUTHOR

 Daniel Peder

 <Daniel.Peder@Infoset.COM>
 http://www.infoset.com

 Czech Republic national flag: 
 LeftSideBlueTriangleRightSideHorizontalSplitTopWhiteBottomRed

=head1 SEE ALSO

Class::ReturnValue
	
=cut

