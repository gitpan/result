

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
  
  my $mighty_value;

  $mighty_value = mySub1();
  print "\n---\n";
  printf "%s\n", result::iserr($mighty_value)?$mighty_value->msg:$mighty_value;
  print $mighty_value->dump."\n" if result::iserr( $mighty_value );
  
  $mighty_value = mySub1( [1] );
  print "\n---\n";
  printf "%s\n", result::iserr($mighty_value)?$mighty_value->msg:$mighty_value;
  print $mighty_value->dump."\n" if result::iserr( $mighty_value );

  $mighty_value = mySub1( 'ok value' );
  print "\n---\n";
  printf "%s\n", result::iserr($mighty_value)?$mighty_value->msg:$mighty_value;
  print $mighty_value->dump."\n" if result::iserr( $mighty_value );

  $mighty_value = mySub2_chain_test();
  print "\n---\n";
  printf "%s\n", result::iserr($mighty_value)?$mighty_value->msg:$mighty_value;
  print $mighty_value->dump."\n" if result::iserr( $mighty_value );
  
