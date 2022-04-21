function f3d_duration_AUC(blocks)
%% Calculate and make a violin plot of the area under the curve (AUC) when
% shuffled data is plotted against true data for the duration subjects 
% spent looking at the believed goal location vs. at a shuffled goal location
% in each epoch.
% NOTE: Trials skipped by the subject were excluded from the analysis.
% NOTE: Trials for which the start or goal locations are inaccessible are
% excluded from the analysis.

clrs=def_colors; subjvec=[2,4,6,9,10,11,13,14,15,16,17,20,21];
duration_search=nan(5,13,60); duration_premove=nan(5,13,60);
duration_move=nan(5,13,60); duration_search_shuffled=nan(5,13,60); 
duration_premove_shuffled=nan(5,13,60); duration_move_shuffled=nan(5,13,60); 
AUC_search=nan(5,13); AUC_premove=nan(5,13); AUC_move=nan(5,13);

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

%% Calculate AUC values
ind1=exclude_skipped_trials(blocks); ind2=exclude_impossible_trials(blocks);
duration_search([ind1,ind2])=NaN; duration_search_shuffled([ind1,ind2])=NaN; 
duration_premove([ind1,ind2])=NaN; duration_premove_shuffled([ind1,ind2])=NaN; 
duration_move([ind1,ind2])=NaN; duration_move_shuffled([ind1,ind2])=NaN; 

for arnum=1:5
    for subj=1:13
        AUC_search(arnum,subj)=calculate_AUC(squeeze(duration_search(arnum,subj,:)),...
            squeeze(duration_search_shuffled(arnum,subj,:)));
        AUC_premove(arnum,subj)=calculate_AUC(squeeze(duration_premove(arnum,subj,:)),...
            squeeze(duration_premove_shuffled(arnum,subj,:)));
        AUC_move(arnum,subj)=calculate_AUC(squeeze(duration_move(arnum,subj,:)),...
            squeeze(duration_move_shuffled(arnum,subj,:)));
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
