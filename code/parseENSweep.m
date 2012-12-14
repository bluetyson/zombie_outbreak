function [ eta, nu, gamma, Sf, Zf, S ] = parseENSweep( id, first, sweepSize, filename, step )
%
% PARSESWEEP parse the results of the sweep function for the parameters
%   eta and nu.
%
% [ ETA. NU, SF, ZF, S ] = PARSESWEEP( ID, SIZE )
%   ID string containing the ID of the parameter sweep.
%   SIZE 1x2 matrix containing the size of the sweep for the parameters
%       ALPHA, BETA and GAMMA.
%
%   ETA NxM matrix where N and M are the size of the respective
%       sweep of the parameters and containing the ETA value for each
%       simulation of the sweep.
%   NU, see ETA.
%   SF final number of susceptible for the simulation.
%   ZF final number of susceptible for the simulation.
%   S number of step required for the simulation to end.

    %% Variable initialization
    % Results path
    path = [ '../results/' id '/output.' ];
    % Number of simulation to consider
    runNbr = prod( sweepSize );
    % Preparation of the output matrices
    eta = zeros( sweepSize );
    nu = zeros( sweepSize );
    Sf = zeros( sweepSize );
    Zf = zeros( sweepSize );
    S = zeros( sweepSize );
    
    alpha = 0;
    beta = 0;
    gamma = 0;
    
    reverseStr = '';
    a = 1;
    
    %% Simulation iterations
    for i = first:( first - 1 + runNbr )
        
        % Loading of the simulation results
        job = load( [ path int2str( i ) '.mat' ] );
        
        %[ x, y, z ] = ind2sub( sweepSize, a );
                
        if a == 1 
            
            alpha = job.alpha;
            beta = job.beta;
            gamma = job.gamma;
            
            x = 1;
            y = 1;
        else
            
            x = round( job.eta / step ) + 1;
            y = round( job.nu / step ) + 1;
        end
        
        if alpha ~= job.alpha || beta ~= job.beta || gamma ~= job.gamma
            
            break;
        end

        % Update of the process status
        msg = sprintf('Processing step %d... \n', a );
        fprintf([ reverseStr, msg]);

        reverseStr = repmat(sprintf('\b'), 1, length(msg));
        
        
        % Update of the result matrices
        eta( x, y ) = job.eta;
        nu( x, y ) = job.nu;
        Sf( x, y ) = job.S( 4, job.step );
        Zf( x, y ) = job.Z( 4, job.step );
        S( x, y ) = job.step;
        
        a = a + 1;
    end
    
    output = struct( 'S', Sf, 'Z', Zf, 'steps', S, 'alpha', eta, 'gamma', gamma, 'beta', nu, 'eta', eta, 'nu', nu );
    save( filename, '-struct', 'output' );
end

