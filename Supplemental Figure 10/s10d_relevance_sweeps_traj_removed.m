function s10d_relevance_sweeps_traj_removed(blocks)
%% Plot the ROC curve and violin plot as seen in Figure 3, but with 
% periods of sweeping (first set of plots) or trajectory gazing
% (second set of plots) removed from the analysis. Most complex arena shown
% for the ROC curves; all arenas for the violin plots.
% NOTE: Trials skipped by the subject were excluded from the analysis.
% NOTE: Trials for which the start or goal locations are inaccessible are
% excluded from the analysis.

clrs=def_colors; subjvec=[2,4,6,9,10,11,13,14,15,16,17,20,21];
relevance_search_sweepsRM=nan(5,13,60); relevance_premove_sweepsRM=nan(5,13,60);
relevance_move_sweepsRM=nan(5,13,60); relevance_search_shuffled_sweepsRM=nan(5,13,60); 
relevance_premove_shuffled_sweepsRM=nan(5,13,60); relevance_move_shuffled_sweepsRM=nan(5,13,60); 
AUC_search_sweepsRM=nan(5,13); AUC_premove_sweepsRM=nan(5,13); AUC_move_sweepsRM=nan(5,13);

relevance_search_trajRM=nan(5,13,60); relevance_premove_trajRM=nan(5,13,60);
relevance_move_trajRM=nan(5,13,60); relevance_search_shuffled_trajRM=nan(5,13,60); 
relevance_premove_shuffled_trajRM=nan(5,13,60); relevance_move_shuffled_trajRM=nan(5,13,60); 
AUC_search_trajRM=nan(5,13); AUC_premove_trajRM=nan(5,13); AUC_move_trajRM=nan(5,13);

%% Remove sweeps

for arnum=1:5
    for subj=1:13
        subject=subjvec(subj); continuous=blocks{arnum}.continuous{subject};
        sweeps=blocks{arnum}.sweeps{subject};
        for trial=1:size(continuous,2)
            detected=blocks{arnum}.discrete{subject}(trial).detect_frame;
            start_move=blocks{arnum}.discrete{subject}(trial).start_move;
            stop_move=blocks{arnum}.discrete{subject}(trial).stop_move;
            true_vals=continuous{trial}.norm_sens;
            shuffled_vals=continuous{trial}.norm_shuf_sens;
            is_sweeping=zeros(length(continuous{trial}.trialTime),1);
            
            % Label which frames pertain to sweeps
            if ~isempty(sweeps{trial}.forward_sweeps)
                for sw=1:size(sweeps{trial}.forward_sweeps,1)
                    is_sweeping(sweeps{trial}.forward_sweeps(sw,1):sweeps{trial}.forward_sweeps(sw,2))=1;
                end
            end
            if ~isempty(sweeps{trial}.backward_sweeps)
                for sw=1:size(sweeps{trial}.backward_sweeps,1)
                    is_sweeping(sweeps{trial}.backward_sweeps(sw,1):sweeps{trial}.backward_sweeps(sw,2))=1;
                end
            end
            
            % Remove these from analysis
            true_vals(is_sweeping==1)=NaN; shuffled_vals(is_sweeping==1)=NaN; 
            
            relevance_search_sweepsRM(arnum,subj,trial)=mean(true_vals(1:detected-1),'omitnan');
            relevance_search_shuffled_sweepsRM(arnum,subj,trial)=mean(shuffled_vals(1:detected-1),'omitnan');
            if ~isnan(start_move)
                relevance_premove_sweepsRM(arnum,subj,trial)=mean(true_vals(detected:start_move-1),'omitnan');
                relevance_premove_shuffled_sweepsRM(arnum,subj,trial)=mean(shuffled_vals(detected:start_move-1),'omitnan');
                if ~isnan(stop_move)
                    relevance_move_sweepsRM(arnum,subj,trial)=mean(true_vals(start_move:stop_move-1),'omitnan');
                    relevance_move_shuffled_sweepsRM(arnum,subj,trial)=mean(shuffled_vals(start_move:stop_move-1),'omitnan');
                else % If the subject presses the end-trial button while still moving...
                    relevance_move_sweepsRM(arnum,subj,trial)=mean(true_vals(start_move:end),'omitnan');
                    relevance_move_shuffled_sweepsRM(arnum,subj,trial)=mean(shuffled_vals(start_move:end),'omitnan');
                end
            else % If the subject does not move during the trial...
                relevance_premove_sweepsRM(arnum,subj,trial)=mean(true_vals(detected:end),'omitnan');
                relevance_premove_shuffled_sweepsRM(arnum,subj,trial)=mean(shuffled_vals(detected:end),'omitnan');
            end
        end
    end
end

%% Remove trajectory

for arnum=1:5
    for subj=1:13
        subject=subjvec(subj); continuous=blocks{arnum}.continuous{subject};
        for trial=1:size(continuous,2)
            detected=blocks{arnum}.discrete{subject}(trial).detect_frame;
            start_move=blocks{arnum}.discrete{subject}(trial).start_move;
            stop_move=blocks{arnum}.discrete{subject}(trial).stop_move;
            true_vals=continuous{trial}.norm_sens;
            shuffled_vals=continuous{trial}.norm_shuf_sens; 
            true_vals(continuous{trial}.idistfromtraj<2)=NaN; 
            shuffled_vals(continuous{trial}.idistfromtraj<2)=NaN; 
            
            relevance_search_trajRM(arnum,subj,trial)=mean(true_vals(1:detected-1),'omitnan');
            relevance_search_shuffled_trajRM(arnum,subj,trial)=mean(shuffled_vals(1:detected-1),'omitnan');
            if ~isnan(start_move)
                relevance_premove_trajRM(arnum,subj,trial)=mean(true_vals(detected:start_move-1),'omitnan');
                relevance_premove_shuffled_trajRM(arnum,subj,trial)=mean(shuffled_vals(detected:start_move-1),'omitnan');
                if ~isnan(stop_move)
                    relevance_move_trajRM(arnum,subj,trial)=mean(true_vals(start_move:stop_move-1),'omitnan');
                    relevance_move_shuffled_trajRM(arnum,subj,trial)=mean(shuffled_vals(start_move:stop_move-1),'omitnan');
                else % If the subject presses the end-trial button while still moving...
                    relevance_move_trajRM(arnum,subj,trial)=mean(true_vals(start_move:end),'omitnan');
                    relevance_move_shuffled_trajRM(arnum,subj,trial)=mean(shuffled_vals(start_move:end),'omitnan');
                end
            else % If the subject does not move during the trial...
                relevance_premove_trajRM(arnum,subj,trial)=mean(true_vals(detected:end),'omitnan');
                relevance_premove_shuffled_trajRM(arnum,subj,trial)=mean(shuffled_vals(detected:end),'omitnan');
            end
        end
    end
end

%% Compute CDFs: sweeps removed
ind1=exclude_skipped_trials(blocks); ind2=exclude_impossible_trials(blocks);
relevance_search_sweepsRM([ind1,ind2])=NaN; relevance_search_shuffled_sweepsRM([ind1,ind2])=NaN; 
relevance_premove_sweepsRM([ind1,ind2])=NaN; relevance_premove_shuffled_sweepsRM([ind1,ind2])=NaN; 
relevance_move_sweepsRM([ind1,ind2])=NaN; relevance_move_shuffled_sweepsRM([ind1,ind2])=NaN; 

arnum=1; figure('Position',[0 0 450 375]); hold on;
true_vals=squeeze(relevance_search_sweepsRM(arnum,:,:));
shuffled_vals=squeeze(relevance_search_shuffled_sweepsRM(arnum,:,:));
[CDF_search,CDF_search_shuf]=plot_CDF(true_vals(:),shuffled_vals(:),clrs.pink,clrs.gray);

true_vals=squeeze(relevance_premove_sweepsRM(arnum,:,:));
shuffled_vals=squeeze(relevance_premove_shuffled_sweepsRM(arnum,:,:));
[CDF_premove,CDF_premove_shuf]=plot_CDF(true_vals(:),shuffled_vals(:),clrs.gold,clrs.gray);

true_vals=squeeze(relevance_move_sweepsRM(arnum,:,:));
shuffled_vals=squeeze(relevance_move_shuffled_sweepsRM(arnum,:,:));
[CDF_move,CDF_move_shuf]=plot_CDF(true_vals(:),shuffled_vals(:),clrs.blue,clrs.gray);
close(gcf)

%% Compute AUCs: sweeps removed
for arnum=1:5
    for subj=1:13
        AUC_search_sweepsRM(arnum,subj)=calculate_AUC(squeeze(relevance_search_sweepsRM(arnum,subj,:)),...
            squeeze(relevance_search_shuffled_sweepsRM(arnum,subj,:)));
        AUC_premove_sweepsRM(arnum,subj)=calculate_AUC(squeeze(relevance_premove_sweepsRM(arnum,subj,:)),...
            squeeze(relevance_premove_shuffled_sweepsRM(arnum,subj,:)));
        AUC_move_sweepsRM(arnum,subj)=calculate_AUC(squeeze(relevance_move_sweepsRM(arnum,subj,:)),...
            squeeze(relevance_move_shuffled_sweepsRM(arnum,subj,:)));
    end
end

%% Plot ROC curve: sweeps removed
figure('Position',[0 0 700 300]); subplot(1,2,1); hold on;
plot(CDF_search,CDF_search_shuf,'color',clrs.pink,'linewidth',5)
plot(CDF_premove,CDF_premove_shuf,'color',clrs.gold,'linewidth',5)
plot(CDF_move,CDF_move_shuf,'color',clrs.blue,'linewidth',5)
set(gca,'color','w','fontsize',24,'Tickdir','out','Ticklength',[.03 .03]); 
xlim([0 1]); xticks([0 1]); xlabel('True')
ylim([0 1]); yticks([0 1]); ylabel('Shuffled') 

%% Make violin plot: sweeps removed
subplot(1,2,2); hold on; facecolor=[clrs.pink;clrs.gold;clrs.blue];
VIOLIN([AUC_search_sweepsRM(:),AUC_premove_sweepsRM(:),AUC_move_sweepsRM(:)],'bw',[0.02 0.02 0.02],...
    'edgecolor','none','facecolor',facecolor,'facealpha',1);
set(gca,'color','w','fontsize',24,'Tickdir','out','Ticklength',[.03 .03])
box off; xlim([0 4]); xticks([1 2 3]); xticklabels({'S','P','M'}); 
ylim([0 1]); yticks([0 0.5 1]); ylabel('AUC')
movegui(gcf,'center'); set(gcf,'color','w','InvertHardCopy','off')

%% Compute CDFs -- trajectory removed
ind1=exclude_skipped_trials(blocks); ind2=exclude_impossible_trials(blocks);
relevance_search_trajRM([ind1,ind2])=NaN; relevance_search_shuffled_trajRM([ind1,ind2])=NaN; 
relevance_premove_trajRM([ind1,ind2])=NaN; relevance_premove_shuffled_trajRM([ind1,ind2])=NaN; 
relevance_move_trajRM([ind1,ind2])=NaN; relevance_move_shuffled_trajRM([ind1,ind2])=NaN; 

arnum=1; figure('Position',[0 0 450 375]); hold on;
true_vals=squeeze(relevance_search_trajRM(arnum,:,:));
shuffled_vals=squeeze(relevance_search_shuffled_trajRM(arnum,:,:));
[CDF_search,CDF_search_shuf]=plot_CDF(true_vals(:),shuffled_vals(:),clrs.pink,clrs.gray);

true_vals=squeeze(relevance_premove_trajRM(arnum,:,:));
shuffled_vals=squeeze(relevance_premove_shuffled_trajRM(arnum,:,:));
[CDF_premove,CDF_premove_shuf]=plot_CDF(true_vals(:),shuffled_vals(:),clrs.gold,clrs.gray);

true_vals=squeeze(relevance_move_trajRM(arnum,:,:));
shuffled_vals=squeeze(relevance_move_shuffled_trajRM(arnum,:,:));
[CDF_move,CDF_move_shuf]=plot_CDF(true_vals(:),shuffled_vals(:),clrs.blue,clrs.gray);
close(gcf)

%% Compute AUCs -- trajectory removed
for arnum=1:5
    for subj=1:13
        AUC_search_trajRM(arnum,subj)=calculate_AUC(squeeze(relevance_search_trajRM(arnum,subj,:)),...
            squeeze(relevance_search_shuffled_trajRM(arnum,subj,:)));
        AUC_premove_trajRM(arnum,subj)=calculate_AUC(squeeze(relevance_premove_trajRM(arnum,subj,:)),...
            squeeze(relevance_premove_shuffled_trajRM(arnum,subj,:)));
        AUC_move_trajRM(arnum,subj)=calculate_AUC(squeeze(relevance_move_trajRM(arnum,subj,:)),...
            squeeze(relevance_move_shuffled_trajRM(arnum,subj,:)));
    end
end

%% Plot ROC curve -- trajectory removed
figure('Position',[0 0 700 300]); subplot(1,2,1); hold on;
plot(CDF_search,CDF_search_shuf,'color',clrs.pink,'linewidth',5)
plot(CDF_premove,CDF_premove_shuf,'color',clrs.gold,'linewidth',5)
plot(CDF_move,CDF_move_shuf,'color',clrs.blue,'linewidth',5)
set(gca,'color','w','fontsize',24,'Tickdir','out','Ticklength',[.03 .03]); 
xlim([0 1]); xticks([0 1]); xlabel('True')
ylim([0 1]); yticks([0 1]); ylabel('Shuffled') 

%% Make violin plot -- trajectory removed
subplot(1,2,2); hold on; facecolor=[clrs.pink;clrs.gold;clrs.blue];
VIOLIN([AUC_search_trajRM(:),AUC_premove_trajRM(:),AUC_move_trajRM(:)],'bw',[0.02 0.02 0.02],...
    'edgecolor','none','facecolor',facecolor,'facealpha',1);
set(gca,'color','w','fontsize',24,'Tickdir','out','Ticklength',[.03 .03])
box off; xlim([0 4]); xticks([1 2 3]); xticklabels({'S','P','M'}); 
ylim([0 1]); yticks([0 0.5 1]); ylabel('AUC')
movegui(gcf,'center'); set(gcf,'color','w','InvertHardCopy','off')
