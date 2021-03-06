function varargout = UpdateHistogram(varargin)
% UpdateHistogram is called by TomoDoseRate when 
% initializing or updating the results plot.  When called with no input 
% arguments, this function returns a string cell array of available plots 
% that the user can choose from.  When called with a plot handle and GUI 
% handles structure, will update varagin{2} based on the value of 
% varargin{2} using the data structure in handles.
%
% The following variables are required for proper execution: 
%   varargin{1} (optional): plot handle to update
%   varargin{2} (optional): type of plot to display (see below for options)
%   varargin{3} (optional): structure containing the data variables used 
%       for statistics computation. This will typically be the guidata (or 
%       data structure, in the case of PrintReport).
%   varargin{4} (optional): file handle to also write data to
%
% The following variables are returned upon succesful completion:
%   vararout{1}: if nargin == 0, cell array of plot options available.
%
% Author: Mark Geurts, mark.w.geurts@gmail.com
% Copyright (C) 2017 University of Wisconsin Board of Regents
%
% This program is free software: you can redistribute it and/or modify it 
% under the terms of the GNU General Public License as published by the  
% Free Software Foundation, either version 3 of the License, or (at your 
% option) any later version.
%
% This program is distributed in the hope that it will be useful, but 
% WITHOUT ANY WARRANTY; without even the implied warranty of 
% MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the GNU General 
% Public License for more details.
% 
% You should have received a copy of the GNU General Public License along 
% with this program. If not, see http://www.gnu.org/licenses/.

% Run in try-catch to log error via Event.m
try

% Specify plot options and order
plotoptions = {
    ''
    'Planned Dose Volume Histogram'
    'Average Dose Rate Histogram'
    'Maximum Dose Rate Histogram'
    'Biologically Effective Dose Histogram'
    'Instantaneous BED Histogram'
    'Continuous Dose BED Histogram'
    'Equivalent Continuous Dose Rate Histogram'
};

% If no input arguments are provided
if nargin == 0
    
    % Return the plot options
    varargout{1} = plotoptions;
    
    % Stop execution
    return;
    
% Otherwise, if 1, set the input variable and update the plot
elseif nargin == 1

    % Set input variables
    handles = varargin{1};

    % Log start
    Event('Updating histogram plot display');
    tic;
    
% Otherwise, throw an error
else 
    Event('Incorrect number of inputs to UpdateHistogram', 'ERROR');
end

% Get view modes
modes = get(handles.histview_menu, 'String');
s = strsplit(modes{get(handles.histview_menu, 'Value')}, '-');
type = lower(s{1});
volume = lower(s{2});

% Clear and set reference to axis
cla(handles.hist_axes, 'reset');
axes(handles.hist_axes);
Event('Current plot set to histogram display');

% Turn off the display while building
set(allchild(handles.hist_axes), 'visible', 'off'); 
set(handles.hist_axes, 'visible', 'off');

% Disable export button
set(handles.exporthist_button, 'enable', 'off');

% Execute code block based on display GUI item value
switch get(handles.hist_menu, 'Value')
    
    % Planned DVH
    case 2
        
        % Log plot selection
        Event('Planned dose volume histogram selected');
        
        % If a DVHViewer object exists, update it with the planned dose
        if isfield(handles, 'histogram') && isfield(handles, 'dose') && ...
                ~isempty(handles.dose)
        
            handles.histogram.Calculate('doseA', ...
                struct('data', handles.dose.data * handles.repeat, ...
                'width', handles.dose.width), 'xlabel', ...
                'Fraction Dose (Gy)', 'type', type, 'volume', volume);
        else
            Event('Histogram not plotted as plan data does not exist');
        end
        
    % Average dose rate
    case 3
        
        % Log plot selection
        Event('Average dose rate histogram selected');
        
        % If a DVHViewer object exists, update it with the planned dose
        if isfield(handles, 'histogram') && isfield(handles, 'rate') && ...
                isfield(handles.rate, 'average')
            
            % Calculate scaling factor for average to account for delays
            % between beams
            s = handles.rate.time(end) / (handles.rate.time(end) + ...
                handles.delay * 60 * (handles.repeat * ...
                length(handles.plan.numberOfProjections) - 1));
        
            handles.histogram.Calculate('doseA', ...
                struct('data', handles.rate.average * s * 60, ...
                'width', handles.dose.width), 'xlabel', ...
                'Dose Rate (Gy/min)', 'type', type, 'volume', volume);
        else
            Event('Histogram not plotted as dose rate data does not exist');
        end
        
    % Maximum dose rate
    case 4
        
        % Log plot selection
        Event('Maximum dose rate histogram selected');
        
        % If a DVHViewer object exists, update it with the planned dose
        if isfield(handles, 'histogram') && isfield(handles, 'rate') && ...
                isfield(handles.rate, 'max')
           
            handles.histogram.Calculate('doseA', ...
                struct('data', handles.rate.max * 60, 'width', ...
                handles.dose.width), 'xlabel', 'Dose Rate (Gy/min)', ...
                'type', type, 'volume', volume);
        else
            Event('Histogram not plotted as dose rate data does not exist');
        end
        
    % BED histogram
    case 5
        
        % Log plot selection
        Event('BED histogram selected');
        
        % If a DVHViewer object exists, update it with the planned dose
        if isfield(handles, 'histogram') && isfield(handles, 'bed') && ...
                isfield(handles.bed, 'variable')
           
            handles.histogram.Calculate('doseA', ...
                struct('data', handles.bed.variable, 'width', ...
                handles.dose.width), 'xlabel', ...
                'Variable Dose Rate Biologically Effective Dose (Gy)', ...
                'type', type, 'volume', volume);
        else
            Event('Histogram not plotted as BED data does not exist');
        end
        
    % Instantaneous BED histogram
    case 6
        
        % Log plot selection
        Event('Instantaneous BED histogram selected');
        
        % If a DVHViewer object exists, update it with the planned dose
        if isfield(handles, 'histogram') && isfield(handles, 'bed') && ...
                isfield(handles.bed, 'instant')
           
            handles.histogram.Calculate('doseA', ...
                struct('data', handles.bed.instant, 'width', ...
                handles.dose.width), 'xlabel', ...
                'Equivalent Instantaneous Dose BED (Gy)', ...
                'type', type, 'volume', volume);
        else
            Event('Histogram not plotted as BED data does not exist');
        end
        
    % Continuous BED histogram
    case 7
        
        % Log plot selection
        Event('Continuous BED histogram selected');
        
        % If a DVHViewer object exists, update it with the planned dose
        if isfield(handles, 'histogram') && isfield(handles, 'bed') && ...
                isfield(handles.bed, 'continuous')
           
            handles.histogram.Calculate('doseA', ...
                struct('data', handles.bed.continuous, 'width', ...
                handles.dose.width), 'xlabel', ...
                'Equivalent Continuous Dose Rate BED (Gy)', ...
                'type', type, 'volume', volume);
        else
            Event('Histogram not plotted as BED data does not exist');
        end
        
    % Equivalent Continuous Dose Rate histogram
    case 8
        
        % Log plot selection
        Event('Equivalent continuous dose rate histogram selected');
        
        % If a DVHViewer object exists, update it
        if isfield(handles, 'histogram') && isfield(handles, 'bed') && ...
                isfield(handles.bed, 'equivdr')
           
            handles.histogram.Calculate('doseA', ...
                struct('data', handles.bed.equivdr * 60, 'width', ...
                handles.dose.width), 'xlabel', ...
                'Equivalent Continuous Dose Rate (Gy/min)', ...
                'type', type, 'volume', volume);
        else
            Event('Histogram not plotted as BED data does not exist');
        end
end

% Clear temporary variables
clear type volume s modes s;

% Log completion
Event(sprintf('Plot updated successfully in %0.3f seconds', toc));

% Catch errors, log, and rethrow
catch err
    Event(getReport(err, 'extended', 'hyperlinks', 'off'), 'ERROR');
end

% Return the handles object
varargout{1} = handles;