function varargout = plateCapture(varargin)
% PLATECAPTURE MATLAB code for platecapture.fig
%      PLATECAPTURE, by itself, creates a new PLATECAPTURE or raises the existing
%      singleton*.
%
%      H = PLATECAPTURE returns the handle to a new PLATECAPTURE or the handle to
%      the existing singleton*.
%
%      PLATECAPTURE('CALLBACK',hObject,eventData,handles,...) calls the local
%      function named CALLBACK in PLATECAPTURE.M with the given input arguments.
%
%      PLATECAPTURE('Property','Value',...) creates a new PLATECAPTURE or raises the
%      existing singleton*.  Starting from the left, property value pairs are
%      applied to the GUI before plateCapture_OpeningFcn gets called.  An
%      unrecognized property name or invalid value makes property application
%      stop.  All inputs are passed to plateCapture_OpeningFcn via varargin.
%
%      *See GUI Options on GUIDE's Tools menu.  Choose "GUI allows only one
%      instance to run (singleton)".
%
% See also: GUIDE, GUIDATA, GUIHANDLES

% Edit the above text to modify the response to help platecapture

% Last Modified by GUIDE v2.5 30-May-2014 13:38:34

% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @plateCapture_OpeningFcn, ...
                   'gui_OutputFcn',  @plateCapture_OutputFcn, ...
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


% --- Executes just before platecapture is made visible.
function plateCapture_OpeningFcn(hObject, eventdata, handles, varargin)
% This function has no output args, see OutputFcn.
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% varargin   command line arguments to platecapture (see VARARGIN)

% Choose default command line output for platecapture
handles.output = hObject;

% Create video object
% Putting the object into manual trigger mode and then
% starting the object will make GETSNAPSHOT return faster
% since the connection to the camera will already have
% been established.
handles.video = videoinput('winvideo', 1, 'RGB24_1600x1200');
axesHandle = findobj(gcf,'Tag','cameraAxes');
vidRes = get(handles.video, 'VideoResolution');
imWidth = vidRes(1);
imHeight = vidRes(2);
nBands = get(handles.video, 'NumberOfBands');
hImage = image(zeros(imHeight, imWidth, nBands), 'parent', axesHandle);
preview(handles.video, hImage);

triggerconfig(handles.video,'manual');
set(handles.video,'TimerPeriod',1); %trigger every 1 second
set(handles.video,'FramesPerTrigger',5); %every 1 second, take 5 frames
set(handles.captureImage,'Enable','on');

% Update handles structure
guidata(hObject, handles);

% UIWAIT makes platecapture wait for user response (see UIRESUME)
uiwait(handles.myCameraGUI);


% --- Outputs from this function are returned to the command line.
function varargout = plateCapture_OutputFcn(hObject, eventdata, handles)
% varargout cell array for returning output args (see VARARGOUT);
% hObject handle to figure
% eventdata reserved - to be defined in a future version of MATLAB
% handles structure with handles and user data (see GUIDATA)

% Get default command line output from handles structure
handles.output = hObject;
varargout{1} = handles.output;
    

% --- Executes on button press in captureImage.
function captureImage_Callback(hObject, eventdata, handles)
% hObject    handle to captureImage (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% frame = getsnapshot(handles.video);

set(handles.text3,'String','Acquiring!')
set(handles.text3,'ForegroundColor',[1,0,0])
%% Trigger Code
% for i=1:5
%     start(handles.video)
%     trigger(handles.video);
%     rgbImage{i} = rgb2gray(getdata(handles.video));
%     pause(1)
% end
%% Snapshot code

%determine file name
dirName=get(handles.edit1,'String');
wellNum=get(handles.edit2,'String');
if ~(exist([dirName, filesep, wellNum])==7)
    mkdir([dirName, filesep, wellNum])
end
t=clock;
timeStamp=strjoin(arrayfun(@(x) num2str(x),t,'uniform',0),'-');
files=dir([dirName, filesep, wellNum, filesep, '*.mat']);
if isempty(files)
    lastFile=0;
else
    files={files.name};
    lastFile=max(cellfun(@(x) str2num(x{1}),cellfun(@(x) strsplit(x,'-'),files,'uniform',0)));
end
newFile=[num2str(lastFile+1),'-',timeStamp,'.mat'];
newFileJPG=[num2str(lastFile+1),'-',timeStamp,'.jpg'];

if ~isrunning(handles.video)
    start(handles.video)
end
for i=1:10
    rgbImage(:,:,i) = rgb2gray(getsnapshot(handles.video));
    t=clock;
    timeStamp=strjoin(arrayfun(@(x) num2str(x),t,'uniform',0),'-');
    newFileJPG=[num2str(lastFile+1),'-',timeStamp,'.jpg'];
    imwrite(rgbImage(:,:,i),[dirName, filesep, wellNum, filesep, newFileJPG])
    pause(0.5)
end


set(handles.text3,'String','Done')
set(handles.text3,'ForegroundColor',[0,0,0])
save('testframe.mat','rgbImage');
save([dirName, filesep, wellNum, filesep, newFile],'rgbImage')
set(handles.text3,'String','Waiting...')
set(handles.edit2,'String',str2num(get(handles.edit2,'String'))+1)

%%test
% bg=median(rgbImage,3);
% ov=imoverlay(rgbImage(:,:,1), mat2gray(bg-rgbImage(:,:,20))>0.1,[1,0,0]);
% imshow(ov)
%
% --- Executes when user attempts to close plateCapture.
function myCameraGUI_CloseRequestFcn(hObject, eventdata, handles)
% hObject    handle to plateCapture (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: delete(hObject) closes the figure
delete(hObject);
delete(imaqfind);



function edit1_Callback(hObject, eventdata, handles)
% hObject    handle to edit1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of edit1 as text
%        str2double(get(hObject,'String')) returns contents of edit1 as a double
if ~exist(get(hObject,'String'))==7
    mkdir(get(hObject,'String'))
end

% --- Executes during object creation, after setting all properties.
function edit1_CreateFcn(hObject, eventdata, handles)
% hObject    handle to edit1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function edit2_Callback(hObject, eventdata, handles)
% hObject    handle to edit2 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of edit2 as text
%        str2double(get(hObject,'String')) returns contents of edit2 as a double


% --- Executes during object creation, after setting all properties.
function edit2_CreateFcn(hObject, eventdata, handles)
% hObject    handle to edit2 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end
