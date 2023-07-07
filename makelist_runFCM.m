%import data regarding samples that have been run and associated cytometer
%file names
[num,txt,raw] = xlsread('C:\data\mvcodata\FCM\MVCO_FCMs_ver2.xls','Sheet2');

%filter out only MVCO samples
MVsample=zeros(length(raw),1);
for count=1:length(MVsample)
    if ~isnan(cell2mat(raw(count,4)))
        run_sample_id = char(raw(count,4));
        MVsample(count)=strcmp(run_sample_id(1:2),'MV'); 
    end
end
ind=find(MVsample==1);

files=dir('C:\Research Assistant\MVCO\FCMs\MEL*');
filename={files.name}';
file_found=[];
for count=1:length(ind)
    temp = raw(ind(count),1);
    if sum(strcmp(filename,temp)) > 0
        file_found= [file_found; raw(ind(count),4) raw(ind(count),1)];
    end
end

load FCM_sample_list
header(11) = {'Cyto File Name'};
year = str2num(datestr(matdate,'yyyy'));

data(:,end+1)={NaN};
for count = 1:length(file_found)
    ind = find(strcmp(data(:,2),file_found(count,1)));
    if sum(ind)>0
        data(ind,end) = file_found(count,2);
    else fprintf(['\n' cell2mat(file_found(count,1)) '\n \n'])
    end
end

clear count ind txt testind temp num run_sample_id file* raw

run_equals_1 = zeros(length(data),1);
for count = 1:length(data)
    if ~isnan(cell2mat(data(count,end)))>0
%        keyboard
    run_equals_1(count) = 1;
    end
end

number_of_samples_run = sum(run_equals_1);
number_of_samples_exists = length(ind_yesfcm);