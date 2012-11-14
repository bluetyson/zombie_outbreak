function dumpState( ~ )

	global states;
	global dump;
	
    index = length( sum( dump.S ) ) + 1;
    
    dump.S( :, index ) = states.pop( :, 2 );
    dump.dS( :, index ) = states.dpop( :, 1 );
    dump.Z( :, index ) = states.pop( :, 3 );
    dump.dZ( :, index ) = states.dpop( :, 2 );
    dump.R( :, index ) = states.pop( :, 4 );
    dump.dR( :, index ) = states.dpop( :, 3 );
    
end

