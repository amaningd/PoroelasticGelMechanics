function [f, E] =  dynamicElasticModulus(h, shape, w, E0, nu, D, npz, mode)

if(nargin < 8)
    mode = '';
end

[t, F] =  poroelasticForceResponse(h, shape, w, E0, nu, D);

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
t_s = t(2) - t(1); % sampling interval
data = iddata([zeros(1, 10) (h /alpha) * F]', [zeros(1,10) ht]', t_s);


%disp(['Predicting E(jw) for ' num2str(npz) ' poles and zeros.'])
%tic
E_est = tfest(data, npz, npz); 
%toc

[E, omega] = freqresp(E_est);
E = E(:,:);
f = omega' / (2*pi);

if strcmp(mode, 'plot')
    [E, omega] = freqresp(E_est);
    E = E(:, :);
    f = omega'/(2*pi); %freqresp() returns omega as an N x 1 vector.
    E_mag = abs(E);
    E_ph = rad2deg(angle(E));
    
    magAx = subplot(2, 1, 1);
    semilogx(f*2*pi, E_mag*10^-3);
    mag = gca;
    mag.XTickLabel = [];
    ylabel('Magnitude [kPa]')
    grid on
    
    phAx =  subplot(2, 1, 2);
    semilogx(f*2*pi, E_ph);
    xlabel('Frequency [Hz]')
    ylabel('Phase (\circ)')
    %phase = gca;
    grid on
    
    hold(magAx, 'on');
    hold(phAx, 'on');
    
    magAx.MinorGridLineStyle = 'none';
    phAx.MinorGridLineStyle ='none';
    
end

end