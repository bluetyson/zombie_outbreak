%% Uberfunction

jobindex = str2double( getenv( 'LSB_JOBINDEX' ) );


cParams = struct( 'alpha', zeros( 3, 1 ), 'beta', zeros( 3, 1 ), 'gamma', zeros( 3, 1 ), 'eta', zeros( 3, 2 ), 'mu', zeros( 3, 2 ), 'nu', zeros( 3, 2 ) );
    
v = load( 'brutus' );
v = v.brutus;

cParams.gamma = v( 3, jobindex ) * ones( 3, 1 );
cParams.eta = v( 2, jobindex ) * ones( 3, 2 );
cParams.nu = v( 1, jobindex ) * ones( 3, 2 );

outputpath = [ './output/job', num2str( jobindex ), '_gamma-', num2str( cParams.gamma( 1 ) ), '_eta-', num2str( cParams.eta( 1 ) ), '_nu-', num2str( cParams.nu( 1 ) ), '/' ];
mkdir( outputpath );


for beta = v( 4, jobindex ):v( 5, jobindex ):v( 6, jobindex )
   
    for alpha = v( 7, jobindex ):v( 8, jobindex ):v( 9, jobindex )
        
        cParams.alpha = alpha * ones( 3, 1 );
        cParams.beta = beta * ones( 3, 1 );
        
        [ e, dump ] = outbreak( 'silent', 2, 'params', cParams, 'zombies', [ 1 0 0 ] );

        output = struct();
        output.S = dump.S;
        output.R = dump.R;
        output.Z = dump.Z;
        output.step = dump.step;
        output.alpha = dump.alpha;
        output.beta = dump.beta;
        output.gamma = dump.gamma;
        output.eta = dump.eta;
        output.nu = dump.nu;
        
        save( [ outputpath, 'output_beta-', num2str( alpha ), '_alpha-', num2str( alpha ), '.mat' ], '-struct', 'output' );
    end
end

