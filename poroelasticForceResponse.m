%% [t, F] = poroelasticForceResponse() returns the force, F, exerted by a poroelastic gel on an indenter

function [t, F] =  poroelasticForceResponse(h, shape, w, E0, nu, D, mode)

if(nargin < 7)
    mode = '';
end

G = E0 / (2 * (1 + nu));

switch shape
    case 'cyl'
        t = 0 : 1e-3 : 500; 
        % cylindrical indenters have a relatively large contact area, 
        % so the simulation is longer while sampling frequency is decreased.
        
        a = w; % m, contact area
        tau = D*t/(a^2); % normalised time
        g = 0.242*exp(-3.13*tau) + 0.536*exp(-1.71*sqrt(tau)) ...
            - 0.043*exp(-12.8*tau.^(1/3)) + 0.266*exp(-0.892*tau.^(1/4));
        % uses new relaxation function presented in Lai and Hu (2017).
        F0 = 8 * G * h * a;
    case 'con'
        t = 0 : 1e-3: 100; %seconds
        a = (2/pi) * h * tand(w); % m, contact area
        tau = D*t/(a^2); % normalised time
        g = 0.493*exp(-0.822*sqrt(tau)) + 0.507*exp(-1.348*tau);
        F0 = 4 * G * h * a;
    case 'sp'
        t = 0 : 1e-3: 100; %seconds
        a = sqrt(w*h); % m, contact area
        tau = D*t/(a^2); % normalised time
        g = 0.491*exp(-0.908*sqrt(tau)) + 0.509*exp(-1.679*tau);
        F0 = (16/3) * G * h * a;
end

Fss = F0 / (2 * (1 - nu));
F = g * (F0 - Fss) + Fss;

%% plot F(t, h) [optional]
if strcmp(mode, 'plot')
    switch shape
        case 'cyl'
            shapestr = 'cylindrical';
        case 'con'
            shapestr = 'conical';
        case 'sp'
            shapestr = 'spherical';
    end
    plot(t, F * 10^3);
    
    titlestr = ['Force on a ' shapestr ' indenter '];
    switch shape
        case 'cyl'
            title([titlestr '(R = ' num2str(w*10^3) ' mm, \nu = ' num2str(nu) ')']);
            %xlim([0 1000]);
        case 'con'
            title([titlestr '(\theta = ' num2str(w) ' mm, \nu = ' num2str(nu) ')']);
            %xlim([0 100]);
        case 'sp'
            title([titlestr '(R = ' num2str(w*10^3) ' mm, \nu = ' num2str(nu) ')']);
            %xlim([0 100]);
    end
    
    xlabel('Time, t [s]');
    ylabel('Indenter force, F(t, h) [mN]');
    legend({['h_0 = ' num2str(h*10^6) ' \mum']});
    grid on
end

end