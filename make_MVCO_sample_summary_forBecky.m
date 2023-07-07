%Taylor March 2018

%make tables of chl/nut/hplc data for Becky for "cilliate analysis"
%only pull dates for sequency samples
%make table for surface and separate table for 2nd shallowest depth "6m"
%make table with individual replicates and also table with averages
%fields without data have NaN
clear all, close all

load MVCO_sample_summary
% load('\\sosiknas1\Lab_data\Grazers\EnvironmentalData\genetics_dates.mat')
load('\\sosiknas1\Lab_data\Grazers\EnvironmentalData\genetics_dates_corrected20180315.mat')

%convert text date and time from cells to matdate
ind_date = find(strcmp(header_summary,'Start_Date'));
datetemp = cell2mat(MVCO_sample_summary(:,ind_date));
ind_time = find(strcmp(header_summary,'Start_Time_UTC'));
timetemp = cell2mat(MVCO_sample_summary(:,ind_time));
matdate  = datenum([datetemp repmat(' ',length(timetemp),1) timetemp]);

%only want to look at samples from dates of grazer sampling
MVCO_sample_summary = MVCO_sample_summary(ismember(floor(matdate),date),:); %date is grazer sampling date variable
MVCO_sample_avg     = MVCO_sample_avg(ismember(floor(matdate),date),:);
matdate             = matdate(ismember(floor(matdate),date),:);

%only care about 'surface' and '6m' samples at MVCO, make samples_of_interest
ind_depth           = find(strcmp(header_summary,'Depth'));
%%%%%%%%%%%%%%%%%%%%%%WHAT ABOUT DOUBLE SURF SAMPLING AT 2M ROSETTE AND BUCKET%%%%%%%%%%%%%%%%%%%%%%

%want same size matrix for surface samples and 6m but separate matrixes for
%the 2 different depths. use unq_event to get correct size
unq_event           = unique(MVCO_sample_summary(:,1));

%pre-allocate matrix to make new cell matrix that gets rid of extra rows.
%probably more efficient way to rid rows but good enough for now
MVCO_grazer_surface     = cell(length(unq_event),size(MVCO_sample_summary,2)); 
MVCO_grazer_surface_avg = cell(length(unq_event),size(MVCO_sample_avg,2)); 
MVCO_grazer_6m          = MVCO_grazer_surface;
MVCO_grazer_6m_avg      = MVCO_grazer_surface_avg;

for count = 1:length(unq_event)
%find all water depths for given event (i.e. date)
    temp = MVCO_sample_summary(strcmp(MVCO_sample_summary(:,1),unq_event(count)),:);
    tempavg = MVCO_sample_avg(strcmp(MVCO_sample_avg(:,1),unq_event(count)),:);

    %find surface samples, designated as shallower than 4m depth
    ind_surf = find(cell2mat(temp(:,ind_depth)) < 4);
    if length(ind_surf)>1
        error('More than 1 surf sample!')
    else
        MVCO_grazer_surface(count,:) = temp(ind_surf,:);
        MVCO_grazer_surface_avg(count,:) = tempavg(ind_surf,:);
    end
    %find 2nd shallowest depth samples, referred to as "6m"
    ind_6m =  find(cell2mat(temp(:,ind_depth))>=4 & cell2mat(temp(:,ind_depth))<9);
    if ~isempty(ind_6m)
        MVCO_grazer_6m(count,:) = temp(ind_6m,:);
        MVCO_grazer_6m_avg(count,:) = tempavg(ind_6m,:);
    else 
        MVCO_grazer_6m(count,1:7) = temp(ind_surf,1:7);
        MVCO_grazer_6m(count,8:end) = repmat(num2cell(NaN),size(temp,2)-7,1);
        MVCO_grazer_6m_avg(count,:) = MVCO_grazer_6m(count,1:size(MVCO_grazer_6m_avg,2));
    end
end
clear MVCO_s* count ind* temp* unq*

%a bit unnecessary to make matdate_MVCO but easier for plotting than
%referencing a potentially different sized matrix of grazer_dates 
ind_date = find(strcmp(header_summary,'Start_Date'));
ind_time = find(strcmp(header_summary,'Start_Time_UTC'));
datetemp = cell2mat(MVCO_grazer_surface(:,ind_date));
timetemp = cell2mat(MVCO_grazer_surface(:,ind_time));
date_MVCO  = datenum([datetemp repmat(' ',length(timetemp),1) timetemp]);
%do we want year day?
%get yearday in case needed (helpful for comparing to ifcb5 data?)
temp     = datevec(date_MVCO);
yearday  = date_MVCO - datenum(temp(:,1),0,0);
date_grazer = date;

clear *temp* ind* matdate station4sum date

save grazer_environmental_data
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%DEAL WITHI MULTIPLE SURF SAMPLES? BOTH 2M NISKIN AND 0M BUCKET??

