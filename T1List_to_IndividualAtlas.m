% make_individual_atlas from T1 file list
% Script to make an individual atlas
% 
% put V_fid.nii and A_fid.nii in present working directory
% from MATLAB command window:
% >> listV=dir("V_*.nii")
% >> T1List_to_IndividualAtlas(listV)

function T1List_to_IndividualAtlas(Vlist)
% definition
global temp_icbm temp_tpm temp_aal
temp_icbm='/home/brain/git/spm12/toolbox/DARTEL/icbm152.nii'
temp_tpm='/home/brain/git/spm12/tpm/TPM.nii'
temp_aal='/home/brain/git/spm12/atlas/aal.nii'

%% Select T1 file and atlas file
numfiles = length(Vlist);
for k = 1:numfiles
	fid=erase(Vlist(k).name,["V_",".nii"]);
	t1vol=strcat(pwd,'/V_',fid,'.nii,1'); % double quotation not allowed!!
	p1vol=strcat(pwd,'/A_',fid,'.nii,1'); % double quotation not allowed!!
	fid_prefix=strcat(fid,'_'); % double quotation not allowed!!
	fprintf(strcat("T1 input :	",t1vol,"\n"))
	fprintf(strcat("PET input :	",p1vol,"\n"))

	% call subroutine
	T1List_to_IndividualAtlas_sub(t1vol,p1vol,fid_prefix);

	% move results
	mkdir(fid);
	status=movefile(strcat("i*",fid,".nii"),fid);
	status=movefile(strcat("r*",fid,"*.*"),fid);
	status=movefile(strcat("c*",fid,".nii"),fid);
	status=movefile(strcat("*",fid,"_aal.nii"),fid);

	fprintf(strcat(string(k),"/",string(numfiles)," done\n"))
end % for 
end % function T1List_to_IndividualAtlas(Vlist)

function T1List_to_IndividualAtlas_sub(t1vol,p1vol,fid_prefix)
global temp_icbm temp_tpm temp_aal

%% Initialize
spm_jobman('initcfg');
matlabbatch={};

%% Prepare the SPM window
% interactive window (bottom-left) to show the progress, 
% and graphics window (right) to show the result of coregistration 

%spm('CreateMenuWin','on'); %Comment out if you want the top-left window.
spm('CreateIntWin','on');
spm_figure('Create','Graphics','Graphics','on');

%% batch
matlabbatch{1}.spm.spatial.coreg.estwrite.ref = {strcat(temp_icbm,',1')};
matlabbatch{1}.spm.spatial.coreg.estwrite.source = {t1vol};
matlabbatch{1}.spm.spatial.coreg.estwrite.other = {''};
matlabbatch{1}.spm.spatial.coreg.estwrite.eoptions.cost_fun = 'nmi';
matlabbatch{1}.spm.spatial.coreg.estwrite.eoptions.sep = [4 2];
matlabbatch{1}.spm.spatial.coreg.estwrite.eoptions.tol = [0.02 0.02 0.02 0.001 0.001 0.001 0.01 0.01 0.01 0.001 0.001 0.001];
matlabbatch{1}.spm.spatial.coreg.estwrite.eoptions.fwhm = [7 7];
matlabbatch{1}.spm.spatial.coreg.estwrite.roptions.interp = 4;
matlabbatch{1}.spm.spatial.coreg.estwrite.roptions.wrap = [0 0 0];
matlabbatch{1}.spm.spatial.coreg.estwrite.roptions.mask = 0;
matlabbatch{1}.spm.spatial.coreg.estwrite.roptions.prefix = 'r';
matlabbatch{2}.spm.spatial.coreg.estwrite.ref(1) = cfg_dep('Coregister: Estimate & Reslice: Resliced Images', substruct('.','val', '{}',{1}, '.','val', '{}',{1}, '.','val', '{}',{1}, '.','val', '{}',{1}), substruct('.','rfiles'));
matlabbatch{2}.spm.spatial.coreg.estwrite.source = {p1vol};
matlabbatch{2}.spm.spatial.coreg.estwrite.other = {''};
matlabbatch{2}.spm.spatial.coreg.estwrite.eoptions.cost_fun = 'nmi';
matlabbatch{2}.spm.spatial.coreg.estwrite.eoptions.sep = [4 2];
matlabbatch{2}.spm.spatial.coreg.estwrite.eoptions.tol = [0.02 0.02 0.02 0.001 0.001 0.001 0.01 0.01 0.01 0.001 0.001 0.001];
matlabbatch{2}.spm.spatial.coreg.estwrite.eoptions.fwhm = [7 7];
matlabbatch{2}.spm.spatial.coreg.estwrite.roptions.interp = 4;
matlabbatch{2}.spm.spatial.coreg.estwrite.roptions.wrap = [0 0 0];
matlabbatch{2}.spm.spatial.coreg.estwrite.roptions.mask = 0;
matlabbatch{2}.spm.spatial.coreg.estwrite.roptions.prefix = 'r';
matlabbatch{3}.spm.spatial.preproc.channel.vols(1) = cfg_dep('Coregister: Estimate & Reslice: Resliced Images', substruct('.','val', '{}',{1}, '.','val', '{}',{1}, '.','val', '{}',{1}, '.','val', '{}',{1}), substruct('.','rfiles'));
matlabbatch{3}.spm.spatial.preproc.channel.biasreg = 0.001;
matlabbatch{3}.spm.spatial.preproc.channel.biasfwhm = 60;
matlabbatch{3}.spm.spatial.preproc.channel.write = [0 0];
matlabbatch{3}.spm.spatial.preproc.tissue(1).tpm = {strcat(temp_tpm,',1')};
matlabbatch{3}.spm.spatial.preproc.tissue(1).ngaus = 1;
matlabbatch{3}.spm.spatial.preproc.tissue(1).native = [1 0];
matlabbatch{3}.spm.spatial.preproc.tissue(1).warped = [0 0];
matlabbatch{3}.spm.spatial.preproc.tissue(2).tpm = {strcat(temp_tpm,',2')};
matlabbatch{3}.spm.spatial.preproc.tissue(2).ngaus = 1;
matlabbatch{3}.spm.spatial.preproc.tissue(2).native = [0 0];
matlabbatch{3}.spm.spatial.preproc.tissue(2).warped = [0 0];
matlabbatch{3}.spm.spatial.preproc.tissue(3).tpm = {strcat(temp_tpm,',3')};
matlabbatch{3}.spm.spatial.preproc.tissue(3).ngaus = 2;
matlabbatch{3}.spm.spatial.preproc.tissue(3).native = [0 0];
matlabbatch{3}.spm.spatial.preproc.tissue(3).warped = [0 0];
matlabbatch{3}.spm.spatial.preproc.tissue(4).tpm = {strcat(temp_tpm,',4')};
matlabbatch{3}.spm.spatial.preproc.tissue(4).ngaus = 3;
matlabbatch{3}.spm.spatial.preproc.tissue(4).native = [0 0];
matlabbatch{3}.spm.spatial.preproc.tissue(4).warped = [0 0];
matlabbatch{3}.spm.spatial.preproc.tissue(5).tpm = {strcat(temp_tpm,',5')};
matlabbatch{3}.spm.spatial.preproc.tissue(5).ngaus = 4;
matlabbatch{3}.spm.spatial.preproc.tissue(5).native = [0 0];
matlabbatch{3}.spm.spatial.preproc.tissue(5).warped = [0 0];
matlabbatch{3}.spm.spatial.preproc.tissue(6).tpm = {strcat(temp_tpm,',6')};
matlabbatch{3}.spm.spatial.preproc.tissue(6).ngaus = 2;
matlabbatch{3}.spm.spatial.preproc.tissue(6).native = [0 0];
matlabbatch{3}.spm.spatial.preproc.tissue(6).warped = [0 0];
matlabbatch{3}.spm.spatial.preproc.warp.mrf = 1;
matlabbatch{3}.spm.spatial.preproc.warp.cleanup = 1;
matlabbatch{3}.spm.spatial.preproc.warp.reg = [0 0.001 0.5 0.05 0.2];
matlabbatch{3}.spm.spatial.preproc.warp.affreg = 'mni';
matlabbatch{3}.spm.spatial.preproc.warp.fwhm = 0;
matlabbatch{3}.spm.spatial.preproc.warp.samp = 3;
matlabbatch{3}.spm.spatial.preproc.warp.write = [1 0];
matlabbatch{3}.spm.spatial.preproc.warp.vox = NaN;
matlabbatch{3}.spm.spatial.preproc.warp.bb = [NaN NaN NaN
                                              NaN NaN NaN];
matlabbatch{4}.spm.util.defs.comp{1}.def(1) = cfg_dep('Segment: Inverse Deformations', substruct('.','val', '{}',{3}, '.','val', '{}',{1}, '.','val', '{}',{1}), substruct('.','invdef', '()',{':'}));
matlabbatch{4}.spm.util.defs.out{1}.pull.fnames = {temp_aal};
matlabbatch{4}.spm.util.defs.out{1}.pull.savedir.savepwd = 1;
matlabbatch{4}.spm.util.defs.out{1}.pull.interp = 0;
matlabbatch{4}.spm.util.defs.out{1}.pull.mask = 1;
matlabbatch{4}.spm.util.defs.out{1}.pull.fwhm = [0 0 0];
matlabbatch{4}.spm.util.defs.out{1}.pull.prefix = fid_prefix;
matlabbatch{5}.spm.util.imcalc.input(1) = cfg_dep('Segment: c1 Images', substruct('.','val', '{}',{3}, '.','val', '{}',{1}, '.','val', '{}',{1}), substruct('.','tiss', '()',{1}, '.','c', '()',{':'}));
matlabbatch{5}.spm.util.imcalc.input(2) = cfg_dep('Deformations: Warped Images', substruct('.','val', '{}',{4}, '.','val', '{}',{1}, '.','val', '{}',{1}), substruct('.','warped'));
matlabbatch{5}.spm.util.imcalc.output = '';
matlabbatch{5}.spm.util.imcalc.outdir = {''};
matlabbatch{5}.spm.util.imcalc.expression = 'i2.*(i1>0.3)';
matlabbatch{5}.spm.util.imcalc.var = struct('name', {}, 'value', {});
matlabbatch{5}.spm.util.imcalc.options.dmtx = 0;
matlabbatch{5}.spm.util.imcalc.options.mask = 0;
matlabbatch{5}.spm.util.imcalc.options.interp = 0;
matlabbatch{5}.spm.util.imcalc.options.dtype = 16;
matlabbatch{6}.spm.util.imcalc.input(1) = cfg_dep('Coregister: Estimate & Reslice: Resliced Images', substruct('.','val', '{}',{2}, '.','val', '{}',{1}, '.','val', '{}',{1}, '.','val', '{}',{1}), substruct('.','rfiles'));
matlabbatch{6}.spm.util.imcalc.input(2) = cfg_dep('Segment: c1 Images', substruct('.','val', '{}',{3}, '.','val', '{}',{1}, '.','val', '{}',{1}), substruct('.','tiss', '()',{1}, '.','c', '()',{':'}));
matlabbatch{6}.spm.util.imcalc.output = '';
matlabbatch{6}.spm.util.imcalc.outdir = {''};
matlabbatch{6}.spm.util.imcalc.expression = 'i1.*(i2>0.3)';
matlabbatch{6}.spm.util.imcalc.var = struct('name', {}, 'value', {});
matlabbatch{6}.spm.util.imcalc.options.dmtx = 0;
matlabbatch{6}.spm.util.imcalc.options.mask = 0;
matlabbatch{6}.spm.util.imcalc.options.interp = 0;
matlabbatch{6}.spm.util.imcalc.options.dtype = 16;

%% Run batch
%spm_jobman('interactive',matlabbatch);
spm_jobman('run',matlabbatch);

end % function T1List_to_IndividualAtlas_sub(t1vol,p1vol,fid_prefix)
