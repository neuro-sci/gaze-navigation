function f3a_relevance_CDFs(blocks)
%% Produce CDFs for average relevance values (true and shuffled) for each epoch.
% Also produce ROC curves. The plots only show the most complex arena.
% NOTE: Trials skipped by the subject were excluded from the analysis.
% NOTE: Trials for which the start or goal locations are inaccessible are
% excluded from the analysis.

clrs=def_colors; subjvec=[2,4,6,9,10,11,13,14,15,16,17,20,21];
relevance_search=nan(5,13,60); relevance_premove=nan(5,13,60);
relevance_move=nan(5,13,60); relevance_search_shuffled=nan(5,13,60); 
relevance_premove_shuffled=nan(5,13,60); relevance_move_shuffled=nan(5,13,60); 

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

%% Plot three separate CDFs

ind1=exclude_skipped_trials(blocks); ind2=exclude_impossible_trials(blocks);
relevance_search([ind1,ind2])=NaN; relevance_search_shuffled([ind1,ind2])=NaN; 
relevance_premove([ind1,ind2])=NaN; relevance_premove_shuffled([ind1,ind2])=NaN; 
relevance_move([ind1,ind2])=NaN; relevance_move_shuffled([ind1,ind2])=NaN; 

arnum=1;
true_vals=squeeze(relevance_search(arnum,:,:));
shuffled_vals=squeeze(relevance_search_shuffled(arnum,:,:));
figure('Position',[0 0 450 375]); hold on;
movegui(gcf,'center'); set(gcf,'color','w','InvertHardCopy','off')
[CDF_search,CDF_search_shuf]=plot_CDF(true_vals(:),shuffled_vals(:),clrs.pink,clrs.gray);

true_vals=squeeze(relevance_premove(arnum,:,:));
shuffled_vals=squeeze(relevance_premove_shuffled(arnum,:,:));
figure('Position',[0 0 450 375]); hold on;
movegui(gcf,'center'); set(gcf,'color','w','InvertHardCopy','off')
[CDF_premove,CDF_premove_shuf]=plot_CDF(true_vals(:),shuffled_vals(:),clrs.gold,clrs.gray);

true_vals=squeeze(relevance_move(arnum,:,:));
shuffled_vals=squeeze(relevance_move_shuffled(arnum,:,:));
figure('Position',[0 0 450 375]); hold on;
movegui(gcf,'center'); set(gcf,'color','w','InvertHardCopy','off')
[CDF_move,CDF_move_shuf]=plot_CDF(true_vals(:),shuffled_vals(:),clrs.blue,clrs.gray);

%% Plot ROC curve

figure('Position',[0 0 450 375]); hold on;
plot(CDF_search,CDF_search_shuf,'color',clrs.pink,'linewidth',5)
plot(CDF_premove,CDF_premove_shuf,'color',clrs.gold,'linewidth',5)
plot(CDF_move,CDF_move_shuf,'color',clrs.blue,'linewidth',5)

movegui(gcf,'center'); set(gcf,'color','w','InvertHardCopy','off')
set(gca,'color','w','fontsize',24,'Tickdir','out','Ticklength',[.03 .03]); 
xlim([0 1]); xticks([0 1]); xlabel('True')
ylim([0 1]); yticks([0 1]); ylabel('Shuffled') 

%% Compute stats: median +/- IQR relevance per epoch

median_premove=median(relevance_premove(:),'omitnan');
median_move=median(relevance_move(:),'omitnan');
IQR_premove=iqr(relevance_premove(:)); IQR_move=iqr(relevance_move(:));
disp(['pre-movement median{IQR} true relevance: ',num2str(median_premove),...
    ' {',num2str(IQR_premove),'}'])
disp(['movement median{IQR} true relevance: ',num2str(median_move),...
    ' {',num2str(IQR_move),'}'])

median_premove=median(relevance_premove_shuffled(:),'omitnan');
median_move=median(relevance_move_shuffled(:),'omitnan');
IQR_premove=iqr(relevance_premove_shuffled(:)); IQR_move=iqr(relevance_move_shuffled(:));
disp(['pre-movement median{IQR} shuffled relevance: ',num2str(median_premove),...
    ' {',num2str(IQR_premove),'}'])
disp(['movement median{IQR} shuffled relevance: ',num2str(median_move),...
    ' {',num2str(IQR_move),'}'])
