function [subject,properties] = activation_level_interface(subject,properties)

%% Get Activation priors
[subject,properties]            = get_activation_priors(subject,properties);
subject                         = BC_V_save(properties,subject,'priors');
%% Starting Activation Analysis
if(properties.general_params.run_by_trial.value)
    sensor_level                = subject.BC_V_info.sensor_level(contains({subject.BC_V_info.sensor_level.Ref_path},properties.trial_name));
else
    sensor_level                = subject.BC_V_info.sensor_level;
end
pos = 1;
for f=1:length(sensor_level)
    ref_path                    = sensor_level(f).Ref_path;
    file_name                   = sensor_level(f).Name;
    subject.sensor_level_out    = load(fullfile(subject.subject_path,ref_path,file_name));
    band                        = subject.sensor_level_out.band;
    disp('=================================================================');
    disp(strcat("BC-V-->> Activation level for frequency band:", band.str_band));
    %%
    %% Band Analysis, activation level
    %%
    for m=1:length(properties.activation_params.methods)
        analysis_method         = properties.activation_params.methods{m};
        fields                  = fieldnames(analysis_method);
        method                  = fields{1};            
        if(analysis_method.(method).run)
            disp('-----------------------------------------------------------------');
            disp(strcat("-->> Start time: ",datestr(now,'mmmm dd, yyyy HH:MM:SS AM')));
            switch method
                case 'sssblpp'                    
                    properties.activation_params.sssblpp_th     = analysis_method.(method).sssblpp_th;
                    [subject,properties,outputs]                = activation_level_sssblpp(subject,properties); 
                case 'eloreta'                   
                    properties.activation_params.gamma1         = analysis_method.(method).gamma1;
                    properties.activation_params.gamma2         = analysis_method.(method).gamma2;
                    properties.activation_params.delta_gamma    = analysis_method.(method).delta_gamma;
                    properties.activation_params.eloreta_th     = analysis_method.(method).eloreta_th;
                    [subject,properties,outputs]                = activation_level_eloreta(subject,properties);
                case 'lcmv'                    
                    properties.activation_params.gamma1         = analysis_method.(method).gamma1;
                    properties.activation_params.gamma2         = analysis_method.(method).gamma2;
                    properties.activation_params.delta_gamma    = analysis_method.(method).delta_gamma;
                    properties.activation_params.lcmv_th        = analysis_method.(method).lcmv_th;
                    [subject,properties,outputs]                = activation_level_lcmv(subject,properties);
            end
            subject                                             = BC_V_save(properties,subject,'activation',method,outputs,pos,band);
            pos                                                 = pos + 1;
            disp(strcat("-->> End time: ",datestr(now,'mmmm dd, yyyy HH:MM:SS AM')));            
        end
    end
end
end

