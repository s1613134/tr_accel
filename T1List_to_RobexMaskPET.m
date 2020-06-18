% 
% Script to make .csv file of 3dROIstats from T1 file list
% 
% put V_fid.nii and A_fid.nii AND AAL.NII in present working directory
% from MATLAB command window:
% >> listV=dir("V_*.nii")
% >> temp_thd=0.15
% >> T1list_to_RobexMaskPET(listV,temp_thd)

function T1list_to_RobexMaskPET(Vlist,temp_thd)
%% definition
global temp_icbm temp_tpm temp_aal
temp_icbm=fullfile(spm('dir'),'toolbox','DARTEL','icbm152.nii')
temp_tpm=fullfile(spm('dir'),'tpm','TPM.nii')
temp_aal=fullfile(pwd,'aal.nii')

temp_tol=0.001; % as EPSilon

str_thd=string(temp_thd)

temp_filename=fullfile(pwd,strcat('hogehoge',datestr(now,'yyyymmddHHMM'),'.csv'))

%% Select T1 file and atlas file
numfiles = length(Vlist);
for k = 1:numfiles
	fid=erase(Vlist(k).name,["V_",".nii"]);

	t1vol=fullfile(pwd,strcat('V_',fid,'.nii,1')); % double quotation not allowed!!
	fprintf(strcat("T1 input :	",t1vol,"\n"))

	% call subroutine
	T1List_ReSlice_sub(t1vol)

	rt1vol_0=fullfile(pwd,strcat('rV_',fid,'.nii'));
	brt1vol_0=fullfile(pwd,strcat('rrV_',fid,'.nii'));
	% run ROBEX
	temp_cmnd=strcat('runROBEX.sh',string(' '),rt1vol_0,string(' '),brt1vol_0); % to expand t2vol, t3vol
	temp_result=system(temp_cmnd);

	rt1vol=strcat(rt1vol_0,',1');
	brt1vol=strcat(brt1vol_0,',1');
	p1vol=fullfile(pwd,strcat('A_',fid,'.nii,1'));
	rp1vol=fullfile(pwd,strcat('rA_',fid,'.nii,1')); % name is prediction
	fid_prefix=strcat(fid,'_');
	fprintf(strcat("resliced T1 input :	",rt1vol,"\n"))
	fprintf(strcat("PET input :	",p1vol,"\n"))
	% call subroutine
	ReSlice_to_RobexMaskPET_sub(rt1vol,p1vol,fid_prefix,str_thd,brt1vol,rp1vol);

	if k==1
		temp_cmnd=strcat('touch',string(' '),temp_filename,';3dROIstats -nzmean -nobriklab -nomeanout -mask',string(' '),fid,'_aal.nii',string(' '),'iirA_',fid,'.nii>',temp_filename); % to expand
	else
		temp_cmnd=strcat('3dROIstats -nzmean -nobriklab -nomeanout -mask',string(' '),fid,'_aal.nii',string(' '),'iirA_',fid,'.nii|sed -n 2p >>',temp_filename); % to expand
	end % if k==1
	temp_result=system(temp_cmnd);

	% move results
	fid_thd=strcat(fid,"_",str_thd)%;
	mkdir(fid_thd);
	status=movefile(strcat("i*",fid,".nii"),fid_thd);
	status=movefile(strcat("r*",fid,"*.*"),fid_thd);
	status=movefile(strcat("c*",fid,".nii"),fid_thd);
	status=movefile(strcat("*",fid,"_aal.nii"),fid_thd);

	fprintf(strcat(string(k),"/",string(numfiles)," done\n"))
end % for 
end % function T1list_to_RobexMaskPET(Vlist,temp_thd)

function T1List_ReSlice_sub(t1vol)
global temp_icbm

%% Initialize
spm_jobman('initcfg');
matlabbatch1={};

%% Prepare the SPM window
% interactive window (bottom-left) to show the progress, 
% and graphics window (right) to show the result of coregistration 

%spm('CreateMenuWin','on'); %Comment out if you want the top-left window.
spm('CreateIntWin','on');
spm_figure('Create','Graphics','Graphics','on');

%% batch
matlabbatch1{1}.spm.spatial.coreg.estwrite.ref = {strcat(temp_icbm,',1')};
matlabbatch1{1}.spm.spatial.coreg.estwrite.source = {t1vol};
matlabbatch1{1}.spm.spatial.coreg.estwrite.other = {''};
matlabbatch1{1}.spm.spatial.coreg.estwrite.eoptions.cost_fun = 'nmi';
matlabbatch1{1}.spm.spatial.coreg.estwrite.eoptions.sep = [4 2];
matlabbatch1{1}.spm.spatial.coreg.estwrite.eoptions.tol = [0.02 0.02 0.02 0.001 0.001 0.001 0.01 0.01 0.01 0.001 0.001 0.001];
matlabbatch1{1}.spm.spatial.coreg.estwrite.eoptions.fwhm = [7 7];
matlabbatch1{1}.spm.spatial.coreg.estwrite.roptions.interp = 4;
matlabbatch1{1}.spm.spatial.coreg.estwrite.roptions.wrap = [0 0 0];
matlabbatch1{1}.spm.spatial.coreg.estwrite.roptions.mask = 0;
matlabbatch1{1}.spm.spatial.coreg.estwrite.roptions.prefix = 'r';

%% Run batch
%spm_jobman('interactive',matlabbatch1);
spm_jobman('run',matlabbatch1);

end % function T1List_ReSlice_sub(t1vol)

function ReSlice_to_RobexMaskPET_sub(rt1vol,p1vol,fid_prefix,str_thd,brt1vol,rp1vol)
global temp_icbm temp_tpm temp_aal

%gt1_thd=char(strcat('i2.*(i1>',str_thd,')'))%;
gt2_thd=char(strcat('i1.*(i2>',str_thd,')'));

%cereb_prefix=strcat('CB_',fid_prefix,'aal')
%verm_prefix=strcat('VM_',fid_prefix,'aal')

%% Initialize
spm_jobman('initcfg');
matlabbatch2={};

%% Prepare the SPM window
% interactive window (bottom-left) to show the progress, 
% and graphics window (right) to show the result of coregistration 

%spm('CreateMenuWin','on'); %Comment out if you want the top-left window.
spm('CreateIntWin','on');
spm_figure('Create','Graphics','Graphics','on');

%% batch
matlabbatch2{1}.spm.spatial.coreg.estwrite.ref = {rt1vol};
matlabbatch2{1}.spm.spatial.coreg.estwrite.source = {p1vol};
matlabbatch2{1}.spm.spatial.coreg.estwrite.other = {''};
matlabbatch2{1}.spm.spatial.coreg.estwrite.eoptions.cost_fun = 'nmi';
matlabbatch2{1}.spm.spatial.coreg.estwrite.eoptions.sep = [4 2];
matlabbatch2{1}.spm.spatial.coreg.estwrite.eoptions.tol = [0.02 0.02 0.02 0.001 0.001 0.001 0.01 0.01 0.01 0.001 0.001 0.001];
matlabbatch2{1}.spm.spatial.coreg.estwrite.eoptions.fwhm = [7 7];
matlabbatch2{1}.spm.spatial.coreg.estwrite.roptions.interp = 4;
matlabbatch2{1}.spm.spatial.coreg.estwrite.roptions.wrap = [0 0 0];
matlabbatch2{1}.spm.spatial.coreg.estwrite.roptions.mask = 0;
matlabbatch2{1}.spm.spatial.coreg.estwrite.roptions.prefix = 'r';

matlabbatch2{2}.spm.spatial.preproc.channel.vols = {rt1vol};
matlabbatch2{2}.spm.spatial.preproc.channel.biasreg = 0.001;
matlabbatch2{2}.spm.spatial.preproc.channel.biasfwhm = 60;
matlabbatch2{2}.spm.spatial.preproc.channel.write = [0 0];
matlabbatch2{2}.spm.spatial.preproc.tissue(1).tpm = {strcat(temp_tpm,',1')};
matlabbatch2{2}.spm.spatial.preproc.tissue(1).ngaus = 1;
matlabbatch2{2}.spm.spatial.preproc.tissue(1).native = [1 0];
matlabbatch2{2}.spm.spatial.preproc.tissue(1).warped = [0 0];
matlabbatch2{2}.spm.spatial.preproc.tissue(2).tpm = {strcat(temp_tpm,',2')};
matlabbatch2{2}.spm.spatial.preproc.tissue(2).ngaus = 1;
matlabbatch2{2}.spm.spatial.preproc.tissue(2).native = [0 0];
matlabbatch2{2}.spm.spatial.preproc.tissue(2).warped = [0 0];
matlabbatch2{2}.spm.spatial.preproc.tissue(3).tpm = {strcat(temp_tpm,',3')};
matlabbatch2{2}.spm.spatial.preproc.tissue(3).ngaus = 2;
matlabbatch2{2}.spm.spatial.preproc.tissue(3).native = [0 0];
matlabbatch2{2}.spm.spatial.preproc.tissue(3).warped = [0 0];
matlabbatch2{2}.spm.spatial.preproc.tissue(4).tpm = {strcat(temp_tpm,',4')};
matlabbatch2{2}.spm.spatial.preproc.tissue(4).ngaus = 3;
matlabbatch2{2}.spm.spatial.preproc.tissue(4).native = [0 0];
matlabbatch2{2}.spm.spatial.preproc.tissue(4).warped = [0 0];
matlabbatch2{2}.spm.spatial.preproc.tissue(5).tpm = {strcat(temp_tpm,',5')};
matlabbatch2{2}.spm.spatial.preproc.tissue(5).ngaus = 4;
matlabbatch2{2}.spm.spatial.preproc.tissue(5).native = [0 0];
matlabbatch2{2}.spm.spatial.preproc.tissue(5).warped = [0 0];
matlabbatch2{2}.spm.spatial.preproc.tissue(6).tpm = {strcat(temp_tpm,',6')};
matlabbatch2{2}.spm.spatial.preproc.tissue(6).ngaus = 2;
matlabbatch2{2}.spm.spatial.preproc.tissue(6).native = [0 0];
matlabbatch2{2}.spm.spatial.preproc.tissue(6).warped = [0 0];
matlabbatch2{2}.spm.spatial.preproc.warp.mrf = 1;
matlabbatch2{2}.spm.spatial.preproc.warp.cleanup = 1; % light clean
%matlabbatch2{2}.spm.spatial.preproc.warp.cleanup = 2; % thorough clean
matlabbatch2{2}.spm.spatial.preproc.warp.reg = [0 0.001 0.5 0.05 0.2];
matlabbatch2{2}.spm.spatial.preproc.warp.affreg = 'mni';
matlabbatch2{2}.spm.spatial.preproc.warp.fwhm = 0;
matlabbatch2{2}.spm.spatial.preproc.warp.samp = 3;
matlabbatch2{2}.spm.spatial.preproc.warp.write = [1 0];
matlabbatch2{2}.spm.spatial.preproc.warp.vox = NaN;
matlabbatch2{2}.spm.spatial.preproc.warp.bb = [NaN NaN NaN
                                              NaN NaN NaN];

matlabbatch2{3}.spm.util.defs.comp{1}.def(1) = cfg_dep('Segment: Inverse Deformations', substruct('.','val', '{}',{2}, '.','val', '{}',{1}, '.','val', '{}',{1}), substruct('.','invdef', '()',{':'}));
matlabbatch2{3}.spm.util.defs.out{1}.pull.fnames = {temp_aal};
matlabbatch2{3}.spm.util.defs.out{1}.pull.savedir.savepwd = 1;
matlabbatch2{3}.spm.util.defs.out{1}.pull.interp = 0;
matlabbatch2{3}.spm.util.defs.out{1}.pull.mask = 1;
matlabbatch2{3}.spm.util.defs.out{1}.pull.fwhm = [0 0 0];
matlabbatch2{3}.spm.util.defs.out{1}.pull.prefix = fid_prefix;
%% mask PET by ROBEX
matlabbatch2{4}.spm.util.imcalc.input = {
                                        rp1vol
                                        brt1vol
                                        };
matlabbatch2{4}.spm.util.imcalc.output = '';
matlabbatch2{4}.spm.util.imcalc.outdir = {''};
matlabbatch2{4}.spm.util.imcalc.expression = '(i2>0).*i1';
matlabbatch2{4}.spm.util.imcalc.var = struct('name', {}, 'value', {});
matlabbatch2{4}.spm.util.imcalc.options.dmtx = 0;
matlabbatch2{4}.spm.util.imcalc.options.mask = 0;
matlabbatch2{4}.spm.util.imcalc.options.interp = 0;
matlabbatch2{4}.spm.util.imcalc.options.dtype = 16;
%% mask ROBEX masked PET by C1
matlabbatch2{5}.spm.util.imcalc.input(1) = cfg_dep('Image Calculator: ImCalc Computed Image: ', substruct('.','val', '{}',{4}, '.','val', '{}',{1}, '.','val', '{}',{1}), substruct('.','files'));
matlabbatch2{5}.spm.util.imcalc.input(2) = cfg_dep('Segment: c1 Images', substruct('.','val', '{}',{2}, '.','val', '{}',{1}, '.','val', '{}',{1}), substruct('.','tiss', '()',{1}, '.','c', '()',{':'}));
matlabbatch2{5}.spm.util.imcalc.output = '';
matlabbatch2{5}.spm.util.imcalc.outdir = {''};
matlabbatch2{5}.spm.util.imcalc.expression = gt2_thd;
matlabbatch2{5}.spm.util.imcalc.var = struct('name', {}, 'value', {});
matlabbatch2{5}.spm.util.imcalc.options.dmtx = 0;
matlabbatch2{5}.spm.util.imcalc.options.mask = 0;
matlabbatch2{5}.spm.util.imcalc.options.interp = 0;
matlabbatch2{5}.spm.util.imcalc.options.dtype = 16;

%% Run batch
%spm_jobman('interactive',matlabbatch2);
spm_jobman('run',matlabbatch2);

end % function ReSlice_to_RobexMaskPET_sub(rt1vol,p1vol,fid_prefix,brt1vol,rp1vol)
