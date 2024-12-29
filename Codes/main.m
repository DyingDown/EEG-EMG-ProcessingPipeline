
global config; 
config = load_config();

% processRawDatas(config.dataBaseFolder, config.startPoint.isPeak);
% eeglab_process(config.dataBaseFolder);

simpleGridUI();

function simpleGridUI
    global config;
    % Create the main UI figure
    hFig = uifigure('Name', 'Grid UI Example', 'Position', [500, 300, 400, 300]);

    % Create the buttons grid layout
    gLayout = uigridlayout(hFig, [3, 2], 'ColumnWidth', {'1x', '1x'}, 'RowHeight', {'1x', '1x', '1x'});

    % Define the running function handle
    runningFunction = []; % Keeps track of the currently running function

    % Create the buttons for specific tasks
    btn1 = uibutton(gLayout, 'Text', 'Manual Correction', ...
        'ButtonPushedFcn', @(~, ~)executeFunction(@manualCorrection, 'Manual Correction'));

    btn2 = uibutton(gLayout, 'Text', 'EEGLAB Preprocessing', ...
        'ButtonPushedFcn', @(~, ~)executeFunction(@eeglabPreprocessing, 'EEGLAB Preprocessing'));

    btn3 = uibutton(gLayout, 'Text', 'Calculate Data', ...
        'ButtonPushedFcn', @(~, ~)executeFunction(@calculateData, 'Calculate Data'));

    btn4 = uibutton(gLayout, 'Text', 'Plot Data', ...
        'ButtonPushedFcn', @(~, ~)executeFunction(@plotData, 'Plot Data'));

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
        disp('Performing manual correction...');
        processRawDatas(config.dataBaseFolder, config.startPoint.isPeak);
    end

    function eeglabPreprocessing
        disp('Running EEGLAB preprocessing...');
        eeglab_process(config.dataBaseFolder);
    end

    function calculateData
        disp('Calculating data...');
        calcC3C4(config.dataBaseFolder);
    end

    function plotData
        disp('Plotting data...');
        plot_cohere(config.dataBaseFolder);
    end
end
