%this processes the as data from spec .sb files into seabass format
%and using the lsqcurvefit.m function to extract the Slope, S

sbdir = 'C:\data\mvcodata\seabass\';
filelist = dir([sbdir,'spec*']);
wavelength = [];

ag = [];
ap = [];
ad = [];
aph = [];
dates = [];
allfiles = [];
cruises = [];
stations = [];

for filecount = 1:length(filelist),
    filecount
    [sdata,sfields,sunits,sheader]=sbread([sbdir,filelist(filecount).name]);
    filename = filelist(filecount).name  
    
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
    
    swvln=squeeze(sdata(:,1,1));
    
    allfile = repmat(filename,size(sdata,1),1);
    allfiles = [allfiles;allfile];
    cruise = repmat(sheader.cruise,size(sdata,1),1);
    cruises = [cruises;cruise];
    station = repmat(sheader.station,size(sdata,1),1);
    stations = [stations;station];
    date = repmat(sheader.start_date,size(sdata,1),1);
    dates = [dates;date];
   

    clear t
end;
% 
Y = dates(:,1:4);
Y = str2num(Y);
M = dates(:,5:6);
M = str2num(M);
D = dates(:,7:8);
D = str2num(D);
dates = datenum(Y,M,D)
ind350 = find(wavelength==350);
ind440 = find(wavelength==440);
ind675 = find(wavelength==675);



%set up some parameters to use with the lsqcurvefit function
%c = lsqcurvefit(@(c,wave) c(1)*exp(-c(2)*(wave-wave0)),[.1 .01],wave,a, [0 0], [inf inf]) 
wave0 = 412;
i=find(wvlncdom<=650 & wvlncdom>=350);
wave = wvlncdom(i);
a = acdom(i);

% c = lsqcurvefit(@(c,wave) c(1)*((wave/wave0).^-c(2)),[.1 .01],wave,a, [0 0], [inf inf]) 
c = lsqcurvefit(@(c,wave) c(1)*exp(-c(2)*(wave-wave0)),[.1 .01],wave,a, [0 0], [inf inf]) 
%c(1) is acdom(wave0), c(2) is slope S
all_cdom_S = [all_cdom_S;c(2)];

j = find(wvlncdom==440);
acdom440 = acdom(j);
all_acdom440 = [all_acdom440;acdom440];

k = find(wvlncdom==675);
acdom675 = acdom(k);
all_acdom675 = [all_acdom675;acdom675];
              
            %plot the acdom data
            plotpos=plotpos+1;
            if plotpos>6, plotpos=1; figure; orient tall; set(gcf,'position',[236    62   789   870]); end
            subplot(3,2,plotpos)
            goodcdom=find(wvlncdom>=300 & wvlncdom<=850);
            plot(wvlncdom(goodcdom),acdom(goodcdom),'y.-')
            hold on
            %title([cruise,', ',num2str(eventno(sampled(rep))),' ,',cast,', ',num2str(depth(rep2)),', ',bassfile_tex])
            title([cruise,', ',' ,',cast,', ',num2str(depth(rep2)),', ',bassfile_tex])
            xlabel('Wavelength (nm)','fontsize',6)
            ylabel('absorption (m^{-1})')
            axis([300 750 -.005 max(acdom(goodcdom))])
            plot(440,acdom(wvlncdom==440),'rs')
        end
        
        % Process ap and ad files.
        if (~strcmp(apfile,'-9999') | ~strcmp(adfile,'-9999')) %& (qualityflag(rep2)~=5 | qualityflag(rep2)~=4)% if there are ap and ad files work on them
            % Process ap and ad files
            if ~strcmp(apfile,'-9999')
                apfilename=[datadir,'\spectra\',apfile,'.sp'];
            else
                apfilename=apfile;
            end
            if ~strcmp(adfile,'-9999')
                adfilename=[datadir,'\spectra\',adfile,'.sp'];
            else 
                adfilename=adfile;
            end
            disp(apfilename)
            [wvln,ap,aph,ad]=apspecproc(apfilename,adfilename,volfilt*1e-6,apfiltarea*1e-4,780,800);
            all_aph440 = [all_aph440;aph(wvln==440)];
            all_ad440 = [all_ad440;ad(wvln==440)];
            
            

            % Plot ap and ad results
            good=find(wvln>=300 & wvln<=850);
           if ~exist('acdom','var');plotpos=plotpos+1; end
           if plotpos>6; plotpos = 1; figure; end
            subplot(3,2,plotpos)
            plot(wvln(good),[ap(good),aph(good),ad(good)],'.-');
            title([cruise,', ',num2str(eventno(sampled(rep))),' ,',cast,', ',num2str(depth(rep2)),', ',bassfile_tex],'fontsize',7)
            xlabel('Wavelength (nm)','fontsize',6)
            ylabel('absorption (m^{-1})','fontsize',6)
            %legend('a_{CDOM}','a_p','a_d','a_{ph}')
            axis([300 750 -.005 max(max([ap(good),aph(good),ad(good)]))])
            if exist('acdom','var')
            text(600,ap(wvln==600)+.15,['a_{cdom}(440): ',num2str(acdom(wvlncdom==440))],'fontsize',7)
% %             text(600,ap(wvln==600)+.075,['S: ',num2str(S)],'fontsize',7)
            text(600,ap(wvln==600)+0.075,['S: ',num2str(c(2))],'fontsize',7)
            end
            

        end
        
        if exist('ap','var') & ~exist('acdom','var')
            acdom=repmat(-9999,length(ap),1);
            goodcdom=[1:length(good)]';
        elseif exist('acdom','var') & ~exist('ap','var')
            ap=repmat(-9999,length(acdom),1);
            ad=repmat(-9999,length(acdom),1);
            aph=repmat(-9999,length(acdom),1);
            good=goodcdom;
            wvln=wvlncdom;
        end
        
        if exist('ap','var') & exist('acdom','var')
            if botfire
                botn=find(bot==niskin(rep2));
                if ~isempty(botn)
                    commentstr=strvcat(commentstr1,['Niskin ',num2str(niskin(rep2)),' fire time: ',dastr(botn,end-7:end),'[GMT]']);
                    firedate=datevec(dastr(botn,:))
                    firem=num2str(firedate(2)); if length(firem)<2; firem=['0',firem]; end
                    fired=num2str(firedate(3)); if length(fired)<2; fired=['0',fired]; end
                    firedate=[num2str(firedate(1)),firem,fired];
                    commentstr=strvcat(commentstr,['Fire date: ',firedate]);
                else
                    commentstr=strvcat(commentstr1,['No matching bottle information in CTD bottle file.']);
                end
            end
            if chlinc
                cdmatch=find(round(cdata(:,1))==round(depth(rep2)))
                if length(cdmatch)>1
                    chlvals=nanmean(cdata(cdmatch,2:end));
                elseif length(cdmatch)==1 
                    chlvals=cdata(cdmatch,2:end);
                else
                    chlvals=ones(1,3)*-9999;
                end
                commentstr=strvcat(commentstr,['Fluorometric Pigments:  Chl, Pheo, Tpg (all mg/m^3):',num2str(chlvals(1)),',',num2str(chlvals(2)),',',num2str(chlvals(3))]);
                aphstar=aph./chlvals(1);
                if chlvals(1)<0
                    aphstar=ones(size(aph)).*-9999; 
                end
            end
            
% % %             fid=fopen([datadir,'\seabass\',bassfile],'W');
% % %             fprintf(fid,'/begin_header\n'); 
% % %             fprintf(fid,'/data_file_name=%-20s\n',bassfile); 
% % %             fprintf(fid,'/affiliations=WHOI\n'); 
% % %             fprintf(fid,'/investigators=%-20s\n',investigators); 
% % %             fprintf(fid,'/experiment=%-20s\n',experiment); 
% % %             fprintf(fid,'/cruise=%-20s\n',cruise);
% % %             fprintf(fid,'/station=%-20s\n',cast); 
% % %             fprintf(fid,'/contact=%-s\n',contact); 
% % %             fprintf(fid,'/data_type=scan\n'); 
% % %             fprintf(fid,'/data_status=preliminary\n');
% % %             fprintf(fid,'/documents=%-s_report.txt\n',cruise);
% % %             fprintf(fid,'/calibration_files=no_calibration.txt\n');
% % %             fprintf(fid,'/north_latitude=%-3.4f[DEG]\n',lat(sampled(rep))); 
% % %             fprintf(fid,'/south_latitude=%-3.4f[DEG]\n',lat(sampled(rep))); 
% % %             fprintf(fid,'/east_longitude=%-3.4f[DEG]\n',long(sampled(rep))); 
% % %             fprintf(fid,'/west_longitude=%-3.4f[DEG]\n',long(sampled(rep))); 
% % %             fprintf(fid,'/start_date=%-8s\n',startdate); 
% % %             fprintf(fid,'/end_date=%-8s\n',enddate); 
% % %             fprintf(fid,'/start_time=%-8s[GMT]\n',starttimeUTC); 
% % %             fprintf(fid,'/end_time=%-8s[GMT]\n',endtimeUTC); 
% % %             fprintf(fid,'/wind_speed=%-5.0f\n',windspeed(sampled(rep)));
% % %             fprintf(fid,'/wave_height=%-5.0f\n',waveheight(sampled(rep)));
% % %             fprintf(fid,'/secchi_depth=%-5.0f\n',secchidepth(sampled(rep)));
% % %             fprintf(fid,'/measurement_depth=%-5.0f\n',depth(rep2));
% % %             fprintf(fid,'/water_depth=%-5.0f\n',waterdepth(sampled(rep)));
% % %             fprintf(fid,'/cloud_percent=%-5.0f\n',cloudpercent(sampled(rep)));
% % %             fprintf(fid,'/original_file_name=%-s,%-s,%s\n',acdomfile,apfile,adfile);
% % %             fprintf(fid,'!\n'); 
% % %             fprintf(fid,'! spectrophotometer: Lambda 18;\n'); 
% % %             fprintf(fid,'! serial number: 75009\n'); 
% % %             fprintf(fid,'! Data are from 850 to 300 nm.\n'); 
% % %             fprintf(fid,'! All have a 1 nm step.\n'); 
% % %             fprintf(fid,'! Beta pathlength amplification factor algorithm from\n');
% % %             fprintf(fid,'! Mitchell, B.G., Ocean Optics X, p.137-148, 1990\n');
% % %             fprintf(fid,'! Volume filtered: %-5.0f ml\n',volfilt)
% % %             
% % %             
% % %             if ~strcmp(acdomblankfile,'-9999') & cdomblnk
% % %                 fprintf(fid,'! acdom blank file: %s\n',acdomblankfile);
% % %             end
% % %             for comrep=1:size(commentstr,1)
% % %                 fprintf(fid,'! %-s\n',commentstr(comrep,:));
% % %             end
% % %             fprintf(fid,'!\n'); 
% % %             fprintf(fid,'/missing=-9999\n');
% % %             fprintf(fid,'/delimiter=space\n'); 
% % %             if ~chlinc
% % %                 fprintf(fid,'/fields=wavelength,ag,ap,ad,aph\n'); 
% % %                 fprintf(fid,'/units=nm,1/m,1/m,1/m,1/m\n'); 
% % %             else 
% % %                 fprintf(fid,'/fields=wavelength,ag,ap,ad,aph,a*ph\n'); 
% % %                 fprintf(fid,'/units=nm,1/m,1/m,1/m,1/m,m^2/mg\n'); 
% % %             end
% % %             fprintf(fid,'/end_header@\n');
% % %             if ~chlinc
% % %                 for rep3=1:length(good)
% % %                     fprintf(fid,'%-3.0f %-5.6f %-5.6f %-5.6f %-5.6f\n',wvln(good(rep3)),acdom(goodcdom(rep3)),ap(good(rep3)),ad(good(rep3)),aph(good(rep3)));
% % %                 end
% % %             else
% % %                 for rep3=1:length(good)
% % %                     fprintf(fid,'%-3.0f %-5.6f %-5.6f %-5.6f %-5.6f %-5.6f\n',wvln(good(rep3)),acdom(goodcdom(rep3)),ap(good(rep3)),ad(good(rep3)),aph(good(rep3)),aphstar(good(rep3)));
% % %                 end
% % %             end
% % %             fclose(fid);
            save S_acdom440_values.mat all_cdom_S all_acdom440 all_acdom675  matedate all_aph440 all_ad440
            clear ap aph ad acdom wvln wvlncdom good goodcdom
        end  
        
    end
   
end