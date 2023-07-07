function [lat,lon,date,data]=fxn_GC2ctdmat(sbdata,sbfields,sbheader,ctd_header);
%****** [sbdata,fields,units,header,fieldwvln]=sbread(sbfile);
%[lat,lon,gtime,data,names,sensors]
%depth_bins = 0:0.25:41;

data = NaN(size(sbdata,1),length(ctd_header)-3);
lat=str2num(sbheader.north_latitude(1:7));
lon=str2num(sbheader.east_longitude(1:7));
a=datestr(datenum(sbheader.start_date,'yyyymmdd'),'dd-mmm-yyyy');
date=datenum([a ' ' sbheader.start_time(1:8)]);
clear a

t = find(strcmp(sbfields, 'depth'));
u = find(strcmp(ctd_header, 'depth m'));
if ~isempty(t) & ~isempty(u)
    data(:,u) = sbdata(:,t);
end
    
t = find(strcmp(sbfields, 'wt'));
u = find(strcmp(ctd_header, 'temperature deg C'));
if ~isempty(t) & ~isempty(u)
    data(:,u) = sbdata(:,t);
end

t = find(strcmp(sbfields, 'sal'));
u = find(strcmp(ctd_header, 'salinity psu'));
if ~isempty(t) & ~isempty(u)
    data(:,u) = sbdata(:,t);
end

%############################## NOT CORRECT UNITS! NEED MG/M^3 NOT VOLTS!
t = find(strcmp(sbfields, 'stimf'));
u = find(strcmp(ctd_header, 'fluorescence mg/m^3'));
if ~isempty(t) & ~isempty(u)
    data(:,u) = sbdata(:,t);
end

%########################## NOT CORRECT UNITS! NEED MG/L NOT UMOL/L!!!
t = find(strcmp(sbfields, 'oxygen'));
u = find(strcmp(ctd_header, 'oxygen conc mg/l'));
if ~isempty(t) & ~isempty(u)
    data(:,u) = sbdata(:,t);
end

ind=find(data==-9999);
data(ind)=data(ind)*nan;

return