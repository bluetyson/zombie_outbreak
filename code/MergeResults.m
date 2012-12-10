
cParams = struct( 'alpha', 0, 'beta', 0, 'gamma', 0, 'eta', 0, 'mu', 0, 'nu', 0 );

brutus = load('brutus');
brutus = brutus.brutus;

susceptibles = zeros( 4, 50, 50, 50 );
zombies = zeros( 4, 50, 50, 50 );
steps = zeros( 4, 50, 50, 50 );
x = zeros( 4, 50, 50, 50 );
y = zeros( 4, 50, 50, 50 );
z = zeros( 4, 50, 50, 50 );

reverseStr = '';
total = 1;

for j = 1:4
    
    total = 1;
    k = 1;
        
    for i = ( ( j - 1 ) * 50 + 1):( j * 50 )

        cParams.gamma = brutus( 3, i );
        cParams.eta = brutus( 2, i );
        cParams.nu = brutus( 1, i );

        outputpath = [ '../results/run2/job', num2str(i), '_gamma-', num2str(cParams.gamma), '_eta-', num2str(cParams.eta), '_nu-', num2str(cParams.nu), '/' ];

        b = 1;
        for beta = brutus( 4, i ):brutus( 5, i ):brutus( 6, i )

            a = 1;
            for alpha = brutus( 7, i ):brutus( 8, i ):brutus( 9, i )

                cParams.alpha = alpha;
                cParams.beta = beta;

                temp = load( [ outputpath, 'output_beta-', num2str(alpha), '_alpha-', num2str(alpha), '.mat' ] );

                x( j, a, b, k ) = alpha;
                y( j, a, b, k ) = beta;
                z( j, a, b, k ) = brutus( 3, i );
                    
                susceptibles( j, a, b, k ) = temp.S( 4, temp.step );
                zombies( j, a, b, k ) = temp.Z( 4, temp.step );
                steps( j, a, b, k ) = temp.step;
               
                
                msg = sprintf('Processing step %d...', total );
                fprintf([reverseStr, msg]);

                reverseStr = repmat(sprintf('\b'), 1, length(msg));

                a = a + 1;
                total = total + 1;
            end

            b = b + 1;
        end
        
        k = k + 1;
    end
end