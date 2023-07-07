%Made by Taylor. First plots ctd cast station locations on lat/lon grid.
%Second, reorganizes ctd_data 4-d matrix into 2-d matrix organized by
%station number for both up and down casts. Up casts are labled with up, 
%down casts are not labeled The last column (21) is the station number. 

%load ctd_data2
load ctd_data_edited
load setlatlon
lat = meta_data(:,2);
lon = meta_data(:,3);

ind1 = find(lat > 41.12 & lat < 41.17 & lon < -70.53 & lon > -70.6);
ind2 = find(lat > 41.19 & lat < 41.21 & lon < -70.53 & lon > -70.6);
ind3 = find(lat > 41.23 & lat < 41.26 & lon < -70.53 & lon > -70.6);
ind4 = find(lat > 41.31 & lat < 41.33 & lon < -70.56 & lon > -70.58);
ind5 = find(lat > 41.33 & lat < 41.34 & lon < -70.55 & lon > -70.562);
ind6 = find(lat > 41.32 & lat < 41.35 & lon < -70.59 & lon > -70.66);
ind7 = find(lat > 41.32 & lat < 41.335 & lon < -70.49 & lon > -70.52);
ind8 = find(lat > 41.3 & lat < 41.33 & lon < -70.41 & lon > -70.46);

w = setcoord(:,4)-setcoord(:,5);
h=setcoord(:,3)-setcoord(:,2);

colormat = [1 0 0;1 0 1; 1 .8 1; 1 .6 0;1 1 0; 0 1 0; 0 1 1;.8 .6 1];

figure
for i=1:8
    rectangle('Position',[coord(i,4) coord(i,3) w(i) h(i)],'FaceColor',colormat(i,:))
end

hold on
plot(lon(:),lat(:),'k.')
plot(lon(ind1,:),lat(ind1,:),'b.')
plot(lon(ind2,:),lat(ind2,:),'y.')
plot(lon(ind3,:),lat(ind3,:),'r.')
plot(lon(ind4,:),lat(ind4,:),'c.')
plot(lon(ind5,:),lat(ind5,:),'g.')
plot(lon(ind6,:),lat(ind6,:),'m.')
plot(lon(ind7,:),lat(ind7,:),'r+')
plot(lon(ind8,:),lat(ind8,:),'b+')
ylabel('Latitude (deg N)');
xlabel('Longitude (deg W)');
title('Locations of 8 MVCO stations with CTD casts');
legend('all','st1', 'st2', 'st3', 'st4', 'st5', 'st6', 'st7', 'st8')

clear lat lon coord w h colormat i ind*


st1 =[]; st1_up = [];
st2 =[]; st2_up = [];
st3 =[]; st3_up = [];
st4 =[]; st4_up = [];
st5 =[]; st5_up = [];
st6 =[]; st6_up = [];
st7 =[]; st7_up = [];
st8 =[]; st8_up = [];

%Arranging data by station in individual matrix for down cast
for cruise_no = 1:size(ctd_down,4)
    lat=ctd_down(20,19,:,cruise_no);
    lon=ctd_down(20,20,:,cruise_no);

    ind1 = find(lat > 41.12 & lat < 41.17 & lon < -70.53 & lon > -70.6);
    ind2 = find(lat > 41.19 & lat < 41.21 & lon < -70.53 & lon > -70.6);
    ind3 = find(lat > 41.23 & lat < 41.26 & lon < -70.53 & lon > -70.6);
    ind4 = find(lat > 41.31 & lat < 41.33 & lon < -70.56 & lon > -70.58);
    ind5 = find(lat > 41.33 & lat < 41.34 & lon < -70.55 & lon > -70.562);
    ind6 = find(lat > 41.32 & lat < 41.35 & lon < -70.59 & lon > -70.66);
    ind7 = find(lat > 41.32 & lat < 41.335 & lon < -70.49 & lon > -70.52);
    ind8 = find(lat > 41.3 & lat < 41.33 & lon < -70.41 & lon > -70.46);
    
    temp_st1 = ctd_down(:,:,ind1,cruise_no);
    if ~isempty(temp_st1)
        st1 = [st1; temp_st1];
    end

    temp_st2 = ctd_down(:,:,ind2,cruise_no);
    if ~isempty(temp_st2)
        st2 = [st2; temp_st2];
    end

    temp_st3 = ctd_down(:,:,ind3,cruise_no);
    if ~isempty(temp_st3)
        st3 = [st3; temp_st3];
    end

    temp_st4 = ctd_down(:,:,ind4,cruise_no);
    if ~isempty(temp_st4)
        st4 = [st4; temp_st4];
    end

    temp_st5 = ctd_down(:,:,ind5,cruise_no);
    if ~isempty(temp_st5)
        st5 = [st5; temp_st5];
    end

    temp_st6 = ctd_down(:,:,ind6,cruise_no);
    if ~isempty(temp_st6)
        st6 = [st6; temp_st6];
    end

    temp_st7 = ctd_down(:,:,ind7,cruise_no);
    if ~isempty(temp_st7)
        st7 = [st7; temp_st7];
    end
    
    temp_st8 = ctd_down(:,:,ind8,cruise_no);
    if ~isempty(temp_st8)
        st8 = [st8; temp_st8];
    end
end

%Arranging data by station in individual matrix for up cast
for cruise_no = 1:size(ctd_down,4)
    lat=ctd_up(20,19,:,cruise_no);
    lon=ctd_up(20,20,:,cruise_no);

    ind1 = find(lat > 41.12 & lat < 41.17 & lon < -70.53 & lon > -70.6);
    ind2 = find(lat > 41.19 & lat < 41.21 & lon < -70.53 & lon > -70.6);
    ind3 = find(lat > 41.23 & lat < 41.26 & lon < -70.53 & lon > -70.6);
    ind4 = find(lat > 41.31 & lat < 41.33 & lon < -70.56 & lon > -70.58);
    ind5 = find(lat > 41.33 & lat < 41.34 & lon < -70.55 & lon > -70.562);
    ind6 = find(lat > 41.32 & lat < 41.35 & lon < -70.59 & lon > -70.66);
    ind7 = find(lat > 41.32 & lat < 41.335 & lon < -70.49 & lon > -70.52);
    ind8 = find(lat > 41.3 & lat < 41.33 & lon < -70.41 & lon > -70.46);

    temp_st1 = ctd_up(:,:,ind1,cruise_no);
    if ~isempty(temp_st1)
        st1_up = [st1_up; temp_st1];
    end

    temp_st2 = ctd_up(:,:,ind2,cruise_no);
    if ~isempty(temp_st2)
        st2_up = [st2_up; temp_st2];
    end

    temp_st3 = ctd_up(:,:,ind3,cruise_no);
    if ~isempty(temp_st3)
        st3_up = [st3_up; temp_st3];
    end

    temp_st4 = ctd_up(:,:,ind4,cruise_no);
    if ~isempty(temp_st4)
        st4_up = [st4_up; temp_st4];
    end

    temp_st5 = ctd_up(:,:,ind5,cruise_no);
    if ~isempty(temp_st5)
        st5_up = [st5_up; temp_st5];
    end

    temp_st6 = ctd_up(:,:,ind6,cruise_no);
    if ~isempty(temp_st6)
        st6_up = [st6_up; temp_st6];
    end

    temp_st7 = ctd_up(:,:,ind7,cruise_no);
    if ~isempty(temp_st7)
        st7_up = [st7_up; temp_st7];
    end
    
    temp_st8 = ctd_up(:,:,ind8,cruise_no);
    if ~isempty(temp_st8)
        st8_up = [st8_up; temp_st8];
    end
end

clear temp* lat lon ind*

st1(:,21) = 1; st1_up(:,21) = 1;
st2(:,21) = 2; st2_up(:,21) = 2;
st3(:,21) = 3; st3_up(:,21) = 3;
st4(:,21) = 4; st4_up(:,21) = 4;
st5(:,21) = 5; st5_up(:,21) = 5;
st6(:,21) = 6; st6_up(:,21) = 6;
st7(:,21) = 7; st7_up(:,21) = 7;
st8(:,21) = 8; st8_up(:,21) = 8;
all_stations = []; all_stations_up = [];
all_stations = [st1;st2;st3;st4;st5;st6;st7;st8];
all_stations_up = [st1_up;st2_up;st3_up;st4_up;st5_up;st6_up;st7_up;st8_up];
ctd_header(21) = {'station no'};
station_titles = ['Station 1'; 'Station 2'; 'Station 3'; 'Station 4'; 'Station 5'; 'Station 6'; 'Station 7'; 'Station 8'];
station_title = ['S1'; 'S2'; 'S3'; 'S4'; 'S5'; 'S6'; 'S7'; 'S8'];


save ctd_station_data all* names sensors ctd_header cruise_dir meta_data station_title*