%sbpath = '\\128.128.110.99\lunac\data\mvcodata\seabass\';
sbpath = 'C:\work\mvco\discrete_spectra\seabass\';
sbpath = 'C:\data\mvcodata\spectra\seabass_temp\';

filelist = dir([sbpath 'spec*.sb']);

cd(sbpath)

for count = 1:length(filelist),
    
    figure(1), clf
    [data,fields,units,header]=sbread(filelist(count).name)
    plot(data(:,1), data(:,[2,3,4,5]))
    title(filelist(count).name, 'interpreter', 'none')
    %ylim([0 1])
    axis([300 800 0 1])
    pause
end;