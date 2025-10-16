classdef AskAI < handle
    % A component class designed to be embedded within a parent container (Panel or Figure)
    
    properties (Access = public)
        AskAIPanel          matlab.ui.container.Panel
        SendButton          matlab.ui.control.Button
        UserTextArea        matlab.ui.control.TextArea
        AiResponse          matlab.ui.control.TextArea
        
        TopLevelGridLayout  matlab.ui.container.GridLayout 
        Image               matlab.ui.control.Image
        
        ParentPanel         matlab.ui.container.Container 
    end

    properties (Access = private)
        % Stores the conversation history for API calls (struct array)
        ConversationHistory 
    end
    
    properties (Constant, Access = private)
        % Updated to use plain text prefix
        THINKING_PLACEHOLDER = "AI Tutor: Thinking..."; 
    end
    
    methods (Access = private)
        % Button pushed function: SendButton
        function SendButtonPushed(app, ~)
            % Get user input and ensure it's a string
            UserInput = string(app.UserTextArea.Value);

            if strlength(strtrim(UserInput)) == 0
                return;
            end

            % --- Step 1: Prepare History State and Update UI ---
            
            % Prepare user message struct for API history state
            userMessageStruct = struct( ...
                "role", "user", ...
                "parts", {struct("text", UserInput)} ...
            );
            
            % Add user message to state history
            app.ConversationHistory{end+1} = userMessageStruct;
            
            % Update UI display (including the '---' separator)
            newMessageBlock = "Student: " + UserInput + newline + app.THINKING_PLACEHOLDER + newline;
            previousConversation = string(app.AiResponse.Value);
            
            % Append new message block to conversation
            if isempty(previousConversation) || contains(previousConversation, "Welcome!")
                conversation = newMessageBlock;
            else
                conversation = previousConversation + newline + "---" + newline + newMessageBlock;
            end
            
            app.AiResponse.Value = conversation;
            app.UserTextArea.Value = '';
            drawnow;

            % --- Step 2: Call Gemini API using the FULL ConversationHistory ---
            api_key = 'AIzaSyCK_mzSyfbegj89PU0izJx7cZaWSoauhpA'; 
            model_name = 'gemini-2.5-flash';
            api_url = ['https://generativelanguage.googleapis.com/v1beta/models/', model_name, ':generateContent?key=', api_key];

            system_prompt = sprintf([ ...
                'You are an expert Electrical and Computer Engineering tutor. Your role is to teach clearly, patiently, and accurately.\n' ...
                'Keep your explanation beginner-friendly. Use plain text and avoid LaTeX or advanced symbols.' ...
                ]);

            % Pass the entire history array in the contents field
            requestBody = struct( ...
                "contents", {app.ConversationHistory}, ...
                "config", struct( ...
                    "systemInstruction", system_prompt ...
                ) ...
            );

            options = weboptions( ...
                'RequestMethod', 'post', ...
                'MediaType', 'application/json', ...
                'Timeout', 30 ...
            );

            generatedText = "AI Tutor: Error: Failed to connect to AI."; % Default error text

            try
                response = webwrite(api_url, requestBody, options);

                if isfield(response, 'candidates') && ~isempty(response.candidates) && isfield(response.candidates(1).content.parts(1), 'text')
                    rawResponseText = string(response.candidates(1).content.parts(1).text);
                    generatedText = "AI Tutor: " + rawResponseText;

                    % CRITICAL: Add the AI's response to the state history
                    modelMessageStruct = struct( ...
                        "role", "model", ...
                        "parts", {struct("text", rawResponseText)} ...
                    );
                    app.ConversationHistory{end+1} = modelMessageStruct;
                    
                else
                    generatedText = "AI Tutor: No valid response received from the model.";
                end
            catch ME
                generatedText = "AI Tutor: Error: Request failed (" + ME.message + "). Check API key or network connection.";
            end

            % --- Step 3: Final UI Update ---
            currentDisplay = string(app.AiResponse.Value);
            
            % Replace the specific placeholder block in the conversation history
            updatedConversation = strrep(currentDisplay, app.THINKING_PLACEHOLDER, generatedText);

            % Final update of the display
            app.AiResponse.Value = updatedConversation;
        end

        % Create components attached to the parent panel
        function createComponents(app, parent)
            
            pathToMLAPP = fileparts(mfilename('fullpath'));
            
            % 1. Create Top Level Grid
            app.TopLevelGridLayout = uigridlayout(parent);
            app.TopLevelGridLayout.ColumnWidth = {'1x'};
            app.TopLevelGridLayout.RowHeight = {50, '1x'}; 
            app.TopLevelGridLayout.Padding = [10 10 10 10];
            app.TopLevelGridLayout.BackgroundColor = parent.BackgroundColor; 

            % 2. Create Image (Row 1)
            app.Image = uiimage(app.TopLevelGridLayout);
            app.Image.Layout.Row = 1;
            app.Image.Layout.Column = 1;
            app.Image.ImageSource = fullfile(pathToMLAPP, 'college-be-logo-eng.png');
            app.Image.BackgroundColor = app.TopLevelGridLayout.BackgroundColor;

            % 3. Create AskAIPanel (Row 2)
            app.AskAIPanel = uipanel(app.TopLevelGridLayout);
            app.AskAIPanel.TitlePosition = 'centertop';
            app.AskAIPanel.Title = 'ECE Gemini Tutor';
            app.AskAIPanel.BackgroundColor = [1 1 1]; 
            app.AskAIPanel.Layout.Row = 2;
            app.AskAIPanel.Layout.Column = 1;
            app.AskAIPanel.FontWeight = 'bold';
            app.AskAIPanel.FontSize = 14;

            % 4. Create Chat Grid Layout inside the panel
            chatGrid = uigridlayout(app.AskAIPanel);
            chatGrid.ColumnWidth = {'1x', 50}; 
            chatGrid.RowHeight = {'1x', 50}; 
            chatGrid.Padding = [5 5 5 5];
            chatGrid.RowSpacing = 5;
            chatGrid.ColumnSpacing = 5;
            chatGrid.BackgroundColor = [1 1 1]; 

            % 5. Create AiResponse (Chat History)
            app.AiResponse = uitextarea(chatGrid);
            app.AiResponse.Layout.Row = 1;
            app.AiResponse.Layout.Column = [1 2];
            app.AiResponse.Editable = 'off';
            % Set initial welcome message
            app.AiResponse.Value = "AI Tutor: Welcome! Ask me any question about Electrical or Computer Engineering.";
            app.AiResponse.FontSize = 12;
            app.AiResponse.BackgroundColor = [0.96 0.96 0.96]; 

            % 6. Create UserTextArea (Input)
            app.UserTextArea = uitextarea(chatGrid);
            app.UserTextArea.BackgroundColor = [1 1 1];
            app.UserTextArea.Layout.Row = 2;
            app.UserTextArea.Layout.Column = 1;
            app.UserTextArea.FontSize = 12;

            % 7. Create SendButton
            app.SendButton = uibutton(chatGrid, 'push');
            app.SendButton.ButtonPushedFcn = @(~,e) app.SendButtonPushed(e); 
            app.SendButton.BackgroundColor = [0.00 0.45 0.74]; 
            app.SendButton.FontColor = [1 1 1];
            app.SendButton.FontSize = 18;
            app.SendButton.Layout.Row = 2;
            app.SendButton.Layout.Column = 2;
            app.SendButton.Text = '↑'; 
        end
    end
    
    methods (Access = public)
        % Constructor
        function app = AskAI(parentPanel)
            app.ParentPanel = parentPanel;
            
            % Initialize the conversation history here
            app.ConversationHistory = {};
            
            createComponents(app, parentPanel);
            
            app.ParentPanel.Visible = 'on';

            if nargout == 0
                clear app
            end
        end

        % Delete method for clean up
        function delete(app)
            if isvalid(app.TopLevelGridLayout)
                delete(app.TopLevelGridLayout);
            end
        end
    end
end