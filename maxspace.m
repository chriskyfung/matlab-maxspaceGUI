clear
clc
%%
[FileName,PathName,FilterIndex] =uigetfile({'*.idx;*.file','¯Á¤ÞÀÉ®×';...
          '*.*','All Files' },'Open File',...
          'd:\ky fung\My Documents\DVDIndex\Database\DIR');
btn = questdlg('Copy or Move the files?', 'Warning', 'Copy', 'Move', 'Cancel','default');
% copyfile([PathName FileName], fullfile(pwd, [FileName '.xls']));
%%
[num,txt] = xlsread('file2burn.xls',1);
[numi,txti] = xlsread('file2burn.xls',2);

clear num numi 

%% 
dvd5 = 4707319808;
dvd9 = 8547991552;

mydvd = dvd5;

%%
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

%% calculate directories' size
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
    
%% summarize main directories
layer = 2;
Gpidx = find(siz2(:,layer)>0);
Gpsiz = siz2(Gpidx, layer);
Gptxt= {txt{Gpidx, layer}}';
Gpinfo = Gptxt;
nGp = length(Gpsiz);
Gpinfo(:,2)=mat2cell(Gpsiz, ones(1,nGp),1);

oversize = (Gpsiz >= mydvd);
if any(oversize)
    oversizedir = Gpinfo(oversize,:)
    openvar('oversizedir');
end

%% run optimization
fitfun = @(x) abs(mydvd-sum(Gpsiz(logical(x))));

options = gaoptimset('PopulationType', 'bitstring', 'PopulationSize', nGp*10);
[x,fval,exitflag] = ga(fitfun, nGp, [],[],[],[],[],[],[],options);

results = Gpinfo(logical(x),:);
fprintf('space remaining = %f MB\n', fval/1024^2)
openvar('results');