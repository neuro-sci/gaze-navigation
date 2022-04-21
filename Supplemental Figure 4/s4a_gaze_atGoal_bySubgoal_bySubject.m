function s4a_gaze_atGoal_bySubgoal_bySubject(blocks)
%% Plot the fraction of time subjects spend gazing within 2 m from the goal,
% and the average distance of gaze to the goal location, given the number
% of subgoals (turns) remaining in their chosen trajectory, by subject
% NOTE: For all analyses in the paper, trials skipped by the subject were
% excluded. Here, trials in which subjects did not move were also excluded
% NOTE: Error bars show standard error across subjects

clrs=def_colors; subjvec=[2,4,6,9,10,11,13,14,15,16,17,20,21];
% Each subject completed <300 trials, but preallocate for more than this
gazedur=nan(6,13,300); gazedur_bySubgoal=nan(6,1); gazedur_bySubject=nan(6,13);
ste_gazedur=nan(6,1);
gazedist=nan(6,13,300); gazedist_bySubgoal=nan(6,1); gazedist_bySubject=nan(6,13);
ste_gazedist=nan(6,1);
cut_before_stop=23; % cut 23 frames before the end of the trial because the subject
% is occupied with button press

%% Compute durations and distances
for subj=1:13, idx=1;
    for arnum=1:5
        subject=subjvec(subj); continuous=blocks{arnum}.continuous{subject};
        turns=blocks{arnum}.turns{subject};
        for trial=1:size(continuous,2)
            start_move=blocks{arnum}.discrete{subject}(trial).start_move;
            % Exclude skipped trials or trials in which the subject didn't move
            if isnan(start_move) || blocks{arnum}.discrete{subject}(trial).RewardZone==9
                continue; end
            target=blocks{arnum}.discrete{subject}(trial).TargetStatenum+1;
            % Scale by 2 b/c the arena was scaled by 2 when loaded into Unity
            target_x=2*blocks{arnum}.arena.centroids(target,1);
            target_y=2*blocks{arnum}.arena.centroids(target,2);
            gazeX=continuous{trial}.gazeX_noblink; gazeY=continuous{trial}.gazeY_noblink;
            dist_fromGoal=sqrt((target_x-gazeX).^2+(target_y-gazeY).^2);
            gaze_atGoal=dist_fromGoal<2;
            triallen=length(continuous{trial}.trialTime)-cut_before_stop;
            
            if ~isempty(turns{trial})
                all_turns=flip(1:height(turns{trial}));
                % From the last turn to the end of the trial
                gazedur(6,subj,idx)=sum(gaze_atGoal(turns{trial}.turn_start(all_turns(1)):triallen),'omitnan')/...
                    nnz(~isnan(gaze_atGoal(turns{trial}.turn_start(all_turns(1)):triallen)));
                gazedist(6,subj,idx)=mean(dist_fromGoal(turns{trial}.turn_start(all_turns(1)):triallen),'omitnan');
                if length(all_turns)>1
                    for subgoal=2:min([height(turns{trial}),5]) % Preceeding each turn
                        gazedur(6-subgoal+1,subj,idx)=sum(gaze_atGoal(turns{trial}.turn_start(all_turns(subgoal)):...
                            turns{trial}.turn_start(all_turns(subgoal-1))),'omitnan')/...
                            nnz(~isnan(gaze_atGoal(turns{trial}.turn_start(all_turns(subgoal)):...
                            turns{trial}.turn_start(all_turns(subgoal-1)))));
                        gazedist(6-subgoal+1,subj,idx)=mean(dist_fromGoal(turns{trial}.turn_start(all_turns(subgoal)):...
                            turns{trial}.turn_start(all_turns(subgoal-1))),'omitnan');
                    end
                    if height(turns{trial})<=5 % From the start of movement to the first turn
                        gazedur(6-height(turns{trial}),subj,idx)=sum(gaze_atGoal(start_move:...
                            turns{trial}.turn_start(all_turns(subgoal-1))),'omitnan')/...
                            nnz(~isnan(gaze_atGoal(start_move:turns{trial}.turn_start(all_turns(subgoal-1)))));
                        gazedist(6-height(turns{trial}),subj,idx)=mean(dist_fromGoal(start_move:...
                            turns{trial}.turn_start(all_turns(subgoal-1))),'omitnan');
                    end
                else % If there is only one turn
                    gazedur(5,subj,idx)=sum(gaze_atGoal(start_move:turns{trial}.turn_start(all_turns(1))),'omitnan')/...
                        nnz(~isnan(gaze_atGoal(start_move:turns{trial}.turn_start(all_turns(1)))));
                    gazedist(5,subj,idx)=mean(dist_fromGoal(start_move:turns{trial}.turn_start(all_turns(1))),'omitnan');
                end
            else % If there are no turns, only populate the last column
                gazedur(6,subj,idx)=sum(gaze_atGoal(start_move:triallen),'omitnan')/...
                    nnz(~isnan(gaze_atGoal(start_move:triallen)));
                gazedist(6,subj,idx)=mean(dist_fromGoal(start_move:triallen),'omitnan');
            end
            idx=idx+1;
        end
    end
end

%% Take averages and standard errors
for subgoal=1:6
    for subj=1:13
        gazedur_bySubject(subgoal,subj)=mean(gazedur(subgoal,subj,:),'all','omitnan');
        gazedist_bySubject(subgoal,subj)=mean(gazedist(subgoal,subj,:),'all','omitnan');
    end
    gazedur_bySubgoal(subgoal)=mean(gazedur(subgoal,:,:),'all','omitnan');
    ste_gazedur(subgoal)=std(gazedur_bySubject(subgoal,:),'omitnan')/sqrt(13);
    gazedist_bySubgoal(subgoal)=mean(gazedist(subgoal,:,:),'all','omitnan');
    ste_gazedist(subgoal)=std(gazedist_bySubject(subgoal,:),'omitnan')/sqrt(13);
end

%% Line plots: Gaze duration/distance vs. turns remaining by subject

figure('Position',[0 0 450 375]); hold on; 
for subj=1:13, plot(1:6,100*gazedur_bySubject(:,subj),'color',[clrs.subjects(subj,:),0.7],'linewidth',2); end
movegui(gcf,'center'); set(gcf,'color','w','InvertHardCopy','off'); 
set(gca,'color','w','fontsize',24,'Tickdir','out','Ticklength',[.03 .03]); 
xticks([2 4 6]); xlim([0.5 6.5]); xticklabels({'4','2','0'}); 
xlabel('Turns remaining'); ylabel('Gaze duration (%)'); ylim([0 65])

figure('Position',[0 0 450 375]); hold on; 
for subj=1:13, plot(1:6,gazedist_bySubject(:,subj),'color',[clrs.subjects(subj,:),0.7],'linewidth',2); end
movegui(gcf,'center'); set(gcf,'color','w','InvertHardCopy','off'); 
set(gca,'color','w','fontsize',24,'Tickdir','out','Ticklength',[.03 .03]); 
xticks([2 4 6]); xlim([0.5 6.5]); xticklabels({'4','2','0'}); 
xlabel('Turns remaining'); ylabel('Gaze distance (m)')

%%  Linear mixed effects model: duration of gaze at the goal (%)

turns=[1:6]';
[fixed,random,R_vals,P_vals]=LME_complexity(turns,gazedur_bySubject);

%%  Linear mixed effects model: distance of gaze from the goal

[fixed,random,R_vals,P_vals]=LME_complexity(turns,gazedist_bySubject);
