classdef AI < matlab.apps.AppBase
    % Properties that correspond to app components
    properties (Access = public)
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
            % Your existing AI API code here...
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
            app.ITSAskAIPanel.BackgroundColor = [0 0.1882 0.3412];
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
            createComponents(app);

            registerApp(app, app.ContainerPanel);

            runStartupFcn(app, @startupFcn);

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
