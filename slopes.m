%this script will find the mean and std of the slope at the following wavelengths;
%412,440,488,532,555,630,650, using non-linear lsqcurvefitting models
%SEM (single exponential model) and (HM (hyperbolic model, Twardowski,
%2004))


%load in the data from the 
function simbiosasapproc(excelfile,commentstr,cdomblnk,eventrange,type);

botfire=0; commentstr='still trying'; chlinc=0;
excelfile='mvcoproc.xls';
cdomblnk=0;
%create empty matrices
hm_S = []; sem_S = [];
all_acdom440 =[];
all_acdom675 = [];
all_aph440 = [];all_ad440 = [];
all_depth=[];
dates = [];

% open the summary page and get header information
channel=ddeinit('excel',['[',excelfile,']summary']);
cruise=ddereq(channel,'r1c3',[1 1]);
cruise=cruise(1:end-1);
cruisestartdate=ddereq(channel,'r2c3',[1 1]);
cruisestartdate=cruisestartdate(1:end-1);
investigators=ddereq(channel,'r4c3',[1 1]);
investigators=investigators(1:end-1);
experiment=ddereq(channel,'r5c3',[1 1]);
experiment=experiment(1:end-1);
contact=ddereq(channel,'r3c7',[1 1]); contact=contact(1:end-1);
datadir=ddereq(channel,'r6c3',[1 1]); datadir=datadir(1:end-1);
apfiltrad=ddereq(channel,'r2c7');
apfiltarea=pi*apfiltrad.^2;
[status,msg]=mkdir(datadir,'seabass');

% Get event details
eventno=ddereq(channel,'r10c1:r500c1');
eventtype=ddereq(channel,'r10c2:r500c2');
lat=ddereq(channel,'r10c9:r500c9');
long=ddereq(channel,'r10c10:r500c10');
waterdepth=ddereq(channel,'r10c11:r500c11');
secchidepth=ddereq(channel,'r10c12:r500c12');
cloudpercent=ddereq(channel,'r10c13:r500c13');
windspeed=ddereq(channel,'r10c14:r500c14');
winddirection=ddereq(channel,'r10c15:r500c15');
waveheight=ddereq(channel,'r10c16:r500c16');
matedate=ddereq(channel,'r10c4:r500c4');

% Work on event type 6 which is bucket with samples.
type = 6
if exist('eventrange','var')
    if length(eventrange)==1
        sampled=find(eventtype==type & eventno==eventrange);
    elseif length(eventrange)==type
        sampled=find(eventtype==type & eventno>=min(eventrange) & eventno<=max(eventrange));
    else 
        disp('Warning: event # range not recognized')
        disp('         Either use single event # or 2 component range.')
    end
else
    sampled=find(eventtype==type);
end
plotpos=0;

for rep=1:length(sampled)
    % read string data from the summary page for each cast
    cast=ddereq(channel,['r',num2str(9+sampled(rep)),'c3'],[1 1]); cast=cast(1:end-1);
    startdate=ddereq(channel,['r',num2str(9+sampled(rep)),'c4'],[1 1]); startdate=startdate(1:end-1);
    enddate=ddereq(channel,['r',num2str(9+sampled(rep)),'c5'],[1 1]); enddate=enddate(1:end-1);
    starttimeUTC=ddereq(channel,['r',num2str(9+sampled(rep)),'c7'],[1 1]); starttimeUTC=[starttimeUTC(1:end-1),':00'];
    endtimeUTC=ddereq(channel,['r',num2str(9+sampled(rep)),'c8'],[1 1]); endtimeUTC=[endtimeUTC(1:end-1),':00'];
    
    
    disp([cast,' ',startdate,' ',enddate,' ',starttimeUTC,' ',endtimeUTC])
    % Open the appropriate page of the excel file for the cast and read in data
    chan2=ddeinit('excel',['[',excelfile,']',num2str(eventno(sampled(rep)))]);
    depth=ddereq(chan2,'r6c2:r40c2');
    niskin=ddereq(chan2,'r6c1:r40c1');
    qualityflag=ddereq(chan2,'r6c12:r40c12');
    
    
    for rep2=1:length(depth)
        acdomfile=ddereq(chan2,['r',num2str(5+rep2),'c3'],[1 1]); acdomfile=acdomfile(1:end-1);
        acdomblankfile=ddereq(chan2,['r',num2str(5+rep2),'c4'],[1 1]); acdomblankfile=acdomblankfile(1:end-1);
        apfile=ddereq(chan2,['r',num2str(5+rep2),'c5'],[1 1]); apfile=apfile(1:end-1);
        adfile=ddereq(chan2,['r',num2str(5+rep2),'c6'],[1 1]); adfile=adfile(1:end-1);
        volfilt=ddereq(chan2,['r',num2str(5+rep2),'c13']);
        bassfile=['spec_',startdate,'_',starttimeUTC([1:2,4:5]),'_',repmat('0',1,3-size(num2str(round(depth(rep2))),2)),num2str(round(depth(rep2))),'m.sb'];
        bassfile_tex=['spec\_',startdate,'\_',starttimeUTC([1:2,4:5]),'\_',repmat('0',1,3-size(num2str(round(depth(rep2))),2)),num2str(round(depth(rep2))),'m.sb'];
        
        % Process acdom files
        disp([num2str(rep2),' ',acdomfile,' ',acdomblankfile,' ',apfile,' ',adfile,' ',num2str(volfilt)]);
        if ~strcmp(acdomfile,'-9999') %& (qualityflag(rep2)~=5 | qualityflag(rep2)~=4)% if there are as work with them
            dates = [dates;bassfile(6:13)];
            if ~strcmp(acdomblankfile,'-9999') & cdomblnk
                acdomblankfilename=[datadir,'\spectra\',acdomblankfile,'.sp']
            else
                acdomblankfilename='-9999';
            end
            [wvlncdom,acdom]=acdomspecproc([datadir,'\spectra\',acdomfile,'.sp'],acdomblankfilename,660,670);

%set up some parameters to use with the lsqcurvefit function
%c = lsqcurvefit(@(c,wave) c(1)*exp(-c(2)*(wave-wave0)),[.1 .01],wave,a, [0 0], [inf inf]) 
wave0 = [412 440 488 532 555 630 650];
i=find(wvlncdom<=650 & wvlncdom>=412);
wave = wvlncdom(i);
a = acdom(i);

for i = 1:length(wave0)
%NON-LINEAR FITTINGS
%hyberbolic model from Twardowski,2004, uses range 412-650nm with a
% wave0 of 412nm
%hm returns the single exponential least squares fit, hm(1)=acdom(wave0) and hm(2)=slope
%hm = lsqcurvefit(@(hm,wave) hm(1)*((wave/wave0).^-hm(2)),[.1 .01],wave,a, [0 0], [inf inf]) 
hm = lsqcurvefit(@(hm,wave) hm(1)*((wave/wave0(i)).^-hm(2)),[.1 .01],wave,a, [0 0], [inf inf])
hm_S = [hm_S;hm(2)];
end

s412 = mean(hm_S(1:36))
s440 = mean(hm_S(37:72))
s488 = mean(hm_S(73:108))
s532 = mean(hm_S(109:144))
s555 = mean(hm_S(145:180))
s630 = mean(hm_S(181:216))
s650 = mean(hm_S(217:end))

meanslopes = (s412+ s440+ s488+ s532+ s555+ s630 +s650)/7


slopes = [s412 s440 s488 s532 s555 s630 s650];
    stdpos412 = s412-std(hm_S(1:36));
    stdneg412 = s412+std(hm_S(1:36));
        stdpos440 = s440-std(hm_S(37:72));
        stdneg440 = s440+std(hm_S(37:72));
    stdpos488 = s488-std(hm_S(73:108));
    stdneg488 = s488+std(hm_S(73:108));
        stdpos532 = s532-std(hm_S(109:144));
        stdneg532 = s532+std(hm_S(109:144));
    stdpos555 = s555-std(hm_S(145:180));
    stdneg555 = s555+std(hm_S(145:180));
        stdpos630 = s630-std(hm_S(181:216));
        stdneg630 = s630+std(hm_S(181:216));
    stdpos650 = s650-std(hm_S(217:end));
    stdneg650 = s650+std(hm_S(217:end));
    
    subplot(2,1,1)
    plot(wave0,slopes,'.-')
    hold on
    plot([wave0(1),wave0(1)],[stdpos412,stdneg412],'gx:')
    plot([wave0(2),wave0(2)],[stdpos440,stdneg440],'gx:')
    plot([wave0(3),wave0(3)],[stdpos488,stdneg488],'gx:')
    plot([wave0(4),wave0(4)],[stdpos532,stdneg532],'gx:')
    plot([wave0(5),wave0(5)],[stdpos555,stdneg555],'gx:')
    plot([wave0(6),wave0(6)],[stdpos630,stdneg630],'gx:')
    plot([wave0(7),wave0(7)],[stdpos650,stdneg650],'gx:')
    

for i = 1:length(wave0)    
%sem returns the sem(1) = acdom(wave0) and sem(2) = slope
%this is an exponential decreasing function where the spectral slope sem(2)
%describes the relative steepness of the spectrum.
%sem(2) is used as a proxy for changes in the composition of CDOM
sem = lsqcurvefit(@(sem,wave) sem(1)*exp(-sem(2)*(wave-wave0(i))),[.1 .01],wave,a, [0 0], [inf inf]) 
sem_S = [sem_S;sem(2)];
end

s412 = mean(sem_S(1:36))
s440 = mean(sem_S(37:72))
s488 = mean(sem_S(73:108))
s532 = mean(sem_S(109:144))
s555 = mean(sem_S(145:180))
s630 = mean(sem_S(181:216))
s650 = mean(sem_S(217:end))

slopes = [s412 s440 s488 s532 s555 s630 s650];
    stdpos412 = s412-std(sem_S(1:36));
    stdneg412 = s412+std(sem_S(1:36));
        stdpos440 = s440-std(sem_S(37:72));
        stdneg440 = s440+std(sem_S(37:72));
    stdpos488 = s488-std(sem_S(73:108));
    stdneg488 = s488+std(sem_S(73:108));
        stdpos532 = s532-std(sem_S(109:144));
        stdneg532 = s532+std(sem_S(109:144));
    stdpos555 = s555-std(sem_S(145:180));
    stdneg555 = s555+std(sem_S(145:180));
        stdpos630 = s630-std(sem_S(181:216));
        stdneg630 = s630+std(sem_S(181:216));
    stdpos650 = s650-std(sem_S(217:end));
    stdneg650 = s650+std(sem_S(217:end));
    
    subplot(2,1,2)
    plot(wave0,slopes,'.-')
    hold on
    plot([wave0(1),wave0(1)],[stdpos412,stdneg412],'gx:')
    plot([wave0(2),wave0(2)],[stdpos440,stdneg440],'gx:')
    plot([wave0(3),wave0(3)],[stdpos488,stdneg488],'gx:')
    plot([wave0(4),wave0(4)],[stdpos532,stdneg532],'gx:')
    plot([wave0(5),wave0(5)],[stdpos555,stdneg555],'gx:')
    plot([wave0(6),wave0(6)],[stdpos630,stdneg630],'gx:')
    plot([wave0(7),wave0(7)],[stdpos650,stdneg650],'gx:')
