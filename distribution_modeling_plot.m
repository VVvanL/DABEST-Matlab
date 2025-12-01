% working script to plot data from mock distributions

%% scratch plotting of p value histograms
hist_face_clr = '#969696';
hist_edge_clr = '#252525';

xlabels= {'p21','p31','p41','p51'};

figure; histogram(p_matrix(:,1),'BinWidth',0.05,'FaceColor', hist_face_clr, 'EdgeColor', hist_edge_clr', 'LineWidth', 1, 'Normalization','probability')
xlim([0 1]); ylim([0 1])
axis square

figure; histogram(p_matrix(:,2),'BinWidth',0.05,'FaceColor', hist_face_clr, 'EdgeColor', hist_edge_clr', 'LineWidth', 1,'Normalization','probability')
xlim([0 1]); ylim([0 1])
axis square

figure; histogram(p_matrix(:,3),'BinWidth',0.05,'FaceColor', hist_face_clr, 'EdgeColor', hist_edge_clr', 'LineWidth', 1, 'Normalization','probability')
xlim([0 1]); ylim([0 1])
axis square

figure; histogram(p_matrix(:,4),'BinWidth',0.05,'FaceColor', hist_face_clr, 'EdgeColor', hist_edge_clr', 'LineWidth', 1, 'Normalization','probability')
xlim([0 1]); ylim([0 1])
axis square


%% plot mock distributions
y1_clr = '#252525';

figure; hold on;

plot(x,distributions.pdf.y1, 'Color', y1_clr, 'LineWidth', 2.5)
plot(x,distributions.pdf.y2, 'Color', clr(1,:), 'LineWidth', 2)
plot(x,distributions.pdf.y3, 'Color', clr(2,:), 'LineWidth', 2)
plot(x,distributions.pdf.y4, 'Color', clr(3,:), 'LineWidth', 2)
plot(x,distributions.pdf.y5, 'Color', clr(4,:), 'LineWidth', 2)

legend('y1','y2','y3','y4','y5','FontSize', 12)
xlim([0 17])

%% plot pairwise distribution comparisons
clr = orderedcolors('gem');

figure; hold on
plot(x,distributions.pdf.y1, 'Color', y1_clr, 'LineWidth', 2.5)
plot(x,distributions.pdf.y2, 'Color', clr(1,:), 'LineWidth', 2.5)
xlim([0 17])
axis square
legend('y1','y2', 'FontSize',12)

figure; hold on
plot(x,distributions.pdf.y1, 'Color', y1_clr, 'LineWidth', 2.5)
plot(x,distributions.pdf.y3, 'Color', clr(2,:), 'LineWidth', 2.5)
xlim([0 17])
axis square
legend('y1','y3', 'FontSize',12)

figure; hold on
plot(x,distributions.pdf.y1, 'Color', y1_clr, 'LineWidth', 2.5)
plot(x,distributions.pdf.y4, 'Color', clr(3,:), 'LineWidth', 2.5)
xlim([0 17])
axis square
legend('y1','y4', 'FontSize',12)

figure; hold on
plot(x,distributions.pdf.y1, 'Color', y1_clr, 'LineWidth', 2.5)
plot(x,distributions.pdf.y5, 'Color', clr(4,:), 'LineWidth', 2.5)
xlim([0 17])
axis square
legend('y1','y5', 'FontSize',12)



%% plot swarmchart of selected sample points


X1 = categorical(repmat({'y1'},23,1));
X2 = categorical(repmat({'y2'},23,1));
X3 = categorical(repmat({'y3'},23,1));
X4 = categorical(repmat({'y4'},23,1));
X5 = categorical(repmat({'y5'},23,1));


figure;
swarmchart(X1, example_data(:,1), 17, 'k', 'filled','XjitterWidth',0.05)
hold on
swarmchart(X2, example_data(:,2), 17, clr(1,:),'filled','XjitterWidth',0.05)
swarmchart(X3, example_data(:,3), 17, clr(2,:),'filled','XjitterWidth',0.05)
swarmchart(X4, example_data(:,4), 17, clr(3,:),'filled','XjitterWidth',0.05)
swarmchart(X5, example_data(:,5), 17, clr(4,:),'filled','XjitterWidth',0.05)