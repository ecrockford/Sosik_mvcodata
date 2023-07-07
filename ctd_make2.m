%NOTE: All ctd casts must have an associated lat/lon coordinate to be
%called into matlab with the current .m file setup. The .m file ctd_make
%does not rely upon lat/lon to organize the matrix so you could potentially
%get around this problem, however each cast should have lat/lon to begin
%with.
%There should also always be a maximum of 8 casts for any given date. (Our
%max number of stations is 8.)

%If files are missing lat/lon go to the Tioga data archives on the WHOI
%internal website and match up the ship data lat/lon with the timestamps.
%Could also get this data from the Athena underway data that we sometimes
%get with the original cast data from the Tioga. Check the folders. The
%data is already in UTC time for these Tioga archive files. Could also get 
%this data from the Athena underway data that we sometimes get with the 
%original cast data from the Tioga. Check the folders. The data is already 
%in UTC time for these Tioga archive files. 

%NOTE: All ctd cast files must be in the same directory format to
%get called in with the automated setup
%MVCO>SurveyCruises>Tioga_###_date>CTD>binned

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


ctd_dir = 'C:\data\MVCO\SurveyCruises\';
cruise_dir = dir('C:\data\MVCO\SurveyCruises\Tioga*');
depth_bins = 0:0.25:41;
ctd_down = NaN(length(depth_bins),20,8,length(cruise_dir));
ctd_up = NaN(length(depth_bins),20,8,length(cruise_dir));
ctd_header = {'depth m' 'pressure db' 'temperature deg C' 'conductivity S/m' 'salinity psu' 'density kg/m^3' 'fluorescence mg/m^3' 'turbidity ftu' 'beam attenuation 1/m' 'oxygen conc mg/l' 'PAR' 'altimeter m' 'bottom contact' 'bottles fired' 'time elapsed min' 'no scans per bin' 'flag' 'datenum' 'lat' 'lon'};

%     Input:  cnv_file = name of .CNV file  (e.g. 'cast002.cnv')
%
%     Output: lon = longitude in decimal degrees, West negative
%             lat = latitude in decimal degrees, North positive
%           gtime = Gregorian time vector in UTC
%            data = matrix containing all the columns of data in the .CNV file
%           names = string matrix containing the names and units of the columns
%         sensors = string matrix containing the names of the sensors
%
load setlatlon %mat file that is adjusted as stations coordinates are tweaked
%station coord are used in multiple .m files. instead of changing them in
%every individual file, the setlatlon.m file can be adjusted and will
%effect ever file that needs the coordinates.
for i=1:length(cruise_dir)
    cruise = strcat(ctd_dir,cruise_dir(i).name,'\CTD\binned\');
    filelist = dir([cruise,'*Dbin*']);
    if length(filelist) == 0
        error('No files in filelist!')
    end
    for j = 1:length(filelist)
        cnv_file = strcat(cruise,filelist(j).name)
        [lat,lon,gtime,data,names,sensors]=cnv2mat(cnv_file);
        date = datenum(gtime);
        if isnan(lat)
            error('Missing Latitude coordinate')
        elseif isnan(lon)
            error('Missing Longitude cooridnate')
        end
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
meta_data = [];
for i=1:length(cruise_dir)
    cruise = strcat(ctd_dir,cruise_dir(i).name,'\CTD\binned\');
    filelist = dir([cruise,'*Ubin*']);
    if length(filelist) == 0
        error('No files in filelist!')
    end
    for j = 1:length(filelist)
        cnv_file = strcat(cruise,filelist(j).name)
        [lat,lon,gtime,data,names,sensors]=cnv2mat(cnv_file);
        date = datenum(gtime);
        temp = [date lat lon];
        meta_data = [meta_data; temp];
        if isnan(lat)
            error('Missing Latitude coordinate')
        elseif isnan(lon)
            error('Missing Longitude cooridnate')
        end
%Station 1 = ctd_up(:,:,1,:)
        if lat > setcoord(1,2) & lat < setcoord(1,3) & lon < setcoord(1,4) & lon > setcoord(1,5)
            ctd_up(:,18,1,i)=date;
            ctd_up(:,19,1,i)=lat;
            ctd_up(:,20,1,i)=lon;
            for k = 1:size(data,1)
                ctd_up(depth_bins == data(k,1),1:17,1,i)=data(k,:);
            end
        
%Station 2 = ctd_up(:,:,1,:)
        elseif lat > setcoord(2,2) & lat < setcoord(2,3) & lon < setcoord(2,4) & lon > setcoord(2,5)
            ctd_up(:,18,2,i)=date;
            ctd_up(:,19,2,i)=lat;
            ctd_up(:,20,2,i)=lon;
            for k = 1:size(data,1)
                ctd_up(depth_bins == data(k,1),1:17,2,i)=data(k,:);
            end
        
%Station 3 = ctd_up(:,:,3,:)
        elseif lat > setcoord(3,2) & lat < setcoord(3,3) & lon < setcoord(3,4) & lon > setcoord(3,5)
            ctd_up(:,18,3,i)=date;
            ctd_up(:,19,3,i)=lat;
            ctd_up(:,20,3,i)=lon;
            for k = 1:size(data,1)
                ctd_up(depth_bins == data(k,1),1:17,3,i)=data(k,:);
            end
        
%Station 4 = ctd_up(:,:,4,:)
        elseif lat > setcoord(4,2) & lat < setcoord(4,3) & lon < setcoord(4,4) & lon > setcoord(4,5)
            ctd_up(:,18,4,i)=date;
            ctd_up(:,19,4,i)=lat;
            ctd_up(:,20,4,i)=lon;
            for k = 1:size(data,1)
                ctd_up(depth_bins == data(k,1),1:17,4,i)=data(k,:);
            end
        
%Station 5 = ctd_up(:,:,5,:)
        elseif lat > setcoord(5,2) & lat < setcoord(5,3) & lon < setcoord(5,4) & lon > setcoord(5,5)
            ctd_up(:,18,5,i)=date;
            ctd_up(:,19,5,i)=lat;
            ctd_up(:,20,5,i)=lon;
            for k = 1:size(data,1)
                ctd_up(depth_bins == data(k,1),1:17,5,i)=data(k,:);
            end
        
%Station 6 = ctd_up(:,:,6,:)
        elseif lat > setcoord(6,2) & lat < setcoord(6,3) & lon < setcoord(6,4) & lon > setcoord(6,5)
            ctd_up(:,18,6,i)=date;
            ctd_up(:,19,6,i)=lat;
            ctd_up(:,20,6,i)=lon;
            for k = 1:size(data,1)
                ctd_up(depth_bins == data(k,1),1:17,6,i)=data(k,:);
            end
        
%Station 7 = ctd_up(:,:,7,:)
        elseif lat > setcoord(7,2) & lat < setcoord(7,3) & lon < setcoord(7,4) & lon > setcoord(7,5)
            ctd_up(:,18,7,i)=date;
            ctd_up(:,19,7,i)=lat;
            ctd_up(:,20,7,i)=lon;
            for k = 1:size(data,1)
                ctd_up(depth_bins == data(k,1),1:17,7,i)=data(k,:);
            end
        
%Station 8 = ctd_up(:,:,8,:)
        elseif lat > setcoord(8,2) & lat < setcoord(8,3) & lon < setcoord(8,4) & lon > setcoord(8,5)
            ctd_up(:,18,8,i)=date;
            ctd_up(:,19,8,i)=lat;
            ctd_up(:,20,8,i)=lon;
            for k = 1:size(data,1)
                ctd_up(depth_bins == data(k,1),1:17,8,i)=data(k,:);
            end
%Station out of range?!
        else error('Crazy lat/lon coordinates!!')
        end

    end
end
clear ans cruise filelist filename cnv_file lat lon gtime data date ctd_dir i j k temp
station_title = ['S1'; 'S2'; 'S3'; 'S4'; 'S5'; 'S6'; 'S7'; 'S8'];

save ctd_data2