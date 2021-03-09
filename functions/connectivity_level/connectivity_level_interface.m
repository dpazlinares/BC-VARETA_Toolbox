function [subject,properties] = connectivity_level_interface(subject,properties)

band                                                        = properties.sensor_level_out.band;
%%
%% Defining path
%%
disp('=================================================================');
if(isfield(band,'f_bin'))    
    disp(strcat( 'BC-V-->> Connectivity level for frequency band: (' , band.name , ') bin ->>>' , string(band.f_bin), 'Hz') );
    properties.str_band                                     =  strcat( band.name,'_',string(band.f_bin),'Hz');
else
    disp(strcat( 'BC-V-->> Connectivity level for frequency band: (' , band.name , ') ' , string(band.f_start), 'Hz-->' , string(band.f_end) , 'Hz') );
    properties.str_band                                     =  strcat( band.name,'_',string(band.f_start),'Hz_',string(band.f_end),'Hz');
end
text_level = 'Connectivity_level'; 

%%
%% Band Analysis, connectivity level
%%
for m=1:length(properties.connectivity_params.methods)
    analysis_method                                         = properties.connectivity_params.methods{m};
    fields                                                  = fieldnames(analysis_method);
    method_name                                             = fields{1};
    if(analysis_method.(method_name).run)
        disp('-----------------------------------------------------------------');
        disp(strcat("-->> Start time: ",datestr(now,'mmmm dd, yyyy HH:MM:SS AM')));
        switch method_name
            case 'higgs'
                if(properties.BC_V_info.properties.general_params.run_by_trial.value)
                    trial_name                              = properties.trial_name;
                    properties.pathname                     = fullfile(subject.subject_path,trial_name,text_level,'HIGGS',band.name);
                else
                    properties.pathname                     = fullfile(subject.subject_path,text_level,'HIGGS',band.name);
                end
                if(~isfolder(properties.pathname))
                    mkdir(properties.pathname);
                end
                properties.connectivity_params.higgs_th     = analysis_method.(method_name).higgs_th;
                [Thetajj,s2j,Tjv,llh,properties]            = connectivity_level_higgs(subject,properties);
                properties.connectivity_params              = rmfield(properties.connectivity_params,'higgs_th');
            case 'hg_lasso'
                if(properties.BC_V_info.properties.general_params.run_by_trial.value)
                    trial_name                              = properties.trial_name;
                    properties.pathname                     = fullfile(subject.subject_path,trial_name,text_level,'HG_LASSO',band.name);
                else
                    properties.pathname                     = fullfile(subject.subject_path,text_level,'HG_LASSO',band.name);
                end
                if(~isfolder(properties.pathname))
                    mkdir(properties.pathname);
                end
                properties.connectivity_params.hg_lasso_th  = analysis_method.(method_name).hg_lasso_th;
                [Thetajj,Sjj,Sigmajj,properties]            = connectivity_level_hg_lasso(subject,properties);
                properties.connectivity_params              = rmfield(properties.connectivity_params,'hg_lasso_th');
        end
        disp(strcat("-->> End time: ",datestr(now,'mmmm dd, yyyy HH:MM:SS AM')));
        
          reference_path                                                                                            = strsplit(properties.pathname,subject.name);
        if(properties.BC_V_info.properties.general_params.run_by_trial.value)
            if(properties.BC_V_info.properties.general_params.run_frequency_bin.value)
                f_bin                                                                                               = replace(num2str(band.f_bin),'.','_');
                f_bin                                                                                               = strcat(band.name,'_',f_bin);
                properties.BC_V_info.(trial_name).connectivity_level.(method_name).(band.name).(f_bin).name         = properties.file_name;
                properties.BC_V_info.(trial_name).connectivity_level.(method_name).(band.name).(f_bin).ref_path     = reference_path{2};
            else
                properties.BC_V_info.(trial_name).connectivity_level.(method_name).(band.name).name                 = properties.file_name;
                properties.BC_V_info.(trial_name).connectivity_level.(method_name).(band.name).ref_path             = reference_path{2};
            end
        else
            if(properties.BC_V_info.properties.general_params.run_frequency_bin.value)
                f_bin                                                                                               = replace(num2str(band.f_bin),'.','_');
                f_bin                                                                                               = strcat(band.name,'_',f_bin);
                properties.BC_V_info.connectivity_level.(method_name).(band.name).(f_bin).name                      = properties.file_name;
                properties.BC_V_info.connectivity_level.(method_name).(band.name).(f_bin).ref_path                  = reference_path{2};
            else
                properties.BC_V_info.connectivity_level.(method_name).(band.name).name                              = properties.file_name;
                properties.BC_V_info.connectivity_level.(method_name).(band.name).ref_path                          = reference_path{2};
            end
        end
    end
end

end

                                                                                                                                                                                                                                                                                                                                                          ggs(Svv,Ke(:,indms),param);
    [Thetajj,s2j,Tjv]                = higgs_destandardization(Thetajj,Svv,Tjv,Winv,W,indms,IsField);
elseif IsCurv == 1
    Ke_giri                          = subject.Ke_giri;
    Ke_sulc                          = subject.Ke_sulc;
    Ke_giri                          = Ke_giri*W;
    Ke_sulc                          = Ke_sulc*W;
    [Thetajj_sulc,Tjv_sulc,llh_sulc] = higgs(Svv,Ke_sulc(:,indms),param);
    [Thetajj_giri,Tjv_giri,llh_giri] = higgs(Svv,Ke_giri(:,indms),param);
    [Thetajj_giri,s2j_giri,Tjv_giri] = higgs_destandardization(Thetajj_giri,Svv,Tjv_giri,Winv,W,indms,IsField);
    [Thetajj_sulc,s2j_sulc,Tjv_sulc] = higgs_destandardization(Thetajj_sulc,Svv,Tjv_sulc,Winv,W,indms,IsField);
    Thetajj                          = (Thetajj_giri + Thetajj_sulc)/2;
    s2j                              = (s2j_giri + s2j_sulc)/2;
    llh                              = [llh_giri llh_sulc];
    Tjv                              = cat(3,Tjv_giri,Tjv_sulc);
end

%%
%% Plotting results
%%
J                   = s2j;
sources_iv          = zeros(length(J),1);
sources_iv(indms)   = sqrt(abs(J(indms)));
sources_iv          = sources_iv/max(sources_iv(:));

figure_name = strcat('BC-VARETA-activation - ',str_band);
if(properties.run_bash_mode.disabled_graphics)
    figure_BC_VARETA1 = figure('Color','w','Name',figure_name,'NumberTitle','off','visible','off'); hold on;
else
    figure_BC_VARETA1 = figure('Color','w','Name',figure_name,'NumberTitle','off'); hold on;
end
define_ico(figure_BC_VARETA1);
patch('Faces',Sc.Faces,'Vertices',Sc.Vertices,'FaceVertexCData',sources_iv,'FaceColor','interp','EdgeColor','none','FaceAlpha',.99);
set(gca,'Color','w');
az = 0; el = 0;
view(az,el);
colormap(gca,cmap_a);
title('BC-VARETA-activation','Color','k','FontSize',16);

disp('-->> Saving figure');
file_name = strcat('BC_VARETA_activation','_',str_band,'.fig');
saveas(figure_BC_VARETA1,fullfile(pathname,file_name));

close(figure_BC_VARETA1);

pause(1e-12);

%%
%% Plotting results

temp_iv    = abs(s2j(indms));
connect_iv = abs(Thetajj);
temp       = abs(connect_iv);
temp_diag  = diag(diag(temp));
temp_ndiag = temp - temp_diag;
temp_ndiag = temp_ndiag/max(temp_ndiag(:));
temp_diag  = diag(temp_iv);
temp_diag  = temp_diag/max(temp_diag(:));
temp_diag  = diag(diag(temp_diag) + 1);
temp_comp  = temp_diag + temp_ndiag;
label_gen = [];
for ii = 1:length(indms)
    label_gen{ii} = num2str(ii);
end

figure_name = strcat('BC-VARETA-node-wise-conn - ',str_band);
if(properties.run_bash_mode.disabled_graphics)
    figure_BC_VARETA2 = figure('Color','w','Name',figure_name,'NumberTitle','off','visible','off');
else
    figure_BC_VARETA2 = figure('Color','w','Name',figure_name,'NumberTitle','off');
end
define_ico(figure_BC_VARETA2);
imagesc(temp_comp);
set(gca,'Color','w','XColor','k','YColor','k','ZColor','k',...
    'XTick',1:length(indms),'YTick',1:length(indms),...
    'XTickLabel',label_gen,'XTickLabelRotation',90,...
    'YTickLabel',label_gen,'YTickLabelRotation',0);
xlabel('sources','Color','k');
ylabel('sources','Color','k');
colorbar;
colormap(gca,cmap_c);
axis square;
title('BC-VARETA-node-wise-conn','Color','k','FontSize',16);

disp('-->> Saving figure');
file_name = strcat('BC_VARETA_node_wise_conn','_',str_band,'.fig');
saveas(figure_BC_VARETA2,fullfile(pathname,file_name));

close(figure_BC_VARETA2);

%% Roi analysis
Thetajj_full              = zeros(length(Ke));
Sjj_full                  = zeros(length(Ke));
Thetajj_full(indms,indms) = Thetajj;
Sjj_full(indms,indms)     = diag(temp_iv);
atlas_label               = cell(1,length(Atlas));
conn_roi                  = zeros(length(Atlas));
act_roi                   = zeros(length(Atlas),1);
for roi1 = 1:length(Atlas)
    for roi2 = 1:length(Atlas)
        conn_tmp             = Thetajj_full(Atlas(roi1).Vertices,Atlas(roi2).Vertices);
        conn_tmp             = mean(abs(conn_tmp(:)));
        conn_roi(roi1,roi2)  = conn_tmp;
    end
    atlas_label{roi1} = Atlas(roi1).Label;
end

for roi1 = 1:length(Atlas)
    act_tmp              = diag(Sjj_full(Atlas(roi1).Vertices,Atlas(roi1).Vertices));
    act_tmp              = mean(abs(act_tmp));
    act_roi(roi1)        = act_tmp;
end
act_roi    = diag(act_roi);
temp_iv    = abs(act_roi);
connect_iv = abs(conn_roi);
temp       = abs(connect_iv);
temp_diag  = diag(diag(temp));
temp_ndiag = temp-temp_diag;
temp_ndiag = temp_ndiag/max(temp_ndiag(:));
temp_diag  = diag(abs(diag(temp_iv)));
temp_diag  = temp_diag/max(temp_diag(:));
temp_diag  = diag(diag(temp_diag)+1);
temp_comp  = temp_diag+temp_ndiag;

figure_name = strcat('BC-VARETA-roi-conn - ',str_band);
if(properties.run_bash_mode.disabled_graphics)
    figure_BC_VARETA3 = figure('Color','w','Name',figure_name,'NumberTitle','off','visible','off');
else
    figure_BC_VARETA3 = figure('Color','w','Name',figure_name,'NumberTitle','off');
end
define_ico(figure_BC_VARETA3);
imagesc(temp_comp);
set(gca,'Color','w','XColor','k','YColor','k','ZColor','k',...
    'XTick',1:length(Atlas),'YTick',1:length(Atlas),...
    'XTickLabel',atlas_label,'XTickLabelRotation',90,...
    'YTickLabel',atlas_label,'YTickLabelRotation',0);
xlabel('sources','Color','k');
ylabel('sources','Color','k');
colorbar;
colormap(gca,cmap_c);
axis square;
title('BC-VARETA-roi-conn','Color','k','FontSize',16);

disp('-->> Saving figure');
file_name = strcat('BC_VARETA_roi_conn','_',str_band,'.fig');
saveas(figure_BC_VARETA3,fullfile(pathname,file_name));

close(figure_BC_VARETA3);


%% Saving files
disp('-->> Saving file.')
disp(strcat("Path: ",pathname));
properties.file_name = strcat('MEEG_source_',str_band,'.mat');
disp(strcat("File: ", properties.file_name));
parsave(fullfile(pathname ,properties.file_name ),Thetajj,s2j,Tjv,llh,Svv,W,indms);

pause(1e-12);

end

                                                                                                                                                                                                                       BC_V_info.properties.connectivity_params = properties.connectivity_params;
                disp(strcat("File: ", "BC_V_info.mat"));
                parsave(fullfile(subject.subject_path ,'BC_V_info.mat'),BC_V_info);
            end
        else
            fprintf(2,strcat('\nBC-V-->> Error: The folder structure for subject: ',subject.name,' \n'));
            fprintf(2,strcat('BC-V-->> Have the folows errors.\n'));
            for j=1:length(error_msg_array)
                fprintf(2,strcat('BC-V-->>' ,error_msg_array(j), '.\n'));
            end
            fprintf(2,strcat('BC-V-->> Jump to an other subject.\n'));
            continue;
        end
    end
else
    fprintf(2,strcat('\nBC-V-->> Error: The folder structure: \n'));
    disp(root_path);
    fprintf(2,strcat('BC-V-->> Error: Do not contain any subject information file.\n'));
    disp("Please verify the configuration of the input data and start the process again.");
    return;
end

end                          ings.SaveCorrected.variances     = false;
Settings.SaveCorrected.ROIweightings = false;
Settings.SubjectLevel.conditionLabel   = {'longvalidR', 'longvalidL', 'ShortValidRight', 'ShortValidLeft'};
Settings.SubjectLevel.designSummary    = {[1 0 0 0]', [0 1 0 0], [0 0 1 0]', [0 0 0 1]};
Settings.SubjectLevel.contrasts        = {[1 0 1 0]; [1 -1 1 -1]};

Settings = ROInets.check_inputs(Settings);
try
    CorrMats = ROInets.run_individual_network_analysis_task(dataFile, ...
                                                           Settings, ...
                                                            resultsName);
catch ME
    fprintf('%s: Test 4 failed. \n', mfilename);
    rethrow(ME);
end%try

%% Test 4 trial data, several subj
dataFiles = {'/Users/gilesc/data/MND-malcolm/Motor_beta.oat/concatMfsession12_spm_meeg.mat'; ...
             '/Users/gilesc/data/MND-malcolm/Motor_beta.oat/concatMfsession120_spm_meeg.mat'; ...
             '/Users/gilesc/data/MND-malcolm/Motor_beta.oat/concatMfsession121_spm_meeg.mat'; ...
             '/Users/gilesc/data/MND-malcolm/Motor_beta.oat/concatMfsession122_spm_meeg.mat'};
% setup the ROI network settings
Settings = struct();
Settings.spatialBasisSet          = parcelFile;                     % a binary file which holds the voxel allocation for each ROI - voxels x ROIs
Settings.gridStep                 = 8; % mm                         % resolution of source recon and nifti parcellation file
Settings.timeRange                = [0.01 3.99];                             % range of times to use for analysis
Settings.Regularize.do            = true;                           % use regularization on partial correlation matrices using the graphical lasso. 
Settings.Regularize.path          = 0.001;              % This specifies a single, or vector, of possible rho-parameters controlling the strength of regularization. 
Settings.Regularize.method        = 'Friedman';                     % Regularization approach to take. {'Friedman' or 'Bayesian'}
Settings.Regularize.adaptivePath  = false;                           % adapth the regularization path if necessary
Settings.leakageCorrectionMethod  = 'closest';                      % choose from 'closest', 'symmetric', 'pairwise' or 'none'. 
Settings.nEmpiricalSamples        = 1;                              % convert correlations to standard normal z-statistics using a simulated empirical distribution. This controls how many times we simulate data of the same size as the analysis dataset
Settings.EnvelopeParams.windowLength = 1/40; % s                       % sliding window length for power envelope calculation. See Brookes 2011, 2012 and Luckhoo 2012. 
Settings.EnvelopeParams.useFilter = true;                        % use a more sophisticated filter than a sliding window average
Settings.EnvelopeParams.takeLogs  = true;
Settings.frequencyBands           = {[]};                       % a set of frequency bands for analysis. Set to empty to use broadband. The bandpass filtering is performed before orthogonalisation. 
Settings.timecourseCreationMethod = 'PCA';                          % 'PCA', 'mean', 'peakVoxel' or 'spatialBasis'
Settings.outputDirectory          = outDir;                         % Set a directory for the results output
Settings.groupStatisticsMethod    = 'mixed-effects';                % 'mixed-effects' or 'fixed-effects'
Settings.FDRalpha                 = 0.05;                           % false determination rate significance threshold
Settings.sessionName              = {'sess1', 'sess2', 'sess3', 'sess4'}; 
Settings.SaveCorrected.timeCourse    = false;
Settings.SaveCorrected.envelopes      = false;
Settings.SaveCorrected.variances     = false;
Settings.SaveCorrected.ROIweightings = false;
Settings.SubjectLevel.conditionLabel   = {'longvalidR', 'longvalidL', 'ShortValidRight', 'ShortValidLeft'};
Settings.SubjectLevel.designSummary    = {[1 0 0 0]', [0 1 0 0], [0 0 1 0]', [0 0 0 1]};
Settings.SubjectLevel.contrasts        = {[1 0 1 0]; [1 -1 1 -1]};
Settings.GroupLevel.designMatrix       = [1 0
                                          1 0
                                          0 1
                                          0 1];
Settings.GroupLevel.contrasts          = [1  1;  % contrast 1
                                          1 -1]; % contrast 2

try
    CorrMats = run_network_analysis(dataFiles, Settings);
catch ME
    fprintf('%s: Test 4 failed. \n', mfilename);
    rethrow(ME);
end%try

%% We've got to the end!
FAIL = 0;
ROInets.call_fsl_wrapper(['rm -rf ' dataDir]);

end%test_me
% [EOF]
                                                                                                                                                                                                                                                                                                                                                                                                                                                                                          on = Settings.nSessions:-1:1,
    fprintf('\n\n%s: Individual correlation analysis for file %d out of %d\n', ...
            mfilename, Settings.nSessions - iSession + 1, Settings.nSessions);

    D                          = Dlist{iSession};
    sessionName                = Settings.sessionName{iSession};
    matsSaveFileName{iSession} = fullfile(outputDirectory,                                      ...
                                          sprintf('%s_single_session_correlation_mats_tmp.mat', ...
                                                  sessionName));

    if strcmpi(Settings.paradigm, 'task'),
        mats{iSession} = ROInets.run_individual_network_analysis_task(D,                          ...
                                                                 Settings,                   ...
                                                                 matsSaveFileName{iSession}, ...
                                                                 iSession);
    elseif strcmpi(Settings.paradigm, 'rest'),
        mats{iSession} = ROInets.run_individual_network_analysis(D,                          ...
                                                                 Settings,                   ...
                                                                 matsSaveFileName{iSession}, ...
                                                                 iSession);
    else
        error([mfilename ':BadParadigm'], ...
              'Unrecognised paradigm %s. \n', Settings.paradigm);
    end%if
end%for

% reformat results - correlationMats is a cell array of frequency bands
correlationMats = ROInets.reformat_results(mats, Settings);

% save current results: will write over later
% just in case of crash at group level
saveFileName = fullfile(outputDirectory, 'ROInetworks_correlation_mats.mat');
save(saveFileName, 'correlationMats');
clear mats

%% Subject-level analysis to average over sessions in a fixed-effects manner
correlationMats = ROInets.do_subject_level_glm(correlationMats, Settings);

%% Group-level analysis
% Find whole group means
if strcmpi(Settings.paradigm, 'rest'),
    correlationMats = ROInets.do_group_level_statistics(correlationMats, Settings);
end%if

% Perform group-level GLM
if ~isempty(Settings.GroupLevel),
    correlationMats = ROInets.do_group_level_glm(correlationMats, Settings);
end%if

%% save matrices
fprintf('\n%s: Saving Results. \n', mfilename);

% save collected results
save(saveFileName, 'correlationMats');

% we stored individual results as we went along, in case of crash. Delete
% them if we've safely got to this stage. 
for iSession = 1:length(matsSaveFileName),
    delete(matsSaveFileName{iSession});
end%for
 
% tidy output of funciton
Settings.correlationMatsFile = saveFileName;
save(fullfile(outputDirectory, 'ROInetworks_settings.mat'), 'Settings');

fprintf('%s: Analysis complete. \n\n\n', mfilename);
end%run_network_analysis
% [EOF]
                                                                                                                  time,            ...
                                                           Settings.EnvelopeParams); %#ok<ASGLU>
    end%for loop over trials
    
    % save power envelopes
    if Settings.SaveCorrected.envelopes,
        saveDir = fullfile(Settings.outputDirectory, ...
                           'corrected-ROI-timecourses', filesep);
        ROInets.make_directory(saveDir);
        saveFile = fullfile(saveDir,                                      ...
                            sprintf('%s_%s_ROI_envelope_timecourses.mat', ...
                                    sessionName, bandName));
        save(saveFile, 'nodeEnv', 'time_ds');
    end%if
        
    %% Run correlation analysis 
    % calculate correlation matrices. 
    CorrMats{iFreq} = ROInets.run_correlation_analysis([],           ...
                                                       nodeEnv,      ...
                                                       Settings.Regularize);
    
    
    % Use an empirical null to enable conversion to z-stats
    transformSurrogates = ~Settings.EnvelopeParams.takeLogs;
    RegParams           = struct('do', Settings.Regularize.do, ...
                                 'rho', CorrMats{iFreq}.Regularization.mean);
    sigma = ROInets.find_permutation_H0_distribution_width(nodeEnv,                    ...
                                                           Settings.nEmpiricalSamples, ...
                                                           RegParams,                  ...
                                                           transformSurrogates);
          
    CorrMats{iFreq}.H0Sigma = sigma;
    
    % Store session name
    CorrMats{iFreq}.sessionName = sessionName;
    CorrMats{iFreq}.timeWindow  = timeRange;
    
    % free up some memory
    clear nodeData nodeEnv
    
    %% conversion of correlations to z-stats
    fprintf(' Converting correlations to normal z-stats\n');
    CorrMats{iFreq} = ROInets.convert_correlations_to_normal_variables(CorrMats{iFreq}, ...
                                                                       sigma,      ...
                                                                       doRegularize);
    
    %% Run first-level GLM
    CorrMats{iFreq}.firstLevel = run_first_level_glm(CorrMats{iFreq},    ...
                                                     designMat,          ...
                                                     Settings.SubjectLevel.contrasts, ...
													 D.fname);
    % clean up filtered object
    delete(cleanD);
end%loop over freq bands

%% save results to disc to provide backup of completed session analyses
save(resultsSaveName, 'CorrMats');




%%% END OF FUNCTION PROPER %%%

end%run_individual_correlation_analysis
%--------------------------------------------------------------------------






%--------------------------------------------------------------------------
function FirstLevel = run_first_level_glm(CorrMats, designMat, contrasts, fileName)
%RUN_FIRST_LEVEL_GLM
%


% input checking
[nTrials, nRegressors] = size(designMat);
nContrasts             = length(contrasts);
[~, nModes, checkMe]   = size(CorrMats.envCorrelation_z);
assert(checkMe == nTrials,         ...
      [mfilename ':LostTrials'],   ...
      'Number of trials must match columns of design matrix. \n');

assert(iscell(contrasts),               ...
       [mfilename ':NonCellContrasts'], ...
       'Contrasts must be a cell array. \n');
assert(all(cellfun(@length, contrasts) == nRegressors), ...
       [mfilename ':BadContrastFormat'],                ...
       'All contrasts must have the same length as number of regressors. \n');
   
% make sure contrasts are formatted as a cell array of column vectors
useContrasts = cell(1,nContrasts);
for iContrast = 1:nContrasts,
    useContrasts{iContrast} = contrasts{iContrast}(:);
end%for
   
% Precompute some helpful things
XtX       = designMat' * designMat;
[RXtX, p] = chol(XtX);
if ~p,
	invXtX = RXtX \ (RXtX' \ eye(nRegressors));
	pinvX  = RXtX \ (RXtX' \ designMat');
	hasBadEVs    = false;
	badContrasts = false(nContrasts, 1);
else
	% design matrix was rank deficient
	% is that because we have missing information for certain trial types?
	badEVs    = all(0 == designMat);
	hasBadEVs = any(badEVs);
	if hasBadEVs,
		warning([mfilename ':MissingTrials'],                   ...
			    '%s: file %s is missing trials for %d EVs. \n', ...
				mfilename, fileName, sum(badEVs));
		badContrasts = logical(cellfun(@(C) any(C(badEVs)), useContrasts));
		invXtX = pinv(XtX);
		pinvX  = invXtX * designMat';
	else
		error([mfilename ':RankDeficientDesign'],                     ...
			  ['%s: the design matrix is rank deficient. ',           ...
			   'Check that you''ve specified your EVs sensibly. \n'], ...
			  mfilename);
	end%if
end%if

% declare memory
[rho, prho, prhoReg] = deal(zeros(nModes, nModes, nContrasts));

% run GLM on each edge
for i = 1:nModes,
    for j = i+1:nModes,
        rho(i,j,:) = glm_fast_for_meg(squeeze(CorrMats.envCorrelation_z(i,j,:)), ...
                                      designMat, invXtX, pinvX, useContrasts, 0);
        prho(i,j,:) = glm_fast_for_meg(squeeze(CorrMats.envPartialCorrelation_z(i,j,:)), ...
                                      designMat, invXtX, pinvX, useContrasts, 0);
								  
	    % fill in uninformative values with NaN.
		if hasBadEVs,
			rho(i,j,badContrasts)  = NaN;
			prho(i,j,badContrasts) = NaN;
		end%if
        if isfield(CorrMats, 'envPartialCorrelationRegularized_z'),
        prhoReg(i,j,1:nContrasts) = glm_fast_for_meg(squeeze(CorrMats.envPartialCorrelationRegularized_z(i,j,:)), ...
                                      designMat, invXtX, pinvX, useContrasts, 0); 
        prhoReg(i,j,badContrasts) = NaN;
        else
            prhoReg(i,j) = 0;
        end%if
    end%for
end%for

% symmetrise and reformat
for iContrast = nContrasts:-1:1,
    FirstLevel(iContrast).cope.correlation                   = rho(:,:,iContrast) + rho(:,:,iContrast)';
    FirstLevel(iContrast).cope.partialCorrelation            = prho(:,:,iContrast) + prho(:,:,iContrast)';
    FirstLevel(iContrast).cope.partialCorrelationRegularized = prhoReg(:,:,iContrast) + prhoReg(:,:,iContrast)';
end%for

end%run_first_level_glm






%--------------------------------------------------------------------------
function [designMat, goodTrials, trialID, nConditions] = set_up_first_level(D, Settings, excludeTrials)
%SET_UP_FIRST_LEVEL creates the design matrix and trial identifiers

nConditions = length(Settings.SubjectLevel.conditionLabel);

% hold the relevant indices for trials in each condition
for iCondition = nConditions:-1:1,
    tI = D.indtrial(Settings.SubjectLevel.conditionLabel{iCondition}, ...
                    'GOOD');
    trialInds{iCondition} = ROInets.setdiff_pos_int(tI, excludeTrials);
    % check we've found something                               
    if isempty(trialInds{iCondition}), 
        warning([mfilename ':EmptyCondition'], ...
                'No good trials found in %s for condition %s. \n', ...
                D.fname, Settings.SubjectLevel.conditionLabel{iCondition});
    end%if
end%for

% extract a list of all good, relevant trials
goodTrials = sort([trialInds{:}]);

% generate a set of IDs linking trials to condition number
trialID = zeros(length(goodTrials), 1);
for iCondition = nConditions:-1:1,
    trialID(ismember(goodTrials,trialInds{iCondition})) = iCondition;
end%for

% check design matrix size
assert(all(cellfun(@length, Settings.SubjectLevel.designSummary) == nConditions), ...
       [mfilename ':DesignMatrixSizeFault'],                                      ...
       ['The design matrix summary must, in each cell, contain a vector of the ', ...
        'same length as the number of conditions. \n']);
% use an OSL function to generate the subject-specific design matrix
designMat = oat_setup_designmatrix(struct('Xsummary', {Settings.SubjectLevel.designSummary}, ...
                                          'trialtypes', trialID));
end%set_up_first_level
    
%--------------------------------------------------------------------------
function [t, tI, tR] = time_range(time, timeRange, iSession)
%TIME_RANGE selects time range for analysis of each session
% TIME is a vector of times
% TIMERANGE is either a cell array of two-component vectors, a single
% two-component vector, or a null vector

if isempty(timeRange),
    % use the whole time range
    t = time;
    tI = true(size(time));
    tR = [];
else
    % subselect time range
    if iscell(timeRange),
        tR = timeRange{iSession};
    else
        tR = timeRange;
    end%if
    validateattributes(tR, {'numeric'}, ...
                       {'vector', 'numel', 2, 'nondecreasing'}, ... % can have negative times in task data. 
                       'time_range', 'timeRange', 2);
                   
    tI = (time <= tR(2)) & (time >= tR(1));
    t  = time(tI);
end%if
end%time_range



%--------------------------------------------------------------------------
% [EOF]
                                                                                                                                                                                                                                                                                                                                                                                                        (std(voxelData, [], 2), eps);
        voxelDataScaled = ROInets.demean(voxelData, 2);
        clear voxelData
        
        % pre-allocate PCA weightings for each parcel
        voxelWeightings = zeros(size(spatialBasis));
        
        % perform PCA on each parcel and select 1st PC scores to represent
        % parcel
        for iParcel = nParcels:-1:1,
%             progress = nParcels - iParcel + 1;
%             ft_progress(progress / nParcels, ...
%                         [mfilename ...
%                          ':    Finding PCA time course for ROI %d out of %d'], ...
%                         iParcel, nParcels);
                
            thisMask = spatialBasis(:, iParcel);
            if any(thisMask), % non-zero
                parcelData = voxelDataScaled(thisMask, :);
                
                [U, S, V]  = ROInets.fast_svds(parcelData, 1);
                PCAscores  = S * V';
                
                % restore sign and scaling of parcel time-series
                % U indicates the weight with which each voxel in the
                % parcel contributes to the 1st PC
                TSsign          = sign(mean(U));
                relVoxelWeights = abs(U) ./ sum(abs(U)); % normalise the linear combination
                % weight the temporal STDs from the ROI by the proportion used in 1st PC
                TSscale         = dot(relVoxelWeights, temporalSTD(thisMask)); 
                nodeTS          = TSsign .*                               ...
                                  (TSscale / max(std(PCAscores), eps)) .* ... 
                                  PCAscores;
                      
                % return the linear operator which is applied to the data
                % to retrieve the nodeTS
                voxelWeightings(thisMask, iParcel) = TSsign .* ...
                                                     (TSscale / max(std(PCAscores), eps)) ...
                                                     .* U';
                
            else
                warning([mfilename ':EmptySpatialComponentMask'],          ...
                        ['%s: When calculating ROI time-courses, ',        ...
                         'an empty spatial component mask was found for ', ...
                         'component %d. \n',                               ...
                         'The ROI will have a flat zero time-course. \n',  ...
                         'Check this does not cause further problems ',    ...
                         'with the analysis. \n'],                         ...
                         mfilename, iParcel);
                     
                nodeTS = zeros(1, ROInets.cols(voxelDataScaled));
            end%if
            
            nodeData(iParcel,:) = nodeTS;
        end%for
        
        clear parcelData voxelDataScaled

    case 'peakvoxel'
        if any(spatialBasis(:)~=0 & spatialBasis(:)~=1),
            warning([mfilename ':NonBinaryParcelMask'],    ...
                    ['Input parcellation is not binary. ', ...
                     'It will be binarised. \n']);
        end%if
        spatialBasis = logical(spatialBasis);
        
        % find rms power in each voxel
        voxelPower = sqrt(ROInets.row_sum(voxelData.^2) ./ ...
                          ROInets.cols(voxelData));
                      
        % pre-allocate weightings for each parcel
        voxelWeightings = zeros(size(spatialBasis));
                      
        % take peak voxel in each parcel
        for iParcel = nParcels:-1:1,
%             progress = nParcels - iParcel + 1;
%             ft_progress(progress / nParcels, ...
%                         [mfilename ...
%                          ':    Finding peak voxel time course for ROI %d out of %d'], ...
%                         iParcel, nParcels);
            
            thisMask = spatialBasis(:, iParcel);
            
            if any(thisMask), % non-zero
                % find index of voxel with max power
                thisParcPower            = voxelPower;
                thisParcPower(~thisMask) = 0;
                [~, maxPowerInd]         = max(thisParcPower);
                
                % select voxel timecourse
                nodeData(iParcel,:) = voxelData(maxPowerInd,:);
                
                % save which voxel was used
                voxelWeightings(maxPowerInd, iParcel) = 1;
                
            else
                warning([mfilename ':EmptySpatialComponentMask'],          ...
                        ['%s: When calculating ROI time-courses, ',        ...
                         'an empty spatial component mask was found for ', ...
                         'component %d. \n',                               ...
                         'The ROI will have a flat zero time-course. \n',  ...
                         'Check this does not cause further problems ',    ...
                         'with the analysis. \n'],                         ...
                         mfilename, iParcel);
                     
                nodeData(iParcel,:) = zeros(1, ROInets.cols(voxelData));
            end%if
        end%loop over parcels
        
        clear voxelData parcelData
        
    case 'spatialbasis'
        % scale group maps so all have a positive peak of height 1
        % in case there is a very noisy outlier, choose the sign from the
        % top 5% of magnitudes
        top5pcInd = abs(spatialBasis) >=                        ...
                         repmat(prctile(abs(spatialBasis), 95), ...
                                [ROInets.rows(spatialBasis), 1]);
        for iParcel = nParcels:-1:1,
            mapSign(iParcel) = sign(mean(...
                              spatialBasis(top5pcInd(:,iParcel), iParcel)));
        end%for
        scaledSpatialMaps = ROInets.scale_cols(spatialBasis, ...
                                   mapSign ./                ...
                                   max(max(abs(spatialBasis), [], 1), eps));
        
        % find time-course for each spatial basis map
        for iParcel = nParcels:-1:1, % allocate memory on the fly
%             progress = nParcels - iParcel + 1;
%             ft_progress(progress / nParcels, ...
%                         [' ' mfilename ...
%                          ':    Finding spatial basis time course for ROI %d out of %d'], ...
%                         iParcel, nParcels);
            
            % extract the spatial map of interest
            thisMap     = scaledSpatialMaps(:, iParcel);
            parcelMask  = logical(thisMap);
            
            % estimate temporal-STD for normalisation
            temporalSTD = max(std(voxelData, [], 2), eps);
            
            % variance-normalise all voxels to remove influence of
            % outliers. - remove this step 20 May 2014 for MEG as data are
            % smooth and little risk of high-power outliers. Also, power is
            % a good indicator of sensible signal. 
            % Weight all voxels by the spatial map in question
            weightedTS  = ROInets.scale_rows(voxelData, thisMap);
            
            % perform svd and take scores of 1st PC as the node time-series
            % U is nVoxels by nComponents - the basis transformation
            % S*V holds nComponents by time sets of PCA scores - the 
            % timeseries data in the new basis
            [U, S, V]   = ROInets.fast_svds(weightedTS(parcelMask,:), 1);
            clear weightedTS
            
            PCAscores   = S * V';
            maskThresh  = 0.5; % 0.5 is a decent arbitrary threshold chosen by Steve Smith and MJ after playing with various maps.
            thisMask    = thisMap(parcelMask) > maskThresh;   
            
            if any(thisMask), % the mask is non-zero
                % U is the basis by which voxels in the mask are weighted
                % to form the scores of the 1st PC
                relativeWeighting = abs(U(thisMask)) ./ ...
                                    sum(abs(U(thisMask)));
                
                TSsign  = sign(mean(U(thisMask)));
                TSscale = dot(relativeWeighting, temporalSTD(thisMask));       
                nodeTS  = TSsign .*                               ...
                          (TSscale / max(std(PCAscores), eps)) .* ...      
                          PCAscores;
                      
                % for Mark: this is the linear operator which is applied to
                % the voxel data to get nodeTS.
                voxelWeightings(parcelMask,iParcel) = TSsign .* ...
                                             (TSscale / max(std(PCAscores), eps)) ...
                                             .* (U' .* thisMap(parcelMask)');
                
            else
                warning([mfilename ':EmptySpatialComponentMask'],          ...
                        ['%s: When calculating ROI time-courses, ',        ...
                         'an empty spatial component mask was found for ', ...
                         'component %d. \n',                               ...
                         'The ROI will have a flat zero time-course. \n',  ...
                         'Check this does not cause further problems ',    ...
                         'with the analysis. \n'],                         ...
                         mfilename, iParcel);
                     
                nodeTS = zeros(1, ROInets.cols(weightedTS));
                voxelWeightings(~thisMask, iParcel) = zeros(length(thisMask), 1);
            end%if
            
            nodeData(iParcel, :) = nodeTS;
            
        end%loop over parcels
        
        clear voxelData 
        
        
    otherwise
        error([mfilename ':UnrecognisedTimeCourseMethod'],            ...
              ['Unrecognised method for finding ROI time-course. \n', ...
               'Expected ''PCA'', ''spatialBasis'', or ''mean''. \n']);
end%switch

% ft_progress('close');

end%get_node_tcs
%--------------------------------------------------------------------------
end%run_individual_correlation_analysis
%--------------------------------------------------------------------------






%--------------------------------------------------------------------------
function balanced = balance_correlations(x)
%BALANCE_CORRELATIONS makes matrices symmetric

if ismatrix(x) && ~isvector(x),
    balanced = (x + x') ./ 2.0;
else
    balanced = x;
end%if
end%balance_correlations






%--------------------------------------------------------------------------
function [t, tI, tR] = time_range(time, timeRange, iSession)
%TIME_RANGE selects time range for analysis of each session
% TIME is a vector of times
% TIMERANGE is either a cell array of two-component vectors, a single
% two-component vector, or a null vector

if isempty(timeRange),
    % use the whole time range
    t = time;
    tI = true(size(time));
    tR = [];
else
    % subselect time range
    if iscell(timeRange),
        tR = timeRange{iSession};
    else
        tR = timeRange;
    end%if
    validateattributes(tR, {'numeric'}, ...
                       {'vector', 'numel', 2, 'nonnegative', 'nondecreasing'}, ...
                       'time_range', 'timeRange', 2);
                   
    tI = (time <= tR(2)) & (time >= tR(1));
    t  = time(tI);
end%if
end%time_range





%--------------------------------------------------------------------------
function [] = save_corrected_timecourse_results(nodeData, ...
    allROImask, voxelWeightings, Settings, sessionName, protocol, bandName)
% Save the weightings over voxels used to calculate the time-course
% for each ROI
if Settings.SaveCorrected.ROIweightings,
    allVoxelWeightings                = zeros(ROInets.rows(allROImask), ...
                                              ROInets.cols(voxelWeightings));
    allVoxelWeightings(allROImask, :) = voxelWeightings;

    saveDir             = fullfile(Settings.outputDirectory, ...
                                   'spatialBasis-ROI-weightings', filesep);
    ROItcWeightSaveFile = fullfile(saveDir,                      ...
                                   [sessionName '_' protocol '_' ...
                                    bandName '_ROI_timecourse_weightings']);
    ROInets.make_directory(saveDir);
    try
        nii.quicksave(allVoxelWeightings, ROItcWeightSaveFile, Settings.gridStep);
    catch % perhaps we have a weird number of voxels
        save(ROItcWeightSaveFile, 'allVoxelWeightings');
    end%try
end%if

% save node data
if Settings.SaveCorrected.timeCourses,
    saveDir = fullfile(Settings.outputDirectory, 'corrected-ROI-timecourses', filesep);
    ROInets.make_directory(saveDir);
    saveFile = fullfile(saveDir, [sessionName '_correction-' protocol '_' bandName '_ROI_timecourses.mat']);
    save(saveFile, 'nodeData');
end%if

% save variance in each ROI
if Settings.SaveCorrected.variances,
    saveDir = fullfile(Settings.outputDirectory, 'corrected-ROI-timecourses', filesep);
    ROInets.make_directory(saveDir);
    varSaveFile = fullfile(saveDir, [sessionName '_correction-' protocol '_' bandName '_ROI_variances.mat']);
    ROIvariances = var(nodeData, [], 2);                                   %#ok<NASGU>
    save(varSaveFile, 'ROIvariances');
end%if
end%save_corrected_timecourse_results
%--------------------------------------------------------------------------
% [EOF]
                                                                    martshare_history: historycount = %d, peercount = %d
 smartmem: host->memavail = %llu
 smartmem: MemTotal       = %llu (%f GB)
 smartmem: MemFree        = %llu (%f GB)
 smartmem: Buffers        = %llu (%f GB)
 smartmem: Cached         = %llu (%f GB)
 smartmem: NumPeers       = %u
 smartmem: MemReserved    = %llu (%f GB)
 smartmem: MemSuggested   = %llu (%f GB)
 smartcpu_update: switching to zombie
 smartcpu_update: ProcessorCount = %d
 smartcpu_update: NumPeers       = %d
 smartcpu_update: BogoMips       = %.2f
 smartcpu_update: AvgLoad        = %.2f
 smartcpu_update: CpuLoad        = %.2f %%
 smartcpu_update: host->status   = %u
 smartcpu_update: switching to idle
 open_uds_connection socket error: open_uds_connection socket
 open_uds_connection connect error: open_uds_connection connect
 open_uds_connection: connected to %s on socket %d
 open_tcp_connection: using direct memory copy
 open_tcp_connection: server = %s, port = %u
 open_tcp_connection: nslookup1 failed on '%s'
 open_tcp_connection: nslookup2 failed on '%s'
 open_tcp_connection: socket = %d
 open_tcp_connection error: open_tcp_connection
 open_tcp_connection: connectioncount = %d
 open_tcp_connection: connected to %s:%u on socket %d
 close_connection: socket = %d
 close_connection error: close_connection
 close_connection: connectioncount = %d
                          �  4   4   _�      4                                   zR x�  $      Z������=        A�C       $   D   0Z�������        A�C       $   l   �Z�������       A�C       $   �   �\�������        A�C       $   �   �\������2	       A�C              zR x�  $      �e������i        A�C       $   D   @f������K       A�C       $   l   hg�������       A�C       $   �   0j�������       A�C              zR x�  $      �m������       A�C       $   D   �o������(
       A�C              zR x�  $      xy�������        A�C       $   D   0z������R       A�C       $   l   h��������       A�C              zR x�  $      ؂������V        A�C       $   D   �������U       A�C       $   l   H�������2       A�C              zR x�  $      H�������m        A�C       $   D   ��������:       A�C       $   l   ��������g       A�C       $   �   ��������"       A�C       $   �   ��������p        A�C       $   �   @�������p        A�C       $     ��������_        A�C       $   4  ���������        A�C       $   \  h�������F       A�C       $   �  ���������        A�C       $   �  ��������        A�C       $   �  ���������        A�C       $   �  8��������        A�C       $   $  Д�������        A�C       $   L  h��������        A�C       $   t   ��������        A�C       $   �  ��������        A�C       $   �  ���������        A�C              zR x�  $      ��������>       A�C       $   D   ؗ������v       A�C              zR x�  $      �������"       A�C       $   D    ��������       A�C       $   l   ��������#        A�C              zR x�  $      ��������       A�C       $   D   ���������       A�C              zR x�  $      0��������        A�C       $   D   ض������P       A�C       $   l    �������P       A�C       $   �   (�������P       A�C              zR x�  $      8��������       A�C              zR x�  $      ��������b        A�C       $   D   м������J       A�C       $   l   ��������R       A�C              zR x�  $      ��������        A�C       $   D   ���������
       A�C              zR x�  $      0��������        A�C       $   D   ��������       A�C              zR x�  $      ���������       A�C       $   D   P�������)       A�C       $   l   X�������#        A�C       $   �   `�������       A�C        �_�  �_�          ��      �      �      �      (�      4�      @�      L�      X�      d�      p�      |�      ��      ��      ��      ��      ��      Ĝ      М      ܜ      �      ��       �      �      �      $�      0�      <�      H�      T�      `�      l�      x�      ��      ��      ��      ��      ��      ��      ̝      ؝      �      �      ��      �      �       �      ,�      8�      D�      P�      \�      h�      t�      ��      ��      ��      ��      ��      ��      Ȟ      Ԟ      ��      �      ��      �      �      �              ��      ��              ���2                                                            ���2                                                                   ���<                                            ���2                                                            ���2                                                            ���2                                                            ���2                                                            ���2                                                            ���2                                                            ���2                                                            ���2                                                            ���2                                                            ���2                                                            ���2                                                            ���2                                                            ���2                                                            ���2                                                            ���2                                                            ���2                                                            ���2                                                            ���2                                                            ���2                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                       (     0     8     @     H     P     X     `     h     p     x     �     �     �     �     �     �     �     �     �     �     �     �     �     �     �     �                           (    0    8    @    H    P    X    `    h    p    x    �    �    �    �    �    �    �    �    �    �    �    �    �    �    �    �                          (    0    H    @    �@����p��������`��p���pp`��������������0�������p��������0        d           +   d           8   f ��U       .  �      x   $  �         $   @          N  @          .         �   $            $   �          N  �          .  �      �   $  �         $   �         N  �         .  �      �   $  �         $   �          N  �          .  @      �   $  @         $   2	         N  2	      �               �               �               �               �                                d             d             d           !  f ��U       .  �      T  $  �         $   p          N  p          .  �      [  $  �         $   P         N  P         .  @      m  $  @         $   �         N  �         .  0!      w  $  0!         $   �         N  �         d             d           �  d           �  f ��U       .  �$      �  $  �$         $             N            .  �&      �  $  �&         $   (
         N  (
         d             d           �  d           �  f ��U       .   1        $   1         $   �          N  �          .   2      *  $   2         $   `         N  `         .  `8      2  $  `8         $   �         N  �         d             d           B  d           K  f ��U    |              �              �              �              �              �              �              �              �              	                            +              @              U              k                            �              �              �              �              �              �              �                                          "              0              =              J              W              h              n              x              �              �              �              �              �              �              �              �              �                                                           d             d           #  d           .  f ��U       .  ;      a  $  ;         $   `          N  `          .  p;      g  $  p;         $   `         N  `         .  �A      q  $  �A         $   2         N  2         d             d           {  d           �  f ��U       .  D      �  $  D         $   p          N  p          .  �D      �  $  �D         $   @         N  @         .  �E      �  $  �E         $   p         N  p         .  0G      �  $  0G         $   0         N  0         .  `I      �  $  `I         $   p          N  p          .  �I      �  $  �I         $   p          N  p          .  @J      �  $  @J         $   `          N  `          .  �J      �  $  �J         $   �          N  �          .  pK      
  $  pK         $   P         N  P         .  �L        $  �L         $   �          N  �          .  `M      /  $  `M         $   �          N  �          .   N      D  $   N         $   �          N  �          .  �N      Z  $  �N         $   �          N  �          .  �O      o  $  �O         $   �          N  �          .  `P      �  $  `P         $   �          N  �          .   Q      �  $   Q         $   �          N  �          .  �Q      �  $  �Q         $             N            .  �Q      �  $  �Q         $   �          N  �          d             d           �  d           �  f ��U       .  pR        $  pR         $   @         N  @         .  �S        $  �S         $   v         N  v         d             d           )  d           5  f ��U       .  0Z      i  $  0Z         $   0         N  0         .  `[      |  $  `[         $   �         N  �         .   b      �  $   b      �  �              $   #          N  #          d             d              d           ,  f ��U       .  Pb      `  $  Pb         $             N            .  pc      s  $  pc         $   �         N  �         d             d           ~  d           �  f ��U       .  @s      �  $  @s         $   �          N  �          .  t      �  $  t         $   P         N  P         .  `u      �  $  `u         $   P         N  P         .  �v      �  $  �v         $   P         N  P         d             d           	  d           	  f ��U       .   x      F	  $   x         $   �         N  �         d             d           W	  d           d	  f ��U       .  �z      �	  $  �z         $   p          N  p          .   {      �	  $   {         $   P         N  P         .  P      �	  $  P         $   R         N  R         d             d           �	  d           �	  f ��U       .  ��      
  $  ��         $   �          N  �          .  P�      
  $  P�         $   �
         N  �
         d             d           /
  d           :
  f ��U       .  0�      m
  $  0�         $   �          N  �          .  Ѝ      |
  $  Ѝ         $            N           d             d           �
  d           �
  f ��U       .  �      �
  $  �         $   �         N  �         .  ��      �
  $  ��         $   0         N  0         .  �      �
  $  �         $   0          N  0          .  @�        $  @�         $            N           d              �      ,    �      ?    �      S           f    �      r    �      {    �      �    �      �    @      �    0!      �    �$      �    �&      �     1      �     2      �    `8      �    ;      �    p;          �A          D          �D      !    �E      +    0G      3    `I      =    �I      H    @J      T    �J      d    pK      s    �L      �    `M      �     N      �    �N      �    �O      �    `P      �     Q          �Q          �Q      %    pR      8    �S      C    0Z      V    `[      a     b      o    Pb      �    pc      �    @s      �    t      �    `u      �    �v      �     x      �    �z      �     {          P           ��      /    P�      @    0�      O    Ѝ      `    �      u    ��      �    �      �    @�      �    X�      �    ��      �    ��      �    ��      �    �      �    P�          ��          ��      &    �      <    P�      G    ��      V    ��      d    �      x    P�      �    ��      �    ��      �    �      �    P�      �    ��      �    ��      �    �          P�          ��      -    ��      6    ��      ?    ��      Q    ��      c    ��      t    ��      �    ��      �    ��      �     �      �    �      �    �      �    �      �    �      �    �      �     �      �    (�          0�          8�      #    @�      3    H�      D    P�      S    X�      c    `�      s    h�      }    ��      �    ��      �    ��      �    ��      �    @      �            �            �            �            �            �                                    #            )            0            7            @            G            Q            W            ^            d            q            z            �            �            �            �            �            �            �            �            �            �            �            �            
                        #            4            J            d            n            �            �            �            �            �            �            �            �            �                                    ,            @            F            O            U            _            e            m            y            �            �            �            �            �            �            �            �            �            �            �  �  �  �  �  �  �  �  �  �  �  �  �  �  �  �  �  �  �  �  �  �  �  �  �  �  �  �  �  �  �  �  �  �  �  �  �  �  �  �  �  �  �  �  �  �  �  �  �  �  �  �                     	  
            �  �  �  �  �  �  �  �  �  �  �  �  �  �  �  �  �  �  �  �  �  �  �  �  �  �  �  �  �  �  �  �  �  �  �  �  �  �  �  �  �  �  �  �  �  �  �  �  �  �  �  �  �                     	  
              /Users/roboos/matlab/fieldtrip/peer/src/ memprofile.c /Users/roboos/matlab/fieldtrip/peer/src/../private/memprofile.o _memprofile_cleanup _memprofile_sample _memprofile _exitFun _mexFunction _mutexmemlist _mutexmemprofile _reftime _memlist _memprofileStatus _memprofileThread announce.c /Users/roboos/matlab/fieldtrip/peer/src/announce.o _frand _cleanup_announce _announce _announce_once discover.c /Users/roboos/matlab/fieldtrip/peer/src/discover.o _cleanup_discover _discover expire.c /Users/roboos/matlab/fieldtrip/peer/src/expire.o _cleanup_expire _expire _check_watchdog extern.c /Users/roboos/matlab/fieldtrip/peer/src/extern.o _syslog_level _condstatus _mutexstatus _mutexappendcount _mutexsocketcount _mutexthreadcount _mutexconnectioncount _mutexhost _mutexpeerlist _mutexjoblist _mutexallowuserlist _mutexrefuseuserlist _mutexallowgrouplist _mutexrefusegrouplist _mutexallowhostlist _mutexrefusehostlist _mutexwatchdog _mutexsmartmem _mutexsmartcpu _mutexprevcpu _mutexsmartshare _udsserverStatus _tcpserverStatus _announceStatus _discoverStatus _expireStatus _appendcount _socketcount _threadcount _connectioncount _host _peerlist _joblist _allowuserlist _refuseuserlist _allowgrouplist _refusegrouplist _allowhostlist _refusehostlist _smartsharelist _watchdog _smartmem _smartcpu _prevcpu _smartshare peerinit.c /Users/roboos/matlab/fieldtrip/peer/src/peerinit.o _hash _peerinit _peerexit util.c /Users/roboos/matlab/fieldtrip/peer/src/util.o _threadsleep _bufread _bufwrite _append _jobcount _peercount _hoststatus _clear_peerlist _clear_joblist _clear_smartsharelist _clear_allowuserlist _clear_allowgrouplist _clear_allowhostlist _clear_refuseuserlist _clear_refusegrouplist _clear_refusehostlist _check_datatypes _getmem udsserver.c /Users/roboos/matlab/fieldtrip/peer/src/udsserver.o _cleanup_udsserver _udsserver tcpserver.c /Users/roboos/matlab/fieldtrip/peer/src/tcpserver.o _cleanup_tcpserver _tcpserver __OSSwapInt16 /Applications/Xcode.app/Contents/Developer/Platforms/MacOSX.platform/Developer/SDKs/MacOSX10.9.sdk/usr/include/libkern/i386/_OSByteOrder.h tcpsocket.c /Users/roboos/matlab/fieldtrip/peer/src/tcpsocket.o _cleanup_tcpsocket _tcpsocket security.c /Users/roboos/matlab/fieldtrip/peer/src/security.o _security_check _ismember_userlist _ismember_grouplist _ismember_hostlist localhost.c /Users/roboos/matlab/fieldtrip/peer/src/localhost.o _check_localhost smartshare.c /Users/roboos/matlab/fieldtrip/peer/src/smartshare.o _smartshare_reset _smartshare_check _smartshare_history smartmem.c /Users/roboos/matlab/fieldtrip/peer/src/smartmem.o _smartmem_info _smartmem_update smartcpu.c /U