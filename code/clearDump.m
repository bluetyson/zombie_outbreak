function [ dump ] = clearDump( dump )

    index = dump.step;
    
    dump.S = dump.S( :, 1:index );
    dump.dS = dump.dS( :, 1:index );
    dump.Z = dump.Z( :, 1:index );
    dump.dZ = dump.dZ( :, 1:index );
    dump.R = dump.R( :, 1:index );
    dump.dR = dump.dR( :, 1:index );
end

