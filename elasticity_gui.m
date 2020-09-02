function elasticity_gui
% ELASTICITY_GUI Plot the frequency-domain poroelastic response of an
% indented material.  Choose indenter shape and width, identation depth,
% diffusivity, elasticity, Poisson ratio, and the number of poles/zeros
% (equal to one another) for the generated transfer function.
%
%%  Create and lay out uifigure window
% Displayed elements are placed relative to figWidth and figHeight to
% remain independent from the window resolution
figWidth = 800; 
figHeight = 500;
fig = uifigure('Name', 'Frequency-domain indentation response', ...
    'Position',[200 300 figWidth figHeight]);

g1 = uigridlayout(fig, [1, 2]); 
g1.ColumnWidth = {0.3 * figWidth, '1x'}; % first column houses panel

%% Left-column items
leftPanel = uipanel(g1, 'Title','Simulation settings');
leftPanel.TitlePosition = 'centertop';
leftPanel.Layout.Column = 1;
leftPanel.FontWeight = 'bold';
g2 = uigridlayout(leftPanel);
g2.RowHeight = {0.2*figHeight, 0.075*figHeight, 0.075*figHeight, ... % shape, radius, depth
    0.05*figHeight, 0.05*figHeight, 0.05*figHeight, ... % elasticity, diffusivity, Poisson ratio label, slider
    0.05*figHeight, '1x'}; % pole-zero text/dropdown, "simulate" button
    

% makes sure labels are not cut off by text fields
g2.ColumnWidth = {0.35*leftPanel.InnerPosition(3), ...
    0.15*leftPanel.InnerPosition(3), '1x'}; 

% Indenter selector (3 radio buttons)
indenter = uibuttongroup(g2, 'SelectionChangedFcn', @indenter_SelectionChangedFcn);
indenter.Title = 'Indenter shape'; 
indenter.TitlePosition = 'centertop';
indenter.Layout.Row = 1;
indenter.Layout.Column = [1, 3];
indenter.FontWeight = 'bold';
% Buttons (positions are required and are w.r.t. the uibuttongroup box)
spButton = uiradiobutton(indenter, 'Position', [10 60 91 15]);
spButton.Text = 'Spherical';

conButton = uiradiobutton(indenter, 'Position', [10 38 91 15]);
conButton.Text = 'Conical';

cylButton = uiradiobutton(indenter, 'Position', [10 16 91 15]);
cylButton.Text = 'Cylindrical';

% Radius field labels
radiusFieldLabel = uilabel(g2);
radiusFieldLabel.Layout.Row = 2;
radiusFieldLabel.Layout.Column = 1;
radiusFieldLabel.HorizontalAlignment = 'right';
radiusFieldLabel.Text = {'Indenter', 'radius:'};
radiusFieldLabel.FontWeight = 'bold';

radiusFieldUnits = uilabel(g2);
radiusFieldUnits.Layout.Row = 2;
radiusFieldUnits.Layout.Column = 3;
radiusFieldUnits.HorizontalAlignment = 'left';
radiusFieldUnits.Text = 'mm';

% Radius field
radiusField = uieditfield(g2, 'numeric');
radiusField.Layout.Row = 2;
radiusField.Layout.Column = 2;

% Depth field labels
depthFieldLabel = uilabel(g2);
depthFieldLabel.Layout.Row = 3;
depthFieldLabel.Layout.Column = 1;
depthFieldLabel.HorizontalAlignment = 'right';
depthFieldLabel.Text = {'Indentation', 'depth:'};
depthFieldLabel.FontWeight = 'bold';

depthFieldUnits = uilabel(g2);
depthFieldUnits.Layout.Row = 3;
depthFieldUnits.Layout.Column = 3;
depthFieldUnits.HorizontalAlignment = 'left';
depthFieldUnits.Text = append(char(956), 'm');

% Depth field
depthField = uieditfield(g2, 'numeric');
depthField.Layout.Row = 3;
depthField.Layout.Column = 2;

% Elasticity field labels
elasticityFieldLabel = uilabel(g2);
elasticityFieldLabel.Layout.Row = 4;
elasticityFieldLabel.Layout.Column = 1;
elasticityFieldLabel.HorizontalAlignment = 'right';
elasticityFieldLabel.Text = 'Elasticity:';
elasticityFieldLabel.FontWeight = 'bold';

elasticityFieldUnits = uilabel(g2);
elasticityFieldUnits.Layout.Row = 4;
elasticityFieldUnits.Layout.Column = 3;
elasticityFieldUnits.HorizontalAlignment = 'left';
elasticityFieldUnits.Text = 'kPa';

% Elasticity field
elasticityField = uieditfield(g2, 'numeric');
elasticityField.Layout.Row = 4;
elasticityField.Layout.Column = 2;

% Diffusivity field labels
diffusivityFieldLabel = uilabel(g2);
diffusivityFieldLabel.Layout.Row = 5;
diffusivityFieldLabel.Layout.Column = 1;
diffusivityFieldLabel.HorizontalAlignment = 'right';
diffusivityFieldLabel.Text = 'Diffusivity:';
diffusivityFieldLabel.FontWeight = 'bold';

diffusivityFieldUnits = uilabel(g2);
diffusivityFieldUnits.Layout.Row = 5;
diffusivityFieldUnits.Layout.Column = 3;
diffusivityFieldUnits.HorizontalAlignment = 'left';
diffusivityFieldUnits.Text = append(char(215), '10', char([8315 8312]), ' m', char(178), '/s');

% Diffusivity field
diffusivityField = uieditfield(g2, 'numeric');
diffusivityField.Layout.Row = 5;
diffusivityField.Layout.Column = 2;

% Poisson ratio (nu) field label
nuFieldLabel = uilabel(g2);
nuFieldLabel.Layout.Row = 6;
nuFieldLabel.Layout.Column = [1];
nuFieldLabel.HorizontalAlignment = 'right';
nuFieldLabel.Text = 'Poisson ratio:';
nuFieldLabel.FontWeight = 'bold';

% Poisson ratio field
nuField = uieditfield(g2, 'numeric', 'Limits', [0 0.5], ...
    'LowerLimitInclusive', 'on', 'UpperLimitInclusive', 'off', ...
    'Value', 0);
nuField.Layout.Row = 6;
nuField.Layout.Column = 2;

% Poisson ratio (nu) bounds label
nuFieldLabel = uilabel(g2);
nuFieldLabel.Layout.Row = 6;
nuFieldLabel.Layout.Column = 3;
nuFieldLabel.HorizontalAlignment = 'left';
nuFieldLabel.Text = append('(0 ', char([8804]), ' ', char(957), ' < 0.5)');

% % Poisson ratio (nu) slider
% nuSlider = uislider(g2);
% nuSlider.Layout.Row = 7;
% nuSlider.Layout.Column = [1, 2];
% nuSlider.Limits = [0.0, 0.5];
% nuSlider.Value = 0;
% nuSlider.MajorTicks = [0.0, 0.1, 0.2, 0.3, 0.4, 0.499];
% nuSlider.MajorTickLabels = {'0.0', '0.1', '0.2', '0.3', '0.4', '0.5'};


% npz dropdown
npzDropdown = uidropdown(g2, 'ValueChangedFcn', @npzDropdown_ValueChangedFcn);
npzDropdown.Items = {'2', '3', '4', '5'};
npzDropdown.ItemsData = 2 : 5; % ensures that npzDropdown.Value is numeric
npzDropdown.Layout.Row = 7;
npzDropdown.Layout.Column = 1;

% npz (number of poles/zeros) field label
npzFieldLabel = uilabel(g2);
npzFieldLabel.Layout.Row = 7;
npzFieldLabel.Layout.Column = [2, 3];
npzFieldLabel.HorizontalAlignment = 'left';
npzFieldLabel.Text = ['poles and ' num2str(npzDropdown.Value) ' zeros'];
npzFieldLabel.FontWeight = 'bold';

% "Simulate" button
simulateButton = uibutton(g2, 'ButtonPushedFcn', @simulateButton_ButtonPushedFcn);
simulateButton.Layout.Row = 8;
simulateButton.Layout.Column = [1, 3];
simulateButton.Text = 'Simulate';
simulateButton.FontWeight = 'bold';

%% Right column items
% Axes must be contained in a uipanel within the grid layout
rightPanel = uipanel(g1);
rightPanel.Layout.Column = 2;
rightPanel.AutoResizeChildren = 'off';

% Create blank axes
magAxes = subplot(2, 1, 1, 'Parent', rightPanel);
magAxes.XTickLabels = [];
magAxes.YLabel.String = 'Magnitude [kPa]';
magAxes.XScale = 'log';
magAxes.FontSize = 12;

phaseAxes = subplot(2, 1, 2, 'Parent', rightPanel);
phaseAxes.XLabel.String = 'Frequency [Hz]';
phaseAxes.YLabel.String = 'Phase [\circ]';
phaseAxes.XScale = 'log';
phaseAxes.FontSize = 12;

%% Callback functions for app functionality (nested so that uifigure elements are accessible)
% See https://www.mathworks.com/help/matlab/creating_guis/add-code-for-components-in-callbacks.html
% for structure of a uibuttongroup callback function

% Change "Radius", "[mm]" to "Width", "[°]" when the indenter shape is set to "Conical"

    function indenter_SelectionChangedFcn(hObject, eventdata, handles)
        switch eventdata.NewValue.Text
            case 'Spherical'
                radiusFieldLabel.Text = {'Indenter', 'radius:'};
                radiusFieldUnits.Text = 'mm';
            case 'Conical'
                radiusFieldLabel.Text = {'Indenter', 'width:'};
                radiusFieldUnits.Text = append(char(176), ' (degrees)');
            case 'Cylindrical'
                radiusFieldLabel.Text = {'Indenter', 'radius:'}';
                radiusFieldUnits.Text = 'mm';
        end
    end

% Update the text "x poles and x zeros"
    function npzDropdown_ValueChangedFcn(hObject, eventdata, handles)
        npzFieldLabel.Text = ['poles and ' num2str(eventdata.Value) ' zeros'];
    end
% Run simulation using the user-provided parameters.
    function simulateButton_ButtonPushedFcn(hObject, eventdata, handles)
        % hObject    handle to pushbutton1 (see GCBO)
        % eventdata  reserved - to be defined in a future version of MATLAB
        % handles    structure with handles and user data (see GUIDATA)
        
        % Change "Simulate" button to indicate that calculation is occuring
        simulateButton.Text = "Please wait; simulation in progress.";
        simulateButton.FontColor = [1, 0, 0];
        
        % Set indenter shape argument for dynamicElasticModulus()
        switch indenter.SelectedObject.Text
            case 'Spherical'
                shape = 'sp';
            case 'Conical'
                shape = 'con';
            case 'Cylindrical'
                shape = 'cyl';
        end
        
        % Spherical and cylindrical indenters' radii are entered in mm (10^-3 m),
        % while the width (in deg.) of the conical indenter is used as-is.
        switch shape
            case 'sp'
                width = radiusField.Value * 1e-3;
            case 'con'
                width = radiusField.Value; % degrees
            case 'cyl'
                width = radiusField.Value * 1e-3;
        end
        
        [f, E] =  dynamicElasticModulus(depthField.Value * 1e-6, shape, ...
            width, elasticityField.Value * 1e3, nuField.Value, ...
            diffusivityField.Value * 1e-8, npzDropdown.Value);
        
        semilogx(magAxes, f, abs(E) * 1e-3, 'LineWidth', 2)
        set(magAxes, 'XLimSpec', 'Tight');
        magAxes.YLabel.String = 'Magnitude [kPa]';
        grid(magAxes, 'on')
        magAxes.XMinorGrid = 'off';
        magAxes.XTickLabels = [];
        magAxes.FontSize = 12;
        
        semilogx(phaseAxes, f, rad2deg(angle(E)), 'LineWidth', 2)
        set(phaseAxes, 'XLimSpec', 'Tight');
        phaseAxes.YLabel.String = 'Phase [\circ]';
        phaseAxes.XLabel.String = 'Frequency [Hz]';
        grid(phaseAxes, 'on')
        phaseAxes.XMinorGrid = 'off';
        phaseAxes.FontSize = 12;
        
        % Revert "Simulate" button after completion
        simulateButton.Text = 'Simulate';
        simulateButton.FontColor = [0, 0, 0];
    end

end
