function f3c_duration_CDFs(blocks)
%% Produce CDFs for the duration subjects spent looking at the believed 
% goal location, and at a shuffled goal location, for each epoch.
% Also produce ROC curves. The plots only show the most complex arena.
% NOTE: Trials skipped by the subject were excluded from the analysis.
% NOTE: Trials for which the start or goal locations are inaccessible are
% excluded from the analysis.

clrs=def_colors; subjvec=[2,4,6,9,10,11,13,14,15,16,17,20,21];
duration_search=nan(5,13,60); duration_premove=nan(5,13,60);
duration_move=nan(5,13,60); duration_search_shuffled=nan(5,13,60); 
duration_premove_shuffled=nan(5,13,60); duration_move_shuffled=nan(5,13,60); 

for arnum=1:5
    for subj=1:13
        subject=subjvec(subj); continuous=blocks{arnum}.continuous{subject};
        for trial=1:size(continuous,2)
            detected=blocks{arnum}.discrete{subject}(trial).detect_frame;
            start_move=blocks{arnum}.discrete{subject}(trial).start_move;
            stop_move=blocks{arnum}.discrete{subject}(trial).stop_move;
            % The believed goal location is taken to be the subject's
            % stopping location at the end of the trial. 
            % NOTE: x in MATLAB = z in Unity; y in MATLAB = -x in Unity
            % NOTE: Scale arena dimensions by two as it was scaled when
            % loaded into Unity
            dist2stop=sqrt((continuous{trial}.gazeX_noblink-continuous{trial}.SubPosZ(end)).^2+...
                (continuous{trial}.gazeY_noblink+continuous{trial}.SubPosX(end)).^2);
            shuf_state=randi(150);
            dist2shuf=sqrt((continuous{trial}.gazeX_noblink-2*blocks{arnum}.arena.centroids(shuf_state,1)).^2+...
                (continuous{trial}.gazeY_noblink-2*blocks{arnum}.arena.centroids(shuf_state,2)).^2);
            
            duration_search(arnum,subj,trial)=sum(dist2stop(1:detected-1)<4*sqrt(3)/3,'omitnan')...
                /nnz(~isnan(dist2stop(1:detected-1)));
            duration_search_shuffled(arnum,subj,trial)=sum(dist2shuf(1:detected-1)<4*sqrt(3)/3,'omitnan')...
                /nnz(~isnan(dist2shuf(1:detected-1)));
            if ~isnan(start_move)
                duration_premove(arnum,subj,trial)=sum(dist2stop(detected:start_move-1)<4*sqrt(3)/3,'omitnan')...
                    /nnz(~isnan(dist2stop(detected:start_move-1)));
                duration_premove_shuffled(arnum,subj,trial)=sum(dist2shuf(detected:start_move-1)<4*sqrt(3)/3,'omitnan')...
                    /nnz(~isnan(dist2shuf(detected:start_move-1)));
                if ~isnan(stop_move)
                    duration_move(arnum,subj,trial)=sum(dist2stop(start_move:stop_move-1)<4*sqrt(3)/3,'omitnan')...
                        /nnz(~isnan(dist2stop(start_move:stop_move-1)));
                    duration_move_shuffled(arnum,subj,trial)=sum(dist2shuf(start_move:stop_move-1)<4*sqrt(3)/3,'omitnan')...
                        /nnz(~isnan(dist2shuf(start_move:stop_move-1)));
                else % If the subject presses the end-trial button while still moving...
                    duration_move(arnum,subj,trial)=sum(dist2stop(start_move:end)<4*sqrt(3)/3,'omitnan')...
                        /nnz(~isnan(dist2stop(detected:end)));
                    duration_move_shuffled(arnum,subj,trial)=sum(dist2shuf(start_move:end)<4*sqrt(3)/3,'omitnan')...
                        /nnz(~isnan(dist2shuf(start_move:end)));
                end
            else % If the subject does not move during the trial...
                duration_premove(arnum,subj,trial)=sum(dist2stop(detected:end)<4*sqrt(3)/3,'omitnan')...
                    /nnz(~isnan(dist2stop(detected:end)));
                duration_premove_shuffled(arnum,subj,trial)=sum(dist2shuf(detected:end)<4*sqrt(3)/3,'omitnan')...
                    /nnz(~isnan(dist2shuf(detected:end)));
            end
        end
    end
end

%% Plot three separate CDFs

ind1=exclude_skipped_trials(blocks); ind2=exclude_impossible_trials(blocks);
duration_search([ind1,ind2])=NaN; duration_search_shuffled([ind1,ind2])=NaN; 
duration_premove([ind1,ind2])=NaN; duration_premove_shuffled([ind1,ind2])=NaN; 
duration_move([ind1,ind2])=NaN; duration_move_shuffled([ind1,ind2])=NaN; 

arnum=1;
true_vals=squeeze(duration_search(arnum,:,:));
shuffled_vals=squeeze(duration_search_shuffled(arnum,:,:));
figure('Position',[0 0 450 375]); hold on;
movegui(gcf,'center'); set(gcf,'color','w','InvertHardCopy','off')
[CDF_search,CDF_search_shuf]=plot_CDF(true_vals(:),shuffled_vals(:),clrs.pink,clrs.gray); xlim([0.005 1]);

true_vals=squeeze(duration_premove(arnum,:,:));
shuffled_vals=squeeze(duration_premove_shuffled(arnum,:,:));
figure('Position',[0 0 450 375]); hold on;
movegui(gcf,'center'); set(gcf,'color','w','InvertHardCopy','off')
[CDF_premove,CDF_premove_shuf]=plot_CDF(true_vals(:),shuffled_vals(:),clrs.gold,clrs.gray); xlim([0.005 1]);

true_vals=squeeze(duration_move(arnum,:,:));
shuffled_vals=squeeze(duration_move_shuffled(arnum,:,:));
figure('Position',[0 0 450 375]); hold on;
movegui(gcf,'center'); set(gcf,'color','w','InvertHardCopy','off')
[CDF_move,CDF_move_shuf]=plot_CDF(true_vals(:),shuffled_vals(:),clrs.blue,clrs.gray); xlim([0.005 1]);

%% Plot ROC curve

figure('Position',[0 0 450 375]); hold on;
plot(CDF_search,CDF_search_shuf,'color',clrs.pink,'linewidth',5)
plot(CDF_premove,CDF_premove_shuf,'color',clrs.gold,'linewidth',5)
plot(CDF_move,CDF_move_shuf,'color',clrs.blue,'linewidth',5)

movegui(gcf,'center'); set(gcf,'color','w','InvertHardCopy','off')
set(gca,'color','w','fontsize',24,'Tickdir','out','Ticklength',[.03 .03]); 
xlim([0 1]); xticks([0 1]); xlabel('True')
ylim([0 1]); yticks([0 1]); ylabel('Shuffled') 
