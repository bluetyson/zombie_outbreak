function [ alpha, beta, gamma, Sf, Zf, S ] = parseSweep( id, first, sweepSize )
%
% PARSESWEEP parse the results of the sweep function for the parameters
%   alpha, beta and gamma.
%
% [ ALPHA, BETA, GAMMA, SF, ZF, S ] = PARSESWEEP( ID, FIRST, SIZE )
%   ID string containing the ID of the parameter sweep.
%   FIRST first simulation of the parameter sweep to be parsed.
%       If the sweep has been made on 4 values for all parameters, the
%       first ALPHA, BETA, GAMMA set will be at 1, the second at 4*4*4, the
%       third at 2*4*4*4,...
%   SIZE 1x3 matrix containing the size of the sweep for the parameters
%       ALPHA, BETA and GAMMA.
%
%   ALPHA NxMxO matrix where N, M and O are the size of the respective
%       sweep of the parameters and containing the ALPHA value for each
%       simulation of the sweep.
%   BETA and GAMMA, see ALPHA.
%   SF final number of susceptible for the simulation.
%   ZF final number of susceptible for the simulation.
%   S number of step required for the simulation to end.

    %% Variable initialization
    % Results path
    path = [ '../results/' id '/output.' ];
    % Number of simulation to consider
    runNbr = prod( sweepSize );
    % Preparation of the output matrices
    alpha = zeros( sweepSize );
    beta = zeros( sweepSize );
    gamma = zeros( sweepSize );
    Sf = zeros( sweepSize );
    Zf = zeros( sweepSize );
    S = zeros( sweepSize );
    
    
    reverseStr = '';
    a = 1;
    
    %% Simulation iterations
    for i = first:( first+runNbr - 1 )

        % Update of the process status
        msg = sprintf('Processing step %d... \n', a );
        fprintf([ reverseStr, msg]);

        reverseStr = repmat(sprintf('\b'), 1, length(msg));
        
        % Loading of the simulation results
        job = load( [ path int2str( i ) '.mat' ] );
        
        % Update of the result matrices
        alpha( a ) = job.alpha;
        beta( a ) = job.beta;
        gamma( a ) = job.gamma;
        Sf( a ) = job.S( job.step );
        Zf( a ) = job.Z( job.step );
        S( a ) = job.step;
        
        a = a + 1;
    end
    
    Z1f = findTransition( Zf > 1 );
    S1f = findTransition( Sf > 1 );
    
    [ xZ, yZ, zZ ] = ind2sub( sweepSize, find( Z1f ) );
    [ xS, yS, zS ] = ind2sub( sweepSize, find( S1f ) );
    
    cS = zeros( size( xS, 1 ), 3 );
    cS( :, 2 ) = 1;
    cZ = zeros( size( xZ, 1 ), 3 );
    cZ( :, 1 ) = 1;
   
    x = [ xS ; xZ ];
    y = [ yS ; yZ ];
    z = [ zS ; zZ ];
    c = [ cS ; cZ ];
    
    scatter3( x, y, z, 4, c );
end

