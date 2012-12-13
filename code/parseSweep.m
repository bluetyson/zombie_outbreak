function [ alpha, beta, gamma, Sf, Zf, S ] = parseSweep( id, first, sweepSize, filename )
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
    eta = 0;
    nu = 0;
    
    reverseStr = '';
    a = 1;
    
    %% Simulation iterations
    for i = first:( first+runNbr - 1 )
        
        % Loading of the simulation results
        job = load( [ path int2str( i ) '.mat' ] );
        
        %[ x, y, z ] = ind2sub( sweepSize, a );
                
        if a == 1 
            
            eta = job.eta;
            nu = job.nu;
            
            x = 1;
            y = 1;
            z = 1;
        else
            
            x = round( job.alpha / alpha( 1, 1, 1 ) );
            y = round( job.beta / beta( 1, 1, 1 ) );
            z = round( job.gamma / gamma( 1, 1, 1 ) );
        end
        
        if eta ~= job.eta || nu ~= job.nu
            
            break;
        end

        % Update of the process status
        msg = sprintf('Processing step %d... \n', a );
        fprintf([ reverseStr, msg]);

        reverseStr = repmat(sprintf('\b'), 1, length(msg));
        
        
        % Update of the result matrices
        alpha( x, y, z ) = job.alpha;
        beta( x, y, z ) = job.beta;
        gamma( x, y, z ) = job.gamma;
        Sf( x, y, z ) = job.S( 4, job.step );
        Zf( x, y, z ) = job.Z( 4, job.step );
        S( x, y, z ) = job.step;
        
        a = a + 1;
    end
    
    output = struct( 'S', Sf, 'Z', Zf, 'steps', S, 'alpha', alpha, 'gamma', gamma, 'beta', beta, 'eta', eta, 'nu', nu );
    save( filename, '-struct', 'output' );
end

