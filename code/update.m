function out = update( ~ )

    %% Setting of parameters : 

    global states;
    global rates;
    global dump;
	
	s = states.pop( 1:3, 2 );
	z = states.pop( 1:3, 3 );
	r = states.pop( 1:3, 4 );
    
	ds = states.dpop( 1:3, 1 );
	dz = states.dpop( 1:3, 2 );
	dr = states.dpop( 1:3, 3 );
    
	
    alpha = rates.alpha;
    beta = rates.beta;
    gamma = rates.gamma;
    mu = rates.mu;
    nu = rates.nu;
    eta = rates.eta;
    
    permutation = [ 0 0 1 ; 1 0 0 ; 0 1 0 ];
    iFluxCoor = [ 2 2 3 1 ; 3 2 1 1 ; 1 2 2 1 ];
    
    %% Update of the susceptible population. 
    
    % Depletion of the susceptible population goes according to :
    %
    %   S  -> Z  = - alpha * s * z
    %   S  -> R  = - gamma * s * z
    %   S1 -> S2 = - mu12 * s * z + nu12 * dS
    %   S1 -> S3 = - mu13 * s * z + nu13 * dS
    %
    % Immigration is the only source of population.
    %
    % dS is a 3x6 matrix containing for each state :
    %
    %   Row 1 : n( S  -> Z  )
    %   Row 2 : n( S  -> R  )
    %   Row 3 : n( S1 -> S2 ) | n( S2 -> S3 ) | n( S3 -> S1 )
    %   Row 4 : n( S1 -> S3 ) | n( S2 -> S1 ) | n( S3 -> S2 )
    %   Row 5 : n( S2 -> S1 ) | n( S3 -> S2 ) | n( S1 -> S3 )
    %   Row 6 : n( S3 -> S1 ) | n( S1 -> S2 ) | n( S2 -> S3 )
    %
    % The sum of each line gives the population variation for the state.
    
    dS = zeros( 3, 6 );
    dS( :, 1 ) = - alpha .* s .* z;
    dS( :, 2 ) = - gamma .* s .* z;
    dS( :, 3 ) = - mu( :, 1 ) .* s .* z + nu( :, 1 ) .* ds;
    dS( :, 4 ) = - mu( :, 2 ) .* s .* z + nu( :, 2 ) .* ds;
    dS( :, 5 ) = - permutation * permutation * dS( :, 4 );
    dS( :, 6 ) = - permutation * dS( :, 3 );
    
    % The possibility that any of the individual |dS| is larger than the
    % actual population is possible we habe to make sure it doesn't happen.
    
    a = 0;
    
    while sum( sum( dS( :, 1:4 ), 2 ) < - ( s + sum( dS( :, 5:6 ), 2 ) ) )

        
        % If it does happen, we do individual check on each state.
        for i = 1:3
           
            if( sum( dS( i, 1:4 ), 2 ) < - ( s( i ) + sum( dS( i, 5:6 ), 2 ) ) )
               
                % We correct the differential for the state with the flaw.
                % Each exiting flow is reduced proportionnally so that the sum is
                % equal to the total population.
                
                dS( i, 1:4 ) = dS( i, 1:4 ) / abs( sum( dS( i, 1:4 ) ) ) * ( sum( dS( i, 5:6 ) ) + s( i ) );
                
                % We then correct the input flux for the two other states.
                
                dS( iFluxCoor( i, 1 ), 4 + iFluxCoor( i, 2 ) ) = - dS( i, 3 );
                dS( iFluxCoor( i, 3 ), 4 + iFluxCoor( i, 4 ) ) = - dS( i, 4 );
            end
        end
        % Note that the input flux can only be lower than the original flux. 
        % Therefore, the sum of the input flux and population of the two 
        % other states decrease. Therefore the process has to be repeated
        % until all states have a population differential equal or bigger
        % than minus the population.
    end
    
    %% Update of the zombie population.
    
    % Depletion of the zombie populations goes according to :
    %
    %   S  -> Z  = alpha * s * z
    %   Z  -> R  = - beta * s * z
    %   Z1 -> Z2 = - eta * tanh( z / s )
    %   Z1 -> Z3 = - eta * tanh( z / s )
    %
    % Conversion from susceptible and "immigration" are the two sources of
    % zombies.
    %
    % dZ is a 3x6 matrix containing for each states :
    %
    %   Row 1 : n( S  -> Z  )
    %   Row 2 : n( Z  -> R  )
    %   Row 3 : n( Z1 -> Z2 ) | n( Z2 -> Z3 ) | n( Z3 -> Z1 )
    %   Row 4 : n( Z1 -> Z3 ) | n( Z2 -> Z1 ) | n( Z3 -> Z2 )
    %   Row 5 : n( Z2 -> Z1 ) | n( Z3 -> Z2 ) | n( Z1 -> Z3 )
    %   Row 6 : n( Z3 -> Z1 ) | n( Z1 -> Z2 ) | n( Z2 -> Z3 )
    %   
    
    dZ = zeros( 3, 6 );
    dZ( :, 1 ) = - dS( :, 1 );
    dZ( :, 2 ) = - beta .* s .* z;
    dZ( :, 3 ) = - eta( :, 1 ) .* tanh( z ./ s );
    dZ( :, 4 ) = - eta( :, 2 ) .* tanh( z ./ s );
    dZ( :, 5 ) = - permutation * permutation * dZ( :, 4 );
    dZ( :, 6 ) = - permutation * dZ( :, 3 );
    
    % We then use the same procedure on the negative variation of Z to
    % ensure that the population will not go negative.
    while sum( ( dZ( :, 1 ) + sum( dZ( :, 5:6 ), 2 ) + z ) + sum( dZ( :, 2:4 ), 2 ) < - 1e-10 )
        
        for i = 1:3
           
            if( - ( dZ( i, 1 ) + sum( dZ( i, 5:6 ), 2 ) + z( i ) ) > sum( dZ( i, 2:4 ) ) )
                
                dZ( i, 2:4 ) = dZ( i, 2:4 ) * ( sum( dZ( i, 5:6 ) ) + dZ( i, 1 ) + z( i ) ) / abs( sum( dZ( i, 2:4 ) ) );
                
                dZ( iFluxCoor( i, 1 ), 4 + iFluxCoor( i, 2 ) ) = - dZ( i, 3 );
                dZ( iFluxCoor( i, 3 ), 4 + iFluxCoor( i, 4 ) ) = - dZ( i, 4 );
            end
        end
    end
    
    %% Update of the removed population
    
    % Variation in the removed population is strictly positive and comes
    % from both the susceptible and zombie population :
    %
    %   S  -> R  = alpha * s * z
    %   Z  -> R  = beta * s * z
    %
    % We can use the value obtained for dS and dZ :
    
    dR = - [ dS( :, 2 ), dZ( :, 2 ) ];
    
    %% Update and save data
    
    states.dpop( 1:3, : ) = [ sum( dS, 2 ), sum( dZ, 2 ), sum( dR, 2 ) ];
    
    states.dpop( 4, : ) = sum( states.dpop( 1:3, : ) );
    
    states.pop( 1:3, 2:4 ) = states.pop( 1:3, 2:4 ) + states.dpop( 1:3, : );
    
    if( states.pop( 1:3, 3 ) < ones( 3, 1 ) )
       
        for i = 1:3 
           
            if( states.pop( i, 3 ) < 1 )
               
                states.pop( i, 4 ) = states.pop( i, 4 ) + states.pop( i, 3 );
                states.pop( i, 3 ) = 0;
            end
        end
    end
    
    states.pop( 4, 2:4 ) = sum( states.pop( 1:3, 2:4 ) );
    
    
    dumpState;
    	
	out = 0;
end

