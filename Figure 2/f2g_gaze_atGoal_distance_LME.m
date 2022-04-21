function f2g_gaze_atGoal_distance_LME(blocks)
%% Fit linear mixed effects models for trial specific effects on the average
% distance of gaze from the goal
% NOTE: For all analyses in the paper, trials skipped by the subject were
% excluded. Here, trials in which subjects did not move were also excluded

clrs=def_colors; subjvec=[2,4,6,9,10,11,13,14,15,16,17,20,21]; mean_centrality=nan(5,1);
gazedist_premove=nan(5,13,60); gazedist_move=nan(5,13,60);

%% Compute distance -- by arena loop
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
                gazedist_premove(arnum,subj,trial)=mean(sqrt((target_x-gazeX(detected:start_move)).^2+...
                    (target_y-gazeY(detected:start_move)).^2),'omitnan');
                if ~isnan(stop_move)
                    gazedist_move(arnum,subj,trial)=mean(sqrt((target_x-gazeX(start_move:stop_move)).^2+...
                        (target_y-gazeY(start_move:stop_move)).^2),'omitnan');
                else % If the subject presses the end-trial button while still moving...
                    gazedist_move(arnum,subj,trial)=mean(sqrt((target_x-gazeX(start_move:end)).^2+...
                        (target_y-gazeY(start_move:end)).^2),'omitnan');
                end
            else % If the subject does not move during the trial...
                gazedist_premove(arnum,subj,trial)=mean(sqrt((target_x-gazeX(detected:end)).^2+...
                    (target_y-gazeY(detected:end)).^2),'omitnan');
            end
        end
    end
    G=graph(blocks{arnum}.arena.neighbor); C=centrality(G,'closeness')*149; 
    mean_centrality(arnum)=mean(C); 
end

%% LME: trial-specific effects on distance of gaze from the target: pre-movement

[fixed_premove_dist,random_premove_dist,R_vals_premove_dist,P_vals_premove_dist]=linear_mixed_effects(blocks,gazedist_premove,clrs.gold);
ylabel('Relative effect');

%% LME: trial-specific effects on distance of gaze from the target: movement

[fixed_move_dist,random_move_dist,R_vals_move_dist,P_vals_move_dist]=linear_mixed_effects(blocks,gazedist_move,clrs.blue);
ylabel('Relative effect');
