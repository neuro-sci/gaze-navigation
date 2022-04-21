function f2f_gaze_atGoal_distance(blocks)
%% Plot the average distance of gaze to the goal location for each arena
% NOTE: For all analyses in the paper, trials skipped by the subject were
% excluded
% NOTE: Error bars show standard error across subjects

clrs=def_colors; subjvec=[2,4,6,9,10,11,13,14,15,16,17,20,21]; mean_centrality=nan(5,1);
gazedist_search=nan(5,13,60); gazedist_premove=nan(5,13,60); gazedist_move=nan(5,13,60);
gazedist_search_byArena=nan(5,1); gazedist_premove_byArena=nan(5,1); gazedist_move_byArena=nan(5,1);
gazedist_search_bySubject=nan(13,1); gazedist_premove_bySubject=nan(13,1); gazedist_move_bySubject=nan(13,1);
ste_gazedist_search=nan(5,1); ste_gazedist_premove=nan(5,1); ste_gazedist_move=nan(5,1); 
gazedist=nan(6,13,300); gazedist_bySubgoal=nan(6,1); gazedist_bySubject=nan(6,13);
ste_gazedist=nan(6,1);
cut_before_stop=23; % cut 23 frames before the end of the trial because the subject
% is occupied with button press

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
            
            gazedist_search(arnum,subj,trial)=mean(sqrt((target_x-gazeX(1:detected)).^2+...
                (target_y-gazeY(1:detected)).^2),'omitnan');
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

%% Compute distances -- by subgoals loop

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
            triallen=length(continuous{trial}.trialTime)-cut_before_stop;
            
            if ~isempty(turns{trial})
                all_turns=flip(1:height(turns{trial}));
                % From the last turn to the end of the trial
                gazedist(6,subj,idx)=mean(dist_fromGoal(turns{trial}.turn_start(all_turns(1)):triallen),'omitnan');
                if length(all_turns)>1
                    for subgoal=2:min([height(turns{trial}),5]) % Preceeding each turn
                        gazedist(6-subgoal+1,subj,idx)=mean(dist_fromGoal(turns{trial}.turn_start(all_turns(subgoal)):...
                            turns{trial}.turn_start(all_turns(subgoal-1))),'omitnan');
                    end
                    if height(turns{trial})<=5 % From the start of movement to the first turn
                        gazedist(6-height(turns{trial}),subj,idx)=mean(dist_fromGoal(start_move:...
                            turns{trial}.turn_start(all_turns(subgoal-1))),'omitnan');
                    end
                else % If there is only one turn
                    gazedist(5,subj,idx)=mean(dist_fromGoal(start_move:turns{trial}.turn_start(all_turns(1))),'omitnan');
                end
            else % If there are no turns, only populate the last column
                gazedist(6,subj,idx)=mean(dist_fromGoal(start_move:triallen),'omitnan');
            end
            idx=idx+1;
        end
    end
end

%% Take averages and standard errors
ind=exclude_skipped_trials(blocks);
gazedist_search(ind)=NaN; gazedist_premove(ind)=NaN; gazedist_move(ind)=NaN;

for arnum=1:5
    for subj=1:13
        gazedist_search_bySubject(arnum,subj)=mean(gazedist_search(arnum,subj,:),'omitnan');
        gazedist_premove_bySubject(arnum,subj)=mean(gazedist_premove(arnum,subj,:),'omitnan');
        gazedist_move_bySubject(arnum,subj)=mean(gazedist_move(arnum,subj,:),'omitnan');
    end
    gazedist_search_byArena(arnum)=mean(gazedist_search(arnum,:,:),'all','omitnan');
    gazedist_premove_byArena(arnum)=mean(gazedist_premove(arnum,:,:),'all','omitnan');
    gazedist_move_byArena(arnum)=mean(gazedist_move(arnum,:,:),'all','omitnan');
    
    ste_gazedist_search(arnum)=std(gazedist_search_bySubject(arnum,:),'omitnan')/sqrt(13); 
    ste_gazedist_premove(arnum)=std(gazedist_premove_bySubject(arnum,:),'omitnan')/sqrt(13);
    ste_gazedist_move(arnum)=std(gazedist_move_bySubject(arnum,:),'omitnan')/sqrt(13);
end

for subgoal=1:6
    for subj=1:13
        gazedist_bySubject(subgoal,subj)=mean(gazedist(subgoal,subj,:),'all','omitnan');
    end
    gazedist_bySubgoal(subgoal)=mean(gazedist(subgoal,:,:),'all','omitnan');
    ste_gazedist(subgoal)=std(gazedist_bySubject(subgoal,:),'omitnan')/sqrt(13);
end

%% Plot average distance of gaze from the goal -- by arena

figure('Position',[0 0 450 350]); hold on; 
complexity=100*(-mean_centrality+0.1115);
plot(flip(complexity),flip(gazedist_search_byArena),'color','k')
plot(flip(complexity),flip(gazedist_premove_byArena),'color','k')
plot(flip(complexity),flip(gazedist_move_byArena),'color','k')

scatter(complexity,gazedist_search_byArena,300,...
    'markerfacecolor',clrs.pink,'markeredgecolor','none')
errorbar(complexity,gazedist_search_byArena,...
    ste_gazedist_search,'LineStyle','none','color','k','CapSize',0)
scatter(complexity,gazedist_premove_byArena,300,...
    'markerfacecolor',clrs.gold,'markeredgecolor','none')
errorbar(complexity,gazedist_premove_byArena,...
    ste_gazedist_premove,'LineStyle','none','color','k','CapSize',0)
scatter(complexity,gazedist_move_byArena,300,...
    'markerfacecolor',clrs.blue,'markeredgecolor','none')
errorbar(complexity,gazedist_move_byArena,...
    ste_gazedist_move,'LineStyle','none','color','k','CapSize',0)

%% Format
movegui(gcf,'center')
set(gca,'color','w','fontsize',24,'Tickdir','out','Ticklength',[.03 .03]); 
set(gcf,'color','w','InvertHardCopy','off'); 
xticks([0 3 6]); xlim([-1 7]); yticks([0 5 10]); ylim([0 10])
xlabel('Arena complexity'); ylabel('Gaze distance (m)')

%% Plot average distance of gaze from the goal -- by subgoal
figure('Position',[0 0 450 350]); hold on; 
plot(1:6,gazedist_bySubgoal,'color','k')
scatter(1:6,gazedist_bySubgoal,300,'markerfacecolor',clrs.blue,'markeredgecolor','k')
errorbar(1:6,gazedist_bySubgoal,ste_gazedist,'LineStyle','none','color','k','CapSize',0)

movegui(gcf,'center')
set(gca,'color','w','fontsize',24,'Tickdir','out','Ticklength',[.03 .03]);
set(gcf,'color','w','InvertHardCopy','off');
xticks([2 4 6]); xlim([0.5 6.5]); xticklabels({'4','2','0'}); 
yticks([3 6 9]); ylim([1 9])
xlabel('Turns remaining'); ylabel('Gaze distance (m)')
