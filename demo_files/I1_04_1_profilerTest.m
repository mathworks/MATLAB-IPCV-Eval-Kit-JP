%% デバッグ機能の紹介
% エディターツールストリップの、"実行および時間の計測" を実行
% プロファイラーの関数の名前をクリックしてカバレッジを確認


function profilerTest()

  I = magic(1000);
  a = 0;
  for i=1:10
      I = myMult(I, 1.1);
      a = a + max(I(:));
  end
  
  if  numel(I) == 20       % Iの要素数
      I=magic(1000);       % 実行されない行
  end
end

function c = myMult(a, b)
  d = a + 1;
  c = d * b;
end




% 現在のフォルダーの"下矢印" => レポート => カバレッジレポート でも表示可

% Copyright 2014 The MathWorks, Inc.
