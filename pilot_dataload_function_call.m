% pilot script to load data and call various functions for difference estimation 

conditions = {'CTRL20', 'iLTP20'};
cnd_n = length(conditions);

folderN = uigetdir();
foldparts = strsplit(folderN,filesep); dirname = foldparts{end-1}; clear foldparts
folderN = ([folderN, filesep]);

file_list = dir([folderN, '*.csv']);
file_n = size(file_list, 1);
data_tables = struct();

for tb = 1:file_n

    tbl_name = file_list(tb).name(1:end-4);
    tbl_temp = readtable([folderN, file_list(tb).name]);

    data_tables.(tbl_name) = tbl_temp;
    
    clear tbl_name
end

var_list = tbl_temp.Properties.VariableNames;
var_list{1} = 'roi';
var_n = length(var_list);
% var_list{var_n + 1} = 'exp';
% var_n = var_n + 1;

var_types = tbl_temp.Properties.VariableTypes;
clear tbl_temp

table_names = fieldnames(data_tables);

data_struct = struct();  % stores data in grouped format for ggram based plotting
data_struct.condition = {};
data_struct.experiment = {};

for var = 1:var_n
    var_name = var_list{var};
    if var_types(var) == 'double' %#ok<*BDSCA>
        data_struct.(var_name) = [];
    elseif var_types(var) == 'cell'
        data_struct.(var_name) = {};
    end
end


for tb = 1:file_n
    table_name = table_names{tb};

    data_n = height(data_tables.(table_name));
    for cnd = 1:cnd_n
        if contains(table_name, conditions{cnd})

            data_struct.condition = vertcat(data_struct.condition, repmat(conditions(cnd),[data_n 1]));
        end
    end
    for var = 1:var_n
        var_name = var_list{var};

        data_struct.(var_name) = vertcat(data_struct.(var_name), data_tables.(table_name).(var_name));
    end
end

save([folderN, dirname, '.mat'], 'data_struct', 'data_tables')
%% initial visualization of data

clear g

figure;
g = gramm('x', data_struct.condition, 'y', data_struct.psd_area, 'color', data_struct.acq);
g.geom_point('dodge', 0.3);
g.set_names('x', 'condition', 'y', 'psd_area', 'color', 'aquisition');
g.draw();
