function [rise,fall,dist,rssi] = A1(data)

    N = length(data);
    point_N = N/8;
    rise = zeros(point_N,1);
    fall = zeros(point_N,1);
    dist = zeros(point_N,1);
    rssi = zeros(point_N,1);    

    for n=1:point_N
        rise(n) = hex2dec(data(8*(n-1)+1,:)) *2^8 + hex2dec(data(8*(n-1)+2,:)) ;
        fall(n) = hex2dec(data(8*(n-1)+3,:)) *2^8 + hex2dec(data(8*(n-1)+4,:)) ;
        dist(n) = hex2dec(data(8*(n-1)+5,:)) *2^8 + hex2dec(data(8*(n-1)+6,:)) ;
        rssi(n) = hex2dec(data(8*(n-1)+7,:)) *2^8 + hex2dec(data(8*(n-1)+8,:)) ;
    end

end