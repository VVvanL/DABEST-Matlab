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



end