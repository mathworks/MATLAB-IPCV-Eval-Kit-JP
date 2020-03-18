function varargout = thresholding(varargin)
% THRESHOLDING1 MATLAB code for thresholding1.fig
%      THRESHOLDING1, by itself, creates a new THRESHOLDING1 or raises the existing
%      singleton*.
%
%      H = THRESHOLDING returns the handle to a new THRESHOLDING1 or the handle to
%      the existing singleton*.
%
%      THRESHOLDING('CALLBACK',hObject,eventData,handles,...) calls the local
%      function named CALLBACK in THRESHOLDING.M with the given input arguments.
%
%      THRESHOLDING('Property','Value',...) creates a new THRESHOLDING or raises the
%      existing singleton*.  Starting from the left, property value pairs are
%      applied to the GUI before thresholding1_OpeningFcn gets called.  An
%      unrecognized property name or invalid value makes property application
%      stop.  All inputs are passed to thresholding1_OpeningFcn via varargin.
%
%      *See GUI Options on GUIDE's Tools menu.  Choose "GUI allows only one
%      instance to run (singleton)".
%
% See also: GUIDE, GUIDATA, GUIHANDLES

% Edit the above text to modify the response to help thresholding

% Last Modified by GUIDE v2.5 05-Apr-2013 09:09:23

% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @thresholding_OpeningFcn, ...
                   'gui_OutputFcn',  @thresholding_OutputFcn, ...
                   'gui_LayoutFcn',  [] , ...
                   'gui_Callback',   []);
if nargin && ischar(varargin{1})
    gui_State.gui_Callback = str2func(varargin{1});
end

if nargout
    [varargout{1:nargout}] = gui_mainfcn(gui_State, varargin{:});
else
    gui_mainfcn(gui_State, varargin{:});
end
% End initialization code - DO NOT EDIT


% --- Executes just before thresholding is made visible.
function thresholding_OpeningFcn(hObject, eventdata, handles, varargin)
% This function has no output args, see OutputFcn.
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% varargin   command line arguments to thresholding1 (see VARARGIN)

% Choose default command line output for thresholding1
handles.output = hObject;

%% 立ち上がった時の処理を記述 %%%%%%%%%%%%%%%%%%%%
handles.in      = varargin{1};  % 関数コールの引数から入力画像を取得
imshow(handles.in > 128);       % 初期閾値(128)で2値化画像表示

% Update handles structure
guidata(hObject, handles);

% figureが消されるか、uiresume関数が実行されるまで待つ
% uiwait(handles.figure1);


% --- Outputs from this function are returned to the command line.
function varargout = thresholding_OutputFcn(hObject, eventdata, handles) 
% varargout  cell array for returning output args (see VARARGOUT);
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Get default command line output from handles structure
varargout{1} = handles.output;



% --- Executes on slider movement.
function slider1_Callback(hObject, eventdata, handles)
% hObject    handle to slider1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'Value') returns position of slider
%        get(hObject,'Min') and get(hObject,'Max') to determine range of slider

%% スライダーを動かした際の動作を記述 %%%%%%%%%%%%%%%%%%%
svalue = get(hObject,'Value');         % スライダーの値を取得
set(handles.text2, 'string', svalue);  % スライダー値を表示
handles.I = handles.in > svalue;       % 2値画像を生成
imshow(handles.I);                     % 2値画像を表示
guidata(hObject, handles);     % 保持している生成画像をUpdate

% --- Executes during object creation, after setting all properties.
function slider1_CreateFcn(hObject, eventdata, handles)
% hObject    handle to slider1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: slider controls usually have a light gray background.
if isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor',[.9 .9 .9]);
end

% --- Executes on button press in pushbutton1.
function pushbutton1_Callback(hObject, eventdata, handles)
% hObject    handle to pushbutton1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

%% Done ボタンを押したときの動作を記述
% MATLABのワークスペース（'base'）へ、OUTという変数名で保存
assignin('base', 'OUT', handles.I);

% Copyright 2018 The MathWorks, Inc.