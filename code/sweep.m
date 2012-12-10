function params = sweep( params )

    cParams = struct( 'alpha', zeros( 3, 1 ), 'beta', zeros( 3, 1 ), 'gamma', zeros( 3, 1 ), 'eta', zeros( 3, 2 ), 'mu', zeros( 3, 2 ), 'nu', zeros( 3, 2 ) );
    output = struct( 'S', 0, 'Z', 0, 'R', 0, 'alpha', 0, 'beta', 0, 'gamma', 0, 'eta', 0, 'nu', 0, 'e', 0, 'step', 0 );
    
    switch class( params )
        
        case 'struct' 
            if length( params.alpha ) == 3

                params.alpha( 4 ) = params.alpha( 1 );
                params.beta( 4 ) = params.beta( 1 );
                params.gamma( 4 ) = params.gamma( 1 );
                params.eta( 4 ) = params.eta( 1 );
                params.nu( 4 ) = params.nu( 1 );
            
            else
                if ~isfield( params, 'step' ) 
                   
                    params.alpha( 4 ) = params.alpha( 1 );
                    params.beta( 4 ) = params.beta( 1 );
                    params.gamma( 4 ) = params.gamma( 1 );
                    params.eta( 4 ) = params.eta( 1 );
                    params.nu( 4 ) = params.nu( 1 );
                end
            end
            
            if ~isfield( params, 'step' )
                
                params.step = 1;
            end
            
            if isfield( params, 'id' )
               
                if exist( [ params.id '.restart' ], 'file' )
                    
                    params = load( [ id '.restart' ], '-mat' );
                end
            else
                
                params.id = num2hex( ceil( 1e20*rand ) );
                mkdir( [ '../results/' params.id ] );
            end
            
        case 'char'
            params = load( [ params '.restart' ], '-mat' );
    end
    
    disp( [ 'Id : ' params.id '.' ] );
    disp( 'Use the id as parameter to resume the sweep anytime.' );
    disp( '----------------------------------------------------------' );
    
    brutus = zeros( 9, 0 );

    for nu = params.nu( 1 ):params.nu( 2 ):params.nu( 3 )
        
        if params.nu( 4 ) > nu
        
            nu = params.nu( 4 );
        end
        
        for eta = params.eta( 1 ):params.eta( 2 ):params.eta( 3 )

            
            for gamma = params.gamma( 1 ):params.gamma( 2 ):params.gamma( 3 )
                
                if ~isfield( params, 'brutus' )
                

                    for beta = params.beta( 1 ):params.beta( 2 ):params.beta( 3 )

                        
                        
                        
                        disp( beta );
                        disp( params.beta( 4 ) );

                        for alpha = params.alpha( 1 ):params.alpha( 2 ):params.alpha( 3 )

                            
                            disp( [ 'Step ' int2str( params.step ) '. Alpha = ' num2str( alpha ) ', Beta = ' num2str( beta ) ',' ] );
                            disp( [ 'Gamma = ' num2str( gamma ) ', Eta = ' num2str( eta ) ', Nu = ' num2str( nu ) '.' ] );

                            cParams.alpha = alpha * ones( 3, 1 );
                            cParams.beta = beta * ones( 3, 1 );
                            cParams.gamma = gamma * ones( 3, 1 );
                            cParams.eta = eta * ones( 3, 2 );
                            cParams.nu = nu * ones( 3, 2 );

                            [ e, dump ] = outbreak( 'silent', 1, 'params', cParams, 'zombies', [ 1 0 0 ] );

                            output.S = dump.S;
                            output.R = dump.R;
                            output.Z = dump.Z;
                            output.step = dump.step;
                            output.alpha = alpha;
                            output.beta = beta;
                            output.gamma = gamma;
                            output.eta = eta;
                            output.nu = nu;
                            output.e = e;

                            params.alpha( 4 ) = alpha + params.alpha( 2 );

                            save( [ '../results/' params.id '/output.' int2str( params.step ) '.mat' ], '-struct', 'output' );

                            params.step = params.step + 1;
                            save( [ params.id '.restart' ], '-struct', 'params' );
                        end

                        params.alpha( 4 ) = params.alpha( 1 );

                        params.beta( 4 ) = beta + params.beta( 2 );
                    end

                    params.beta( 4 ) = params.beta( 1 );
 
                else
                    disp( [ 'Gamma = ' num2str( gamma ) ', Eta = ' num2str( eta ) ', Nu = ' num2str( nu ) '.' ] );
                    brutus( :, ( length( brutus( 1, : ) ) + 1 ) ) = [ nu eta gamma params.beta( 1:3 ) params.alpha( 1:3 ) ]';
                end
                
                params.gamma( 4 ) = gamma + params.gamma( 2 );
            end

            params.gamma( 4 ) = params.gamma( 1 );

            params.eta( 4 ) = eta + params.eta( 2 );
        end
                    
        params.eta( 4 ) = params.eta( 1 );
        
        params.nu( 4 ) = nu + params.nu( 2 );
    end
    
    if isfield( params, 'brutus' )
       
        disp( 'save' );
        
        save( 'brutus.mat', 'brutus' );
    end
end

