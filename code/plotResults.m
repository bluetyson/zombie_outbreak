function plotResults( ~ )

	global dump;

	x = 0:( length( dump.state1.S ) - 1 );
		
	subplot( 2, 2, 1 );
	plot( x, dump.state1.S, x, dump.state1.Z, x, dump.state1.R );
	ylim( [ 0 dump.global.S( 1 ) ] );
	title( 'State 1' );
	
	subplot( 2, 2, 2 );
	plot( x, dump.state2.S, x, dump.state2.Z, x, dump.state2.R );
	ylim( [ 0 dump.global.S( 1 ) ] );
	title( 'State 2' );
	
	subplot( 2, 2, 3 );
	plot( x, dump.state3.S, x, dump.state3.Z, x, dump.state3.R );
	ylim( [ 0 dump.global.S( 1 ) ] );
	title( 'State 3' );
	
	subplot( 2, 2, 4 );
	plot( x, dump.global.S, x, dump.global.Z, x, dump.global.R );
	ylim( [ 0 dump.global.S( 1 ) ] );
	legend( 'Susceptible', 'Zombie', 'Removed' );
	title( 'World population' );


end

