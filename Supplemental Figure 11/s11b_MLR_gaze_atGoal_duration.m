function s11b_MLR_gaze_atGoal_duration(blocks)
%% Produce a bar plot showing the relative effect of arena complexity vs.
% path length on the relative duration of gaze at the goal during
% pre-movement and movement
% NOTE: For all analyses in the paper, trials skipped by the subject were
% excluded

subjvec=[2,4,6,9,10,11,13,14,15,16,17,20,21]; mean_centrality=nan(5,1);
gazedur_premove=nan(5,13,60); gazedur_move=nan(5,13,60); clrs=def_colors; 

%% Compute durations
for arnum=1:5
    for subj=1:13
        subject=subjvec(subj); continuous=blocks{arnum}.continuous{subject};
        for trial=1:size(continuous,2)
            target=blocks{arnum}.discrete{subject}(trial).TargetStatenum+1;
            % Scale by 2 b/c the arena was scaled by 2 when loaded into Unity
            target_x=2*blocks{arnum}.arena.centroids(target,1);
            target_y=2*blocks{arnum}.arena.centroids(target,2);
            gazeX=continuous{trial}.gazeX_noblink; gazeY=continuous{trial}.gazeY_noblink;
            detected=blocks{arnum}.discrete{subject}(trial).detect_frame;
            start_move=blocks{arnum}.discrete{subject}(trial).start_move;
            stop_move=blocks{arnum}.discrete{subject}(trial).stop_move;
            
            if ~isnan(start_move)
                gazedur_premove(arnum,subj,trial)=sum(sqrt((target_x-gazeX(detected:start_move)).^2+...
                    (target_y-gazeY(detected:start_move)).^2)<2)/...
                    sum(nnz(~isnan(gazeX(detected:start_move)) & ~isnan(gazeY(detected:start_move))));
                if ~isnan(stop_move)
                    gazedur_move(arnum,subj,trial)=sum(sqrt((target_x-gazeX(start_move:stop_move)).^2+...
                        (target_y-gazeY(start_move:stop_move)).^2)<2)/...
                        sum(nnz(~isnan(gazeX(start_move:stop_move)) & ~isnan(gazeY(start_move:stop_move))));
                else % If the subject presses the end-trial button while still moving...
                    gazedur_move(arnum,subj,trial)=sum(sqrt((target_x-gazeX(start_move:end)).^2+...
                        (target_y-gazeY(start_move:end)).^2)<2)/...
                        sum(nnz(~isnan(gazeX(start_move:end)) & ~isnan(gazeY(start_move:end))));
                end
            else % If the subject does not move during the trial...
                gazedur_premove(arnum,subj,trial)=sum(sqrt((target_x-gazeX(detected:end)).^2+...
                    (target_y-gazeY(detected:end)).^2)<2)/...
                    sum(nnz(~isnan(gazeX(detected:end)) & ~isnan(gazeY(detected:end))));
            end
        end
    end
    G=graph(blocks{arnum}.arena.neighbor); C=centrality(G,'closeness')*149; 
    mean_centrality(arnum)=mean(C); 
end

%% Fit regression models and plot
complexity=100*(-mean_centrality+0.1115);
[~,~,LENGTH]=get_trial_qualities(blocks);
MLR_slopes=MLR_length_complexity(gazedur_premove,LENGTH,complexity,clrs.gold);
MLR_slopes=MLR_length_complexity(gazedur_move,LENGTH,complexity,clrs.blue);
