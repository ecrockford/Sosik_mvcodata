%this script will pull the wavelength,ag,ap,ad,and aph values from
%the Seabass files that are inside of working directory
%updated slightly by taylor 11/16/10 (added some clear commands)
%
%last updated 5/6/2014 - Taylor - updated sbdir and saved directory when
%switched computers from Samwise to Queenrose
%
%last updated 5/6/2015 - Taylor - updated sbdir and saved directory when
%rebuilt Queenrose HD 
clear all
sbdir = 'F:\from_Samwise\data\mvcodata\spectra\seabass\'; %shared file directory, can use for reading files but not for other scripts with fopen/fprintf
filelist = dir([sbdir,'spec*']);
wavelength = [];
ag = [];
ap = [];
ad = [];
aph = [];
dates = [];
depth = [];
lat = [];
lon = [];
allfiles = [];
cruises = [];
stations = [];
lons = [];
lats = [];
for filecount = 1:length(filelist),
    [sdata,sfields,sunits,sheader]=sbread([sbdir,filelist(filecount).name]);
    filename = filelist(filecount).name  ;
    disp(filename)

    %sort the spec data so that it is from 300nm to 850nm
    [d,ci]=sort(sdata(:,1));
    sdata=sdata(ci,:);

    sdata(find(sdata==-9999))=NaN;

    depth=str2num(strvcat(sheader.measurement_depth));
    lon=strvcat(sheader.east_longitude);
    lon = str2num(lon(1:end-5));
    lat=strvcat(sheader.north_latitude);
    lat = str2num(lat(1:end-5));
    %s=find(depth==min(depth));
    swvln=squeeze(sdata(:,1,1));
   
    t = find(strcmp(sfields, 'wavelength'));
    wavelength = [wavelength;sdata(:,t)];
    t = find(strcmp(sfields, 'ag'));
    ag = [ag;sdata(:,t)];
    t = find(strcmp(sfields, 'ap'));
    ap = [ap;sdata(:,t)];
    t = find(strcmp(sfields, 'ad'));
    ad = [ad;sdata(:,t)]; 
    t = find(strcmp(sfields, 'aph'));
    aph = [aph;sdata(:,t)];
    allfile = repmat(filename,size(sdata,1),1);
    allfiles = [allfiles;allfile];
    cruise = repmat(sheader.cruise,size(sdata,1),1);
    cruises = [cruises;cruise];
    station = repmat(sheader.station,size(sdata,1),1);
    stations = [stations;station];
    %Taylor 10Jan2012 changed date line to include UTC time, previously
    %only had date not time
%    date = repmat(sheader.start_date,size(sdata,1),1);
    date = repmat([sheader.start_date sheader.start_time(1:8)],size(sdata,1),1);
    dates = [dates;date];
    lat = repmat(lat,size(sdata,1),1);
    lon = repmat(lon,size(sdata,1),1);
    lats = [lats; lat];
    lons = [lons; lon];
    clear t
end;
% updated by taylor to clear some variables from the workspace
clear lat lon t allfile cruise station date swvln filecount sdata sfields sunits sheader filename d ci
Y = dates(:,1:4);
Y = str2num(Y);
MO = dates(:,5:6);
MO = str2num(MO);
D = dates(:,7:8);
D = str2num(D);
%Taylor added following 10Jan2012 to include time in matdate
H = dates(:,9:10);
H = str2num(H);
MI = dates(:,12:13);
MI = str2num(MI);
S = 00;


depth = allfiles(:,23:24);
depth = str2num(depth);

allfiles = cellstr(allfiles);
%Taylor edited following 10Jan2012 to include time in matdate
%matdatespec = datenum(Y,M,D);
matdatespec = datenum(Y,MO,D,H,MI,S);
% updated by taylor to clear some variables from the workspace
clear Y M D
%variable names changed, Heidi 2/3/10
spectra_titles = {'ap', 'aph', 'ad', 'ag' ,'wvln', 'depth', 'lat', 'lon', 'matdate'};
spectra = [ap aph ad ag wavelength depth lats lons matdatespec];
save mvco_specdb.mat spectra spectra_titles allfiles

