% pilot script to load data and call various functions for difference estimation 

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
clear tbl_temp
var_n = length(var_list);

data_struct = struct();  % stores data in grouped format for ggram based plotting

for var = 1:var_n

    var_name = var_list{var};

    for tb = 1:tbl_name





    end



end




%% initial visualization of data