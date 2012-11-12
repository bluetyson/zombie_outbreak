function out = update( ~ )

    global states;
    global rates;
    global dump;
	
	s = states( 1:3, 2 );
	z = states( 1:3, 3 );
	r = states( 1:3, 4 );
	
	% microstate SZR :
	
	% Definition of standard variation of the three population
	
	% dS = - ( alpha + gamma ) * S * Z 
	% with the constraint that dS > -S to keep a positive or null S population.
	dS = max( - ( rates( 1 ) + rates( 2 ) ) * s .* z, - s );
	
	% dS = ( alpha - beta ) * S * Z 
	% with the constraint that dZ > -Z to keep a positive or null Z population.
	dZ = max( ( rates( 1 ) - rates( 3 ) ) * s .* z, - z );
	
	% dR = ( beta + gamma ) * S * R
	dR = ( rates( 2 ) + rates( 3 ) ) * s .* z;

	% The model allows the increase of Zombie and Removed to be bigger than the decrease of Susceptible. The following test
	% control that the overall population in the macrostate is conserved, and correct the flow for each microstate otherwise.
	if( sum( abs( dS + dR + dZ ) ) > 1e-7 )
	
		for i = 1:3
		
			if( abs( dS( i ) + dR( i ) + dZ( i ) ) > 1e-7 )
			
				% In the case where the total population is not conserved for a microstate, we assume that the transfer from the susceptible population to the zombie and removed population 
				% is proportional to the respective transfer rate constants. Solving the system :
				%
				%		dR + dZ = - dS
				%		- gamma dZ + alpha dR = 0
				%
				% Gives the transfer from the S population to the Z and R population respecting the limited S population. We then add the transfer from Z to R.
				
				sol = rref( [ 1, 1, - dS( i ) ; - rates( 2 ), rates( 1 ), 0 ] );
				
				dZ( i ) = sol( 1, 3 ) - rates( 3 ) * s( i ) * z( i );
				dR( i ) = sol( 2, 3 ) + rates( 3 ) * s( i ) * z( i );
			end
			
			% ! Test again and if not corrected, flow is caused by zombie population variation ! %
		end
		
	end;
	
	dPop = [ dS dZ dR ];
	
	
	% macrostate SZR :
	
	% Random walker :
	% The number of zombie exiting one state is defined by the product eta * Z ; we consider the flows to the two neighbours to be equals.
	% The exiting flow for the microstate i is therefore - eta * Zi and the entering flow is Sum( 0.5 * eta * Zi~=i ).
	dZ = rates( 4 ) * [ -1, 0.5, 0.5 ; 0.5, -1, 0.5 ; 0.5, 0.5, -1 ] * z; 
	
	% Flesh-craving
	dZ = rates( 4 ) * ( z .* ( [ 0, -1, -1 ; -1, 0, -1 ; -1, -1, 0 ] * s ) + s .* ( [ 0, 1, 1 ; 1, 0, 1 ; 1, 1, 0 ] * z ) );
	
	
	
	
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

