clear;

x = 0:0.05:4*pi; 
y = 0*x;
for ii=1:length(x)
    a = FootTrajectory2(x(ii), 2/3, 1, [0;0], [0;0]);
    y(ii) = a(4)/2/pi;
end
plot(x/2/pi, y);

function ret = FootTrajectory2( Phase, rate, h, p1, p2)
    ret = zeros(4,1);
    while Phase > 2*pi
        Phase = Phase - 2*pi;
    end
    % Phase modification
    rateRad = rate*2*pi;
    if Phase <= rateRad
        Phi = pi*Phase/rateRad;
    else
        Phi = pi*(Phase-rateRad)/(2*pi-rateRad) + pi;
    end
    Phi2 = Phi;
    if Phi <= pi
        % p1 -> p2 ( ground )
        ret(1:2) = (p2-p1)*Phi/pi + p1;
    else
        % p2 -> p1 ( float )
        Phi = Phi - pi;
        ret(1:2) = (p1-p2)*Phi/pi + p2;
        ret(3) = h*sin(Phi);
    end
    ret(4) = Phi2;
end
