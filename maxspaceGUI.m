function varargout = maxspaceGUI(varargin)
% MAXSPACEGUI M-file for maxspaceGUI.fig
%      MAXSPACEGUI, by itself, creates a new MAXSPACEGUI or raises the existing
%      singleton*.
%
%      H = MAXSPACEGUI returns the handle to a new MAXSPACEGUI or the handle to
%      the existing singleton*.
%
%      MAXSPACEGUI('CALLBACK',hObject,eventData,handles,...) calls the local
%      function named CALLBACK in MAXSPACEGUI.M with the given input arguments.
%
%      MAXSPACEGUI('Property','Value',...) creates a new MAXSPACEGUI or raises the
%      existing singleton*.  Starting from the left, property value pairs are
%      applied to the GUI before maxspaceGUI_OpeningFcn gets called.  An
%      unrecognized property name or invalid value makes property application
%      stop.  All inputs are passed to maxspaceGUI_OpeningFcn via varargin.
%
%      *See GUI Options on GUIDE's Tools menu.  Choose "GUI allows only one
%      instance to run (singleton)".
%
% See also: GUIDE, GUIDATA, GUIHANDLES

% Edit the above text to modify the response to help maxspaceGUI

% Last Modified by GUIDE v2.5 10-Apr-2009 09:38:55

% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @maxspaceGUI_OpeningFcn, ...
                   'gui_OutputFcn',  @maxspaceGUI_OutputFcn, ...
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

% --- Executes just before maxspaceGUI is made visible.
function maxspaceGUI_OpeningFcn(hObject, eventdata, handles, varargin)
% This function has no output args, see OutputFcn.
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% varargin   command line arguments to maxspaceGUI (see VARARGIN)

% Choose default command line output for maxspaceGUI
handles.output = hObject;

% Update handles structure
guidata(hObject, handles);

% UIWAIT makes maxspaceGUI wait for user response (see UIRESUME)
% uiwait(handles.figure1);


% --- Outputs from this function are returned to the command line.
function varargout = maxspaceGUI_OutputFcn(hObject, eventdata, handles) 
% varargout  cell array for returning output args (see VARARGOUT);
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Get default command line output from handles structure
varargout{1} = handles.output;


% --- Executes on button press in Importbtn.
function Importbtn_Callback(hObject, eventdata, handles)
% hObject    handle to Importbtn (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
[FileName,PathName,FilterIndex] =uigetfile({'*.idx;*.file','�����ɮ�';...
          '*.*','All Files' },'Open File',...
          'd:\ky fung\My Documents\DVDIndex\Database\DIR');
btn = questdlg('Copy or Move the files?', 'Warning', 'Copy', 'Move', 'Cancel','Copy');
FileName = strtok(FileName, '.');
switch btn
    case 'Copy'
        copyfile([PathName FileName '.idx'], fullfile(pwd, [FileName '.xls']));
        copyfile([PathName FileName '.file'], fullfile(pwd, [FileName '_.xls']));
    case 'Move'
        movefile([PathName FileName '.idx'], fullfile(pwd, [FileName '.xls']));
        movefile([PathName FileName '.file'], fullfile(pwd, [FileName '_.xls']));
    otherwise
        return
end
[num,txt] = xlsread([FileName '.xls']);
[numi,txti] = xlsread([FileName '_.xls']);
clear num numi 
delete([FileName '.xls'],[FileName '_.xls'])

sz = size(txti);
for i = 1:sz(1)
    for j = 1:sz(2)
        if isempty(txti{i,j})
        else
            [typ(i,j),siz(i,j)] = strread(txti{i,j}, '%1c%d.%*d');
        end
    end
end
clear i j

% calculate directories' size
isdirs = typ=='D';

siz2 = siz;
for j=1:sz(2)
    diridx = find(isdirs(:,j)==1);
    ndir = nnz(diridx);
    diridx(end+1)=sz(1);
    for r=1:ndir
        curdir = diridx(r);
        nextdir = diridx(r+1);
        siz2(curdir, j) = sum(sum(siz(curdir:nextdir, j+1:end)));
    end
end
    
% summarize main directories
layer = 2;
Gpidx = find(siz2(:,layer)>0);
Gpsiz = siz2(Gpidx, layer);
Gptxt= {txt{Gpidx, layer}}';
Gpinfo = Gptxt;
nGp = length(Gpsiz);
Gpinfo(:,2)=num2cell(Gpsiz./1024^2);

dvd5 = 4706074624;
oversize = (Gpsiz >= dvd5);
oversizedir = [];
if any(oversize)
    oversizedir = Gpinfo(oversize,:);
%     openvar('oversizedir');
end
while 1
    try
        if exist('temp.xls')~=0
            delete('temp.xls');
        end
        if ~isempty(oversizedir)
            xlswrite('temp.xls', oversizedir, 2);
        end
        xlswrite('temp.xls', Gpinfo, 1);
        break
    catch me
        h =warndlg('Please close the Excel files!');
        uiwait(h);
    end    
end
winopen('temp.xls')



% --- Executes on button press in Optimize.
function Optimize_Callback(hObject, eventdata, handles)
% hObject    handle to Optimize (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
dvdsz = [4706074624;8547991552];
mydvd = get(handles.listbox2, 'Value');
mydvd = dvdsz(mydvd);
if exist('temp.xls')==0
    h = warndlg('temp.xls does not exist!');
    uiwait(h);
    return
end
[num,txt] = xlsread('temp.xls',1);
% run optimization
num =num.*1024^2;
getspace = @(x) mydvd-sum(num(logical(x)));
subfun = @(sp) abs(sp)/(sp>0);
fitfun = @(x) subfun(getspace(x));
nGp=length(num);
set(handles.edit1, 'String', 'running');
options = gaoptimset('PopulationType', 'bitstring', 'PopulationSize', nGp*10, 'Display', 'off');
[x,fval,exitflag] = ga(fitfun, nGp, [],[],[],[],[],[],[],options);
num = num2cell(num./1024^2);
tmp = [txt, num];
results = tmp(logical(x), :);
remains = tmp(~logical(x), :);
set(handles.edit1, 'String', fval/1024^2);
% msg = [num2str(fval/1024^2) ' Mb is left'];
while 1
    try
        if exist('results.xls')~=0
            delete('results.xls')
        end
        if ~isempty(remains)
            xlswrite('results.xls', remains, 2);
        end
        xlswrite('results.xls', results, 1);
        break
    catch me
        h =warndlg('Please close the Excel files!');
        uiwait(h);
    end
end


function edit1_Callback(hObject, eventdata, handles)
% hObject    handle to edit1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of edit1 as text
%        str2double(get(hObject,'String')) returns contents of edit1 as a double


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


% --- Executes when user attempts to close figure1.
function figure1_CloseRequestFcn(hObject, eventdata, handles)
% hObject    handle to figure1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: delete(hObject) closes the figure
delete(hObject);
% while exist('temp.xls')~=0
%     h =warndlg('Please close the Excel files!');
%     uiwait(h);
%     delete('temp.xls');
% end

% --- Executes on selection change in listbox2.
function listbox2_Callback(hObject, eventdata, handles)
% hObject    handle to listbox2 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: contents = get(hObject,'String') returns listbox2 contents as cell array
%        contents{get(hObject,'Value')} returns selected item from listbox2


% --- Executes during object creation, after setting all properties.
function listbox2_CreateFcn(hObject, eventdata, handles)
% hObject    handle to listbox2 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: listbox controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on button press in Importlast.
function Importlast_Callback(hObject, eventdata, handles)
% hObject    handle to Importlast (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
if exist('results.xls')==0
    warndlg('results.xls does not exist!');
else
    [num, txt, raw]=xlsread('results.xls',  2);
    while 1
        try
            if exist('temp.xls')~=0
                delete('temp.xls')
            end
            xlswrite('temp.xls', raw, 1);
            break
        catch
            h =warndlg('Please close the Excel files!');
            uiwait(h);
        end
    end
end


% --- Executes on button press in ViewResults.
function ViewResults_Callback(hObject, eventdata, handles)
% hObject    handle to ViewResults (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
if exist('results.xls')==0
    warndlg('results.xls does not exist!');
else
    winopen('results.xls');
end

