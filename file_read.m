function [matrix,head]=file_read(file,n_Lines)
% function [matrix,header]=file_read(file,n_lines)
%
% reads in a header of 'n_lines' from 'file' and
% then reads in data to 'matrix'.
%
% data must be uniform.  Number of elements in 
% each row or column should not change.


% open file 
	fid=fopen(file);
	
% preallocates an array for storing the header
% this header array may need to be adjusted 
% if header lines exceed 70 characters.

	head=setstr(32*ones(n_Lines,70));

% look thru header lines
% store maximum line length so that header
% array can be streamlined.
	max_Line_length=0;
	for i=1:n_Lines,
		Line=fgetl(fid);length_Line=length(Line);
        if length_Line==0; Line=' '; length_Line=1; end
		head(i,1:length_Line)=Line;
		max_Line_length=max([max_Line_length,length_Line]);
	end

	head=head(:,1:max_Line_length);

% read first line to determine the number of 
% columns

	data_start=ftell(fid);
	ncol=length(sscanf(fgets(fid),'%f'));
	fseek(fid,data_start,-1);
	
% read in rest of file as a column vector then reshape it to matrix
	[matrix,elements]=fscanf(fid,'%f');
	matrix=reshape(matrix,ncol,elements/ncol)';
fclose(fid);



