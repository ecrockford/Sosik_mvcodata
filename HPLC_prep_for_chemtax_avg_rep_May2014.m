%This file pulls prevelent information from the HPLC mat file created from
%the database and HPLCproc.xl and organizes it in a format that is readily
%inputted into Chemtax to get diatom, flagellate, etc. estimates. 
%~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
%!!! need to make sure HPLC_reps has been run first. and that database is
%up to date
%~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
clear all
%loads HPLC, header
load MVCO_HPLC_reps
%combine duplicates into 1 column instead of a&b side by side in matrix for
%less coding later on. make station matrix matchup with new, elongated hplc
%matrix (i.e. a & b samples stacked 1 on top of other - not side by side

%get them out of cell array so can treat at numbers and get rid of below
%detection limit values. set BDL to zero
hplca       = cell2mat(HPLC(:,9:58));
hplcb       = cell2mat(HPLC(:,61:end-1));%end is reb b quality flag 

%change to double, make all below detection
%limit values (0.000999 and -111) to zero values for chemtax use. BDL
%values were originally supplied as 0.000999 and were changed to -111 in
%late 2013 (for seabass purposes)
BDL         = find(hplca < 0.001);%below detection limit
hplca(BDL)  = 0;
BDL         = find(hplcb < 0.001);%below detection limit
hplcb(BDL)  = 0;

%need to average HPL duplicates, easiest to put back in original matrix and
%loop through so don't have to deap with pairing down meta-data when
%getting rid of duplicate rows
HPLC(:,9:58)     = num2cell(hplca);
HPLC(:,61:end-1) = num2cell(hplcb);
clear BDL hplca hplcb

%AVERAGE DUPLICATES IN LOOP FOR BOTH OURS AND HPL 
unq_hsno = unique(HPLC(:,8)); %HPLC duplicates have same HS number
%pre-allocate new matrix to fill in loop
hplc = repmat(HPLC(1,1:59),length(unq_hsno),1); %need new matrix because removing duplicate rows messes up indexing in loop
duplicates = zeros(length(unq_hsno),1);%keep track if value is avg of duplicate (either Sosik lab or HPL-not differentiated)
stations = duplicates;
for count=1:length(unq_hsno) 
    ind=find(strcmp(HPLC(:,8),unq_hsno(count))); 
    hplc(count,:) = HPLC(ind(1),1:59); %need meta data, insert averaged values in row below
    stations(count) = station4hplc(ind(1));
    if length(ind)==2
        hplca = nanmean(cell2mat(HPLC(ind,9:59)));%avg HPL duplicates - avg inclues quality flag
        hplcb = nanmean(cell2mat(HPLC(ind,61:end)));%duplicate will have same values, but average just in case, avg includes quality flag
        hplc(count,9:end) = num2cell(nanmean([hplca; hplcb]));%average rep a&b
        duplicates(count) = 2;
    elseif length(ind)>2
        fprintf(['\n \n There were more than 2 rows found for sample ' cell2mat(unq_hsno(count)) '.\n \n Keyboard in use to investigate. \n'])
        keyboard; %why is there more than 1 duplicate? HPL duplicate on one of our duplicates?
    else
        hplc(count,9:end) = num2cell(nanmean([cell2mat(HPLC(ind,9:59)); cell2mat(HPLC(ind,61:end))]));%just avg rep a&b
        if ~strcmp(HPLC(ind,60),'null') 
            duplicates(count) = 1; 
        end
    end; 
end

header4chemtax={'Year','Month','Day','Hour','Minute','Second','CTD NO.','Sample ID','Depth(m)','Date','Time_GMT','Station_number','Latitude_S','Longitude_E',...
    'TChlb','TChlc','Carot','HexFuc','ButFuc','Allox','Diadin','Diatox','Fucox','Perid','Chl_c12','Chl_c3','Zeaxan','Neoxan','Violax','Prasin','Lutein','Tchla','quality'};

%reformat date for proper Chemtax format. Convert to matlab matday number
%because easier to manipulate below.
tempdate = cell2mat(hplc(:,3));
temptime = cell2mat(hplc(:,4));
matdate=datenum([tempdate(:,1:11) temptime(:,12:19)]);
[y,i] = sort(matdate);
matdate = y;
hplc = hplc(i,:);
duplicates = duplicates(i);
stations = stations(i);
ymdhhmmss = num2cell(datevec(matdate));
%date
date2 = [cellstr(datestr(matdate,'mm/dd/yyyy')) cellstr(datestr(matdate,'hh:mm:ss'))];

clear i y temp*

%get out just the MVCO samples (exclude the Cramer cruise samples)
%HPLC_pigments=cell(length(ind),25);
%Bottle number; Sample ID number/HS###; sample depth
ID = [hplc(:,2) hplc(:,8)]; %HS### will be missing rep b label... whatever
depth = hplc(:,7);

%Lat, Lon
latlon=hplc(:,5:6);
%pigments, found them individually in case need to rearrange later. Used
%averages from hplc varialbe that has different indicies than HPLC variable
TChlb   = hplc(:,10);
TChlc   = hplc(:,11);
Carot   = hplc(:,12);
HexFuc  = hplc(:,14);
ButFuc  = hplc(:,13);
Allox   = hplc(:,15);
Diadin  = hplc(:,16);
Diatox  = hplc(:,17);
Fucox   = hplc(:,18);
Perid   = hplc(:,19);
Chl_c12 = hplc(:,28);
Chl_c3  = hplc(:,29);
Zeaxan  = hplc(:,20);
Neoxan  = hplc(:,31);
Violax  = hplc(:,32);
Prasin  = hplc(:,35);
Lutein  = hplc(:,30);
TChla   = hplc(:,9);
quality = hplc(:,end);
%combine all pigment columns, 
%use num2cell below to change data double matrix back to cell matrix to
%combine for final variable for ease of using xlswrite below.
data = [TChlb TChlc Carot HexFuc ButFuc Allox Diadin Diatox Fucox Perid Chl_c12 Chl_c3 Zeaxan Neoxan Violax Prasin Lutein TChla];
%combine all the individual pieces into one usuable matrix. some pieces of
%matrix numbers, other pieces strings, etc.
HPLC_pigments  = [ymdhhmmss ID depth date2 num2cell(stations) latlon data quality];

%save mat file with all MVCO sample HPLC pigment results
save HPLC_pigments_for_chemtax_avg_rep_May2014 HPLC_pigments header4chemtax duplicates


%save just surface sample MVCO HPLC's with surface being >= 4m
ind = find(cell2mat(depth) <= 3.5);
HPLC_surf_pig=HPLC_pigments(ind,:);
surf_duplicates = duplicates(ind);
save HPLC_surface_pigments_for_chemtax_avg_reps HPLC_surf_pig header4chemtax surf_duplicates
%save in excel format for Emily to use in Chemtax - takes out apostrophe's
%in cell array
%updates HPLC_pigments.xls with a new worksheet with all data. the new worksheet is
%labeled with the date it was update.
excel=[header4chemtax;HPLC_pigments];
[status,message]=xlswrite('HPLC_pigments.xls',excel,['HPLC_Data_' date])

%{
%save pigment version to plot
hpmeta = [ID date1 date2 date3 time station4hplc latlon];
hpdepth = cell2mat(ID(:,3));
hpstation = cell2mat(station4hplc);
hplat = cell2mat(latlon(:,1));
hplon = cell2mat(latlon(:,2));
pigments = cell2mat([pig8 pig1 pig2 pig3 pig4 pig5 pig6 pig7]);
header_pig = {'Tchl','TChlb','TChlc','Carot','HexFuc','ButFuc','Allox','Diadin','Diatox','Fucox','Perid','Zeaxan','Neoxan','Violax','Prasin','Lutein'};
save HPLC_MVCO_pigments4plot.mat hp* header_pig pigments duplicates
clear pig* date8 time ID latlon date* HPLC HPLC_a HPLC_b date header i ind time hp* header_pig start_of_dup

clear excel HPLC_surf_pig message status surf_dup
%}