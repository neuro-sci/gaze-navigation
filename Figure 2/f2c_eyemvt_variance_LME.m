function f2c_eyemvt_variance_LME(blocks)
%% Plot bar graphs showing variance in the point of gaze within trials
% vs. across trials for different epochs
% NOTE: For all analyses in the paper, trials skipped by the subject were
% excluded
% NOTE: The superimposed scatter pertains to data for each subject

clrs=def_colors; subjvec=[2,4,6,9,10,11,13,14,15,16,17,20,21];
within_search=nan(5,13,60); within_premove=nan(5,13,60); within_move=nan(5,13,60);

%% Compute variances
for arnum=1:5
    for subj=1:13
        subject=subjvec(subj); continuous=blocks{arnum}.continuous{subject};
        for trial=1:size(continuous,2)
            gazeX=continuous{trial}.gazeX_noblink; gazeY=continuous{trial}.gazeY_noblink;
            detected=blocks{arnum}.discrete{subject}(trial).detect_frame;
            start_move=blocks{arnum}.discrete{subject}(trial).start_move;
            stop_move=blocks{arnum}.discrete{subject}(trial).stop_move;
            
            within_search(arnum,subj,trial)=sqrt(var(gazeX(1:detected),'omitnan')+var(gazeY(1:detected),'omitnan'));
            across_search(arnum,subj,trial,1)=mean(gazeX(1:detected),'omitnan');
            across_search(arnum,subj,trial,2)=mean(gazeY(1:detected),'omitnan');
            if ~isnan(start_move)
                within_premove(arnum,subj,trial)=sqrt(var(gazeX(detected:start_move),'omitnan')+var(gazeY(detected:start_move),'omitnan'));
                across_premove(arnum,subj,trial,1)=mean(gazeX(detected:start_move),'omitnan');
                across_premove(arnum,subj,trial,2)=mean(gazeY(detected:start_move),'omitnan');
                if ~isnan(stop_move)
                    within_move(arnum,subj,trial)=sqrt(var(gazeX(start_move:stop_move),'omitnan')+var(gazeY(start_move:stop_move),'omitnan'));
                    across_move(arnum,subj,trial,1)=mean(gazeX(start_move:stop_move),'omitnan');
                    across_move(arnum,subj,trial,2)=mean(gazeY(start_move:stop_move),'omitnan');
                else % If the subject presses the end-trial button while still moving...
                    within_move(arnum,subj,trial)=sqrt(var(gazeX(start_move:end),'omitnan')+var(gazeY(start_move:end),'omitnan'));
                    across_move(arnum,subj,trial,1)=mean(gazeX(start_move:end),'omitnan');
                    across_move(arnum,subj,trial,2)=mean(gazeY(start_move:end),'omitnan');
                end
            else % If the subject does not move during the trial...
                within_premove(arnum,subj,trial)=sqrt(var(gazeX(detected:end),'omitnan')+var(gazeY(detected:end),'omitnan'));
                across_premove(arnum,subj,trial,1)=mean(gazeX(detected:end),'omitnan');
                across_premove(arnum,subj,trial,2)=mean(gazeY(detected:end),'omitnan');
            end
        end
    end
end

ind=exclude_skipped_trials(blocks); % Exclude skipped trials
within_premove(ind)=NaN; within_move(ind)=NaN;

%% LME: trial-specific effects on within-trial eye movement variance

[fixed_premove,random_premove,R_vals_premove,P_vals_premove]=linear_mixed_effects(blocks,within_premove,clrs.gold);
ylabel('Relative effect');
[fixed_move,random_move,R_vals_move,P_vals_move]=linear_mixed_effects(blocks,within_move,clrs.blue);
ylabel('Relative effect');
