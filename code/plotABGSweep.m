function plotABGSweep( ~ )

    results = struct();
    results.run1 = load( 'output_1.mat' );
    results.run2 = load( 'output_2.mat' );
    results.run3 = load( 'output_3.mat' );
    results.run4 = load( 'output_4.mat' );

    cutoff = [ 1 800 1600 2400 ];
    
    for i = 1:4
        
        s = results.( [ 'run' int2str( i ) ] ).S;
        
        for j = 1:4
            
            indexS = find( s > cutoff( j ) );
            
            [ X, Y, Z ] = ind2sub( size( s ), indexS );
            
            alpha = results.( [ 'run' int2str( i ) ] ).alpha( 1, 1, 1 ) + ( X - 1 ) * ( results.( [ 'run' int2str( i ) ] ).alpha( 2, 1, 1 ) - results.( [ 'run' int2str( i ) ] ).alpha( 1, 1, 1 ) );
            beta = results.( [ 'run' int2str( i ) ] ).beta( 1, 1, 1 ) + ( Y - 1 ) * ( results.( [ 'run' int2str( i ) ] ).beta( 1, 2, 1 ) - results.( [ 'run' int2str( i ) ] ).beta( 1, 1, 1 ) );
            gamma = results.( [ 'run' int2str( i ) ] ).gamma( 1, 1, 1 ) + ( Z - 1 ) * ( results.( [ 'run' int2str( i ) ] ).gamma( 1, 1, 2 ) - results.( [ 'run' int2str( i ) ] ).gamma( 1, 1, 1 ) );
            values = zeros( size( indexS, 1 ), 1 );
            
            for k = 1:size( indexS, 1 )
               
                values( k ) = s( X( k ), Y( k ), Z( k ) );
            end
            
            subplot( 4, 4, i + ( j - 1 ) * 4 );
            
            scatter3( alpha, beta, gamma, 7.5, values, 'filled' );
            
            title( [ 'Eta = ' num2str( results.( [ 'run' int2str( i ) ] ).eta ) ', Nu = ' num2str( results.( [ 'run' int2str( i ) ] ).nu ) ', Cutoff = ' int2str( cutoff( j ) ) ], 'fontweight', 'b' );
            
            axis( [ 0 1e-2 0 1e-2 0 1e-2 ] );
            
            xlabel('alpha');
            ylabel('beta');
            zlabel('gamma');
        end
    end

end

