function s11a_MLR_premove_dur(blocks)
%% Produce a bar plot showing the relative effect of arena complexity vs.
% path length on the premove and relative pre-move duration
% NOTE: Only skipped trials were excluded for this analysis

epoch_durations=get_epoch_durations(blocks);
mean_centrality=nan(5,1); clrs=def_colors; 

for arnum=1:5
    G=graph(blocks{arnum}.arena.neighbor); C=centrality(G,'closeness')*149; 
    mean_centrality(arnum)=mean(C); 
end

relative_premove=epoch_durations.pre_move./...
    (epoch_durations.entire_trial-epoch_durations.search);

complexity=100*(-mean_centrality+0.1115);
[~,~,LENGTH]=get_trial_qualities(blocks);
MLR_slopes=MLR_length_complexity(epoch_durations.pre_move,LENGTH,complexity,clrs.gold);
MLR_slopes=MLR_length_complexity(relative_premove,LENGTH,complexity,clrs.gold);
