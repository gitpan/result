
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
