function varargout = HSV_gui(varargin)
% HSV_GUI MATLAB code for HSV_gui.fig
%      HSV_GUI, by itself, creates a new HSV_GUI or raises the existing
%      singleton*.
%
%      H = HSV_GUI returns the handle to a new HSV_GUI or the handle to
%      the existing singleton*.
%
%      HSV_GUI('CALLBACK',hObject,eventData,handles,...) calls the local
%      function named CALLBACK in HSV_GUI.M with the given input arguments.
%
%      HSV_GUI('Property','Value',...) creates a new HSV_GUI or raises the
%      existing singleton*.  Starting from the left, property value pairs are
%      applied to the GUI before HSV_gui_OpeningFcn gets called.  An
%      unrecognized property name or invalid value makes property application
%      stop.  All inputs are passed to HSV_gui_OpeningFcn via varargin.
%
%      *See GUI Options on GUIDE's Tools menu.  Choose "GUI allows only one
%      instance to run (singleton)".
%
% See also: GUIDE, GUIDATA, GUIHANDLES

% Edit the above text to modify the response to help HSV_gui

% Last Modified by GUIDE v2.5 06-May-2025 11:08:47

% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @HSV_gui_OpeningFcn, ...
                   'gui_OutputFcn',  @HSV_gui_OutputFcn, ...
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


% --- Executes just before HSV_gui is made visible.
function HSV_gui_OpeningFcn(hObject, eventdata, handles, varargin)
% This function has no output args, see OutputFcn.
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% varargin   command line arguments to HSV_gui (see VARARGIN)

% Choose default command line output for HSV_gui
handles.output = hObject;

% Update handles structure
handles.min_H.String='0';
handles.min_H.Value=str2double(handles.min_H.String);

handles.max_H.String='65535';
handles.max_H.Value=str2double(handles.max_H.String);
%%%%%%%%%%%%%%%%%%%%%%%%%
handles.min_S.String='0';
handles.min_S.Value=str2double(handles.min_S.String);

handles.max_S.String='65535';
handles.max_S.Value=str2double(handles.max_S.String);
%%%%%%%%%%%%%%%%%%%%%%%%%
handles.min_V.String='0';
handles.min_V.Value=str2double(handles.min_V.String);

handles.max_V.String='65535';
handles.max_V.Value=str2double(handles.max_V.String);
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
[file,path] = uigetfile('*.*');
H=double(imread([path,'\',file]));

handles.Res=size(H);
%%%%%%%%%%%%%HSV%%%%%%%%%%%%%%%%%%%%%%%%

handles.I=zeros(handles.Res(1),handles.Res(2),3);
handles.II=zeros(handles.Res(1),handles.Res(2),3);
%%%%%%%%%%%%%H%%%%%%%%%%%%%%%%%%%%%%%%
handles.H=100.*randn(handles.Res);
handles.S=100.*randn(handles.Res);
handles.V=100.*randn(handles.Res);
%%%%%%%%%%%%%AXE%%%%%%%%%%%%%%%%%%%%%%%%

axes(handles.axesHSV);
handles.HSV_display=imshow(zeros(handles.Res),'DisplayRange',[0 1],'Parent',handles.axesHSV);
hold off
%%%%%%%%%%%%%%%%%%%%%%%%%HISTO


axes(handles.axesH);
handles.H_display=histogram(handles.H,length(min(min(handles.H)):max(max(handles.H))),...
    'binedges',min(min(handles.H)):max(max(handles.H)),'Parent',handles.axesH);
hold off
% 
axes(handles.axesS);
handles.S_display=histogram(handles.S,length(min(min(handles.S)):max(max(handles.S))),...
    'binedges',min(min(handles.S)):max(max(handles.S)),'Parent',handles.axesS);
hold off
% 
axes(handles.axesV);
handles.V_display=histogram(handles.V,length(min(min(handles.V)):max(max(handles.V))),...
    'binedges',min(min(handles.V)):max(max(handles.V)),'Parent',handles.axesV);
hold off

guidata(hObject, handles);

% UIWAIT makes HSV_gui wait for user response (see UIRESUME)
% uiwait(handles.figure1);


% --- Outputs from this function are returned to the command line.
function varargout = HSV_gui_OutputFcn(hObject, eventdata, handles) 
% varargout  cell array for returning output args (see VARARGOUT);
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Get default command line output from handles structure
varargout{1} = handles.output;


% --- Executes on button press in H_load.
function H_load_Callback(hObject, eventdata, handles)
[file,path] = uigetfile('*.*');
handles.H=double(imread([path,'\',file]));

handles.Res=size(handles.H);

handles.min_H.String=num2str(min(min(handles.H)));
handles.min_H.Value=str2double(handles.min_H.String);


handles.max_H.String=num2str(max(max(handles.H)));
handles.max_H.Value=str2double(handles.max_H.String);

axes(handles.axesH);
handles.H_display=histogram(handles.H,length(min(min(handles.H)):max(max(handles.H))),...
    'binedges',min(min(handles.H)):max(max(handles.H)),'Parent',handles.axesH);
hold off

handles.I(:,:,1)=handles.H;
guidata(hObject, handles);



% --- Executes on button press in S_load.
function S_load_Callback(hObject, eventdata, handles)
[file,path] = uigetfile('*.*');
handles.S=double(imread([path,'\',file]));
handles.Res=size(handles.S);

handles.min_S.String=num2str(min(min(handles.S)));
handles.min_S.Value=str2double(handles.min_S.String);

handles.max_S.String=num2str(max(max(handles.S)));
handles.max_S.Value=str2double(handles.max_S.String);
max(max(handles.S))
min(min(handles.S))
axes(handles.axesS);
% handles.S_display=histogram(handles.S,length(min(min(handles.S)):max(max(handles.S))),...
%     'binedges',min(min(handles.S)):max(max(handles.S)),'Parent',handles.axesS);
handles.S_display=histogram(handles.S,'Parent',handles.axesS);
hold off

handles.I(:,:,2)=handles.S;
guidata(hObject, handles);


% --- Executes on button press in V_load.
function V_load_Callback(hObject, eventdata, handles)
[file,path] = uigetfile('*.*');
handles.V=double(imread([path,'\',file]));
handles.Res=size(handles.V);

handles.min_V.String=num2str(min(min(handles.V)));
handles.min_V.Value=str2double(handles.min_V.String);

handles.max_V.String=num2str(max(max(handles.V)));
handles.max_V.Value=str2double(handles.max_V.String);

axes(handles.axesV);
handles.V_display=histogram(handles.V,'Parent',handles.axesV);
hold off

handles.I(:,:,3)=handles.V;

guidata(hObject, handles);



function min_H_Callback(hObject, eventdata, handles)
handles.min_H.Value=str2double(handles.min_H.String);

handles.H_display=histogram(handles.H,length(handles.min_H.Value:handles.max_H.Value),...
    'binedges',handles.min_H.Value:handles.max_H.Value,'Parent',handles.axesH);

handles=HSV_generation(handles);
% guidata(hObject, handles);




% --- Executes during object creation, after setting all properties.
function min_H_CreateFcn(hObject, eventdata, handles)
% hObject    handle to min_H (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function max_H_Callback(hObject, eventdata, handles)
handles.max_H.Value=str2double(handles.max_H.String);

handles.H_display=histogram(handles.H,length(handles.min_H.Value:handles.max_H.Value),...
    'binedges',handles.min_H.Value:handles.max_H.Value,'Parent',handles.axesH);

handles=HSV_generation(handles);
% guidata(hObject, handles);


% --- Executes during object creation, after setting all properties.
function max_H_CreateFcn(hObject, eventdata, handles)
% hObject    handle to max_H (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function min_S_Callback(hObject, eventdata, handles)
handles.min_S.Value=str2double(handles.min_S.String);

handles.S_display=histogram(handles.S,...
    'binedges',handles.min_S.Value:handles.max_S.Value,'Parent',handles.axesS);

handles=HSV_generation(handles);


% --- Executes during object creation, after setting all properties.
function min_S_CreateFcn(hObject, eventdata, handles)
% hObject    handle to min_S (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function max_S_Callback(hObject, eventdata, handles)
handles.max_S.Value=str2double(handles.max_S.String);

handles.S_display=histogram(handles.S,length(handles.min_S.Value:handles.max_S.Value),...
    'binedges',handles.min_S.Value:handles.max_S.Value,'Parent',handles.axesS);

handles=HSV_generation(handles);


% --- Executes during object creation, after setting all properties.
function max_S_CreateFcn(hObject, eventdata, handles)
% hObject    handle to max_S (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function min_V_Callback(hObject, eventdata, handles)
handles.min_V.Value=str2double(handles.min_V.String);

handles.V_display=histogram(handles.V,length(handles.min_V.Value:handles.max_V.Value),...
    'binedges',handles.min_V.Value:handles.max_V.Value,'Parent',handles.axesV);

handles=HSV_generation(handles);


% --- Executes during object creation, after setting all properties.
function min_V_CreateFcn(hObject, eventdata, handles)
% hObject    handle to min_V (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function max_V_Callback(hObject, eventdata, handles)
handles.max_V.Value=str2double(handles.max_V.String);

handles.V_display=histogram(handles.V,length(handles.min_V.Value:handles.max_V.Value),...
    'binedges',handles.min_V.Value:handles.max_V.Value,'Parent',handles.axesV);

handles=HSV_generation(handles);
guidata(hObject, handles);


% --- Executes during object creation, after setting all properties.
function max_V_CreateFcn(hObject, eventdata, handles)
% hObject    handle to max_V (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on button press in SAVE.
function SAVE_Callback(hObject, eventdata, handles)
% handles.II(:,:,1)=(handles.I(:,:,1)-handles.min_H.Value)./(handles.max_H.Value-handles.min_H.Value);
% 
% a=handles.II(:,:,1);
% a(a<handles.min_H.Value)=handles.min_H.Value;
% a(a>handles.max_H.Value)=handles.max_H.Value;
% handles.II(:,:,1)=a;
% 
% handles.II(:,:,2)=(handles.I(:,:,2)-handles.min_S.Value)./(handles.max_S.Value-handles.min_S.Value);
% 
% a=handles.II(:,:,2);
% a(a<handles.min_S.Value)=handles.min_S.Value;
% a(a>handles.max_S.Value)=handles.max_S.Value;
% handles.II(:,:,2)=a;
% 
% handles.II(:,:,3)=(handles.I(:,:,3)-handles.min_V.Value)./(handles.max_V.Value-handles.min_V.Value);
% 
% a=handles.II(:,:,3);
% a(a<handles.min_V.Value)=handles.min_V.Value;
% a(a>handles.max_V.Value)=handles.max_V.Value;
% handles.II(:,:,3)=a;

% HSV_sat = hsv2rgb(handles.II);

asd=(handles.I(:,:,1)-handles.min_H.Value)./(handles.max_H.Value-handles.min_H.Value);
asd(asd>1)=1;
asd(asd<0)=0;
handles.II(:,:,1)=rescale(asd,0,0.66);
handles.II(:,:,2)=(handles.I(:,:,2)-handles.min_S.Value)./(handles.max_S.Value-handles.min_S.Value);
handles.II(:,:,3)=(handles.I(:,:,3)-handles.min_V.Value)./(handles.max_V.Value-handles.min_V.Value);
HSV_sat = hsv2rgb(handles.II);




data=rescale(HSV_sat,0,1);
    data=uint16(data.*65536);
    NA=[handles.file_name.String,'.tif'];
    imwrite(data,NA)


function handles=HSV_generation(handles)

% handles.II(:,:,1)=(handles.I(:,:,1)-handles.min_H.Value)./(handles.max_H.Value-handles.min_H.Value);
asd=(handles.I(:,:,1)-handles.min_H.Value)./(handles.max_H.Value-handles.min_H.Value);
asd(asd>1)=1;
asd(asd<0)=0;
handles.II(:,:,1)=rescale(asd,0.05,0.55);
asd=(handles.I(:,:,2)-handles.min_S.Value)./(handles.max_S.Value-handles.min_S.Value);
% handles.II(:,:,2)=rescale(handles.I(:,:,2));
asd(asd>1)=1;
asd(asd<0)=0;
handles.II(:,:,2)=rescale(asd);
asd=(handles.I(:,:,3)-handles.min_V.Value)./(handles.max_V.Value-handles.min_V.Value);
asd(asd>1)=1;
asd(asd<0)=0;
handles.II(:,:,3)=rescale(asd);
% handles.II(:,:,3)=rescale(handles.I(:,:,3));
HSV_sat = hsv2rgb(handles.II);

set(handles.HSV_display,'CData',HSV_sat); 

% guidata(hObject, handles);



function CD_Callback(hObject, eventdata, handles)
[file,path] = uigetfile('*.*');
handles.CD.String=[path];


% --- Executes during object creation, after setting all properties.
function CD_CreateFcn(hObject, eventdata, handles)
% hObject    handle to CD (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function file_name_Callback(hObject, eventdata, handles)
% hObject    handle to file_name (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of file_name as text
%        str2double(get(hObject,'String')) returns contents of file_name as a double


% --- Executes during object creation, after setting all properties.
function file_name_CreateFcn(hObject, eventdata, handles)
% hObject    handle to file_name (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on button press in inverse_H.
function inverse_H_Callback(hObject, eventdata, handles)

if handles.inverse_H.Value==1
handles.I(:,:,1)=handles.max_H.Value-1.*handles.H;

handles.H_display=histogram(handles.I(:,:,1),length(handles.min_H.Value:handles.max_H.Value),...
    'binedges',handles.min_H.Value:handles.max_H.Value,'Parent',handles.axesH);

else
    handles.I(:,:,1)=handles.H;
    handles.H_display=histogram(handles.H,length(handles.min_H.Value:handles.max_H.Value),...
    'binedges',handles.min_H.Value:handles.max_H.Value,'Parent',handles.axesH);
    
end

handles=HSV_generation(handles);
guidata(hObject, handles);


% Hint: get(hObject,'Value') returns toggle state of inverse_H


% --- Executes during object creation, after setting all properties.
function figure1_CreateFcn(hObject, eventdata, handles)
% hObject    handle to figure1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called
