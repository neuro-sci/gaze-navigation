function f3b_relevance_AUC(blocks)
%% Calculate and make a violin plot of the area under the curve (AUC) when
% shuffled data is plotted against true relevance values for each epoch
% NOTE: Trials skipped by the subject were excluded from the analysis.
% NOTE: Trials for which the start or goal locations are inaccessible are
% excluded from the analysis.

clrs=def_colors; subjvec=[2,4,6,9,10,11,13,14,15,16,17,20,21];
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

%% Calculate AUC values
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
end

%% Plot
figure('Position',[0 0 475 375]); hold on;
facecolor=[clrs.pink;clrs.gold;clrs.blue];
VIOLIN([AUC_search(:),AUC_premove(:),AUC_move(:)],'bw',[0.02 0.02 0.02],...
    'edgecolor','none','facecolor',facecolor,'facealpha',1);
movegui(gcf,'center'); box off; 
set(gca,'color','w','fontsize',24,'Tickdir','out','Ticklength',[.03 .03])
set(gcf,'color','w','InvertHardCopy','off');  
xlim([0 4]); xticks([1 2 3]); xticklabels({'S','P','M'}); 
ylim([0.35 1]); yticks([0.5 0.75 1]); ylabel('AUC')

%% Compute stats: AUC

mean_search=mean(AUC_search,'all','omitnan');
mean_premove=mean(AUC_premove,'all','omitnan');
mean_move=mean(AUC_move,'all','omitnan');
STD_search=nan(13,1); STD_premove=nan(13,1); STD_move=nan(13,1);

for subj=1:13
    STD_search(subj)=mean(AUC_search(:,subj),'omitnan');
    STD_premove(subj)=mean(AUC_premove(:,subj),'omitnan');
    STD_move(subj)=mean(AUC_move(:,subj),'omitnan');
end
STD_search=std(STD_search); STD_premove=std(STD_premove); STD_move=std(STD_move);

disp(['AUC of relevance during search: ',num2str(mean_search),...
    ' +/- ',num2str(STD_search),'}'])
disp(['AUC of relevance during pre-movement: ',num2str(mean_premove),...
    ' +/- ',num2str(STD_premove),'}'])
disp(['AUC of relevance during movement: ',num2str(mean_move),...
    ' +/- ',num2str(STD_move),'}'])
