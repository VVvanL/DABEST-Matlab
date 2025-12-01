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

% plot ARS057 data

clear g

for m = 1:metrics_n
    
    metric_name = metrics{m};

    g(1,m) = gramm('x', data_struct.condition, 'y', data_struct.(metric_name), 'color', data_struct.experiment); %#ok<*SAGROW>
    g(1,m).geom_jitter('dodge', 0.6);
    g(1,m).set_title(metric_name);
    g(1,m).set_names('x', '', 'y', '');

end 
g(1, metrics_n).set_names('x', '', 'y', '', 'color','experiment');
figure
g.draw()



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

figure; hold on; grid on
plot(x,distributions.pdf.y1)
plot(x,distributions.pdf.y2)
plot(x,distributions.pdf.y3)
plot(x,distributions.pdf.y4)
plot(x,distributions.pdf.y5)

legend('y1','y2','y3','y4','y5')


% create random samples from mock distributions
sz = [37 1]; % sample size 
itr_n = 100; % number of iterations
dist_n = 5; % number of mock distributions to sample from
sample_matrix =  zeros([sz(1), dist_n, itr_n]);
p_matrix = zeros(itr_n, dist_n -1);



for itr = 1:itr_n

    r1 = gamrnd(5,1,sz);

    r2 = gamrnd(10,0.5,sz);
    p21 = ranksum(r2,r1);

    r3 = gamrnd(5.5,1,sz);
    p31 = ranksum(r3,r1);

    r4 = gamrnd(6,1,sz);
    p41 = ranksum(r4,r1);

    r5 = gamrnd(6.5,1,sz);
    p51 = ranksum(r5,r1);

    r_matrix = [r1, r2, r3, r4, r5];
    sample_matrix(:,:,itr) = r_matrix;
    p_matrix(itr,:) = [p21,p31,p41,p51];    

end
clear r_matrix r1 r2 r3 r4 r5 p21 p31 p41 p51

save([folderN, dirname, '.mat'], 'mock_data', '-append')


%% scratch plotting commands

xlabels= {'p21','p31','p41','p51'};

figure; histogram(p_matrix(:,1),'BinWidth',0.05,'FaceColor', 'Normalization','probability')
figure; histogram(p_matrix(:,2),'BinWidth',0.05,'Normalization','probability')
figure; histogram(p_matrix(:,3),'BinWidth',0.05,'Normalization','probability')
figure; histogram(p_matrix(:,4),'BinWidth',0.05,'Normalization','probability')


y_matrix = [repmat({'y1'},sz), repmat({'y2'},sz), repmat({'y3'},sz), repmat({'y4'},sz), repmat({'y5'},sz)];
gammadist = struct();
gammadist.r = reshape(r_matrix,[],1);
gammadist.y = reshape(y_matrix,[],1);


clear g

g = gramm('x', gammadist.y, 'y', gammadist.r);
g.geom_jitter('dodge', 0.6);
figure;
g.draw();

%% format example data for DABEST pilot

% create identifier column for DABEST .csv
dists = {'y1','y2','y3','y4','y5'};
dist_n = length(dists);
sample_sz = 23;

identifiers = {};
for dst = 1:dist_n
    dist_str = dists(dst);
    temp_cells = repmat(dist_str, sample_sz, 1);

    identifiers = vertcat(identifiers, temp_cells); %#ok<*AGROW>
end

