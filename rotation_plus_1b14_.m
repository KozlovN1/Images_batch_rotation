% Rotation of images. Processing in a batch mode.
% v1.beta14
% Requires MATLAB R2016b or higher.
% 2022-06-03. Nick Kozlov
%% Init
prompt = strcat('Do you want to CLEAN and restart over?');
dlgtitle = 'Restart over: y/n?';
definput = {'n'};
dims = [1 50];
answer = inputdlg(prompt,dlgtitle,dims,definput);
if answer{1,1} == 'y'
    clc; clear all; close all;
elseif answer{1,1} == 'n'
else
    disp('I did not understand the answer: y or n?'); % This part is merely informative, no real action taken.
end

global showfigure Nstart Nfiles fig

%% Parameters
 anglemode = 1; % 1 - manually input a fixed angle, 2 - rotation at constant rate: fixed angle * number of steps, 3 - read the angle value from a file
    suffix = '*.tiff'; % *.bmp or *.tif or *.jpg or *.tiff or *.jpeg
showfigure = true;

if anglemode == 3 % DO NOT EDIT this line!
%_only for anglemode == 3_%    
        phi_file = 'phi.csv'; % strictly necessary: the file should contain four columns with names "phi,x_c,y_c,dphase" - vector|value|value|value
    dotestperiod = false; % optional, may be usefull if you are unsure of the steadiness of your object rotation in real world
      showgraphs = true; % only takes action if dotestperiod == true
       maxperiod = 128; % only takes action if dotestperiod == true
%_%
end

%% Program main body
%_select directories_%
if  exist('directory','var') == 1 && ischar(directory)
    directory=uigetdir(directory,'Directory containing the images you want to PROCESS');
else
    directory=uigetdir([],'Directory containing the images you want to PROCESS'); %directory containing the images you want to analyze
end
direc = dir([directory,filesep,suffix]); filenames={};
[filenames{1:length(direc),1}] = deal(direc.name);
filenames = sortrows(filenames); % sort all image files
if  exist('exportdir','var')==1 && ischar(exportdir)
    exportdir=uigetdir(exportdir,'Where to SAVE the figures files?');
else
    exportdir=uigetdir(directory,'Where to SAVE the figures files?');
end
%_%

%_Check the config file_% v. 1b11
if isfile(strcat(directory,filesep,'rotation.conf') )
    conffile = fopen(strcat(directory,filesep,'rotation.conf') );
    fgets(conffile);
    val1 = fgetl(conffile);
    val2 = fgetl(conffile);
    val3 = fgetl(conffile);
    fclose(conffile);
else
    val1 = ''; val2 = ''; val3 = '';
end
%_%

%_Import data_%
if anglemode == 1
    prompt = {'Set the angle of rotation in degrees',...
        'Set the centre coordinate x_c','Set the centre coordinate y_c'};
    dlgtitle = 'Configure the rotation: MODE 1';
    dims = [1 50];
    definput = {val1, val2, val3};
    answer = inputdlg(prompt,dlgtitle,dims,definput);
    phi = str2double(answer{1});
    x_c = str2double(answer{2});
    y_c = str2double(answer{3});
elseif anglemode == 2
    prompt = {'Set the rate of rotation in frames per revolution',...
        'Set the centre coordinate x_c','Set the centre coordinate y_c'};
    dlgtitle = 'Configure the rotation: MODE 3';
    dims = [1 50];
    definput = {val1, val2, val3};
    answer = inputdlg(prompt,dlgtitle,dims,definput);
    rate = str2double(answer{1});
    x_c = str2double(answer{2});
    y_c = str2double(answer{3});
elseif anglemode == 3
    T = readtable(strcat(directory,filesep,phi_file));
    phi = T{:,{'phi'}};
    x_c = T{1,{'x_c'}};
    y_c = T{1,{'y_c'}};
    dphase = T{1,{'dphase'}};
else
    msgbox('Wrong value of anglemode', 'Error','error');
end
%_%

%_Set the number of images to process_%
element1 = 1;
element2 = length(filenames);
prompt = {'Start number','End number'};
dlgtitle = 'How many images to process?';
dims = [1 50];
if anglemode == 3
    if dphase < 0
        element1 = 1-dphase;
        element2 = length(filenames);
    elseif dphase > 0
        element1 = 1;
        element2 = length(filenames)-dphase;
    end
end
definput = {num2str(element1),num2str(element2)};
answer = inputdlg(prompt,dlgtitle,dims,definput);
if str2double(answer{1}) >= element1
    Nstart = str2double(answer{1});
else
    disp(strcat('Invalid value; setting it to the default: ',...
        num2str(element1)));
    Nstart = element1;
end
if str2double(answer{2}) <= element2
    Nfiles = str2double(answer{2});
else
    disp(strcat('Invalid value; setting it to the maximum amount of files: ',...
        num2str(element2)));
    Nfiles = element2;
end
%_%

im1={};
im2={};
im = imread(strcat(directory,filesep,filenames{1}));
if isnan(x_c)
    x_c = 0.5*size(im,2);
end
if isnan(y_c)
    y_c = 0.5*size(im,1);
end
if ceil(2*x_c) <= size(im,2)
    ColStart = 1;
    ColEnd = ceil(2*x_c);
else
    msgbox("Column boundary exceeded - reducing.");
    ColStart = 2*x_c - size(im,2); % v. 1b9
    ColEnd = size(im,2); % v. 1b9
end
if ceil(2*y_c) <= size(im,1)
    RowStart = 1;
    RowEnd = ceil(2*y_c);
else
    msgbox("Row boundary exceeded - reducing.");
    RowStart = 2*y_c - size(im,1); % v. 1b9
    RowEnd = size(im,1); % v. 1b9
end
if showfigure == true; cnt = 0; fig = figure; end
for i=Nstart:1:Nfiles
    im = imread(strcat(directory,filesep,filenames{i}));
    im1 = im(RowStart:RowEnd,ColStart:ColEnd,:);
    if anglemode == 1
        im2 = imrotate(im1,phi,'bilinear','loose');
    elseif anglemode == 2
        im2 = imrotate(im1,-(i-Nstart)*360/rate,'bilinear','crop');
    elseif anglemode == 3
        im2 = imrotate(im1,phi(i+dphase)*180/pi,'bilinear','crop');
    end
    imwrite(im2,strcat(exportdir,filesep,filenames{i}),'tif','Compression','none');
%     cnt = displayfigure(i,im2,cnt); % local_function, v. 1b10
    if showfigure == true
        cnt = cnt+1;
        if Nfiles / cnt <= 100
            figure(fig);
            imshow(im2);
            title(['Saving figures: ' int2str((i)/Nfiles*100) ' %']);
            drawnow;
            cnt = 0;
        end
    end
    clc;
    disp(['Saving rotated images: ' int2str(round(i/Nfiles*100,2)) ' %']);
end

%% Save the parameters last used
if anglemode == 1 || anglemode == 2 % v. 1b11
    conffile = fopen(strcat(directory,filesep,'rotation.conf'), 'w');
    fprintf(conffile, '%s ', 'The parameters registered on');
    fprintf(conffile, '%s\n', string(datetime) );
    if anglemode == 1; fprintf(conffile, '%g\n', phi, x_c, y_c); end
    if anglemode == 2; fprintf(conffile, '%g\n', rate, x_c, y_c); end
    fclose(conffile);
end

%% Additional functionality
if anglemode == 3 && dotestperiod == true
    [period,dx1,dx2] = test_period(phi,maxperiod);
    num = zeros(length(period),round(Nfiles/length(period) ) );
    for i=1:1:length(period)
%         for j=1:1:round(Nfiles/length(period))
            num(i,1) = i;
            num(i,2) = period(i);
%         end
    end
    T2 = array2table(num);
    writetable(T2,strcat(directory,filesep,'period.csv'),'Delimiter',';');

    if showgraphs == true
        figure('Name','Period vs element number');
        subplot(1,2,1); plot(period,'-');
        xlabel('Element number');
        ylabel('Period in steps');
        subplot(1,2,2); hold on; plot(dx1,'--'); plot(dx2,'-'); hold off;
        xlabel('Element number');
        ylabel('\Delta x, radian','Interpreter','tex');
    end
end

%% Functions
function cnt = displayfigure(i,im2,cnt)
    global showfigure Nfiles fig
    if showfigure == true
        cnt = cnt+1;
        if Nfiles / cnt <= 100
            figure(fig);
            imshow(im2);
            title(['Saving figures: ' int2str((i)/Nfiles*100) ' %']);
            drawnow;
            cnt = 0;
        end
    end
end

function [T,dx1,dx2] = test_period(x,y)

% Определяем период повторения координат каждой фазы.
% На выходе получаем 1D массив T, содержащий разницу в количестве кадров -
% сколько надо прибавить к кадру i, чтобы попасть в ту же фазу.

    T = zeros(length(x)-y,1);
    dx1 = zeros(length(x)-y,1);
    dx2 = zeros(length(x)-y,1);
    for i = 1:1:length(x)-y
        delta = zeros(y,1);
        check_dx1 = zeros(y,1);
        check_dx2 = zeros(y,1);
        for j = 1:1:y
            check_dx1(j) = (x(i+1)-x(i));
            check_dx2(j) = (x(j+1)-x(j));
            delta(j) = abs(x(i)-x(i+j));
            if j == 1
                T(i) = j;
            elseif j > 1
                if delta(j) < delta(j-1)
                    T(i) = j;
                    dx1(i) = check_dx1(j);
                    dx2(i) = check_dx2(j);
                end
            end
        end
    end

end