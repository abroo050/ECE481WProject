classdef AI < matlab.apps.AppBase
    % Properties that correspond to app components
    properties (Access = public)
        ITSAskAIPanel         matlab.ui.container.Panel
        MainAppHandle         matlab.apps.AppBase
        ParentPanel           matlab.ui.container.Panel % <-- NEW: the parent container
        ContainerPanel        matlab.ui.container.Panel
        SendQuestionButton    matlab.ui.control.Button
        EditField             matlab.ui.control.TextArea
        TextArea              matlab.ui.control.TextArea
    end
    
    methods (Access = private)
        
        function onAIClose(app)
            % If embedded, no separate window to close, so maybe just cleanup
            if ~isempty(app.MainAppHandle) && isvalid(app.MainAppHandle)
                app.MainAppHandle.AIAppHandle = [];
                app.MainAppHandle.OpenAIButton.Text = 'Open AI';
            end
            % Delete components if needed
            delete(app);
        end

    end

    % Callbacks that handle component events
    methods (Access = private)
        % Button pushed function: SendQuestionButton
        function SendQuestionButtonPushed(app, event)
            %% 1. Get user input
% Get user input
UserInput = app.EditField.Value;

% Add user message and "Thinking..." to the conversation
app.TextArea.Value = [app.TextArea.Value ; "User: " + UserInput + newline + "AI: Thinking..." + newline];

% Save the current conversation before adding new message
currentText = app.TextArea.Value;

% Clear input field
app.EditField.Value = '';

% Force UI update
drawnow;

%% 2. API configuration
api_key = 'AIzaSyB4OFCdPCrOIrDAVPcVC0OwzJF2NiM-DaE';

%% 3. Models
model_name = 'gemini-2.5-flash';

try
    % Build the API URL
    api_url = ['https://generativelanguage.googleapis.com/v1beta/models/',model_name, ':generateContent?key=', api_key];
    
    % Create the request data
    requestBody = struct(...
        'contents', struct(...
            'parts', struct(...
                'text', UserInput ... % User's question
            ) ...
        ) ...
    );
    
    % Set up request options
    options = weboptions(...
        'RequestMethod', 'post', ...      % POST request
        'MediaType', 'application/json', ... % JSON data
        'Timeout', 30 ...                 % 30 second timeout
    );
    
    % Send request to AI API
    response = webwrite(api_url, requestBody, options);
    
    % Check if we got a good response
    if isfield(response, 'candidates') && ~isempty(response.candidates)
        % Get the AI's answer text
        generatedText = response.candidates(1).content.parts.text;
  
        % REPLACE ONLY THE "Thinking..." PART, KEEP THE REST
        % currentText = app.TextArea.Value;
        updatedText = strrep(currentText, 'Thinking...', generatedText);
        app.TextArea.Value = updatedText;
        
    end
    
catch ME
    % REPLACE ONLY THE "Thinking..." PART WITH ERROR MESSAGE
    % currentText = app.TextArea.Value;
    updatedText = strrep(currentText, 'Thinking...', ['Error: ' ME.message]);
    app.TextArea.Value = updatedText;
end
        end
    end

    % Component initialization
    methods (Access = private)
        % Create UI components inside ParentPanel
        function createComponents(app, parent)
            app.ParentPanel = parent; % store reference
            
            % Create ITSAskAIPanel inside parent panel
            app.ITSAskAIPanel = uipanel(app.ParentPanel);
            app.ITSAskAIPanel.ForegroundColor = [1 1 1];
            app.ITSAskAIPanel.TitlePosition = 'centertop';
            app.ITSAskAIPanel.Title = 'ITS Ask AI';
            app.ITSAskAIPanel.BackgroundColor = [1, 1, 1];
            app.ITSAskAIPanel.FontWeight = 'bold';
            app.ITSAskAIPanel.FontSize = 14;
            app.ITSAskAIPanel.Position = [0 0 app.ParentPanel.Position(3) app.ParentPanel.Position(4)]; % Fill parent panel
            
            % Create TextArea inside ITSAskAIPanel
            app.TextArea = uitextarea(app.ITSAskAIPanel);
            app.TextArea.FontColor = [1 1 1];
            app.TextArea.BackgroundColor = [0 0.1882 0.3412];
            app.TextArea.Position = [14 96 438 393];

            % Create EditField inside ITSAskAIPanel
            app.EditField = uitextarea(app.ITSAskAIPanel);
            app.EditField.FontColor = [1 1 1];
            app.EditField.BackgroundColor = [0 0.1882 0.3412];
            app.EditField.Position = [17 44 435 37];

            % Create SendQuestionButton inside ITSAskAIPanel
            app.SendQuestionButton = uibutton(app.ITSAskAIPanel, 'push');
            app.SendQuestionButton.ButtonPushedFcn = createCallbackFcn(app, @SendQuestionButtonPushed, true);
            app.SendQuestionButton.BackgroundColor = [0 0.1882 0.3412];
            app.SendQuestionButton.FontColor = [1 1 1];
            app.SendQuestionButton.Position = [352 11 100 23];
            app.SendQuestionButton.Text = 'Send Question';
        end
    end

    % App creation and deletion
    methods (Access = public)
        % Construct app with a parent container input
        function app = AI(parentPanel)
            app.ParentPanel = parentPanel;  % Store the parent panel handle

            % Create the container panel inside parentPanel
            app.ContainerPanel = uipanel(app.ParentPanel);
            app.ContainerPanel.Position = [0 0 app.ParentPanel.Position(3) app.ParentPanel.Position(4)];
            app.ContainerPanel.BackgroundColor = [0 0.1882 0.3412];

            % Now create all controls inside ContainerPanel
            createComponents(app, app.ContainerPanel);

            registerApp(app, app.ContainerPanel);

            if nargout == 0
                clear app
            end
        end


        % Code that executes before app deletion
        function delete(app)
            % Delete components explicitly
            if isvalid(app.ITSAskAIPanel)
                delete(app.ITSAskAIPanel)
            end
        end
    end
end
