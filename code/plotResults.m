function plotResults( dump )
	
    % PLOTRESULTS plots the populations' evolution during the simulation. It
    %   plots the different populations (S, Z, R) for each state as well as
    %   the population variation. Furthermore the global populations and
    %   population variations are also displayed.
    %
    % PLOTRESULTS( DUMP )
    %   DUMP is the dumping structure as defined in the OUTBREAK function.
    %

	x = 0:( length( dump.S ) - 1 );

    % For each of the three states, plot the populations and
    % populations' variations.
    for i = 1:3
       
        subplot( 4, 4, ( i * 4 - 3 ):( i * 4 - 2 ) );
        plot( x, dump.S( i, : ), 'g', x, dump.Z( i, : ), 'r', x, dump.R( i, : ), 'k' );
        ylim( [ 0 dump.S( 4 ) ] );
        xlabel( 'Step' );
        ylabel( 'Population' );
        title( [ 'State ', int2str( i ) ], 'fontweight', 'b' );
        if i == 1
            
            legend( 'Susceptibles', 'Zombies', 'Removed' );
        end
        
        subplot( 4, 4, ( i * 4 - 1 ):( i * 4 ) );
        plot( x, dump.dS( i, : ), 'g', x, dump.dZ( i, : ), 'r', x, dump.dR( i, : ), 'k' );
        xlabel( 'Step' );
        ylabel( 'Population Variation' );
        title( [ 'State ', int2str( i ) ], 'fontweight', 'b' );
	
    end
	
    % Plot the total populations and total populations' variations.
	subplot( 4, 4, 13:14 );
	plot( x, dump.S( 4, : ), 'g', x, dump.Z( 4, : ), 'r', x, dump.R( 4, : ), 'k' );
	ylim( [ 0 dump.S( 4 ) ] );
    xlabel( 'Step' );
    ylabel( 'Population' );
	title( 'World population', 'fontweight', 'b' );
    
	subplot( 4, 4, 15:16 );
	plot( x, dump.dS( 4, : ), 'g', x, dump.dZ( 4, : ), 'r', x, dump.dR( 4, : ), 'k' );
    xlabel( 'Step' );
    ylabel( 'Population Variation' );
	title( 'World population', 'fontweight', 'b' );


end

