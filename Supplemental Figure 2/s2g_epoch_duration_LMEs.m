function s2g_epoch_duration_LMEs(blocks)
%% Fit linear mixed effects models for trial-specific effects on epoch durations
% NOTE: Only skipped trials were excluded for this analysis

clrs=def_colors; epoch_durations=get_epoch_durations(blocks);

premove_epoch_duration=epoch_durations.pre_move;
[fixed,random,R_vals,P_vals]=linear_mixed_effects(blocks,premove_epoch_duration,clrs.gold);
ylabel('Relative effect');

move_epoch_duration=epoch_durations.move;
[fixed,random,R_vals,P_vals]=linear_mixed_effects(blocks,move_epoch_duration,clrs.blue);
ylabel('Relative effect');
