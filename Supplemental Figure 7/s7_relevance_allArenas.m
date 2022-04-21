function s7_relevance_allArenas(blocks)
%% Produce Figure 3A/B (relevance CDFs, ROC curves, and AUC violins) for all arenas

clrs=def_colors; subjvec=[2,4,6,9,10,11,13,14,15,16,17,20,21];
facecolor=[clrs.pink;clrs.gold;clrs.blue];
relevance_search=nan(5,13,60); relevance_premove=nan(5,13,60);
relevance_move=nan(5,13,60); relevance_search_shuffled=nan(5,13,60); 
relevance_premove_shuffled=nan(5,13,60); relevance_move_shuffled=nan(5,13,60); 
AUC_search=nan(5,13); AUC_premove=nan(5,13); AUC_move=nan(5,13);

for arnum=1:5
    for subj=1:13
        subject=subjvec(subj); continuous=blocks{arnum}.continuous{subject};
        for trial=1:size(continuous,2)
            detected=blocks{arnum}.discrete{subject}(trial).detect_frame;
            start_move=blocks{arnum}.discrete{subject}(trial).start_move;
            stop_move=blocks{arnum}.discrete{subject}(trial).stop_move;
            
            relevance_search(arnum,subj,trial)=mean(continuous{trial}.norm_sens(1:detected-1),'omitnan');
            relevance_search_shuffled(arnum,subj,trial)=mean(continuous{trial}.norm_shuf_sens(1:detected-1),'omitnan');
            if ~isnan(start_move)
                relevance_premove(arnum,subj,trial)=mean(continuous{trial}.norm_sens(detected:start_move-1),'omitnan');
                relevance_premove_shuffled(arnum,subj,trial)=mean(continuous{trial}.norm_shuf_sens(detected:start_move-1),'omitnan');
                if ~isnan(stop_move)
                    relevance_move(arnum,subj,trial)=mean(continuous{trial}.norm_sens(start_move:stop_move-1),'omitnan');
                    relevance_move_shuffled(arnum,subj,trial)=mean(continuous{trial}.norm_shuf_sens(start_move:stop_move-1),'omitnan');
                else % If the subject presses the end-trial button while still moving...
                    relevance_move(arnum,subj,trial)=mean(continuous{trial}.norm_sens(start_move:end),'omitnan');
                    relevance_move_shuffled(arnum,subj,trial)=mean(continuous{trial}.norm_shuf_sens(start_move:end),'omitnan');
                end
            else % If the subject does not move during the trial...
                relevance_premove(arnum,subj,trial)=mean(continuous{trial}.norm_sens(detected:end),'omitnan');
                relevance_premove_shuffled(arnum,subj,trial)=mean(continuous{trial}.norm_shuf_sens(detected:end),'omitnan');
            end
        end
    end
end

%% Create a wide plot with five panels for each arena

ind1=exclude_skipped_trials(blocks); ind2=exclude_impossible_trials(blocks);
relevance_search([ind1,ind2])=NaN; relevance_search_shuffled([ind1,ind2])=NaN; 
relevance_premove([ind1,ind2])=NaN; relevance_premove_shuffled([ind1,ind2])=NaN; 
relevance_move([ind1,ind2])=NaN; relevance_move_shuffled([ind1,ind2])=NaN; 

for arnum=1:5
    for subj=1:13
        AUC_search(arnum,subj)=calculate_AUC(squeeze(relevance_search(arnum,subj,:)),...
            squeeze(relevance_search_shuffled(arnum,subj,:)));
        AUC_premove(arnum,subj)=calculate_AUC(squeeze(relevance_premove(arnum,subj,:)),...
            squeeze(relevance_premove_shuffled(arnum,subj,:)));
        AUC_move(arnum,subj)=calculate_AUC(squeeze(relevance_move(arnum,subj,:)),...
            squeeze(relevance_move_shuffled(arnum,subj,:)));
    end
    
    figure('Position',[0 0 1500 225]); subplot(1,5,1); hold on % Search
    movegui(gcf,'center'); set(gcf,'color','w','InvertHardCopy','off')
    true_vals=squeeze(relevance_search(arnum,:,:)); 
    shuffled_vals=squeeze(relevance_search_shuffled(arnum,:,:));
    [CDF_search,CDF_search_shuf]=plot_CDF(true_vals(:),shuffled_vals(:),clrs.pink,clrs.gray);
    set(gca,'fontsize',14)

    subplot(1,5,2); hold on; 
	true_vals=squeeze(relevance_premove(arnum,:,:)); % Pre-move
    shuffled_vals=squeeze(relevance_premove_shuffled(arnum,:,:));
    [CDF_premove,CDF_premove_shuf]=plot_CDF(true_vals(:),shuffled_vals(:),clrs.gold,clrs.gray);
    set(gca,'fontsize',14); xlabel(''); ylabel('');

    subplot(1,5,3); hold on
    true_vals=squeeze(relevance_move(arnum,:,:)); % Move
    shuffled_vals=squeeze(relevance_move_shuffled(arnum,:,:));
    [CDF_move,CDF_move_shuf]=plot_CDF(true_vals(:),shuffled_vals(:),clrs.blue,clrs.gray);
    set(gca,'fontsize',14); xlabel(''); ylabel('');
    
    subplot(1,5,4); hold on % ROC curves
    plot(CDF_search,CDF_search_shuf,'color',clrs.pink,'linewidth',5)
    plot(CDF_premove,CDF_premove_shuf,'color',clrs.gold,'linewidth',5)
    plot(CDF_move,CDF_move_shuf,'color',clrs.blue,'linewidth',5)
    set(gca,'color','w','fontsize',14,'Tickdir','out','Ticklength',[.03 .03]); 
    xlim([0 1]); xticks([0 1]); xlabel('True')
    ylim([0 1]); yticks([0 1]); ylabel('Shuffled') 
    
    subplot(1,5,5); hold on
    VIOLIN([AUC_search(arnum,:)',AUC_premove(arnum,:)',AUC_move(arnum,:)'],'bw',[0.02 0.02 0.02],...
        'edgecolor','none','facecolor',facecolor,'facealpha',1); box off
    set(gca,'color','w','fontsize',14,'Tickdir','out','Ticklength',[.03 .03])
    xlim([0 4]); xticks([1 2 3]); xticklabels({'S','P','M'}); 
    ylim([0.35 1]); yticks([0.5 0.75 1]); ylabel('AUC')
end
