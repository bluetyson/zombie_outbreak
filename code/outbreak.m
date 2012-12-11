function dump = outbreak( varargin )

    %
    % OUTBREAK runs the simulation of a zombie oubreak in a 3 states
    %   system.
    %
    %   DUMP = OUTBREAK( ARGS )
    %       ARGS are name-value pairs. Possible arguments are :
    %           params: structure containing rate parameters (alpha, beta,
    %                    gamma, eta, nu) as arrays (3x1 for alpha, beta and
    %                    gamma or 3x2 for eta and nu).
    %           paramfile: path to a mat-file storing the parameter
    %                    structure.
    %           zombies: 3x1 array containing the number of initial zombie
    %                    per state (default: 0, 0, 0).
    %           population: 3x1 array containing the number of initial
    %                    susceptible population per state (default: 1000,
    %                    1000, 1000).
    %           steps: maximal number of steps for the simulation (default:
    %                    1e8).
    %           silent:  level of output for the simulation:
    %                           0 = all outputs
    %                           1 = all outputs excepts graphs
    %                           2 = no outputs
    %           dslength: size of the sliding window used for the
    %                    calculation of the mean of dS (used as weight 
    %                    factor for the inter-state susceptible transfer).
    %
    %       DUMP is a structure containing the following fields:
    %           S: 4xn array containing the evolution of the susceptible
    %              population.
    %           dS: 4xn array containing the evolution of the susceptible
    %              population's variation.
    %           Z: 4xn array containing the evolution of the zombie
    %              population.
    %           dZ: 4xn array containing the evolution of the zombie
    %              population's variation.
    %           R: 4xn array containing the evolution of the removed
    %              population.
    %           dR: 4xn array containing the evolution of the removed
    %              population's variation.
    %           step: number of steps performed.
    %           alpha, beta, gamma, eta, nu: transfer rate parameters.
    %           time: simulation time.
    %

    
    %% Variable initialization
    silent = 0;
    dslength = 10;
    maxSteps = 1e8;
	rates = struct( 'alpha', [ 0.00095 ; 0.00095 ; 0.00095 ], 'beta', [0.00025 ; 0.00025 ; 0.00025 ], 'gamma', [ 0.00005 ; 0.00005 ; 0.00005 ], 'mu', [ 0.00000005 , 0.00000005 ; 0.00000005 , 0.00000005 ; 0.00000005 , 0.00000005 ], 'nu', [ 0.00000005 , 0.00000005 ; 0.00000005 , 0.00000005 ; 0.00000005 , 0.00000005 ], 'eta', [ 0.00000005 , 0.00000005 ; 0.00000005 , 0.00000005 ; 0.00000005 , 0.00000005 ] );    
    zombies = [ 0 ; 0 ; 0 ; 0 ];
    populations = [ 1e3 ; 1e3 ; 1e3 ; 3e3 ];
    
    % Structure storing populations and populations variation
    states = struct( 'pop', zeros( 4, 3 ), 'dpop', zeros( 4, 3 ) );
    
    % See exit condition at the end of the loop.
    exitThreshold = 1e-1;
    
    p = [ 'alpha' ; 'beta ' ; 'gamma' ; 'eta  ' ; 'mu   ' ; 'nu   ' ];
    reverseStr = '';
    
    
    %% Argument parsing
    % All argument are optional.
    for i = 1:2:nargin
           
        % Argument are passed in name-value pairs. If i + 1 does not exist,
        % then the value is absent and the program stops.
        if( nargin < i + 1 )

            error( [ 'Missing argument for parameter "' varargin{ i } '".' ] );
        end

        switch varargin{ i }

            % params excepts a structure containing the rates values for the
            % epidemiologic model. Not all fields have to be present. If a
            % field is missing, the default value is used.
            case 'params'
                for j = 1:6
                   
                    if isfield( varargin{ i + 1 }, strtrim( p( j, : ) ) )
                       
                        rates.( strtrim( p( j, : ) ) ) = varargin{ i + 1 }.( strtrim( p( j, : ) ) );
                    end
                end

            % paramfile excepts the path to a mat-file containing a
            % parameter structure (refer to parms).
            case 'paramfile'
                pfile = load( varargin{ i + 1 }, '-mat' );
                for j = 1:6
                   
                    if isfield( pfile{ i + 1 }, strtrim( p( j, : ) ) )
                       
                        rates.( strtrim( p( j ) ) ) = pfile{ i + 1 }.( strtrim( p( j ) ) );
                    end
                end

            % zombies excepts an array containing the initial zombie
            % populations in each state.
            case 'zombies' 
                temp = varargin{ i + 1 };
                for j = 1:3

                    zombies( j ) = temp( j );
                    zombies( 4 ) = zombies( 4 ) + temp( j );
                end

            % zombies excepts an array containing the initial susceptible  
            % population in each state.
            case 'population'
                temp = varargin{ i + 1 };
                populations( 4 ) = 0;
                for j = 1:3

                    populations( j ) = temp( j );
                    populations( 4 ) = populations( 4 ) + populations( j );
                end

            % steps excepts the maximum number of steps allowed for the 
            % simulation.
            case 'steps'
                maxSteps = varargin{ i + 1 };

            % silent except a int defining the output type :
            % 2 : No output
            % 1 : All outputs but the graphs
            % 0 : Normal output
            case 'silent' 
                silent = varargin{ i + 1 };
                
            % dslength excepts the size of the sliding window used for the
            % calculation of the mean of dS (used as weight factor for the
            % inter-state susceptible transfer).
            case 'dslength'
                dslength = varargin{ i + 1 };
                
            otherwise
                error( [ 'Unknown parameter "', varargin{ i }, '".' ] );
        end
    end
	
	
    
    %% Initialization of simulation 
	
    % Setting the initial populations.
    states.pop( :, 1 ) = populations;
	states.pop( :, 2 ) = zombies;
	
    % Initialization of the sliding window for inter-state population
    % transfer.
    dshistory = zeros( 3, dslength );
    
    % Setting up the initial dump structure. Large matrices are used to
    % avoid the need of dynamic memory allocation to improve code
    % efficency.
    d = zeros( 4, max( 200, .0001 * maxSteps ) );
    dump = struct( 'S', d, 'dS', d, 'Z', d, 'dZ', d, 'R', d, 'dR', d, 'step', 1, 'alpha', mean( rates.alpha ), 'beta', mean( rates.beta ), 'gamma', mean( rates.gamma ), 'eta', mean( mean( rates.eta ) ), 'nu', mean( mean( rates.nu ) ), 'time', 0 );
    dump.S( :, 1 ) = states.pop( 1:4, 1 );
    dump.Z( :, 1 ) = states.pop( 1:4, 2 );
    dump.R( :, 1 ) = states.pop( 1:4, 3 );
    
    % Initialize timer.
    tic;
    
    %% Update loop.
    for i = 1:maxSteps
        
        % Output of step # and current population count.
        if silent < 2

            msg = sprintf('Processing step %d... Human population %d, Zombie population %d\n', i, dump.S( 4, dump.step ), dump.Z( 4, dump.step ) );
            fprintf([ reverseStr, msg]);

            reverseStr = repmat(sprintf('\b'), 1, length(msg));
        end
        
        % Update function (see update.m for details).
        [ states, rates, dshistory ] = update( states, rates, dshistory );
        
        % Dumping of the latest state of the simulation.
        % Update of the step number.
        dump.step = i + 1;

        % Dumping of the various population and population variation.
        dump.S( :, dump.step ) = states.pop( :, 1 );
        dump.dS( :, dump.step ) = states.dpop( :, 1 );
        dump.Z( :, dump.step ) = states.pop( :, 2 );
        dump.dZ( :, dump.step ) = states.dpop( :, 2 );
        dump.R( :, dump.step ) = states.pop( :, 3 );
        dump.dR( :, dump.step ) = states.dpop( :, 3 );
    
        % Stops simulation if S is equal to 0.
        if states.pop( 4, 1 ) == 0
            
            if silent < 2
                
                disp( ' ' );
                disp( 'End of the human race.' );
            end
            break;
        end
        
        % Stops simulation if Z is equal to 0.
        if states.pop( 4, 2 ) == 0
            
            if silent < 2
                
                disp( ' ' );
                disp( 'Humanity survived.' );
            end
            break;
        end
        
        % Stops simulation if the average fluctuation of both dS and dZ
        % over a sliding window is lower than the threshold (simulation
        % reached equilibrium in the limit of our time frame).
        if i > 100 && mean( abs( dump.dS( 4, ( i - 100 ):i ) ) ) < exitThreshold && mean( abs( dump.dZ( 4, ( i - 100 ):i ) ) ) < exitThreshold
           
            
            if silent < 2
                
                disp( ' ' );
                disp( 'Equilibrium reached.' );
            end
            break;
        end
    end
    
    % Store simulation time.
    dump.time = toc;
    
    % Resizing of the dump matrices before plotting.
    dump.S = dump.S( :, 1:dump.step );
    dump.dS = dump.dS( :, 1:dump.step );
    dump.Z = dump.Z( :, 1:dump.step );
    dump.dZ = dump.dZ( :, 1:dump.step );
    dump.R = dump.R( :, 1:dump.step );
    dump.dR = dump.dR( :, 1:dump.step );
    
    if ~silent
        
        % Plot the simulation history (see plotResults.m for details).
        plotResults( dump );
    end
end

