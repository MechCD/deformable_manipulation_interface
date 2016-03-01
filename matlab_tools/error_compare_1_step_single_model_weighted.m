clc; clear;
%%
experiment = 'rope_cylinder';
base_dir = ['../logs/' experiment '/'];

%%
experiment2.base_dir = [base_dir 'z_old/pre_caching_refactor/1_step_single_model/trans_14_rot_14/'];
experiment2.error = load( [experiment2.base_dir 'error.txt'] );
experiment2.name = ['Non-weighted Pseudoinverse K = 14' repmat(char(3), 1, 1)];
experiment2.time = load( [experiment2.base_dir 'time.txt'] );

%%
deform_range = 5:0.5:15;
experiment1.base_dir = [ base_dir '1_step_single_model/' ];
experiment1.time = load( [experiment1.base_dir 'trans_10_rot_10/time.txt'] );
experiment1.error = zeros( length(experiment1.time), length(deform_range), length( deform_range ) );
experiment1.name = ['Weighted Pseudoinverse' repmat(char(3), 1, 2)];

for trans_deform_ind = 1:length( deform_range )
    for rot_deform_ind = 1:length( deform_range )
        experiment1.error( :, trans_deform_ind, rot_deform_ind ) = ...
            load( [experiment1.base_dir sprintf( 'trans_%g_rot_%g/error.txt', ...
                                                 deform_range( trans_deform_ind ), ...
                                                 deform_range( rot_deform_ind ) )] );
    end
end

t_start = min([experiment2.time; experiment1.time]);

experiment1.time = experiment1.time - t_start;
experiment2.time = experiment2.time - t_start;

output_name = ['output_images/' experiment '/1-step-single-model-weighted-comparison.eps' ];

%%
% https://dgleich.github.io/hq-matlab-figs/
% http://blogs.mathworks.com/loren/2007/12/11/making-pretty-graphs/

width = 7;      % Width in inches
height = 6;     % Height in inches
alw = 0.7;      % AxesLineWidth
fsz = 18;       % Fontsize
lw = 2;         % LineWidth
msz = 12;       % MarkerSize

%%
close all;
fig = figure( 'Units', 'inches', ...
              'Position', [0, 0, width, height] );
set( fig, 'PaperPositionMode', 'auto' );

hold on;

for trans_deform_ind = length( deform_range ):-1:1
    for rot_deform_ind = length( deform_range ):-1:1
        h = plot( experiment1.time, experiment1.error(:, trans_deform_ind, rot_deform_ind), ...
            'Color', [ 1, trans_deform_ind/(length( deform_range )+10), rot_deform_ind/(length( deform_range )+10)], ...
            'LineWidth', lw/4 );
        
        if rot_deform_ind == 1 && trans_deform_ind == 1
            experiment1.plot_handle = h;
        end
        
        if deform_range(rot_deform_ind) == 10 && deform_range(trans_deform_ind) == 10
            h_manual_best = h;
            set( h, 'Color', 'b', 'LineWidth', lw );
        end
    end
end

uistack( h_manual_best, 'top' );

experiment2.plot_handle = plot( experiment2.time, experiment2.error, 'g', 'LineWidth', lw );
hold off

h_legend = legend( [experiment1.plot_handle, experiment2.plot_handle, h_manual_best], ...
    experiment1.name, experiment2.name, ['Weighted Pseudoinverse K = 14' repmat(char(3), 1, 2)] );

h_Xlabel = xlabel( 'Time (s)' );
h_Ylabel = ylabel( 'Error' );
% h_title = title( 'Colaborative folding results' );


set([h_Xlabel, h_Ylabel, h_legend], ...
    'FontName'   , 'Helvetica');
set([gca, h_legend]            , ...
    'FontSize'   , fsz-2       );
set([h_Xlabel, h_Ylabel]       , ...
    'FontSize'   , fsz         );

print( output_name, '-depsc2', '-r300');