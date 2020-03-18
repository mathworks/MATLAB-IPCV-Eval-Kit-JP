classdef I5_02_CarDetection < vision.labeler.AutomationAlgorithm
    % Copyright 2018 The MathWorks, Inc.
    
    %----------------------------------------------------------------------
    % Step 1: アルゴリズムの説明の記述
    properties(Constant)
        
        % Name: アルゴリズム名
        Name = '車検出器';
        
        % Description: 1行のアルゴリズム説明
        Description = '車検出アルゴリズム';
        
        % UserDirections: 実行するときの各ステップの説明。
        %                 セル配列の各要素が1つのステップに該当。
        UserDirections = {...
            ['学習済みのカスケード検出器を使ったラベリングを行います']};
        
    end
    
    %---------------------------------------------------------------------
    % Step 2: アルゴリズム実行中に保持するプロパティを定義
    properties
        
        %------------------------------------------------------------------
        % Place your code here
        %------------------------------------------------------------------
        mydetector
        
    end
    
    %----------------------------------------------------------------------
    % Step 3: アルゴリズム実行のための初期化
    methods
        % a) ラベルのチェック(必要なラベルがあるかないか)
        function isValid = checkLabelDefinition(algObj, labelDef)
            
            disp(['Executing checkLabelDefinition on label definition "' labelDef.Name '"'])
            
            %--------------------------------------------------------------
            % Place your code here
            %--------------------------------------------------------------
            isValid = true;
                        
        end
        
        % b) アルゴリズムの準備が完了しているかどうか
        function isReady = checkSetup(algObj)
            
            disp('Executing checkSetup')
            
            %--------------------------------------------------------------
            % Place your code here
            %--------------------------------------------------------------
            algObj.mydetector = vision.CascadeObjectDetector('I5_02_carDetector_20151015Bb.xml');
            isReady = true;
            
            
        end
        
        % c) オプションで設定項目を追加することもできる
        %    (設定ボタンをクリックしたときの動作)
        function settingsDialog(algObj)
            
            disp('Executing settingsDialog')
            
            %--------------------------------------------------------------
            % Place your code here
            %--------------------------------------------------------------
         
            
        end
    end
    
    %----------------------------------------------------------------------
    % Step 4: 実行するアルゴリズムの記述
    methods
        % a) アルゴリズムの初期化
        function initialize(algObj, I)
            
            disp('Executing initialize on the first image frame')
            
            %--------------------------------------------------------------
            % Place your code here
            %--------------------------------------------------------------
            
        end
        
        % b) 実行ボタンをクリックしたときの動作
        function autoLabels = run(algObj, I)
            
            disp('Executing run on image frame')
            
            %--------------------------------------------------------------
            % Place your code here
            %--------------------------------------------------------------
            
            bboxes = step(algObj.mydetector,I);
            if ~isempty(bboxes)
                for k = 1:size(bboxes,1)
                    autoLabels(k).Name = 'car'; %#ok<*AGROW>
                    autoLabels(k).Type = labelType('Rectangle');
                    autoLabels(k).Position = bboxes(k,:);
                end
            end
            
        end
        
        % c) 終了時の動作
        function terminate(algObj)
            
            disp('Executing terminate')
            
            %--------------------------------------------------------------
            % Place your code here
            %--------------------------------------------------------------
            
            
        end
    end
end