function varargout = outbreak( varargin )

    silent = 0;
        
    ds10 = zeros( 3, 10 );
    
    states = struct( 'pop', zeros( 4, 4 ), 'dpop', zeros( 4, 3 ) );
    
    maxSteps = 1e8;
	
	% rates of the SZR model. 
	% 1 ) S -> Z
	% 2 ) S -> R
	% 3 ) Z -> R
	% 4 ) Za -> Zb
	rates = struct( 'alpha', [ 0.00095 ; 0.00095 ; 0.00095 ], 'beta', [0.00025 ; 0.00025 ; 0.00025 ], 'gamma', [ 0.00005 ; 0.00005 ; 0.00005 ], 'mu', [ 0.00000005 , 0.00000005 ; 0.00000005 , 0.00000005 ; 0.00000005 , 0.00000005 ], 'nu', [ 0.00000005 , 0.00000005 ; 0.00000005 , 0.00000005 ; 0.00000005 , 0.00000005 ], 'eta', [ 0.00000005 , 0.00000005 ; 0.00000005 , 0.00000005 ; 0.00000005 , 0.00000005 ] );    
    
    zombies = [ 0 ; 0 ; 0 ; 0 ];
    populations = [ 1e3 ; 1e3 ; 1e3 ; 3e3 ];
    
    for i = 1:2:nargin
           
        if( nargin < i + 1 )

            error( [ 'Missing argument for parameter "' varargin{ i } '".' ] );
        end

        switch varargin{ i }

            case 'params'
                rates = varargin{ i + 1 };

            case 'paramfile'
                rates = load( varargin{ i + 1 }, '' );

            case 'zombies' 
                temp = varargin{ i + 1 };
                for j = 1:3

                    zombies( j ) = temp( j );
                    zombies( 4 ) = zombies( 4 ) + temp( j );
                end

            case 'population'
                temp = varargin{ i + 1 };
                populations( 4 ) = 0;
                for j = 1:3

                    populations( j ) = temp( j );
                    populations( 4 ) = populations( 4 ) + populations( j );
                end

            case 'steps'
                maxSteps = varargin{ i + 1 };

                
            case 'silent' 
                silent = varargin{ i + 1 };
                
            otherwise
                error( [ 'Unknown parameter "', varargin{ i }, '".' ] );
        end
    end
    
    states.pop( 4, 1 ) = 1;
    states.pop( 1, 1 ) = populations( 1 ) / populations( 4 );
    states.pop( 2, 1 ) = populations( 2 ) / populations( 4 );
    states.pop( 3, 1 ) = populations( 3 ) / populations( 4 );  
	
    states.pop( :, 2 ) = populations;
	states.pop( :, 3 ) = zombies;
	
    d = zeros( 4, .001 * maxSteps );
    
    dump = struct( 'S', d, 'dS', d, 'Z', d, 'dZ', d, 'R', d, 'dR', d, 'step', 1 );
    dump.S( :, 1 ) = states.pop( 1:4, 2 );
    dump.Z( :, 1 ) = states.pop( 1:4, 3 );
    dump.R( :, 1 ) = states.pop( 1:4, 4 );
    reverseStr = '';
    
    for i = 1:maxSteps
        
        if silent < 2

            msg = sprintf('Processing step %d... Human population %d, Zombie population %d', i, dump.S( 4, dump.step ), dump.Z( 4, dump.step ) );
            fprintf([reverseStr, msg]);

            reverseStr = repmat(sprintf('\b'), 1, length(msg));
        end
        
        [ states, rates, ds10, dump ] = update( states, rates, ds10, dump );
        
        if states.pop( 4, 2 ) == 0
            
            if silent < 2
                
                disp( ' ' );
                disp( 'Humanity vanished.' );
            end
            break;
        end
        
        if states.pop( 4, 3 ) == 0 
            
            if silent < 2
                
                disp( ' ' );
                disp( 'Humanity survived.' );
            end
            break;
        end
    end
    
    
    varargout{ 1 } = 0;
    varargout{ 2 } = dump;
end

