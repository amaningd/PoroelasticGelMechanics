function [omega, E] =  dynamicElasticModulus_normFreq(h, shape, w, E0, nu, D, npz, mode)

if(nargin < 8)
    mode = '';
end

[tau, F] =  poroelasticForceResponse_normTime(h, shape, w, E0, nu, D);

ht = h * ones(1, length(F)); % step input of height h
switch(shape)
    case 'cyl'
        a = w; % contact area
        alpha = (2 * a * h) / (1 - nu^2);
    case 'con'
        a = (2 / pi) * h * tand(w); % contact area
        alpha = (a * h) / (1 - nu^2);
    case 'sp'
        a = sqrt(w * h); % contact area
        alpha = (4/3) * (a * h) / ( 1 - nu^2);
end
tau_s = tau(2) - tau(1); % sampling interval
data_norm = iddata([zeros(1, 10) (h /alpha) * F]', [zeros(1,10) ht]', tau_s);


%disp(['Predicting normalized E(jw) ()'])
%tic
E_est_norm = tfest(data_norm, npz, npz); 
%toc

[E, w] = freqresp(E_est_norm);
E = E(:,:);
omega = w' / (2*pi); % omega = a^2 * f / D

if strcmp(mode, 'plot')
    E_mag = abs(E);
    E_ph = rad2deg(angle(E));
    
    magAx = subplot(2, 1, 1);
    semilogx(omega, E_mag*10^-3);
    mag = gca;
    mag.XTickLabel = [];
    ylabel('Magnitude [kPa]')
    grid on
    
    phAx =  subplot(2, 1, 2);
    semilogx(omega, E_ph);
    xlabel('Normalized Frequency, \Omega')
    ylabel('Phase (\circ)')
    %phase = gca;
    grid on
    
    hold(magAx, 'on');
    hold(phAx, 'on');
    
    magAx.MinorGridLineStyle = 'none';
    phAx.MinorGridLineStyle ='none';
    
end

end