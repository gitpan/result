  use result qw( :ERR );

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
