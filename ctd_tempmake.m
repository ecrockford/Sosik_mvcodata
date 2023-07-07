%ctd_tempmake.m imports all ctd data contained in the directory:
%\\Samwise\C:\data\MVCO\SurveyCruises and creats ctd_data3.mat of all
%downcast data
%Subfunctions unique to Sosik lab nested in this script:
% cnv2mat.m
% cnv2mat4hand.m
% sbread.m
% fxn_GCctdmat.m

% Read word document: CTDdata_MVCO_processing_organizing found in directory
% C:\Research Assistant\MVCO.
%meticulous file organization and formating is needed for this file to work

%Data is held within a 4D matrix. The 4th dimension is organized by data in
%sequential order. The 3rd dimesion is organized by station 1:8.
%Coordinates for each stations are part of the script below. If adjusting
%coordinates the folowing files also need to be adjusted:
% ctd_make.m
% ctd_make2.m
% check_coord.m
% ctd_make_stations2D.m
% chl_reps.m
% HPLC_reps.m
% MVCO_sample_reps.m
% nut_reps.m

%There should also always be a maximum of 8 casts for any given date. (Our
%max number of stations is 8.)

%If an error appears as the following:
%??? Attempted to access dm(2); index out of bounds because
%numel(dm)=1.
%
%Error in ==> cnv2mat at 70
%           lon=-(dm(1)+dm(2)/60);
%
%Error in ==> make_ctd2 at 29
%        [lat,lon,gtime,data,names,sensors]=cnv2mat(cnv_file);


%Be sure to check the file the script crashed on. Sometimes the lat, lon,
%and date data are mixed up. EX)
%* NMEA Latitude = 070 33.96 W
%* NMEA Longitude = 000000000000014:39:14
%* NMEA UTC (Time) = 41 11.97 N
%It should be:
%* NMEA Latitude = 41 11.97 N
%* NMEA Longitude = 070 33.96 W
%* NMEA UTC (Time) = 000000000000014:39:14
load setlatlon

ctd_dir = 'C:\data\MVCO\SurveyCruises\';
cruise_dir = dir('C:\data\MVCO\SurveyCruises\*_*');
cruisetemp=NaN(1,length(cruise_dir));
for i=1:length(cruise_dir)
    cruisetemp(i)=datenum(cruise_dir(i).name(end-6:end));
end
[folder,xi]=sort(cruisetemp);
depth_bins = 0:0.25:41;
ctd_down = NaN(length(depth_bins),20,8,length(cruise_dir));
ctd_header = {'depth m' 'pressure db' 'temperature deg C' 'conductivity S/m' 'salinity psu' 'density kg/m^3' 'fluorescence mg/m^3' 'turbidity ftu' 'beam attenuation 1/m' 'oxygen conc mg/l' 'PAR' 'altimeter m' 'bottom contact' 'bottles fired' 'time elapsed min' 'no scans per bin' 'flag' 'datenum' 'lat' 'lon'};

meta_data = [];
for i=1:length(cruise_dir)
    cruise = strcat(ctd_dir,cruise_dir(xi(i)).name,'\CTD\binned\');
    if strncmp(cruise_dir(xi(i)).name,'GC',2)
        filelist = dir([cruise,'IOP*']);
    else
        filelist = dir([cruise,'*Dbin*']);
    end
    if isempty(filelist)
        error('No files in filelist!')
    end
    for j = 1:length(filelist)
        file = strcat(cruise,filelist(j).name)
        if strcmp(file(end-2:end),'cnv') %& isempty(strfind(file,'hand'))
            [lat,lon,gtime,data,names,sensors]=cnv2mat(file,ctd_header);
            date = datenum(gtime);
%        elseif strcmp(file(end-2:end),'cnv') & ~isempty(strfind(file,'hand'))
%            [lat,lon,gtime,data,names,sensors]=cnv2mat4hand(file,ctd_header);
%            date = datenum(gtime);
        elseif strcmp(file(end-1:end),'sb')
            [sbdata,sbfields,sbunits,sbheader,sbfieldwvln]=sbread(file);
            [lat,lon,date,data]=fxn_GC2ctdmat(sbdata,sbfields,sbheader,ctd_header);
        else
            error('Unknown file type. File is not .cnv or .sb.')
        end
        temp = [date lat lon];
        meta_data = [meta_data; temp];
        if isnan(lat) | isempty(lat)
            error('Missing Latitude coordinate')
        elseif isnan(lon) | isempty(lon)
            error('Missing Longitude cooridnate')
        end
clear sbdata sbfields sbunits sbheader sbfieldwvln gtime
%setcoord_header={'station no'; 'bottom (S) lat'; 'top (N) lat'; 'right (E) lon';'left (W) lon'}
%Station 1ctd_down(:,:,1,:)
        if lat > setcoord(1,2) & lat < setcoord(1,3) & lon < setcoord(1,4) & lon > setcoord(1,5)
            ctd_down(:,18,1,i)=date;
            ctd_down(:,19,1,i)=lat;
            ctd_down(:,20,1,i)=lon;
            for k = 1:size(data,1)
                ctd_down(depth_bins == data(k,1),1:17,1,i)=data(k,:);
            end
        
%Station 2 = ctd_down(:,:,2,:)
        elseif lat > setcoord(2,2) & lat < setcoord(2,3) & lon < setcoord(2,4) & lon > setcoord(2,5)
            ctd_down(:,18,2,i)=date;
            ctd_down(:,19,2,i)=lat;
            ctd_down(:,20,2,i)=lon;
            for k = 1:size(data,1)
                ctd_down(depth_bins == data(k,1),1:17,2,i)=data(k,:);
            end
        
%Station 3 = ctd_down(:,:,3,:)
        elseif lat > setcoord(3,2) & lat < setcoord(3,3) & lon < setcoord(3,4) & lon > setcoord(3,5)
            ctd_down(:,18,3,i)=date;
            ctd_down(:,19,3,i)=lat;
            ctd_down(:,20,3,i)=lon;
            for k = 1:size(data,1)
                ctd_down(depth_bins == data(k,1),1:17,3,i)=data(k,:);
            end
        
%Station 4 = ctd_down(:,:,4,:)
        elseif lat > setcoord(4,2) & lat < setcoord(4,3) & lon < setcoord(4,4) & lon > setcoord(4,5)
            ctd_down(:,18,4,i)=date;
            ctd_down(:,19,4,i)=lat;
            ctd_down(:,20,4,i)=lon;
            for k = 1:size(data,1)
                ctd_down(depth_bins == data(k,1),1:17,4,i)=data(k,:);
            end
        
%Station 5 = ctd_down(:,:,5,:)
        elseif lat > setcoord(5,2) & lat < setcoord(5,3) & lon < setcoord(5,4) & lon > setcoord(5,5)
            ctd_down(:,18,5,i)=date;
            ctd_down(:,19,5,i)=lat;
            ctd_down(:,20,5,i)=lon;
            for k = 1:size(data,1)
                ctd_down(depth_bins == data(k,1),1:17,5,i)=data(k,:);
            end
        
%Station 6 = ctd_down(:,:,6,:)
        elseif lat > setcoord(6,2) & lat < setcoord(6,3) & lon < setcoord(6,4) & lon > setcoord(6,5)
            ctd_down(:,18,6,i)=date;
            ctd_down(:,19,6,i)=lat;
            ctd_down(:,20,6,i)=lon;
            for k = 1:size(data,1)
                ctd_down(depth_bins == data(k,1),1:17,6,i)=data(k,:);
            end
        
%Station 7 = ctd_down(:,:,7,:)
        elseif lat > setcoord(7,2) & lat < setcoord(7,3) & lon < setcoord(7,4) & lon > setcoord(7,5)
            ctd_down(:,18,7,i)=date;
            ctd_down(:,19,7,i)=lat;
            ctd_down(:,20,7,i)=lon;
            for k = 1:size(data,1)
                ctd_down(depth_bins == data(k,1),1:17,7,i)=data(k,:);
            end
        
%Station 8 = ctd_down(:,:,8,:)
        elseif lat > setcoord(8,2) & lat < setcoord(8,3) & lon < setcoord(8,4) & lon > setcoord(8,5)
            ctd_down(:,18,8,i)=date;
            ctd_down(:,19,8,i)=lat;
            ctd_down(:,20,8,i)=lon;
            for k = 1:size(data,1)
                ctd_down(depth_bins == data(k,1),1:17,8,i)=data(k,:);
            end
%Station out of range?!
        else error('Crazy lat/lon coordinates!!')
        end
    end
end

clear ans cruise filelist filename cnv_file lat lon gtime data date ctd_dir i j k temp
station_title = ['S1'; 'S2'; 'S3'; 'S4'; 'S5'; 'S6'; 'S7'; 'S8'];

save ctd_data3 ctd_down cruise_dir ctd_header meta_data names sensors station_title