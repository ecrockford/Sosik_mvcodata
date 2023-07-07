function [data,fields,units,header,fieldwvln]=sbread(sbfile);
% [data,fields,units,header,fieldwvln]=sbread(sbfile);
% Reads in data from SeaBASS files and assigns field names to 'fields', units
% to 'units', data to 'data', and header parameters to 'header'.  List of 
% header parameters is in 'header.parameters' and all of the header text is in
% 'header.all'.  Time in the format hh:mm:ss is reformated to decimal hours and
% inserted in place of the orignal.  Uses function NEAREST.M


% Ru Morrison, 18-July-2001.
% Modified, 18-Feb-2002 as file TIES9602_2_partscan.dat did not have @ at end of
% header line.  See note below.
% Also excluded some 'E's from letter replacement in data string as these can be part
% of exponential notation.  The function may not work correctly if there are E's which
% do not fit the logic below.

% Open file
inprop=dir(sbfile);

if isempty(inprop)
    disp('Warning:  file not found')
    data=[];fields=[];units=[];header=[];fieldwvln=[];
    return
end
    
i=[1:inprop.bytes-12];
fid=fopen(sbfile,'rb');
if fid==-1
    data=[];fields=[];units=[];header=[];fieldwvln=[];
    return
end

allfile=fread(fid,inprop.bytes,'uchar');
fclose(fid);
allfile=setstr(allfile);

% Line below orignally used but file 'TIES9602_2_partscan.dat' retrieved from SEABASS on 15 Feb 2002
% did not have '@' at the end of the end header line.
%datastart=find(allfile(i)=='/' & allfile(i+1)=='e' & allfile(i+2)=='n' & allfile(i+11)=='@')+12;
datastart=find(allfile(i)=='/' & allfile(i+1)=='e' & allfile(i+2)=='n' & allfile(i+5)=='h')+12;
allfiles=allfile(1:datastart-1)';

% find end of lines
endline=find(double(allfiles==10));
n_Lines=length(endline)+1;

fid=fopen(sbfile);
head=setstr(32*ones(n_Lines,70));

% look thru header lines
% store maximum line length so that header
% array can be streamlined.
	max_Line_length=0;
	for i=1:n_Lines,
		Line=fgetl(fid);length_Line=length(Line);
		head(i,1:length_Line)=Line;
		max_Line_length=max([max_Line_length,length_Line]);
	end

	head=head(:,1:max_Line_length);
fclose(fid);

% Define header information to extract;
headerinfo=strvcat('investigators','affiliations','contact','experiment','cruise','station','data_file_name','documents', ...
   'calibration_files','data_type','data_status','start_date','end_date','start_time','end_time','north_latitude', ...
   'south_latitude','east_longitude','west_longitude','cloud_percent','measurement_depth','secchi_depth', ...
   'water_depth','wave_height','wind_speed','missing','delimiter','original_file_name');
typefile=find(double(allfile)==13);
if isempty(typefile)
   endlineoff=1;
else
   endlineoff=2;
end

for rep=1:size(headerinfo,1)
   tobefound=['/',deblank(headerinfo(rep,:))];
   hpos=strmatch(tobefound,head);
   headval=deblank(head(hpos,size(tobefound,2)+2:end));
   eval(['header.',tobefound(2:end),'=headval;']);
end
header.parameters=headerinfo;
comments=strmatch('!',head);
header.comments=deblank(head(comments,:));
header.all=head;
   
% find field line
fieldline=strmatch('/fields',head);
fieldline=deblank(head(fieldline,9:end));

% Parse field line
fields=[]; tflag=0;
commas=[0,findstr(fieldline,','),length(fieldline)+1];
for rep=2:length(commas);
   field=fieldline(commas(rep-1)+1:commas(rep)-1);
   fields=strvcat(fields,field);
   if strcmp('time',field)
      tflag=1; tpos=size(fields,1);
   end
end
fields=cellstr(fields)';

% Extract wavelengths from fields if appropriate
field1=strvcat(fields);
for rep=1:size(field1,1);
    wvln=double(deblank(field1(rep,:)));
    numbers=find((wvln>=48 & wvln<=57) | wvln==46);
    if isempty(numbers)
        fieldwvln(rep)=NaN;
    else
        fieldwvln(rep)=str2num(field1(rep,numbers));
    end
end


% find unit line
unitline=strmatch('/units',head);
unitline=deblank(head(unitline,8:end));

% Parse unit line
units=[];
commas=[0,findstr(unitline,','),length(unitline)+1];
for rep=2:length(commas);
   units=strvcat(units,unitline(commas(rep-1)+1:commas(rep)-1));
end
units=cellstr(units)';

% handle data
datastr=allfile(datastart:length(allfile))';
% replace letters with numbers apart from 'E's which may be part of 
% exponential notation.
% N.B. The 'E' exclusion was added on 18-Feb-2002 and may cause function to crash
% if E's other than exponents in datastr.
datastr=upper(datastr);
% find the E's
Es=find(double(datastr)==69);
if length(Es)>0
    % determine if E's part of exponential notation by studying characters before and after
    % 1) Any E at the end of the datastr is not exponent
    if Es(end)==length(datastr)
        datastr(Es(end))='0'; Es(end)=[];
    end
    % 2) Check to see if character after is a number or a +/- sign and
    % that before is a number as well.
    bad=find((double(datastr(Es+1))<49 | double(datastr(Es+1))>57) & ...
        datastr(Es+1)~='-' & datastr(Es+1)~='+' & double(datastr(Es-1))>=49 ... 
        & double(datastr(Es-1))<=57);
    % Replace bad E's with 0's
    datastr(Es(bad))='0';
end

datastr(find(double(datastr)>=65 & double(datastr)<=122 & double(datastr)~=69))='0';
% replace ':' with spaces
datastr(find(datastr==':'))=' ';
data=str2num(datastr);
if isempty(data)  % str2num not used.
	fid=fopen('temp.txt','w'); % data saved to temporary ascii file and then read in
	fwrite(fid,datastr);       % This is due to the str2num function being unable to cope
	fclose(fid);               % with some data from some files such as microtops-s990810w.txt.sb
	load temp.txt              % but the load function seems to be able to.
	data=temp;
end
% Determine if there is time data field and process to include in data matrix.
if tflag
   dectime=data(:,tpos)+data(:,tpos+1)/60+data(:,tpos+2)/3600;
   % insert decimal time into data matrix
   if tpos==1
      data=[dectime,data(4:end)];
   elseif tpos==size(fields,1)
      data=[data(1:end-4),dectime];
   else
      data=[data(:,1:tpos-1),dectime,data(:,tpos+3:end)];
   end
   
end

