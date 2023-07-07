%HPLC_reps
%last updated 5/7/14 Taylor
%last updated 9/12/16 Taylor
%!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!
%must run this script in 32-bit Matlab in order to successfully connect to
%Microsoft Access database (as of May2014 - Microsoft 2010, Matlab 2014a 32-bit
%!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!
%
% connecting to Access through ODBC database driver. must be setup through:
% C:\Windows\SysWOW64\odbcad32.exe
% setup ms access dbase connection. name must match script database below.
% Winodws 10 - set up 
% add "Microsoft Access Driver (*.mdb)"

% need to set up .mbd connection. Once slected there will be an option of
% data base with 'select' 'create' 'repair' 'compact'. Use selcted to
% select most updated data base. 
% in this case: SOSIK_Database
%

%HPLC_reps
%Creates the variable 'HPLC_reps' as a cell array  
    % Set preferences with setdbprefs.
    s.DataReturnFormat = 'cellarray';
    s.ErrorHandling = 'store';
    s.NullNumberRead = 'NaN';
    s.NullNumberWrite = 'NaN';
    s.NullStringRead = 'null';
    s.NullStringWrite = 'null';
    s.JDBCDataSourceFile = '';
    s.UseRegistryForSources = 'yes';
    s.TempDirForRegistryOutput = '';
    setdbprefs(s)

% See more database notes above.
% Make connection to database.  Note that the password has been omitted.
% Using ODBC driver. If getting error when trying to close(e) make sure
% that the ODBC driver is pointing to the correct (most up-to-date)
% database. **** OLD ODBC in 32-bit comp Check connection by going to Control Panel > Administrative
% Tools > Data Sources (ODBC)
conn = database('SOSIK_Database','','password');

% Read data from database.  
% Make the SQL statement easily with querybuilder and paste in here - or select all fields with *
%SQL_query = 'SELECT ALL Event_Number,Event_Number_Niskin,Date,Start_Time_UTC,Latitude,Longitude,Depth,HPLC_a,HPLC_a_amt_filt,HPLC_a.Vx_mL,HPLC_a.Total_Chl_a,HPLC_a.Total_Chl_b,HPLC_a.Total_Chl_c,HPLC_a.Carotene,HPLC_a.But_Fucoxanthin,HPLC_a.Hex_Fucoxanthin,HPLC_a.Alloxanthin,HPLC_a.Diadinoxanthin,HPLC_a.Diatoxanthin,HPLC_a.Fucoxanthin,HPLC_a.Peridinin,HPLC_a.Zeaxanthin,HPLC_a.Monovinyl_Chl_a,HPLC_a.Divinyl_Chl_a,HPLC_a.Chlorophyllide_a,HPLC_a.Monovinyl_Chl_b,HPLC_a.Divinyl_Chl_b,HPLC_a.Chlorophyll_c1,HPLC_a.Chlorophyll_c2,HPLC_a.Chlorophyll_c12,HPLC_a.Chlorophyll_c3,HPLC_a.Lutein,HPLC_a.Neoxanthin,HPLC_a.Violaxanthin,HPLC_a.Pheophytin,HPLC_a.Pheophorbide_a,HPLC_a.Prasinoxanthin,HPLC_a.Gyroxanthin_Diester,HPLC_a.TChl,HPLC_a.PPC,HPLC_a.PSC,HPLC_a.PSP,HPLC_a.TCaro,HPLC_a.TAcc,HPLC_a.Tpig,HPLC_a.DP,HPLC_a.TAcc/Tchla,HPLC_a.PSC/TCaro,HPLC_a.PPC/Tcaro,HPLC_a.TChl/TCaro,HPLC_a.PPC/Tpig,HPLC_a.PSP/TPig,HPLC_a.TChla/TPig,HPLC_a.microplankton,HPLC_a.nanoplankton,HPLC_a.picoplankton,HPLC_a.FL_Chl_a,HPLC_a.FL_Pheo,HPLC_a.Chl_a_Allomer,HPLC_a.Chl_a_Epimer,HPLC_b,HPLC_b_amt_filt,HPLC_b.Vx_mL,HPLC_b.Total_Chl_a,HPLC_b.Total_Chl_b,HPLC_b.Total_Chl_c,HPLC_b.Carotene,HPLC_b.But_Fucoxanthin,HPLC_b.Hex_Fucoxanthin,HPLC_b.Alloxanthin,HPLC_b.Diadinoxanthin,HPLC_b.Diatoxanthin,HPLC_b.Fucoxanthin,HPLC_b.Peridinin,HPLC_b.Zeaxanthin,HPLC_b.Monovinyl_Chl_a,HPLC_b.Divinyl_Chl_a,HPLC_b.Chlorophyllide_a,HPLC_b.Monovinyl_Chl_b,HPLC_b.Divinyl_Chl_b,HPLC_b.Chlorophyll_c1,HPLC_b.Chlorophyll_c2,HPLC_b.Chlorophyll_c12,HPLC_b.Chlorophyll_c3,HPLC_b.Lutein,HPLC_b.Neoxanthin,HPLC_b.Violaxanthin,HPLC_b.Pheophytin,HPLC_b.Pheophorbide_a,HPLC_b.Prasinoxanthin,HPLC_b.Gyroxanthin_Diester,HPLC_b.TChl,HPLC_b.PPC,HPLC_b.PSC,HPLC_b.PSP,HPLC_b.TCaro,HPLC_b.TAcc,HPLC_b.Tpig,HPLC_b.DP,HPLC_b.TAcc/Tchla,HPLC_b.PSC/TCaro,HPLC_b.PPC/Tcaro,HPLC_b.TChl/TCaro,HPLC_b.PPC/Tpig,HPLC_b.PSP/TPig,HPLC_b.TChla/TPig,HPLC_b.microplankton,HPLC_b.nanoplankton,HPLC_b.picoplankton,HPLC_b.FL_Chl_a,HPLC_b.FL_Pheo,HPLC_b.Chl_a_Allomer,HPLC_b.Chl_a_Epimer FROM HPLC_reps';


%!!!!!!!! the query in Access is already set up to filter out ONLY MVCO
%samples!!! not other existing samples (such as Cramer cruise sampels)
SQL_query = 'SELECT ALL * from HPLC_reps';  %get all field from the table HPLC_reps
% SQL_query = 'SELECT ALL * from MVCO_HPLC';  %get all field from the table HPLC_reps
e =exec(conn, SQL_query);

%e = exec(conn,'SELECT ALL Event_Number,Event_Number_Niskin,Date,Start_Time_UTC,Latitude,Longitude,Depth,HPLC_a,HPLC_a_amt_filt,HPLC_a.Vx_mL,HPLC_a.Total_Chl_a,HPLC_a.Total_Chl_b,HPLC_a.Total_Chl_c,HPLC_a.Carotene,HPLC_a.But_Fucoxanthin,HPLC_a.Hex_Fucoxanthin,HPLC_a.Alloxanthin,HPLC_a.Diadinoxanthin,HPLC_a.Diatoxanthin,HPLC_a.Fucoxanthin,HPLC_a.Peridinin,HPLC_a.Zeaxanthin,HPLC_a.Monovinyl_Chl_a,HPLC_a.Divinyl_Chl_a,HPLC_a.Chlorophyllide_a,HPLC_a.Monovinyl_Chl_b,HPLC_a.Divinyl_Chl_b,HPLC_a.Chlorophyll_c1,HPLC_a.Chlorophyll_c2,HPLC_a.Chlorophyll_c12,HPLC_a.Chlorophyll_c3,HPLC_a.Lutein,HPLC_a.Neoxanthin,HPLC_a.Violaxanthin,HPLC_a.Pheophytin,HPLC_a.Pheophorbide_a,HPLC_a.Prasinoxanthin,HPLC_a.Gyroxanthin_Diester,HPLC_a.TChl,HPLC_a.PPC,HPLC_a.PSC,HPLC_a.PSP,HPLC_a.TCaro,HPLC_a.TAcc,HPLC_a.Tpig,HPLC_a.DP,HPLC_a.TAcc/Tchla,HPLC_a.PSC/TCaro,HPLC_a.PPC/Tcaro,HPLC_a.TChl/TCaro,HPLC_a.PPC/Tpig,HPLC_a.PSP/TPig,HPLC_a.TChla/TPig,HPLC_a.microplankton,HPLC_a.nanoplankton,HPLC_a.picoplankton,HPLC_a.FL_Chl_a,HPLC_a.FL_Pheo,HPLC_a.Chl_a_Allomer,HPLC_a.Chl_a_Epimer,HPLC_b,HPLC_b_amt_filt,HPLC_b.Vx_mL,HPLC_b.Total_Chl_a,HPLC_b.Total_Chl_b,HPLC_b.Total_Chl_c,HPLC_b.Carotene,HPLC_b.But_Fucoxanthin,HPLC_b.Hex_Fucoxanthin,HPLC_b.Alloxanthin,HPLC_b.Diadinoxanthin,HPLC_b.Diatoxanthin,HPLC_b.Fucoxanthin,HPLC_b.Peridinin,HPLC_b.Zeaxanthin,HPLC_b.Monovinyl_Chl_a,HPLC_b.Divinyl_Chl_a,HPLC_b.Chlorophyllide_a,HPLC_b.Monovinyl_Chl_b,HPLC_b.Divinyl_Chl_b,HPLC_b.Chlorophyll_c1,HPLC_b.Chlorophyll_c2,HPLC_b.Chlorophyll_c12,HPLC_b.Chlorophyll_c3,HPLC_b.Lutein,HPLC_b.Neoxanthin,HPLC_b.Violaxanthin,HPLC_b.Pheophytin,HPLC_b.Pheophorbide_a,HPLC_b.Prasinoxanthin,HPLC_b.Gyroxanthin_Diester,HPLC_b.TChl,HPLC_b.PPC,HPLC_b.PSC,HPLC_b.PSP,HPLC_b.TCaro,HPLC_b.TAcc,HPLC_b.Tpig,HPLC_b.DP,HPLC_b.TAcc/Tchla,HPLC_b.PSC/TCaro,HPLC_b.PPC/Tcaro,HPLC_b.TChl/TCaro,HPLC_b.PPC/Tpig,HPLC_b.PSP/TPig,HPLC_b.TChla/TPig,HPLC_b.microplankton,HPLC_b.nanoplankton,HPLC_b.picoplankton,HPLC_b.FL_Chl_a,HPLC_b.FL_Pheo,HPLC_b.Chl_a_Allomer,HPLC_b.Chl_a_Epimer FROM HPLC_reps');

e = fetch(e);

%Create header file with metadata
%creates a 1x113 struct with the metadata information
attributes = attr(e);
header_hplc = cellstr(strvcat(attributes.fieldName));

close(e)

% Close database connection.
close(conn)
    
%Create a variable 'HPLC_reps' which equals the data contained in
%the variable 'e'
HPLC=e.Data;
    
clear e conn s exec_str tempstr SQL* attributes
%Make station labeling matrix for matching up all the different types of
%data (including ctd casts)
lat = cell2mat(HPLC(:,5)); 
lon = cell2mat(HPLC(:,6));
station4hplc = NaN(length(HPLC),1);

load setlatlon
for i=1:length(station4hplc)
    if lat(i) > setcoord(1,2) && lat(i) < setcoord(1,3) && lon(i) < setcoord(1,4) && lon(i) > setcoord(1,5)
        station4hplc(i) = 1;
    elseif lat(i) > setcoord(2,2) && lat(i) < setcoord(2,3) && lon(i) < setcoord(2,4) && lon(i) > setcoord(2,5)
        station4hplc(i) = 2;
     elseif lat(i) > setcoord(3,2) && lat(i) < setcoord(3,3) && lon(i) < setcoord(3,4) && lon(i) > setcoord(3,5)
         station4hplc(i) = 3;
     elseif lat(i) > setcoord(4,2) && lat(i) < setcoord(4,3) && lon(i) < setcoord(4,4) && lon(i) > setcoord(4,5)
         station4hplc(i) = 4;
     elseif lat(i) > setcoord(5,2) && lat(i) < setcoord(5,3) && lon(i) < setcoord(5,4) && lon(i) > setcoord(5,5)
         station4hplc(i) = 5;
     elseif lat(i) > setcoord(6,2) && lat(i) < setcoord(6,3) && lon(i) < setcoord(6,4) && lon(i) > setcoord(6,5)
         station4hplc(i) = 6;
     elseif lat(i) > setcoord(7,2) && lat(i) < setcoord(7,3) && lon(i) < setcoord(7,4) && lon(i) > setcoord(7,5)
         station4hplc(i) = 7;
    elseif lat(i) > setcoord(8,2) && lat(i) < setcoord(8,3) && lon(i) < setcoord(8,4) && lon(i) > setcoord(8,5)
         station4hplc(i) = 8;
    else
        error('HPLC out of lat/lon station ranges!')
    end
end
clear i lat lon 


%Save workspace variables as a .mat file
save('MVCO_HPLC_reps.mat','HPLC','station4hplc','header_hplc');
