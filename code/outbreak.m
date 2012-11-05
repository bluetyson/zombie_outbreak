function varargout = outbreak( varargin )

    minargs = 5;
    
    narginchk( minargs, 20 );
    
    global states;
    global rates;
    global dump;
    
    states = zeros( 4, 4 );
	
	% rates of the SZR model. 
	% 1 ) S -> Z
	% 2 ) S -> R
	% 3 ) Z -> R
	% 4 ) Za -> Zb
	rates = [ 0.00095, 0.00025, 0.00005, 0.005 ];
    
    
    states( 4, 1 ) = varargin{ 2 } + varargin{ 3 } + varargin{ 4 };
    states( 1, 1 ) = varargin{ 2 };
    states( 2, 1 ) = varargin{ 3 };
    states( 3, 1 ) = varargin{ 4 };
    
    states( 4, 2 ) = varargin{ 5 };
    states( 1, 2 ) = states( 4, 2 ) / states( 4, 1 ) * states( 1, 1 );
    states( 2, 2 ) = states( 4, 2 ) / states( 4, 1 ) * states( 2, 1 );
    states( 3, 2 ) = states( 4, 2 ) / states( 4, 1 ) * states( 3, 1 );   
	
	states( 1, 3 ) = 1;
	
	dump = struct( 'state1', struct( 'S', states( 1, 2 ), 'Z', states( 1, 3 ), 'R', 0 ), 'state2', struct( 'S', states( 2, 2 ), 'Z', states( 2, 3 ), 'R', 0 ), 'state3', struct( 'S', states( 3, 2 ), 'Z', states( 3, 3 ), 'R', 0 ), 'global', struct( 'S', states( 4, 2 ), 'Z', states( 4, 3 ), 'R', 0 ) );
    
    for i = 1:varargin{ 1 }
        
        update;
    
    end
	
	plotResults;
       
    varargout{ 1 } = 0;
    varargout{ 2 } = dump;
end

