classdef quiz < handle
    properties
        MainApp
        numQuestions
        timed logical
        difficulty string
        questions struct   % array of structs: {question, answer, choices}
        currentIndex = 1
        score = 0
        startTime datetime
        AIHelper          % reference to AI class
        Main
    end

    methods
        function obj = Quiz(aiHelper)
            obj.AIHelper = aiHelper;
        end

        function setMainApp(app, mainAppHandle)
            app.MainApp = mainAppHandle;
        end

        function launchQuiz(app)
    % Ensure AIAppHandle is valid
    if isempty(app.MainApp.AIAppHandle) || ~isvalid(app.MainApp.AIAppHandle)
        error('AI app not available.');
    end
    
    % --- Step 1: Ask for quiz length ---
    lengthPrompt = [
        "How long would you like the quiz to be?" + newline + ...
        "1) Short (5 questions)" + newline + ...
        "2) Medium (10 questions)" + newline + ...
        "3) Long (15 questions)"
    ];
    app.MainApp.AIAppHandle.postMessage(lengthPrompt);
    
    % Store mode so next input goes to quiz configuration
    app.MainApp.AIAppHandle.toggleMode("QUIZ");  
    app.MainApp.AIAppHandle.nextQuizStep = "length";  

    % --- Step 2: Ask if they want it timed ---
    % This will be triggered after length is selected
    % Use nextQuizStep = 'timed' after handling length
    % Example message:
    timedPrompt = "Do you want the quiz to be timed? Enter Yes or No.";
    app.MainApp.AIAppHandle.nextQuizStepMessage.timed = timedPrompt;
    
    % --- Step 3: Ask for difficulty ---
    difficultyPrompt = [
        "Select the difficulty level:" + newline + ...
        "1) Easy" + newline + ...
        "2) Medium" + newline + ...
        "3) Hard"
    ];
    app.MainApp.AIAppHandle.nextQuizStepMessage.difficulty = difficultyPrompt;
end


        function setup(obj, numQuestions, difficulty, timed)
            % Set quiz parameters
            obj.numQuestions = numQuestions;
            obj.difficulty = difficulty;
            obj.timed = timed;

            % Generate questions from AI
            obj.generateQuestions();
        end

        function generateQuestions(obj)
            % Ask AI for quiz questions
            % You can loop numQuestions times, or ask AI to return all at once
            obj.questions = obj.AIHelper.getQuizQuestions(obj.numQuestions, obj.difficulty);
        end

        function q = getNextQuestion(obj)
            if obj.currentIndex <= obj.numQuestions
                q = obj.questions(obj.currentIndex);
            else
                q = [];
            end
        end

        function correct = answerCurrent(obj, studentAnswer)
            correctAnswer = obj.questions(obj.currentIndex).answer;
            correct = strcmpi(studentAnswer, correctAnswer);

            if correct
                obj.score = obj.score + 1;
            end

            obj.currentIndex = obj.currentIndex + 1;
        end

        function finished = isFinished(obj)
            finished = obj.currentIndex > obj.numQuestions;
        end

        function reset(obj)
            obj.currentIndex = 1;
            obj.score = 0;
        end
    end
end