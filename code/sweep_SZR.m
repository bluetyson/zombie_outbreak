function results = sweep_SZR( varargin )

    % Sweeping parameters must composed of one property for each parameter
    % define as a vector containing the lowest value, the step and the
    % highest value. 
    % It also contains the name of the restart file.

    results = struct( 'alpha', 0, 'beta', 0, 'gamma', 0, 'eta', 0, 'mu', 0, 'nu', 0, 'steps', 0, 'survival', 0, 'humans', 0, 'zombies', 0 );
    
    narginchk( 1, 1 );
    switch class( varargin{ 1 } )
        
        case 'char'
            sweepingParameters = load( varargin{ 1 } );
            results = load( '.results.tmp.mat' );
            
        case 'struct'
            sweepingParameters = varargin{ 1 };
            sweepingParameters.index = 1;
            sweepingParameters.alpha( 4 ) = sweepingParameters.alpha( 1 );
            sweepingParameters.beta( 4 ) = sweepingParameters.beta( 1 );
            sweepingParameters.gamma( 4 ) = sweepingParameters.gamma( 1 );
            sweepingParameters.eta( 4 ) = sweepingParameters.eta( 1 );
            sweepingParameters.mu( 4 ) = sweepingParameters.mu( 1 );
            sweepingParameters.nu( 4 ) = sweepingParameters.nu( 1 );
    end
    
    disp( sweepingParameters );
    
    b = length( results.alpha );
    reverseStr = '';
    
    for alpha = sweepingParameters.alpha( 1 ):sweepingParameters.alpha( 2 ):sweepingParameters.alpha( 3 )
       
        if alpha < sweepingParameters.alpha( 4 )
            
            continue;
        end
        
        sweepingParameters.alpha( 4 ) = alpha;
        
        for beta = sweepingParameters.beta( 1 ):sweepingParameters.beta( 2 ):sweepingParameters.beta( 3 )
            
            if beta < sweepingParameters.beta( 4 )

                continue;
            end
            
            sweepingParameters.beta( 4 ) = beta;
                        
            for gamma = sweepingParameters.gamma( 1 ):sweepingParameters.gamma( 2 ):sweepingParameters.gamma( 3 )
                
                if gamma < sweepingParameters.gamma( 4 )

                    continue;
                end
                
                sweepingParameters.gamma( 4 ) = gamma;
               
                for eta = sweepingParameters.eta( 1 ):sweepingParameters.eta( 2 ):sweepingParameters.eta( 3 )
                    
                    if eta < sweepingParameters.eta( 4 )

                        continue;
                    end
                    
                    sweepingParameters.eta( 4 ) = eta;
                    
                    for mu = sweepingParameters.mu( 1 ):sweepingParameters.mu( 2 ):sweepingParameters.mu( 3 )
                        
                        if mu < sweepingParameters.mu( 4 )

                            continue;
                        end
                        
                        sweepingParameters.mu( 4 ) = mu;
                                                
                        for nu = sweepingParameters.nu( 1 ):sweepingParameters.nu( 2 ):sweepingParameters.nu( 3 )
                                                        
                            if nu < sweepingParameters.nu( 4 )
                                
                                continue;
                            end
                            
                            sweepingParameters.nu( 4 ) = nu;
                            
                            params.alpha = alpha * ones( 3, 1 );
                            params.beta = beta * ones( 3, 1 );
                            params.gamma = gamma * ones( 3, 1 );
                            params.eta = eta * ones( 3, 2 );
                            params.mu = mu * ones( 3, 2 );
                            params.nu = nu * ones( 3, 2 );
                            
                            msg = sprintf('Processing %d.\n', b );
                            fprintf([reverseStr, msg]);  
                            %reverseStr = repmat(sprintf('\b'), 1, length(msg));
                            disp( [ 'alpha : ' num2str( alpha ) ' ; beta : ' num2str( beta ) ' ; gamma : ' num2str( gamma ) ' ; eta : ' num2str( eta ) ' ; nu : ' num2str( nu ) ] );
                            b = b + 1;
                            
                            [ a, out ] = outbreak( 'populations', [ 1000 1000 1000 ], 'zombies', [ 1 0 0 ], 'silent', 0, 'params', params );
                            
                            index = sweepingParameters.index;
                            results.alpha( 1, index ) = alpha;
                            results.beta( 1, index ) = beta;
                            results.gamma( 1, index ) = gamma;
                            results.eta( 1, index ) = eta;
                            results.mu( 1, index ) = mu;
                            results.nu( 1, index ) = nu;
                            results.steps( 1, index ) = out.step;
                            results.humans( 1, index ) = out.S( 4, out.step );
                            results.humans( 1, index ) = out.Z( 4, out.step );
                                                        
                            if out.S( 4, out.step ) > 1e-4
                               
                                results.survival( 1, index ) = 1;
                            else
                                
                                results.survival( 1, index ) = 0;
                            end
                            
                            sweepingParameters.index = sweepingParameters.index + 1;
                            
                            save( '.results.tmp.mat', '-struct', 'results' );                            
                            save( sweepingParameters.restart, '-struct', 'sweepingParameters' );
                        end
                        
                        sweepingParameters.nu( 4 ) = sweepingParameters.nu( 1 );
                    end
                    
                    sweepingParameters.mu( 4 ) = sweepingParameters.mu( 1 );
                end
                
                sweepingParameters.eta( 4 ) = sweepingParameters.eta( 1 );
            end
            
            sweepingParameters.gamma( 4 ) = sweepingParameters.gamma( 1 );
        end
        
        sweepingParameters.beta( 4 ) = sweepingParameters.beta( 1 );
    end
end

