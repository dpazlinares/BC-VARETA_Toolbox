function [status,reject_subjects] = check_properties(properties)
%CHECK_PROPERTIES Summary of this function goes here
%   Detailed explanation goes here
status = true;
reject_subjects = {};
disp("-->> Checking properties");

if(~isfolder(properties.general_params.params.bcv_workspace.BCV_input_dir))
    fprintf(2,strcat('\nBC-V-->> Error: The param BCV_input_dir defined on bcv_properties/general_params.json file: \n'));
    disp(properties.general_params.params.bcv_workspace.BCV_input_dir);
    fprintf(2,strcat('It is not a correct adreess directory. \n'));
    disp('Please verify the location path.');
    status = false;
    return;
end
if(~isfolder(properties.general_params.params.bcv_workspace.BCV_work_dir))
    fprintf(2,strcat('\nBC-V-->> Error: The param BCV_work_dir defined on bcv_properties/general_params.json file: \n'));
    disp(properties.general_params.params.bcv_workspace.BCV_work_dir);
    fprintf(2,strcat('It is not a correct adreess directory. \n'));
    disp('Please verify the location path.');
    status = false;
    return;
else
    [status,values] = fileattrib(properties.general_params.params.bcv_workspace.BCV_work_dir);
    if(~values.UserWrite)
        fprintf(2,strcat('\nBC-V-->> Error: The current user do not have write permissions on: \n'));
        disp(properties.general_params.params.bcv_workspace.BCV_work_dir);
        disp('Please check the folder permission.');
        status = false;
        return;
    end
end
frequencies = properties.sensor_params.params.frequencies;
for i=1:length(frequencies)
    freq = frequencies(i);
    if(freq.run && freq.f_start > freq.f_end)
        fprintf(2,strcat('\nBC-V-->> Error: The current frequency is not well configured: \n'));
        disp(freq.name);
        disp('Please check the <<f_start>> and <<f_end>> params.');
        status = false;
        return;
    end
end
% sensor_layout = properties.sensor_params.params.fieldtrip.layout.value;
% defaults = dir(fullfile('external/fieldtrip/template/layout'));
% electrode = dir(fullfile('external/fieldtrip/template/electrode'));
% if(isempty(find(ismember({defaults.name},sensor_layout),1)) && isempty(find(ismember({electrode.name},sensor_layout),1)))
%     fprintf(2,strcat('\nBC-V-->> Error: The current sensor level layout is not well configured: \n'));
%     disp(sensor_layout);
%     disp('Please check the sensor layout configured in bcv_properties/sensor_params.json file.');
%     status = false;
%     return;
% end
base_path = properties.general_params.params.bcv_workspace.BCV_input_dir;
structures = dir(base_path);
structures(ismember( {structures.name}, {'.', '..'})) = [];  %remove . and ..
count_data = 0;
for i=1:length(structures)
    structure = structures(i);
    data_file = fullfile(base_path,structure.name,'subject.mat');
    if(~isfile(data_file))
        count_data = count_data + 1;        
        reject_subjects{length(reject_subjects)+1} = structure.name;        
    end
end
if(~isequal(count_data,0))
    if(isequal(count_data,length(structures)))
        fprintf(2,'Any folder in the Input path have a specific format.\n');
        fprintf(2,strcat(base_path,'\n'));
        disp('Please check the general configuration file.');
        status = false;
        disp('-->> Process stoped!!!');
        return;
    else
        warning('One or more of the Subject folder are not correct.');
        warning('These subjects will be rejected for the analysis.');
        disp(reject_subjects);
        warning('Please check the input data configuration.');
    end
    
end

end

                                                                                                                                                            