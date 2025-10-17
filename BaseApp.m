classdef BaseApp < handle
    % A component class designed to be embedded within a parent container (Panel or Figure)
    
    properties (Access = public)
        % Main container that is parented to the external panel (ECEITSPanel)
        TopLevelLayout                  matlab.ui.container.GridLayout
        
        % Components from the original design
        Base                            matlab.ui.container.Panel
        GridLayout_2                    matlab.ui.container.GridLayout
        ExplorediversesubjectsacrossECEcoursesLabel  matlab.ui.control.Label
        FundumentalsofComupterEngineeringButton  matlab.ui.control.Button
        CircuitsAnalysisIIButton        matlab.ui.control.Button
        CircuitsAnalysisIButton         matlab.ui.control.Button
        ActionDropDown                  matlab.ui.control.DropDown
        GetstartedwithinteractivelearningLabel  matlab.ui.control.Label
        ECEIntelegentTutoringSystemCompanionLabel  matlab.ui.control.Label
        Image                           matlab.ui.control.Image
    end
    
    % Constructor and Deletion Logic
    methods (Access = public)
        
        % The single class constructor: accepts the parent container
        function app = BaseApp(parentPanel)
            
            % 1. Create the Top-Level Layout and parent it to the input 'parentPanel'
            app.TopLevelLayout = uigridlayout(parentPanel);
            app.TopLevelLayout.ColumnWidth = {'1x'};
            app.TopLevelLayout.RowHeight = {100, '1x'}; 
            app.TopLevelLayout.Padding = [10 10 10 10];
            
            % 2. Initialize the rest of the UI inside the layout
            % Pass the TopLevelLayout as the parent for subsequent components
            app.createComponents(app.TopLevelLayout);
            
            if nargout == 0
                clear app
            end
        end
        
        % Code that executes before app deletion
        function delete(app)
            % Delete the top-level layout, which automatically deletes all children
            if isvalid(app.TopLevelLayout)
                delete(app.TopLevelLayout);
            end
        end
    end
    
    % Component Initialization and Callbacks
    methods (Access = private)
        
        % Component initialization: now accepts the parent layout
        function createComponents(app, parentLayout)
            % Get the file path for locating images
            pathToMLAPP = fileparts(mfilename('fullpath'));
            
            % --- Row 1: Image and Title ---
            
            % Create a dedicated grid for the header
            headerGrid = uigridlayout(parentLayout);
            headerGrid.Layout.Row = 1;
            headerGrid.Layout.Column = 1;
            headerGrid.ColumnWidth = {100, '1x'};
            headerGrid.RowHeight = {'1x'};
            headerGrid.RowSpacing = 0;
            headerGrid.ColumnSpacing = 10;
            headerGrid.Padding = [0 0 0 0];
            headerGrid.BackgroundColor = parentLayout.BackgroundColor;
            
            % 2. Create ECEIntelegentTutoringSystemCompanionLabel (Parented to headerGrid)
            app.ECEIntelegentTutoringSystemCompanionLabel = uilabel(headerGrid);
            app.ECEIntelegentTutoringSystemCompanionLabel.WordWrap = 'on';
            app.ECEIntelegentTutoringSystemCompanionLabel.FontSize = 24;
            app.ECEIntelegentTutoringSystemCompanionLabel.FontWeight = 'bold';
            app.ECEIntelegentTutoringSystemCompanionLabel.Layout.Row = 1;
            app.ECEIntelegentTutoringSystemCompanionLabel.Layout.Column = 2;
            app.ECEIntelegentTutoringSystemCompanionLabel.Text = 'ECE Intelligent Tutoring System Companion ';
            app.ECEIntelegentTutoringSystemCompanionLabel.VerticalAlignment = 'bottom';
            app.ECEIntelegentTutoringSystemCompanionLabel.FontColor = [0.00 0.45 0.74];

            % --- Row 2: Main Content Grid ---
            
            % 3. Create Main Content Panel (Base)
            app.Base = uipanel(parentLayout);
            app.Base.Layout.Row = 2;
            app.Base.Layout.Column = 1;
            app.Base.BorderType = 'none'; % Use borderless panel for cleaner embed
            
            % 4. Create GridLayout_2 inside the Base panel
            app.GridLayout_2 = uigridlayout(app.Base);
            app.GridLayout_2.ColumnWidth = {'1x', '1x', '1x', '1x', '1x', '1x', '1x'};
            app.GridLayout_2.RowHeight = {'1x', 30, 30, 40, 40, 40, 30, 50, 50, '1x'}; % Adjusted row heights for better layout
            app.GridLayout_2.BackgroundColor = [0.8118 0.851 0.8706];
            app.GridLayout_2.Padding = [10 10 10 10];

            % --- Content Elements ---
            
            % Get started with interactive learning Label
            app.GetstartedwithinteractivelearningLabel = uilabel(app.GridLayout_2);
            app.GetstartedwithinteractivelearningLabel.FontWeight = 'bold';
            app.GetstartedwithinteractivelearningLabel.Layout.Row = 2;
            app.GetstartedwithinteractivelearningLabel.Layout.Column = [1 3];
            app.GetstartedwithinteractivelearningLabel.Text = 'Get started with interactive learning';
            
            % ActionDropDown
            app.ActionDropDown = uidropdown(app.GridLayout_2);
            app.ActionDropDown.Items = {'Select Options...', 'Concept Explorer', 'Dynamic Testing', 'System Design', 'Self-Assesment'};
            app.ActionDropDown.ValueChangedFcn = @(src, event) app.ActionDropDownValueChanged(event);
            app.ActionDropDown.BackgroundColor = [0.9098 0.9294 0.9412];
            app.ActionDropDown.Layout.Row = 4;
            app.ActionDropDown.Layout.Column = [2 6];
            app.ActionDropDown.Value = 'Select Options...';
            
            % Explore diverse subjects label
            app.ExplorediversesubjectsacrossECEcoursesLabel = uilabel(app.GridLayout_2);
            app.ExplorediversesubjectsacrossECEcoursesLabel.FontWeight = 'bold';
            app.ExplorediversesubjectsacrossECEcoursesLabel.Layout.Row = 7;
            app.ExplorediversesubjectsacrossECEcoursesLabel.Layout.Column = [1 4];
            app.ExplorediversesubjectsacrossECEcoursesLabel.Text = 'Explore diverse subjects across ECE courses';
            
            % CircuitsAnalysisIButton
            app.CircuitsAnalysisIButton = uibutton(app.GridLayout_2, 'push');
            app.CircuitsAnalysisIButton.ButtonPushedFcn = @(src, event) app.CircuitsAnalysisIButtonPushed(event);
            app.CircuitsAnalysisIButton.Enable = 'off';
            app.CircuitsAnalysisIButton.Layout.Row = 8;
            app.CircuitsAnalysisIButton.Layout.Column = [2 3];
            app.CircuitsAnalysisIButton.Text = 'Circuits Analysis I';
            app.CircuitsAnalysisIButton.BackgroundColor = [0.00 0.45 0.74];
            app.CircuitsAnalysisIButton.FontColor = [1 1 1];
            
            % CircuitsAnalysisIIButton
            app.CircuitsAnalysisIIButton = uibutton(app.GridLayout_2, 'push');
            app.CircuitsAnalysisIIButton.Enable = 'off';
            app.CircuitsAnalysisIIButton.Layout.Row = 9;
            app.CircuitsAnalysisIIButton.Layout.Column = [2 3];
            app.CircuitsAnalysisIIButton.Text = 'Circuits Analysis II';
            app.CircuitsAnalysisIIButton.BackgroundColor = [0.00 0.45 0.74];
            app.CircuitsAnalysisIIButton.FontColor = [1 1 1];
            
            % FundumentalsofComupterEngineeringButton
            app.FundumentalsofComupterEngineeringButton = uibutton(app.GridLayout_2, 'push');
            app.FundumentalsofComupterEngineeringButton.WordWrap = 'on';
            app.FundumentalsofComupterEngineeringButton.Enable = 'off';
            app.FundumentalsofComupterEngineeringButton.Layout.Row = 8;
            app.FundumentalsofComupterEngineeringButton.Layout.Column = [4 6];
            app.FundumentalsofComupterEngineeringButton.Text = 'Fundamentals of Computer Engineering';
            app.FundumentalsofComupterEngineeringButton.BackgroundColor = [0.00 0.45 0.74];
            app.FundumentalsofComupterEngineeringButton.FontColor = [1 1 1];

        end
        
        % Button pushed function: CircuitsAnalysisIButton
        function CircuitsAnalysisIButtonPushed(app, event)
            action =  app.ActionDropDown.Value;
            if action == "Concept Explorer"
                run('CE_201'); % Assuming CE_201 is a script/app name
            elseif action == "Dynamic Testing"
                run('DT_201'); % Assuming DT_201 is a script/app name
            elseif action == "System Design"
                % run(); % Removed empty run call
            end
        end
        
        % Value changed function: ActionDropDown
        function ActionDropDownValueChanged(app, event)
            value = app.ActionDropDown.Value;
            switch value
                case 'Select Options...'
                    app.CircuitsAnalysisIButton.Enable = 'off';
                    app.CircuitsAnalysisIIButton.Enable = 'off';
                    app.FundumentalsofComupterEngineeringButton.Enable = 'off';
                case 'Self-Assesment'
                    app.CircuitsAnalysisIButton.Enable = 'off';
                    app.CircuitsAnalysisIIButton.Enable = 'off';
                    app.FundumentalsofComupterEngineeringButton.Enable = 'off';
                    run('SA'); % Assuming SA is a script/app name

                otherwise
                    app.CircuitsAnalysisIButton.Enable = 'on';
                    app.CircuitsAnalysisIIButton.Enable = 'on';
                    app.FundumentalsofComupterEngineeringButton.Enable = 'on';
      
            end
        end
    end
end