%% imageBatchProcessorによるバッチ処理

%% サンプルデータの生成
%     JPEGは、1ビットイメージに非対応
[~,~,~] = mkdir('I2_13_MRIdata');
d = load('mri.mat');
image = squeeze(d.D);    %大きさ1の第3次元を削除
for ind = 1:size(image,3)
    fileName = sprintf('Slice%02d.tif',ind);
    imwrite(image(:,:,ind),fullfile('I2_13_MRIdata', fileName));
end

%% imageBatchProcessor    コマンド
imageBatchProcessor
% もしくは、アプリケーション タブから、イメージのバッチ処理用 アプリケーションの起動

%% バッチ処理
% "イメージの取り込み"ボタンで、画像が入っているフォルダ I2_13_MRIdata を指定
% "関数名"に、  I2_13_batchProcess.m  を指定
% 先ず、数枚選択し、"選択対象を処理" を実行し、結果の確認(拡大も可)
% 全てを実行（Parallel Computing Toolboxがあれば、並列処理可能）
% パラメータを使用したい場合は、global 変数等を使用

% Copyright 2018 The MathWorks, Inc.