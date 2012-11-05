function dumpState( ~ )

	global states;
	global dump;
	
	dump.state1.S( length( dump.state1.S ) + 1 ) = states( 1, 2 );
	dump.state1.Z( length( dump.state1.S ) ) = states( 1, 3 );
	dump.state1.R( length( dump.state1.S ) ) = states( 1, 4 );
	
	dump.state2.S( length( dump.state1.S ) ) = states( 2, 2 );
	dump.state2.Z( length( dump.state1.S ) ) = states( 2, 3 );
	dump.state2.R( length( dump.state1.S ) ) = states( 2, 4 );
	
	dump.state3.S( length( dump.state1.S ) ) = states( 3, 2 );
	dump.state3.Z( length( dump.state1.S ) ) = states( 3, 3 );
	dump.state3.R( length( dump.state1.S ) ) = states( 3, 4 );
	
	dump.global.S( length( dump.state1.S ) ) = states( 4, 2 );
	dump.global.Z( length( dump.state1.S ) ) = states( 4, 3 );
	dump.global.R( length( dump.state1.S ) ) = states( 4, 4 );

end

