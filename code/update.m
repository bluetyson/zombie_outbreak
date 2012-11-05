function out = update( ~ )

    global states;
    global rates;
    global dump;
    
    state1 = states( 1, : );
	state2 = states( 2, : );
	state3 = states( 3, : );
	stateG = states( 4, : );
	
	% microstate SZR :
	
	dS = [ - rates( 1 ) * state1( 2 ) * state1( 3 ) - rates( 2 ) * state1( 2 ) * state1( 3 ) ; - rates( 1 ) * state2( 2 ) * state2( 3 ) - rates( 2 ) * state2( 2 ) * state2( 3 ) ; - rates( 1 ) * state3( 2 ) * state3( 3 ) - rates( 2 ) * state3( 2 ) * state3( 3 ) ];
	dZ = [ rates( 1 ) * state1( 2 ) * state1( 3 ) - rates( 3 ) * state1( 2 ) * state1( 3 ); rates( 1 ) * state2( 2 ) * state2( 3 ) - rates( 3 ) * state2( 2 ) * state2( 3 ); rates( 1 ) * state3( 2 ) * state3( 3 ) - rates( 3 ) * state3( 2 ) * state3( 3 ) ];
	dR = [ rates( 2 ) * state1( 2 ) * state1( 3 ) + rates( 3 ) * state1( 2 ) * state1( 3 ); rates( 2 ) * state2( 2 ) * state2( 3 ) + rates( 3 ) * state2( 2 ) * state2( 3 ); rates( 2 ) * state3( 2 ) * state3( 3 ) + rates( 3 ) * state3( 2 ) * state3( 3 ) ];
	
	dPop = [ dS dZ dR ];
	
	if( dPop < - states( 1:3, 2:3 )  )
	
	% macrostate SZR :
	
	dZ = rates( 4 ) * [ - state1( 3 ) + .5 * state2( 3 ) + .5 * state3( 3 ) ; .5 * state1( 3 ) - state2( 3 ) + .5 * state3( 3 ) ; .5 * state1( 3 ) + .5 * state2( 3 ) - state3( 3 ) ];
	
	dPop( :, 2 ) = dPop( :, 2 ) + dZ;
	
	% update

	states( 1:3, 2:4 ) = states( 1:3, 2:4 ) + dPop;

	%states( 1:3, 2:4 ) = states( 1:3, 2:4 ) .* ( states( 1:3, 2:4 ) > 0 );
	
	states( 4, 2 ) = sum( states( 1:3, 2 ) );
	states( 4, 3 ) = sum( states( 1:3, 3 ) );
	states( 4, 4 ) = sum( states( 1:3, 4 ) );
	
	dumpState;
	
	out = 0;
end

