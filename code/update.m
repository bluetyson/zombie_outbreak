    function [ states, rates, dshistory ] = update( states, rates, dshistory )

    %
    % UPDATE compute the population evolution for one step of the
    %   epidemiological model.
    %
    % [ STATES, RATES, DSHISTORY, DUMP ] = UPDATE( STATES, RATES, DSHISTORY, DUMP )
    %       STATES is the structure storing the populations and population
    %           variations as defined in the OUTBREAK function.
    %       RATES is the structure containing the epidemiological transfer 
    %           rates as defined in the OUTBREAK function.
    %       DSHISTORY is the array containing the sliding window for
    %           inter-state susceptible transfer.
    %
    
    %% Initialization of parameters : 
	
	s = states.pop( 1:3, 1 );
	z = states.pop( 1:3, 2 );    
	
    alpha = rates.alpha;
    beta = rates.beta;
    gamma = rates.gamma;
    nu = rates.nu;
    eta = rates.eta;
    
    % Permutation matrix used to set the input inter-state flux from the
    % inter-state output flux to avoid redundant calculations. See flux
    % update.
    permutation = [ 0 0 1 ; 1 0 0 ; 0 1 0 ];
    
    % Matrix containing the coordinates of the input inter-state flux from
    % each state (line) to the other two (block of two colons). See flux
    % correction.
    iFluxCoor = [ 2 2 3 1 ; 3 2 1 1 ; 1 2 2 1 ];
    
    %% Update of the susceptible population. 
    
    % Depletion of the susceptible population goes according to :
    %
    %   S  -> Z  = - alpha * s * z
    %   S  -> R  = - gamma * s * z
    %   S1 -> S2 = nu * dSmean
    %   S1 -> S3 = nu * dSmean
    %
    % Immigration is the only source of susceptible population.
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
    
    % Mean variation of the susceptible in the sliding window.
    dsmean = mean( dshistory, 2 );
    
    dS = zeros( 3, 6 );
    dS( :, 1 ) = - alpha .* s .* z;
    dS( :, 2 ) = - gamma .* s .* z;
    dS( :, 3 ) = min( nu( :, 1 ) .* dsmean, 0 );
    dS( :, 4 ) = min( nu( :, 2 ) .* dsmean, 0 );
    dS( :, 5 ) = - permutation * permutation * dS( :, 4 );
    dS( :, 6 ) = - permutation * dS( :, 3 );
    
    % There is the possibility that any of the |-dSi| is larger than the
    % actual population in the state (negative population fluctuation larger
    % than the actual population). If so, a correction is applied to
    % avoid negative population.
    % As long as any state falls into this category: 
    while sum( sum( dS( :, 1:4 ), 2 ) + s + sum( dS( :, 5:6 ), 2 ) < -1e-4 )

        for i = 1:3
           
            % Correct the state that falls into this category:
            if( sum( dS( i, 1:4 ), 2 ) + ( s( i ) + sum( dS( i, 5:6 ), 2 ) ) < -1e-4 )
               
                % Population is considered equal to the sum of previous
                % population and the inter-state input transfer. The
                % negative contributions to the dS are reduced so that it
                % equals this population.
                dS( i, 1:4 ) = dS( i, 1:4 ) / abs( sum( dS( i, 1:4 ) ) ) * ( sum( dS( i, 5:6 ) ) + s( i ) );
                
                % The effect of the correction on the output flux is
                % applied to the other state input flux.
                dS( iFluxCoor( i, 1 ), 4 + iFluxCoor( i, 2 ) ) = - dS( i, 3 );
                dS( iFluxCoor( i, 3 ), 4 + iFluxCoor( i, 4 ) ) = - dS( i, 4 );
            end
        end
        % Note that the output flux can only be lower than the original flux. 
        % Therefore, the input flux for the two other states can only 
        % be smaller than before the correction. Accordingly, the
        % process has to be repeated until all states have a population
        % differential such that it doesn't lead to a negative population.
    end
    
    %% Update of the zombie population.
    
    % Depletion of the zombie populations goes according to :
    %
    %   S  -> Z  = alpha * s * z
    %   Z  -> R  = - beta * s * z
    %   Z1 -> Z2 = - eta * z * tanh( z / s )
    %   Z1 -> Z3 = - eta * z * tanh( z / s )
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
    dZ( :, 3 ) = - eta( :, 1 ) .* z .* tanh( z ./ s );
    dZ( :, 4 ) = - eta( :, 2 ) .* z .* tanh( z ./ s );
    dZ( :, 5 ) = - permutation * permutation * dZ( :, 4 );
    dZ( :, 6 ) = - permutation * dZ( :, 3 );
    
    % The same control procedure as for the susceptible population is
    % applied to avoid negative population of zombies. See susceptible 
    % correction for details on the procedure.
    while sum( ( dZ( :, 1 ) + sum( dZ( :, 5:6 ), 2 ) + z ) + sum( dZ( :, 2:4 ), 2 ) < - 1e-4 )
        
        for i = 1:3
           
            if( ( dZ( i, 1 ) + sum( dZ( i, 5:6 ), 2 ) + z( i ) ) + sum( dZ( i, 2:4 ) ) < - 1e-4 )
                
                dZ( i, 2:4 ) = dZ( i, 2:4 ) * ( sum( dZ( i, 5:6 ) ) + dZ( i, 1 ) + z( i ) ) / abs( sum( dZ( i, 2:4 ) ) );
                
                dZ( iFluxCoor( i, 1 ), 4 + iFluxCoor( i, 2 ) ) = - dZ( i, 3 );
                dZ( iFluxCoor( i, 3 ), 4 + iFluxCoor( i, 4 ) ) = - dZ( i, 4 );
            end
        end
    end
    
    %% Update of the removed population
    
    % Variation in the removed population is strictly positive and comes
    % from both the susceptible and zombie population:
    %
    %   S  -> R  = alpha * s * z
    %   Z  -> R  = beta * s * z
    %
    % The value obtained for dS and dZ are used:
    
    dR = - [ dS( :, 2 ), dZ( :, 2 ) ];
    
    %% Update each population
    
    % Compilation of the populations variations
    states.dpop( 1:3, : ) = [ sum( dS, 2 ), sum( dZ, 2 ), sum( dR, 2 ) ];
    
    % Update of the sliding window matrix for the susceptible.
    [ ~, dsSize ] = size( dshistory );
    dshistory( :, 2:dsSize ) = dshistory( :, 1:( dsSize - 1 ) );
    dshistory( :, 1 ) = states.dpop( 1:3, 1 );
    
    % Update of the current populations
    states.pop( 1:3, : ) = states.pop( 1:3, : ) + states.dpop( 1:3, : );
   
    % Update of the total populations
    states.pop( 4, : ) = sum( states.pop( 1:3, : ) );
    states.dpop( 4, : ) = sum( states.dpop( 1:3, : ) );
end

