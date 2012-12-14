function [ oArray ] = findTransition( array )

% FINDTRANSITION expect a 3D array. It will return an 3D array from
%   the same size where only the values respecting the following conditions
%   are kept:
%
%       1) the value was greater than 0 in the input array
%       2) at least one neighbor had the value 0 in the input array
%

    [ xM, yM, zM ] = size( array );
    
    oArray = zeros( xM, yM, zM );

    % Recover all positions where the value is not 0
    [ x1, y1, z1 ] = ind2sub( [ xM, yM, zM ], find( array ) );
    
    for i = 1:length( x1 )
       
        % For each position, we check the neighbors, if at least one equals
        % 0, we set the position to 1 and continue.
        
        if x1( i ) ~= 1 && array( x1( i ) - 1, y1( i ), z1( i ) ) == 0
            
            oArray( x1( i ), y1( i ), z1( i ) ) = 1;
            continue;
        end
        
        if x1( i ) ~= xM && array( x1( i ) + 1, y1( i ), z1( i ) ) == 0
            
            oArray( x1( i ), y1( i ), z1( i ) ) = 1;
            continue;
        end
        
        if y1( i ) ~= 1 && array( x1( i ), y1( i ) - 1, z1( i ) ) == 0
            
            oArray( x1( i ), y1( i ), z1( i ) ) = 1;
            continue;
        end
        
        if y1( i ) ~= yM && array( x1( i ), y1( i ) + 1, z1( i ) ) == 0
            
            oArray( x1( i ), y1( i ), z1( i ) ) = 1;
            continue;
        end
        
        if z1( i ) ~= 1 && array( x1( i ), y1( i ), z1( i ) - 1 ) == 0
            
            oArray( x1( i ), y1( i ), z1( i ) ) = 1;
            continue;
        end
        
        if z1( i ) ~= xM && array( x1( i ), y1( i ), z1( i ) + 1 ) == 0
            
            oArray( x1( i ), y1( i ), z1( i ) ) = 1;
            continue;
        end
    end
end

