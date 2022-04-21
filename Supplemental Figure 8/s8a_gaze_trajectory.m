function s8a_gaze_trajectory(blocks)
%% Plot the fraction of time subjects spend gazing within 2 m from the trajectory,
% excluding the time gazing within 2 m of the goal location
% Also fit linear mixed effects models
% NOTE: For all analyses in the paper, trials skipped by the subject were
% excluded
% NOTE: Error bars show standard error across subjects

clrs=def_colors; subjvec=[2,4,6,9,10,11,13,14,15,16,17,20,21]; mean_centrality=nan(5,1);
gazedur_premove=nan(5,13,60); gazedur_move=nan(5,13,60);
gazedur_premove_byArena=nan(5,1); gazedur_move_byArena=nan(5,1);
gazedur_premove_bySubject=nan(13,1); gazedur_move_bySubject=nan(13,1);
ste_gazedur_premove=nan(5,1); ste_gazedur_move=nan(5,1); 

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
            
            gaze_target=zeros(length(continuous{trial}.trialTime),1);
            gaze_target(sqrt((gazeX-target_x).^2+(gazeY-target_y).^2)<2)=1;
            gaze_trajectory=zeros(length(continuous{trial}.trialTime),1);
            gaze_trajectory(gaze_target==0 & continuous{trial}.idistfromtraj<2)=1;
            
            if ~isnan(start_move)
                gazedur_premove(arnum,subj,trial)=sum(gaze_trajectory(detected:start_move))/...
                    nnz(~isnan(gazeX(detected:start_move)));
                if ~isnan(stop_move)
                    gazedur_move(arnum,subj,trial)=sum(gaze_trajectory(start_move:stop_move))/...
                        nnz(~isnan(gazeX(start_move:stop_move)));
                else % If the subject presses the end-trial button while still moving...
                    gazedur_move(arnum,subj,trial)=sum(gaze_trajectory(start_move:end))/...
                        nnz(~isnan(gazeX(start_move:end)));
                end
            else % If the subject does not move during the trial...
                gazedur_premove(arnum,subj,trial)=sum(gaze_trajectory(detected:end))/...
                    nnz(~isnan(gazeX(detected:end)));
            end
        end
    end
    G=graph(blocks{arnum}.arena.neighbor); C=centrality(G,'closeness')*149; 
    mean_centrality(arnum)=mean(C); 
end

%% Take averages and standard errors
ind=exclude_skipped_trials(blocks);
gazedur_premove(ind)=NaN; gazedur_move(ind)=NaN;

for arnum=1:5
    for subj=1:13
        gazedur_premove_bySubject(arnum,subj)=mean(gazedur_premove(arnum,subj,:),'omitnan');
        gazedur_move_bySubject(arnum,subj)=mean(gazedur_move(arnum,subj,:),'omitnan');
    end
    gazedur_premove_byArena(arnum)=mean(gazedur_premove(arnum,:,:),'all','omitnan');
    gazedur_move_byArena(arnum)=mean(gazedur_move(arnum,:,:),'all','omitnan');
    
    ste_gazedur_premove(arnum)=std(gazedur_premove_bySubject(arnum,:),'omitnan')/sqrt(13); 
    ste_gazedur_move(arnum)=std(gazedur_move_bySubject(arnum,:),'omitnan')/sqrt(13); 
end

%% Plot fraction of time subjects gaze at the goal
figure('position',[0 0 450 375]); hold on
complexity=100*(-mean_centrality+0.1115);
plot(flip(complexity),flip(100*gazedur_premove_byArena),'color','k')
plot(flip(complexity),flip(100*gazedur_move_byArena),'color','k')

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
xticks([0 3 6]); xlim([-1 7]); yticks([0 25 50]); ylim([0 50])
xlabel('Arena complexity'); ylabel('% Time')

%% LME: trial-specific effects on percent of time looking at the trajectory: premove

[fixed_premove,random_premove,R_vals_premove,P_vals_premove]=...
    linear_mixed_effects(blocks,gazedur_premove,clrs.gold);
ylabel('Relative effect');

%% LME: trial-specific effects on percent of time looking at the trajectory: move

[fixed_move,random_move,R_vals_move,P_vals_move]=...
    linear_mixed_effects(blocks,gazedur_move,clrs.blue);
ylabel('Relative effect');
