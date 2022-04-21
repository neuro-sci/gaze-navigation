function f3e_relevance_byArena(blocks)
%% Scatter the mean AUC of relevance values for each arena
% Also perform a linear regression.
% NOTE: For this plot, gaze within the reward zone was excluded to
% complement Figure 3F
% NOTE: Trials skipped by the subject were excluded from the analysis.
% NOTE: Trials for which the start or goal locations are inaccessible are
% excluded from the analysis.
% NOTE: Error bars show standard error across subjects

clrs=def_colors; subjvec=[2,4,6,9,10,11,13,14,15,16,17,20,21];
relevance_premove=nan(5,13,60);
relevance_move=nan(5,13,60);
relevance_premove_shuffled=nan(5,13,60); 
relevance_move_shuffled=nan(5,13,60);
AUC_premove=nan(5,13); AUC_move=nan(5,13);
AUC_premove_byArena=nan(5,1); AUC_move_byArena=nan(5,1);
sterr_premove=nan(5,1); sterr_move=nan(5,1);
mean_centrality=nan(5,1);

for arnum=1:5
    for subj=1:13
        subject=subjvec(subj); continuous=blocks{arnum}.continuous{subject};
        for trial=1:size(continuous,2)
            target=blocks{arnum}.discrete{subject}(trial).TargetStatenum+1;
            target_x=2*blocks{arnum}.arena.centroids(target,1);
            target_y=2*blocks{arnum}.arena.centroids(target,2);
            detected=blocks{arnum}.discrete{subject}(trial).detect_frame;
            start_move=blocks{arnum}.discrete{subject}(trial).start_move;
            stop_move=blocks{arnum}.discrete{subject}(trial).stop_move;
            
            % Exclude when gaze is within the reward zone
            relevance=continuous{trial}.norm_sens;
            relevance_shuffled=continuous{trial}.norm_shuf_sens;
            relevance(sqrt((continuous{trial}.gazeX_noblink-target_x).^2+...
                (continuous{trial}.gazeY_noblink-target_y).^2)<4*sqrt(3)/3)=NaN;
            relevance_shuffled(sqrt((continuous{trial}.gazeX_noblink-target_x).^2+...
                (continuous{trial}.gazeY_noblink-target_y).^2)<4*sqrt(3)/3)=NaN;
            
            if ~isnan(start_move)
                relevance_premove(arnum,subj,trial)=mean(relevance(detected:start_move-1),'omitnan');
                relevance_premove_shuffled(arnum,subj,trial)=mean(relevance_shuffled(detected:start_move-1),'omitnan');
                if ~isnan(stop_move)
                    relevance_move(arnum,subj,trial)=mean(relevance(start_move:stop_move-1),'omitnan');
                    relevance_move_shuffled(arnum,subj,trial)=mean(relevance_shuffled(start_move:stop_move-1),'omitnan');
                else % If the subject presses the end-trial button while still moving...
                    relevance_move(arnum,subj,trial)=mean(relevance(start_move:end),'omitnan');
                    relevance_move_shuffled(arnum,subj,trial)=mean(relevance_shuffled(start_move:end),'omitnan');
                end
            else % If the subject does not move during the trial...
                relevance_premove(arnum,subj,trial)=mean(relevance(detected:end),'omitnan');
                relevance_premove_shuffled(arnum,subj,trial)=mean(relevance_shuffled(detected:end),'omitnan');
            end
        end
    end
    G=graph(blocks{arnum}.arena.neighbor); C=centrality(G,'closeness')*149; 
    mean_centrality(arnum)=mean(C); 
end

%% Calculate AUC values and standard errors
ind1=exclude_skipped_trials(blocks); ind2=exclude_impossible_trials(blocks);
relevance_premove([ind1,ind2])=NaN; relevance_premove_shuffled([ind1,ind2])=NaN;
relevance_move([ind1,ind2])=NaN; relevance_move_shuffled([ind1,ind2])=NaN;

for arnum=1:5
    for subj=1:13
        AUC_premove(arnum,subj)=calculate_AUC(squeeze(relevance_premove(arnum,subj,:)),...
            squeeze(relevance_premove_shuffled(arnum,subj,:)));
        AUC_move(arnum,subj)=calculate_AUC(squeeze(relevance_move(arnum,subj,:)),...
            squeeze(relevance_move_shuffled(arnum,subj,:)));
    end
    AUC_premove_byArena(arnum)=mean(AUC_premove(arnum,:),'omitnan');
    AUC_move_byArena(arnum)=mean(AUC_move(arnum,:),'omitnan');
    sterr_premove(arnum)=std(AUC_premove(arnum,:),'omitnan')/sqrt(13);
    sterr_move(arnum)=std(AUC_move(arnum,:),'omitnan')/sqrt(13);
end

%% Make a scatter plot 
figure('Position',[0 0 450 375]); hold on;
complexity=100*(-mean_centrality+0.1115);
errorbar(complexity,AUC_premove_byArena,...
    sterr_premove,'LineStyle','none','color','k','CapSize',0)
errorbar(complexity,AUC_move_byArena,...
    sterr_move,'LineStyle','none','color','k','CapSize',0)

% Perform linear regression
X=[-1:7]'; 
plan_move_line=fitlm([complexity;complexity],...
    [AUC_premove_byArena;AUC_move_byArena]); plan_move_pred=predict(plan_move_line,X);
% Plot linear regression
plot(X,plan_move_pred,'color','k')

scatter(complexity,AUC_premove_byArena,200,'markerfacecolor',clrs.gold,'markeredgecolor','none')
scatter(complexity,AUC_move_byArena,200,'markerfacecolor',clrs.blue,'markeredgecolor','none')

%% Format
movegui(gcf,'center')
set(gca,'color','w','fontsize',24,'Tickdir','out','Ticklength',[.03 .03]); 
set(gcf,'color','w','InvertHardCopy','off'); 
xticks([0 3 6]); xlim([-1 7]); 
xlabel('Arena complexity'); ylabel('AUC')

%% Compute stats: correlation between relevance AUC and arena complexity

complexity_matrix=repmat(complexity,1,13);
[R_premove,P_premove]=corrcoef(AUC_premove(:),complexity_matrix(:),'rows','complete');
disp(['correlation of relevance AUC vs. arena complexity (df = 63) pre-movement is ',...
    num2str(R_premove(1,2)),', p_val = ',num2str(P_premove(1,2))])
[R_move,P_move]=corrcoef(AUC_move(:),complexity_matrix(:),'rows','complete');
disp(['correlation of relevance AUC vs. arena complexity (df = 63) during movement is ',...
    num2str(R_move(1,2)),', p_val = ',num2str(P_move(1,2))])
