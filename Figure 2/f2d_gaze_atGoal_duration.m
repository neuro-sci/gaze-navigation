function f2d_gaze_atGoal_duration(blocks)
%% Plot the fraction of time subjects spend gazing within 2 m from the goal
% across arenas and as a function of the number of turns remaining
% NOTE: For all analyses in the paper, trials skipped by the subject were
% excluded
% NOTE: Error bars show standard error across subjects

clrs=def_colors; subjvec=[2,4,6,9,10,11,13,14,15,16,17,20,21]; mean_centrality=nan(5,1);
gazedur_search=nan(5,13,60); gazedur_premove=nan(5,13,60); gazedur_move=nan(5,13,60);
gazedur_search_byArena=nan(5,1); gazedur_premove_byArena=nan(5,1); gazedur_move_byArena=nan(5,1);
gazedur_search_bySubject=nan(5,13); gazedur_premove_bySubject=nan(13,1); gazedur_move_bySubject=nan(13,1);
ste_gazedur_search=nan(5,1); ste_gazedur_premove=nan(5,1); ste_gazedur_move=nan(5,1); 
% Each subject completed <300 trials, but preallocate for more than this
gazedur=nan(6,13,300); gazedur_bySubgoal=nan(6,1); gazedur_bySubject=nan(6,13);
ste_gazedur=nan(6,1); cut_before_stop=23; 
% cut 23 frames before the end of the trial because the subject
% is occupied with button press

%% Compute duration -- by arena loop
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
            
            gazedur_search(arnum,subj,trial)=sum(sqrt((target_x-gazeX(1:detected)).^2+...
                (target_y-gazeY(1:detected)).^2)<2)/sum(nnz(~isnan(gazeX(1:detected)) & ~isnan(gazeY(1:detected))));
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

%% Compute duration -- subgoal loop
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
                if length(all_turns)>1
                    for subgoal=2:min([height(turns{trial}),5]) % Preceeding each turn
                        gazedur(6-subgoal+1,subj,idx)=sum(gaze_atGoal(turns{trial}.turn_start(all_turns(subgoal)):...
                            turns{trial}.turn_start(all_turns(subgoal-1))),'omitnan')/...
                            nnz(~isnan(gaze_atGoal(turns{trial}.turn_start(all_turns(subgoal)):...
                            turns{trial}.turn_start(all_turns(subgoal-1)))));
                    end
                    if height(turns{trial})<=5 % From the start of movement to the first turn
                        gazedur(6-height(turns{trial}),subj,idx)=sum(gaze_atGoal(start_move:...
                            turns{trial}.turn_start(all_turns(subgoal-1))),'omitnan')/...
                            nnz(~isnan(gaze_atGoal(start_move:turns{trial}.turn_start(all_turns(subgoal-1)))));
                    end
                else % If there is only one turn
                    gazedur(5,subj,idx)=sum(gaze_atGoal(start_move:turns{trial}.turn_start(all_turns(1))),'omitnan')/...
                        nnz(~isnan(gaze_atGoal(start_move:turns{trial}.turn_start(all_turns(1)))));
                end
            else % If there are no turns, only populate the last column
                gazedur(6,subj,idx)=sum(gaze_atGoal(start_move:triallen),'omitnan')/...
                    nnz(~isnan(gaze_atGoal(start_move:triallen)));
            end
            idx=idx+1;
        end
    end
end

%% Take averages and standard errors
ind=exclude_skipped_trials(blocks);
gazedur_search(ind)=NaN; gazedur_premove(ind)=NaN; gazedur_move(ind)=NaN;

for arnum=1:5
    for subj=1:13
        gazedur_search_bySubject(arnum,subj)=mean(gazedur_search(arnum,subj,:),'omitnan');
        gazedur_premove_bySubject(arnum,subj)=mean(gazedur_premove(arnum,subj,:),'omitnan');
        gazedur_move_bySubject(arnum,subj)=mean(gazedur_move(arnum,subj,:),'omitnan');
    end
    gazedur_search_byArena(arnum)=mean(gazedur_search(arnum,:,:),'all','omitnan');
    gazedur_premove_byArena(arnum)=mean(gazedur_premove(arnum,:,:),'all','omitnan');
    gazedur_move_byArena(arnum)=mean(gazedur_move(arnum,:,:),'all','omitnan');
    
    ste_gazedur_search(arnum)=std(gazedur_search_bySubject(arnum,:),'omitnan')/sqrt(13); 
    ste_gazedur_premove(arnum)=std(gazedur_premove_bySubject(arnum,:),'omitnan')/sqrt(13); 
    ste_gazedur_move(arnum)=std(gazedur_move_bySubject(arnum,:),'omitnan')/sqrt(13); 
end

for subgoal=1:6
    for subj=1:13
        gazedur_bySubject(subgoal,subj)=mean(gazedur(subgoal,subj,:),'all','omitnan');
    end
    gazedur_bySubgoal(subgoal)=mean(gazedur(subgoal,:,:),'all','omitnan');
    ste_gazedur(subgoal)=std(gazedur_bySubject(subgoal,:),'omitnan')/sqrt(13);
end

%% Plot fraction of time subjects gaze at the goal -- by arena
figure('Position',[0 0 450 350]); hold on; 
complexity=100*(-mean_centrality+0.1115);
plot(flip(complexity),flip(100*gazedur_search_byArena),'color','k')
plot(flip(complexity),flip(100*gazedur_premove_byArena),'color','k')
plot(flip(complexity),flip(100*gazedur_move_byArena),'color','k')

scatter(complexity,100*gazedur_search_byArena,300,...
    'markerfacecolor',clrs.pink,'markeredgecolor','none')
errorbar(complexity,100*gazedur_search_byArena,...
    100*ste_gazedur_search,'LineStyle','none','color','k','CapSize',0)
scatter(complexity,100*gazedur_premove_byArena,300,...
    'markerfacecolor',clrs.gold,'markeredgecolor','none')
errorbar(complexity,100*gazedur_premove_byArena,...
    100*ste_gazedur_premove,'LineStyle','none','color','k','CapSize',0)
scatter(complexity,100*gazedur_move_byArena,300,...
    'markerfacecolor',clrs.blue,'markeredgecolor','none')
errorbar(complexity,100*gazedur_move_byArena,...
    100*ste_gazedur_move,'LineStyle','none','color','k','CapSize',0)

%% Format
movegui(gcf,'center')
set(gca,'color','w','fontsize',24,'Tickdir','out','Ticklength',[.03 .03]); 
set(gcf,'color','w','InvertHardCopy','off'); 
xticks([0 3 6]); xlim([-1 7]); yticks([0 40 80]); ylim([0 90])
xlabel('Arena complexity'); ylabel('Gaze duration (%)')

%% Compute stats: % gazing at goal

mean_premove=mean(gazedur_premove,'all','omitnan');
mean_move=mean(gazedur_move,'all','omitnan');
premove_STD=nan(13,1); move_STD=nan(13,1);
for subj=1:13
    premove_STD(subj)=mean(gazedur_premove_bySubject(:,subj),'all','omitnan');
    move_STD(subj)=mean(gazedur_move_bySubject(:,subj),'all','omitnan');
end
premove_STD=std(premove_STD); move_STD=std(move_STD);
disp(['during pre-movement, subjects gaze at the goal ',num2str(100*mean_premove),...
    ' +/- ',num2str(100*premove_STD),'% of the time'])
disp(['during movement, subjects gaze at the goal ',num2str(100*mean_move),...
    ' +/- ',num2str(100*move_STD),'% of the time'])

%% Plot average distance of gaze from the goal -- by subgoal
figure('Position',[0 0 450 350]); hold on; 
plot(1:6,100*gazedur_bySubgoal,'color','k')
scatter(1:6,100*gazedur_bySubgoal,300,'markerfacecolor',clrs.blue,'markeredgecolor','k')
errorbar(1:6,100*gazedur_bySubgoal,100*ste_gazedur,'LineStyle','none','color','k','CapSize',0)

movegui(gcf,'center')
set(gca,'color','w','fontsize',24,'Tickdir','out','Ticklength',[.03 .03]);
set(gcf,'color','w','InvertHardCopy','off');
xticks([2 4 6]); xlim([0.5 6.5]); xticklabels({'4','2','0'}); 
yticks([0 20 40 60]); ylim([0 60])
xlabel('Turns remaining'); ylabel('Gaze duration (%)')
