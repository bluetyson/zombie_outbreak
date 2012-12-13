function plotResults( dump )
	
    % PLOTRESULTS plots the populations' evolution during the simulation. It
    %   plots the different populations (S, Z, R) for each state as well as
    %   the population variation. Furthermore the global populations and
    %   population variations are also displayed.
    %
    % PLOTRESULTS( DUMP )
    %   DUMP is the dumping structure as defined in the OUTBREAK function.
    %

    
    set(0, 'DefaultAxesColorOrder', [ 0, 0, 1 ; 1, 0, 0 ; 0, 0, 0 ], 'DefaultLineLineWidth', 1.45 );
   
    x = 0:( length( dump.S ) - 1 );
    
    minD = min( min( [ dump.dS ; dump.dZ ; dump.dR ] ) );
    maxD = max( max( [ dump.dS ; dump.dZ ; dump.dR ] ) );
    maxAmplitude = 1.2 * max( abs( minD ), maxD );
    
    % For each of the three states, plot the populations and
    % populations' variations.
    for i = 1:3
       
        subplot( 4, 2, 1 + ( i - 1 ) * 2 );
        plot( x, dump.S( i, : ), x, dump.Z( i, : ), x, dump.R( i, : ) );
        ylim( [ 0 1.2 * dump.S( 4 ) ] );
        xlim( [ 0 length( dump.S ) - 1 ] );
        xlabel( 'Step', 'fontsize', 11 );
        ylabel( 'Population', 'fontsize', 11 );
        title( [ 'State ', int2str( i ) ], 'fontweight', 'b', 'fontsize', 12 );
       
        
        subplot( 4, 2, 2 + ( i - 1 ) * 2 );
        plot( x, dump.dS( i, : ), x, dump.dZ( i, : ), x, dump.dR( i, : ) );
        xlabel( 'Step', 'fontsize', 11 );
        ylabel( 'Population Variation', 'fontsize', 11 );
        title( [ 'State ', int2str( i ) ], 'fontweight', 'b', 'fontsize', 12 );
        xlim( [ 0 length( dump.S ) - 1 ] );
        ylim( [ - maxAmplitude, maxAmplitude ] );
	
    end
	
    % Plot the total populations and total populations' variations.
	subplot( 4, 2, 7 );
	plot( x, dump.S( 4, : ), x, dump.Z( 4, : ), x, dump.R( 4, : ) );
	ylim( [ 0  1.2 * dump.S( 4 ) ] );
    xlabel( 'Step', 'fontsize', 11 );
    ylabel( 'Population', 'fontsize', 11 );
	title( 'World population', 'fontweight', 'b', 'fontsize', 12 );
    xlim( [ 0 length( dump.S ) - 1 ] );
    
	subplot( 4, 2, 8 );
	plot( x, dump.dS( 4, : ), x, dump.dZ( 4, : ), x, dump.dR( 4, : ) );
    xlabel( 'Step', 'fontsize', 11 );
    ylabel( 'Population Variation', 'fontsize', 11 );
	title( 'World population', 'fontweight', 'b', 'fontsize', 12 );
    xlim( [ 0 length( dump.S ) - 1 ] );
    
    ylim( [ - maxAmplitude, maxAmplitude ] );

end

