function varargout = outbreak( varargin )

    minargs = 5;
    
    narginchk( minargs, 20 );
    
    global states;
    global rates;
    global dump;
    global ds10;
    
    ds10 = zeros( 3, 10 );
    
    states = struct( 'pop', zeros( 4, 4 ), 'dpop', zeros( 4, 3 ) );
    
	
	% rates of the SZR model. 
	% 1 ) S -> Z
	% 2 ) S -> R
	% 3 ) Z -> R
	% 4 ) Za -> Zb
	rates = struct( 'alpha', [ 0.00095 ; 0.00095 ; 0.00095 ], 'beta', [0.00025 ; 0.00025 ; 0.00025 ], 'gamma', [ 0.00005 ; 0.00005 ; 0.00005 ], 'mu', [ 0.00000005 , 0.00000005 ; 0.00000005 , 0.00000005 ; 0.00000005 , 0.00000005 ], 'nu', [ 0.00000005 , 0.00000005 ; 0.00000005 , 0.00000005 ; 0.00000005 , 0.00000005 ], 'eta', [ 0.00000005 , 0.00000005 ; 0.00000005 , 0.00000005 ; 0.00000005 , 0.00000005 ] );    
    zombies = [ 0 ; 0 ; 0 ; 0 ];
    
    if( nargin > 5 )
        
        for i = 6:2:nargin
           
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
                    
                otherwise
                    error( [ 'Unknown parameter "', varargin{ i }, '".' ] );
            end
        end
    end
    
    states.pop( 4, 1 ) = varargin{ 2 } + varargin{ 3 } + varargin{ 4 };
    states.pop( 1, 1 ) = varargin{ 2 };
    states.pop( 2, 1 ) = varargin{ 3 };
    states.pop( 3, 1 ) = varargin{ 4 };
    
    states.pop( 4, 2 ) = varargin{ 5 };
    states.pop( 1, 2 ) = states.pop( 4, 2 ) / states.pop( 4, 1 ) * states.pop( 1, 1 );
    states.pop( 2, 2 ) = states.pop( 4, 2 ) / states.pop( 4, 1 ) * states.pop( 2, 1 );
    states.pop( 3, 2 ) = states.pop( 4, 2 ) / states.pop( 4, 1 ) * states.pop( 3, 1 );   
	
	states.pop( :, 3 ) = zombies;
	
    dump = struct( 'S', states.pop( 1:4, 2 ), 'dS', zeros( 4, 1 ), 'Z', states.pop( 1:4, 3 ), 'dZ', zeros( 4, 1 ), 'R', states.pop( 1:4, 4 ), 'dR', zeros( 4, 1 ) );
    
    reverseStr = '';
    
    for i = 1:varargin{ 1 }
        
        update;
    
        msg = sprintf('Processed %d/%d', i, varargin{ 1 });
        fprintf([reverseStr, msg]);
        
        reverseStr = repmat(sprintf('\b'), 1, length(msg));
    end
	
    plotResults;
    
    varargout{ 1 } = 0;
    varargout{ 2 } = dump;
end

