path = [ '../results/' id '/' ];

files = dir( path );

s = zeros( 20, 20, 20 );
z = zeros( 20, 20, 20 );
a = zeros( 20, 20, 20 );
b = zeros( 20, 20, 20 );
g = zeros( 20, 20, 20 );

a0 = 1;
b0 = 1;
g0 = 1;

for i = 1:length( files )
   
    if files( i ).isdir
        
        continue;
    end
    
    temp = load( [ path files( i ).name ], '-mat' );
    
    s( g0, b0, a0 ) = temp.S( 4, temp.step );
    z( g0, b0, a0 ) = temp.Z( 4, temp.step );
    a( g0, b0, a0 ) = temp.alpha;
    b( g0, b0, a0 ) = temp.beta;
    g( g0, b0, a0 ) = temp.gamma;
    
    g0 = g0 + 1;
    if g0 == 21
        
        g0 = 1;
        
        b0 = b0 + 1;
        if b0 == 21
            
            b0 = 1;
            
            a0 = a0 + 1;
        end
    end
        
end