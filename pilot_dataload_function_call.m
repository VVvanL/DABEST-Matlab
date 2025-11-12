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
    
    data_struct.experiment = vertcat(data_struct.experiment, repmat({table_name}, [data_n 1]));

    for var = 1:var_n
        var_name = var_list{var};

        data_struct.(var_name) = vertcat(data_struct.(var_name), data_tables.(table_name){:, var});
    end
end

save([folderN, dirname, '.mat'], 'data_struct', 'data_tables')
%% initial visualization of data
metrics = fieldnames(data_struct);
metrics = metrics(4:end);
metrics_n = length(metrics);

clear g

for m = 1:metrics_n
    
    metric_name = metrics{m};

    g(1,m) = gramm('x', data_struct.condition, 'y', data_struct.(metric_name), 'color', data_struct.experiment); %#ok<*SAGROW>
    g(1,m).geom_jitter('dodge', 0.6);
    g(1,m).set_names('x', 'condition', 'y', metric_name,'color','experiment');

end 
figure;
g = gramm('x', data_struct.condition, 'y', data_struct.psd_area);
g.geom_point('dodge', 0.3);
g.set_names('x', 'condition', 'y', 'psd_area');
g.draw();

%% create subset of data for distribution modeling 
% use data from ARS057 datasets; area metrics
ARS057 = struct();
ARS057.ctrl = data_tables.CTRL20_ARS057;
ARS057.iLTP = data_tables.iLTP20_ARS057;
conditions = {'ctrl', 'iLTP'};
cnd_n = length(conditions); 
% calculate mean and variance for each metric
ARS057.stats = struct();

for cnd = 1:cnd_n
    cnd_name = conditions{cnd};

    ARS057.stats.(cnd_name).n = height(ARS057.(cnd_name));
    
    for m = 1:metrics_n
        metric_name = metrics{m};

        [V,M] = var(ARS057.(cnd_name).(metric_name));

        ARS057.stats.(cnd_name).(metric_name).var_mean = [V,M];

    end
end

save([folderN, dirname, '.mat'], 'ARS057', '-append')

%% create simulated distributions

% pd = makedist('Gamma','a',5,'b',1);

% PDFs of various gamma distributions
distributions = struct();
distributions.pdf = struct();

x = 0:0.1:25;
distributions.pdf.y1 = gampdf(x,5,1);
distributions.pdf.y2 = gampdf(x, 10, 0.5);
distributions.pdf.y3 = gampdf(x,5.5,1);
distributions.pdf.y4 = gampdf(x,6,1);
distributions.pdf.y5 = gampdf(x,6.5,1);
distributions.pdf.x = x; clear x

save([folderN, dirname, '.mat'], 'distributions', '-append')

% figure; hold on; grid on
% plot(x,y1)
% plot(x,y2)
% plot(x,y3)
% plot(x,y4)
% plot(x,y5)

% legend()

sz = [37 1];

r1 = gamrnd(5,1,sz);
r2 = gamrnd(10,0.5,sz);
r3 = gamrnd(5.5,1,sz);
r4 = gamrnd(6,1,sz);
r5 = gamrnd(6.5,1,sz);

% plot random samples from gamma distributions

r_matrix = [r1, r2, r3, r4, r5];
y_matrix = [repmat({'y1'},sz), repmat({'y2'},sz), repmat({'y3'},sz), repmat({'y4'},sz), repmat({'y5'},sz)];

gammadist = struct();
gammadist.r = reshape(r_matrix,[],1);
gammadist.y = reshape(y_matrix,[],1);

clear g

g = gramm('x', gammadist.y, 'y', gammadist.r);
g.geom_jitter('dodge', 0.6);
figure;
g.draw();