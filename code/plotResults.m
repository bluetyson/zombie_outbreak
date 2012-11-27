function plotResults( dump )
	
	x = 0:( length( dump.S ) - 1 );
		
    for i = 1:3
       
        subplot( 4, 4, ( i * 4 - 3 ):( i * 4 - 2 ) );
        plot( x, dump.S( i, : ), x, dump.Z( i, : ), x, dump.R( i, : ) );
        ylim( [ 0 dump.S( 4 ) ] );
        xlabel( 'Time' );
        ylabel( 'Population' );
        title( [ 'State ', int2str( i ) ] );
    
        subplot( 4, 4, ( i * 4 - 1 ):( i * 4 ) );
        plot( x, dump.dS( i, : ), x, dump.dZ( i, : ), x, dump.dR( i, : ) );
        xlabel( 'Time' );
        ylabel( 'Population Variation' );
        title( [ 'State ', int2str( i ) ] );
	
    end
	
	subplot( 4, 4, 13:14 );
	plot( x, dump.S( 4, : ), x, dump.Z( 4, : ), x, dump.R( 4, : ) );
	ylim( [ 0 dump.S( 4 ) ] );
    xlabel( 'Time' );
    ylabel( 'Population' );
	legend( 'Susceptible', 'Zombie', 'Removed' );
	title( 'World population' );
    
	subplot( 4, 4, 15:16 );
	plot( x, dump.dS( 4, : ), x, dump.dZ( 4, : ), x, dump.dR( 4, : ) );
    xlabel( 'Time' );
    ylabel( 'Population Variation' );
	title( 'State 1' );


end

