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
   
    x = 0:( dump.step - 1 );
    
    minD = min( min( [ dump.dS ; dump.dZ ; dump.dR ] ) );
    maxD = max( max( [ dump.dS ; dump.dZ ; dump.dR ] ) );
    maxAmplitude = 1.2 * max( abs( minD ), maxD );
    
    % For each of the three states, plot the populations and
    % populations' variations.
    for i = 1:3
       
        subplot( 4, 2, 1 + ( i - 1 ) * 2 );
        plot( x, dump.S( i, 1:dump.step ), x, dump.Z( i, 1:dump.step ), x, dump.R( i, 1:dump.step ) );
        ylim( [ 0 1.2 * dump.S( 4 ) ] );
        xlim( [ 0 x( end ) ] );
        xlabel( 'Step', 'fontsize', 11 );
        ylabel( 'Population', 'fontsize', 11 );
        title( [ 'State ', int2str( i ) ], 'fontweight', 'b', 'fontsize', 12 );
       
        
        subplot( 4, 2, 2 + ( i - 1 ) * 2 );
        plot( x, dump.dS( i, 1:dump.step ), x, dump.dZ( i, 1:dump.step ), x, dump.dR( i, 1:dump.step ) );
        xlabel( 'Step', 'fontsize', 11 );
        ylabel( 'Population Variation', 'fontsize', 11 );
        title( [ 'State ', int2str( i ) ], 'fontweight', 'b', 'fontsize', 12 );
        xlim( [ 0 x( end ) ] );
        ylim( [ - maxAmplitude, maxAmplitude ] );
	
    end
	
    % Plot the total populations and total populations' variations.
	subplot( 4, 2, 7 );
	plot( x, dump.S( 4, 1:dump.step ), x, dump.Z( 4, 1:dump.step ), x, dump.R( 4, 1:dump.step ) );
	ylim( [ 0  1.2 * dump.S( 4 ) ] );
    xlabel( 'Step', 'fontsize', 11 );
    ylabel( 'Population', 'fontsize', 11 );
	title( 'World population', 'fontweight', 'b', 'fontsize', 12 );
    xlim( [ 0 x( end ) ] );
    
	subplot( 4, 2, 8 );
	plot( x, dump.dS( 4, 1:dump.step ), x, dump.dZ( 4, 1:dump.step ), x, dump.dR( 4, 1:dump.step ) );
    xlabel( 'Step', 'fontsize', 11 );
    ylabel( 'Population Variation', 'fontsize', 11 );
	title( 'World population', 'fontweight', 'b', 'fontsize', 12 );
    xlim( [ 0 x( end ) ] );
    
    ylim( [ - maxAmplitude, maxAmplitude ] );

end

