function f2e_gaze_atGoal_duration_LME(blocks)
%% Fit linear mixed effects models for trial specific effects on the amount 
% of time subjects spent gazing at the goal
% NOTE: For all analyses in the paper, trials skipped by the subject were
% excluded

clrs=def_colors; subjvec=[2,4,6,9,10,11,13,14,15,16,17,20,21]; mean_centrality=nan(5,1);
gazedur_premove=nan(5,13,60); gazedur_move=nan(5,13,60);

%% Compute duration
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

ind=exclude_skipped_trials(blocks);
gazedur_premove(ind)=NaN; gazedur_move(ind)=NaN;

%% LME: trial-specific effects on percent of time gazing at the target: pre-movement

[fixed_premove,random_premove,R_vals_premove,P_vals_premove]=linear_mixed_effects(blocks,gazedur_premove,clrs.gold);
ylabel('Relative effect');

%% LME: trial-specific effects on percent of time gazing at the target: movement

[fixed_move,random_move,R_vals_move,P_vals_move]=linear_mixed_effects(blocks,gazedur_move,clrs.blue);
ylabel('Relative effect');
