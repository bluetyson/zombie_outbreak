function params = sweep( params )

    %
    % SWEEP allows to run multiple simulation sequentially varying the
    %   parameters in a defined range with defined steps.
    %
    %   PARAMS = SWEEP( PARAMS )
    %       PARAMS is a structure storing for each parameter alpha, beta,
    %           gamma, eta and nu a 1x3 matrix with the minimal value, the
    %           step and the maximal value for the parameter.
    %           The return value also contains the ID of the sweep as well
    %           as the number of simulations done.
    %
    %   PARAMS = SWEEP( ID )
    %       ID is the ID string of a previous sweep. The sweep will start
    %           over where the sweep stopped the last time.
    %   

    
    %% Parsing of the argument
    switch class( params )
        
        case 'struct' 
            % If the parameter set has never been employed, the restart
            % fields are created.
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
            
            % Initialization of the number of simulation ran
            if ~isfield( params, 'step' )
                
                params.step = 1;
            end
            
            % If an ID is assigned, the restart file is loaded, otherwise,
            % an ID is created as well as a folder for the simulation
            % results.
            if isfield( params, 'id' )
               
                if exist( [ params.id '.restart' ], 'file' )
                    
                    params = load( [ id '.restart' ], '-mat' );
                end
            else
                
                params.id = num2hex( ceil( 1e20*rand ) );
                mkdir( [ '../results/' params.id ] );
            end
            
        case 'char'
            % If an ID is provided, the restart file is loaded.
            params = load( [ params '.restart' ], '-mat' );
    end
    
    %% Display of the simulation details
    disp( [ 'Id : ' params.id '.' ] );
    disp( 'Use the id as parameter to resume the sweep anytime.' );
    disp( '----------------------------------------------------------' );
    disp( params );
    disp( '----------------------------------------------------------' );
    
    %% Variables initialization
    cParams = struct( 'alpha', zeros( 3, 1 ), 'beta', zeros( 3, 1 ), 'gamma', zeros( 3, 1 ), 'eta', zeros( 3, 2 ), 'nu', zeros( 3, 2 ) );
    output = struct( 'S', 0, 'Z', 0, 'R', 0, 'alpha', 0, 'beta', 0, 'gamma', 0, 'eta', 0, 'nu', 0, 'e', 0, 'step', 0 );
    reverseStr = '';
    step = 1;
    
    %% Parameter sweeping
    for nu = params.nu( 1 ):params.nu( 2 ):params.nu( 3 )

        for eta = params.eta( 1 ):params.eta( 2 ):params.eta( 3 )
    
            for gamma = params.gamma( 1 ):params.gamma( 2 ):params.gamma( 3 )

                
                for beta = params.beta( 1 ):params.beta( 2 ):params.beta( 3 )

                    for alpha = params.alpha( 1 ):params.alpha( 2 ):params.alpha( 3 )

                        % If the current step number is larger than the
                        % step number in the parameter file, the simulation
                        % has already be done and can be skipped.
                        if step > params.step

                            % Update of the current process status.
                            msg = sprintf('Step %d.\nAlpha = %f, Beta = %f,\nGamma = %f, Eta = %f, Nu = %f.', step, alpha, beta, gamma, eta, nu );
                            fprintf([ reverseStr, msg]);
                            reverseStr = repmat(sprintf('\b'), 1, length(msg));

                            % Preparation of the simulation parameters
                            cParams.alpha = alpha * ones( 3, 1 );
                            cParams.beta = beta * ones( 3, 1 );
                            cParams.gamma = gamma * ones( 3, 1 );
                            cParams.eta = eta * ones( 3, 2 );
                            cParams.nu = nu * ones( 3, 2 );

                            % Simulation
                            dump = outbreak( 'silent', 2, 'params', cParams, 'zombies', [ 1 0 0 ] );

                            % Preparation of the output structure
                            output.S = dump.S;
                            output.R = dump.R;
                            output.Z = dump.Z;
                            output.step = dump.step;
                            output.alpha = alpha;
                            output.beta = beta;
                            output.gamma = gamma;
                            output.eta = eta;
                            output.nu = nu;

                            % Saving of the results of the simulation
                            save( [ '../results/' params.id '/output.' int2str( params.step ) '.mat' ], '-struct', 'output' );

                            % Update of the parameter structure and saving
                            % of the restart file.
                            params.step = params.step + 1;
                            params.alpha( 4 ) = alpha + params.alpha( 2 );
                            save( [ params.id '.restart' ], '-struct', 'params' );
                        end

                        % Update of the current step.
                        step = step + 1;
                    end

                    % Parameters update
                    params.alpha( 4 ) = params.alpha( 1 );

                    params.beta( 4 ) = beta + params.beta( 2 );
                end

                params.beta( 4 ) = params.beta( 1 );

                params.gamma( 4 ) = gamma + params.gamma( 2 );
            end
            
            params.gamma( 4 ) = params.gamma( 1 );

            params.eta( 4 ) = eta + params.eta( 2 );
        end
        
        params.eta( 4 ) = params.eta( 1 );

        params.nu( 4 ) = nu + params.nu( 2 );
    end    
end

