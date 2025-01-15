clear

global config runningFunction; 
config = load_config();

% processRawDatas(config.dataBaseFolder, config.startPoint.isPeak);
% eeglab_process(config.dataBaseFolder);

simpleGridUI();

function simpleGridUI
    global config runningFunction;
    % Create the main UI figure
    hFig = uifigure('Name', 'Grid UI Example', 'Position', [500, 300, 400, 400]);  % Increase height for 4 rows

    % Create the buttons grid layout (change the rows to 4)
    gLayout = uigridlayout(hFig, [4, 2], 'ColumnWidth', {'1x', '1x'}, 'RowHeight', {'1x', '1x', '1x', '1x'});  % Change rows to 4

    % Define the running function handle
    runningFunction = []; % Keeps track of the currently running function

    % Create the buttons for specific tasks
    btn1 = uibutton(gLayout, 'Text', 'Point Info Man Corr', ...  % Changed to 'Pnt Man Corr'
        'ButtonPushedFcn', @(~, ~)executeFunction(@manualCorrection, 'Pnt Man Corr'));  % Adjust function name here

    btn2 = uibutton(gLayout, 'Text', 'EEGLAB Preprocessing', ...
        'ButtonPushedFcn', @(~, ~)executeFunction(@eeglabPreprocessing, 'EEGLAB Preprocessing'));

    btn3 = uibutton(gLayout, 'Text', 'Calculate Data', ...
        'ButtonPushedFcn', @(~, ~)executeFunction(@calculateData, 'Calculate Data'));

    btn4 = uibutton(gLayout, 'Text', 'Plot Data', ...
        'ButtonPushedFcn', @(~, ~)executeFunction(@plotData, 'Plot Data'));

    % New button for plotting average data, placed in the third row
    btn5 = uibutton(gLayout, 'Text', 'Plot Coh Avg', ...
        'ButtonPushedFcn', @(~, ~)executeFunction(@plotCohAvg, 'Plot Coh Avg'));

    % Create a terminate button
    terminateBtn = uibutton(gLayout, 'Text', 'Terminate', 'ButtonPushedFcn', @terminateCurrentFunction);

    % Create an exit button
    exitBtn = uibutton(gLayout, 'Text', 'Exit', 'ButtonPushedFcn', @exitApplication);

    waitfor(hFig);

    % Callback to execute the function
    function executeFunction(func, funcName)
        if ~isempty(runningFunction)
            uialert(hFig, sprintf('Currently running %s. Please terminate it first.', runningFunction.Name), 'Function Running');
            return;
        end
        runningFunction = struct('Handle', func, 'Name', funcName);
        disp(['Started ', funcName]);
        pause(1); % Simulate processing delay for demo purposes
        runningFunction.Handle();
        disp(['Completed ', funcName]);
        runningFunction = [];
    end

    % Callback to terminate the current function
    function terminateCurrentFunction(~, ~)
        if isempty(runningFunction)
            uialert(hFig, 'No function is currently running.', 'No Running Task');
            return;
        end
        response = uiconfirm(hFig, sprintf('Currently running %s. Do you want to terminate it?', runningFunction.Name), ...
            'Confirm Termination', 'Options', {'Yes', 'No'}, 'DefaultOption', 'No');
        if strcmp(response, 'Yes')
            disp(['Terminating ', runningFunction.Name]);
            runningFunction = [];
        end
        close all;
         % Find all open figures
        allFigures = findall(0, 'Type', 'figure');  % Find all figure handles
        
        % Filter out the main UI figure (hFig) from the list
        figuresToClose = allFigures(allFigures ~= hFig);
        
        % Close the filtered figures
        close(figuresToClose);
    end

    % Callback to exit the application
    function exitApplication(~, ~)
        if ~isempty(runningFunction)
            response = uiconfirm(hFig, sprintf('Currently running %s. Do you want to terminate it and exit?', runningFunction.Name), ...
                'Confirm Exit', 'Options', {'Yes', 'No'}, 'DefaultOption', 'No');
            if strcmp(response, 'No')
                return;
            end
        end
        disp('Exiting application...');
        close all;
        delete(hFig);
        allFigures = findall(0, 'Type', 'figure');  % Find all figure handles
        close(allFigures);  % Close all figures
    end

    % Dummy functions for the tasks
    function manualCorrection
        disp('Performing Pnt Man Corr...');
        processRawDatas(config.dataBaseFolder, config.startPoint.isPeak);  % Assuming this function exists elsewhere
    end

    function eeglabPreprocessing
        disp('Running EEGLAB preprocessing...');
        eeglab_process(config.dataBaseFolder);  % Assuming this function exists elsewhere
    end

    function calculateData
        disp('Calculating data...');
        calcC3C4(config.dataBaseFolder);  % Assuming this function exists elsewhere
    end

    function plotData
        disp('Plotting data...');
         plotCohAvg();  % Assuming this function exists elsewhere
    end

end
