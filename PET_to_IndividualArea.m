% make_individual_area from fid directory list
% Script to make an individual area
% 
% put irA_fid.nii and ic1rV_fid.nii in ./fid directory
% from MATLAB command window:
% >> listD=dir("M_*")
% >> PET_to_IndividualAtlas(listD)

function PET_to_IndividualArea(Dlist)
% definition
numarea=116;
temp_tol=0.001;

%% Select T1 file and atlas file
numfiles = length(Dlist);
for kk = 1:numfiles
	fid=Dlist(kk).name;
	p1vol=strcat(pwd,'/',fid,'/','irA_',fid,'.nii,1'); % double quotation not allowed!!
	a1vol=strcat(pwd,'/',fid,'/','ic1rV_',fid,'.nii,1'); % double quotation not allowed!!
	%fid_prefix=strcat(fid,'_'); % double quotation not allowed!!
	fprintf(strcat("PET input :	",p1vol,"\n"))
	fprintf(strcat("Atlas input :	",a1vol,"\n"))

	for ii = 1:numarea
		% call subroutine
		temp_output=char(strcat('iirA_',fid,'_',sprintf('%03d',ii),'.nii'));
		PET_to_IndividualArea_sub(p1vol,a1vol,ii,temp_tol,temp_output);

		fprintf(strcat("area ",string(ii),"/",string(numarea)," of fid ",string(kk),"/",string(numfiles)," done\n"))
	end % for ii = 1:numarea

	% move results
	%mkdir(fid);
	status=movefile(strcat("i*",fid,"_*.nii"),fid);

end % for 
end % function PET_to_IndividualArea(Dlist)

function PET_to_IndividualArea_sub(p1vol,a1vol,area_no,temp_tol,temp_output)

temp_exp=char(strcat('i1.*((i2>',string(area_no-temp_tol),')&(i2<',string(area_no+temp_tol),'))'));

%% Initialize
spm_jobman('initcfg');
matlabbatch={};

%% Prepare the SPM window
% interactive window (bottom-left) to show the progress, 
% and graphics window (right) to show the result of coregistration 

%spm('CreateMenuWin','on'); %Comment out if you want the top-left window.
spm('CreateIntWin','on');
%spm_figure('Create','Graphics','Graphics','on');

%% batch
matlabbatch{1}.spm.util.imcalc.input = {
                                        p1vol
                                        a1vol
                                        };
matlabbatch{1}.spm.util.imcalc.output = temp_output;
matlabbatch{1}.spm.util.imcalc.outdir = {''};
matlabbatch{1}.spm.util.imcalc.expression = temp_exp;
matlabbatch{1}.spm.util.imcalc.var = struct('name', {}, 'value', {});
matlabbatch{1}.spm.util.imcalc.options.dmtx = 0;
matlabbatch{1}.spm.util.imcalc.options.mask = 0;
matlabbatch{1}.spm.util.imcalc.options.interp = 0;
matlabbatch{1}.spm.util.imcalc.options.dtype = 16;

%% Run batch
%spm_jobman('interactive',matlabbatch);
spm_jobman('run',matlabbatch);

end % function PET_to_IndividualArea_sub(p1vol,a1vol,area_no,temp_tol,temp_output)
