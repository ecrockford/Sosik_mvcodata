%any updated beam data files need to be manually transferred from
%\\Raspberry\mvco_moxanode\code to \\Samwise\C:\data\mvcodata\matlab_files\BeamData

%##########################################################################
%###############################CTD########################################
%##########################################################################
%compile all available CTD beam data for easy access to all years w/in 1
%mat file. potential helpful for compare to SST from satellites
beamdata_dir = '\\Raspberry\mvco_moxanode\code\';

CTDall=[];
CTDallstd=[];
a = dir([beamdata_dir 'CTDsmoothhr*.mat']);
for count=1:length(a)
    load([beamdata_dir a(count).name])
    CTDall=[CTDall; CTDsmooth];
    CTDallstd=[CTDallstd; CTDstd];
end
save ./BeamData/beamCTDhr CTDall CTDallstd CTDtitles

%make daily 24 hour yearday compiled mat file
clear
beamdata_dir = '\\Raspberry\mvco_moxanode\code\';
a = dir([beamdata_dir 'CTDdata2*.mat']);
CTDdaily=[];
CTDstd=[];
for count=1:length(a)
    load([beamdata_dir a(count).name])
%    yearday=[1:366]';
    yearday=datenum(['1/1/' a(count).name(end-7:end-4)]):datenum(['12/31/' a(count).name(end-7:end-4)]);
%!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!Line below is wrong!!! should datenum the
%right value
yr=str2num(a(count).name(end-7:end-4));
%    datadays=floor(CTDdata(:,1))-repmat(yr,length(CTDdata),1)+1;
datadays=floor(CTDdata(:,1));
temp=NaN(length(yearday),length(CTDtitles));
    tempstd=temp;
%    for count2=1:366
    for count2=1:length(yearday)
        ind=find(datadays == yearday(count2));
        temp(count2,:)=[yearday(count2) mean(CTDdata(ind,2:end),1)];
        tempstd(count2,:)=[yearday(count2) std(CTDdata(ind,2:end),0,1)];
    end
    CTDdaily=[CTDdaily; temp];
    CTDstd=[CTDstd; tempstd];
end
save ./BeamData/beamCTDdaily CTDdaily CTDstd CTDtitles
clear all

%make beam daily temp matrix
load ./BeamData/beamCTDdaily
clear
beamdata_dir = '\\Raspberry\mvco_moxanode\code\';
a = dir([beamdata_dir 'CTDdata2*.mat']);
%make a matrix of beam temp to match Heidi's format of the daily node
%temp.so that the dates match up, we start the matrix at 2003 which will be
%a whole column of NaNs. But i think for now that will be the easiest for
%plotting. This is for work with the node temp and satellite sst
junk=datevec(now);
matrixyears=2003:junk(1);
beamT=NaN(366,length(matrixyears));

[y,m,d,h,mi,s] = datevec(CTDdaily(:,1));
datayear=unique(y);
yearday=[1:366]';
for count=1:length(datayear)
    ind=find(y==datayear(count));
    temp=CTDdaily(ind,:);
    year=datenum(num2str(datayear(count)),'yyyy');
    spot=find(matrixyears==datayear(count));
    datadays=temp(:,1)-year+1;
    for count2=1:length(yearday)
        ind=find(datadays == yearday(count2));
        if sum(ind)>0
            beamT(count2,spot)=nanmean(temp(ind,2));
        end
    end
end





%{
%~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
    
    %daily smooth
%current daily average includes full 24hour bin. Oceancolor satellites only
%take daytime readings. Do we want to try and account for that in average?
    [y,m,d,h,mi,s] = datevec(CTDdata(:,1));
    t = find(diff(d));
    t = [0; t];
    CTDtemp = NaN.*zeros(length(t), size(CTDdata,2));
    tempCTDstd = CTDtemp;

    total = length(t);
    for count2 = 1:total-1
        if rem(count2,100) == 0,
            disp([num2str(count2) ' of ' num2str(total)]) 
        end;
        CTDtemp(count2,:) = mean(CTDdata(t(count2)+1:t(count2+1),:),1);
        tempCTDstd(count2,:) = std(CTDdata(t(count2)+1:t(count2+1),:),0,1);
    end;
    count2 = count2 + 1;
    CTDtemp(count2,:) = mean(CTDdata(t(count2)+1:end,:),1);
    tempCTDstd(count2,:) = std(CTDdata(t(count2)+1:end,:),0,1);
    
    CTDdaily=[CTDdaily; CTDtemp];
    CTDstd=[CTDstd; tempCTDstd];
end
clear a y m d h mi s t total CTDsmooth tempCTDstd count count2 CTDdata
save ./BeamData/beamCTDdaily CTDdaily CTDstd CTDtitles
%}
%##########################################################################
%###############################CDOM#######################################
%##########################################################################
%compile all available CDOM beam data for easy access to all years w/in 1
%mat file. potentially helpful for satellite analysis
clear all
beamdata_dir = '\\Raspberry\mvco_moxanode\code\';
CDOMall=[];
stdCDOM=[];
a = dir([beamdata_dir 'CDOMsmoothhr*.mat']);
for count=1:length(a) %!!!!!!!
%count starts at 4 because earlier cdom years don't have fluor reading converted to est cdom (use count and scale factor from calibration)    
    load([beamdata_dir a(count).name])
    CDOMall=[CDOMall; CDOMsmooth];
    stdCDOM=[stdCDOM; CDOMstd];
end
save ./BeamData/beamCDOMhr CDOMall stdCDOM CDOMtitles
clear a

%compile all available CDOM beam data for easy access to all years w/in 1
%mat file. potentially helpful for satellite analysis
%make daily 24 hour average
clear
beamdata_dir = '\\Raspberry\mvco_moxanode\code\';
CTDdaily=[];
CTDstd=[];
a = dir([beamdata_dir 'CDOMdata2*.mat']);
CDOMdaily=[];
stdCDOM=[];
for count=1:length(a)
    load([beamdata_dir a(count).name])
    yearday=datenum(['1/1/' a(count).name(end-7:end-4)]):datenum(['12/31/' a(count).name(end-7:end-4)]);
    datadays=floor(CDOMdata(:,1));
    temp=NaN(length(yearday),length(CDOMtitles));
    tempstd=temp;
    for count2=1:length(yearday)
        ind=find(datadays == yearday(count2));
        temp(count2,:)=[yearday(count2) mean(CDOMdata(ind,2:end),1)];
        tempstd(count2,:)=[yearday(count2) std(CDOMdata(ind,2:end),0,1)];
    end
    CDOMdaily=[CDOMdaily; temp];
    stdCDOM=[stdCDOM; tempstd];
end
save ./BeamData/beamCDOMdaily CDOMdaily stdCDOM CDOMtitles
clear
%~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

%{
beamdata_dir = '\\Raspberry\mvco_moxanode\code\';
CDOMdaily=[];
stdCDOM=[];
a = dir([beamdata_dir 'CDOMsmooth2*.mat']);
for count=1:length(a)
    load([beamdata_dir a(count).name])
    %daily smooth
%current daily average includes full 24hour bin. Oceancolor satellites only
%take daytime readings. Do we want to try and account for that in average?
    [y,m,d,h,mi,s] = datevec(CDOMsmooth(:,1));
    t = find(diff(d));
    t = [0; t];
    CDOMtemp = NaN.*zeros(length(t), size(CDOMsmooth,2));
    tempstd = CDOMtemp;

    total = length(t);
    for count2 = 1:total-1
        if rem(count2,100) == 0,
            disp([num2str(count2) ' of ' num2str(total)]) 
        end;
        CDOMtemp(count2,:) = mean(CDOMsmooth(t(count2)+1:t(count2+1),:),1);
        tempstd(count2,:) = std(CDOMsmooth(t(count2)+1:t(count2+1),:),0,1);
    end;
    count2 = count2 + 1;
    CDOMtemp(count2,:) = mean(CDOMsmooth(t(count2)+1:end,:),1);
    tempstd(count2,:) = std(CDOMsmooth(t(count2)+1:end,:),0,1);
    
    CDOMdaily=[CDOMdaily; CDOMtemp];
    stdCDOM=[stdCDOM; tempstd];
end
clear y m d h mi s CDOMtemp tempstd total count2 count a CDOMsmooth CDOMstd
save ./BeamData/beamCDOMdaily CDOMdaily stdCDOM CDOMtitles
%}
%##########################################################################
%###############################FLUOR#######################################
%##########################################################################
%compile all available ecofluor beam data for easy access to all years w/in 1
%mat file to use for satellite analysis
fprintf('dealing with old fluor w 5 column vs new fluor with 8 col\n')
clear all
beamdata_dir = '\\Raspberry\mvco_moxanode\code\';
titles={'date_matlab, UTC','CHLREF','CHLFL','NTUREF','NTU','itemp','Chl (ug/l), rough est.','Beta(700) m^-1 sr^-1'};
%fluorall=NaN(1,length(titles));
fluorall=[];
%stdfluor=NaN(1,length(titles));
stdfluor=[];
chlmats = dir([beamdata_dir 'ecochlsmoothhr*.mat']);
for count=1:length(chlmats)
    load([beamdata_dir chlmats(count).name])
    if size(ecosmooth,2) == 5
        filler=NaN(length(ecosmooth),1);
        ecosmooth=[ecosmooth(:,1:3) filler filler ecosmooth(:,4:5) filler];
        ecostd=[ecostd(:,1:3) filler filler ecostd(:,4:5) filler];
    elseif size(ecosmooth,2) == length(titles)
        disp('Has beta cal')
    else
        error('Size of matrix is different than usual 5 or 8 column format')
    end
    fluorall=[fluorall; ecosmooth];
    stdfluor=[stdfluor; ecostd];
end
save ./BeamData/beamecochlhr fluorall stdfluor ecofltitles

%~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
%compile all available fluor beam data for easy access to all years w/in 1
%mat file. daily avg for satellite analysis
clear
beamdata_dir = '\\Raspberry\mvco_moxanode\code\';
fluordaily=[];
stdfluor=[];
titles={'date_matlab, UTC','CHLREF','CHLFL','NTUREF','NTU','itemp','Chl (ug/l), rough est.','Beta(700) m^-1 sr^-1'};
chlmats = dir([beamdata_dir 'ecofldata2*.mat']);
for count=1:length(chlmats)
    load([beamdata_dir chlmats(count).name])
    yearday=datenum(['1/1/' chlmats(count).name(end-7:end-4)]):datenum(['12/31/' chlmats(count).name(end-7:end-4)]);
    datadays=floor(ecofldata(:,1));
    temp=NaN(length(yearday),length(ecofltitles));
    tempstd=temp;
    for count2=1:length(yearday)
        ind=find(datadays == yearday(count2));
        temp(count2,1:length(ecofltitles))=[yearday(count2) mean(ecofldata(ind,2:end),1)];
        tempstd(count2,1:length(ecofltitles))=[yearday(count2) std(ecofldata(ind,2:end),0,1)];
    end
    if size(temp,2) == 5
        filler=NaN(length(temp),1);
        temp=[temp(:,1:3) filler filler temp(:,4:5) filler];
        tempstd=[tempstd(:,1:3) filler filler tempstd(:,4:5) filler];
    elseif size(temp,2) == length(titles)
        disp('Has beta cal')
    else
        error('Size of matrix is different than usual 5 or 8 column format')
    end
    fluordaily=[fluordaily; temp];
    stdfluor=[stdfluor; tempstd];
end
save ./BeamData/beamECOCHLdaily fluordaily stdfluor titles
clear all

%~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
%{
clear
beamdata_dir = '\\Raspberry\mvco_moxanode\code\';
fluordaily=[];
stdfluor=[];
a = dir([beamdata_dir 'ecochlsmooth2*.mat']);
for count=1:length(a)
    load([beamdata_dir a(count).name])
    %daily smooth
%current daily average includes full 24hour bin. Oceancolor satellites only
%take daytime readings. Do we want to try and account for that in average?
    [y,m,d,h,mi,s] = datevec(ecosmooth(:,1));
    t = find(diff(d));
    t = [0; t];
    ecotemp = NaN.*zeros(length(t), size(ecosmooth,2));
    tempstd = ecotemp;

    total = length(t);
    for count2 = 1:total-1
        if rem(count2,100) == 0,
            disp([num2str(count2) ' of ' num2str(total)]) 
        end;
        ecotemp(count2,:) = mean(ecosmooth(t(count2)+1:t(count2+1),:),1);
        tempstd(count2,:) = std(ecosmooth(t(count2)+1:t(count2+1),:),0,1);
    end;
    count2 = count2 + 1;
    ecotemp(count2,:) = mean(ecosmooth(t(count2)+1:end,:),1);
    tempstd(count2,:) = std(ecosmooth(t(count2)+1:end,:),0,1);
    
    fluordaily=[fluordaily; ecotemp];
    stdfluor=[stdfluor; tempstd];
end
clear y m d h mi s ecotemp tempstd total count2 count a ecosmooth ecostd
save ./BeamData/beamecochldaily fluordaily stdfluor ecofltitles
%}
%{
%##########################################################################
%###############################HS#######################################
%##########################################################################
%hydroscat changes wavelengths and number of variables throughout
%calibrations. makes it difficult to compile into 1 file. easiest to use
%each year.

clear all
beamdata_dir = '\\Raspberry\mvco_moxanode\code\';
HSall=[];
stdHS=[];
a = dir([beamdata_dir 'HSdata2*']);
for count=1:length(a)
    load([beamdata_dir a(count).name])
    HSall=[HSall; HSsmooth];
    stdHS=[stdHS; HSstd];
end
save beamHShr HSall stdHS HStitles
%}

%##########################################################################
%###############################VSF######################################
%##########################################################################
%compile all available ecofluor beam data for easy access to all years w/in 1
%mat file to use for satellite analysis
clear all
beamdata_dir = '\\Raspberry\mvco_moxanode\code\';
vsfall=[];
stdvsf=[];
a = dir([beamdata_dir 'VSFsmoothhr*.mat']);
for count=1:length(a)
    load([beamdata_dir a(count).name])
    vsfall=[vsfall; vsfsmooth];
    stdvsf=[stdvsf; vsfstd];
end
save beamfluorhr vsfall stdvsf vsftitles

%compile all available fluor beam data for easy access to all years w/in 1
%mat file. daily avg for satellite analysis
clear
beamdata_dir = '\\Raspberry\mvco_moxanode\code\';
vsfdaily=[];
stdvsf=[];
a = dir([beamdata_dir 'VSFdata2*.mat']);
for count=1:length(a)
    load([beamdata_dir a(count).name])
    yearday=datenum(['1/1/' a(count).name(end-7:end-4)]):datenum(['12/31/' a(count).name(end-7:end-4)]);
    datadays=floor(vsfdata(:,1));
    temp=NaN(length(yearday),length(vsftitles));
    tempstd=temp;
    for count2=1:length(yearday)
        ind=find(datadays == yearday(count2));
        temp(count2,:)=[yearday(count2) mean(vsfdata(ind,2:end),1)];
        tempstd(count2,:)=[yearday(count2) std(vsfdata(ind,2:end),0,1)];
    end
    vsfdaily=[vsfdaily; temp];
    stdvsf=[stdvsf; tempstd];
end
save ./BeamData/beamVSFdaily vsfdaily stdvsf vsftitles

%{
    %daily smooth
%current daily average includes full 24hour bin. Oceancolor satellites only
%take daytime readings. Do we want to try and account for that in average?
    [y,m,d,h,mi,s] = datevec(vsfsmooth(:,1));
    t = find(diff(d));
    t = [0; t];
    vsftemp = NaN.*zeros(length(t), size(vsfsmooth,2));
    tempstd = vsftemp;

    total = length(t);
    for count2 = 1:total-1
        if rem(count2,100) == 0,
            disp([num2str(count2) ' of ' num2str(total)]) 
        end;
        vsftemp(count2,:) = mean(vsfsmooth(t(count2)+1:t(count2+1),:),1);
        tempstd(count2,:) = std(vsfsmooth(t(count2)+1:t(count2+1),:),0,1);
    end;
    count2 = count2 + 1;
    vsftemp(count2,:) = mean(vsfsmooth(t(count2)+1:end,:),1);
    tempstd(count2,:) = std(vsfsmooth(t(count2)+1:end,:),0,1);
    
    vsfdaily=[vsfdaily; vsftemp];
    stdvsf=[stdvsf; tempstd];
end
clear y m d h mi s ecotemp tempstd total count2 count a ecosmooth ecostd
save ./BeamData/beamVSFdaily vsfdaily stdvsf vsftitles
%}