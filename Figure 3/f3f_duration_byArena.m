function f3f_duration_byArena(blocks)
%% Scatter the mean AUC of gaze duration values (see explanation for F3c/d) 
% for each arena; also perform a linear regression.
% NOTE: This plot changes slightly upon each run due to the pairing of each 
% trial with a random target location to construct the shuffled data. In
% contrast, Figure 3E does not change with each run because the shuffled
% data has already been stored as part of the dataset.
% NOTE: Trials skipped by the subject were excluded from the analysis.
% NOTE: Trials for which the start or goal locations are inaccessible are
% excluded from the analysis.
% NOTE: Error bars show standard error across subjects

clrs=def_colors; subjvec=[2,4,6,9,10,11,13,14,15,16,17,20,21];
duration_premove=nan(5,13,60);
duration_move=nan(5,13,60);
duration_premove_shuffled=nan(5,13,60); 
duration_move_shuffled=nan(5,13,60); 
AUC_premove=nan(5,13); AUC_move=nan(5,13);
AUC_premove_byArena=nan(5,1); AUC_move_byArena=nan(5,1);
sterr_premove=nan(5,1); sterr_move=nan(5,1);
mean_centrality=nan(5,1);

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
    G=graph(blocks{arnum}.arena.neighbor); C=centrality(G,'closeness')*149; 
    mean_centrality(arnum)=mean(C); 
end

%% Calculate AUC values
ind1=exclude_skipped_trials(blocks); ind2=exclude_impossible_trials(blocks);
duration_search([ind1,ind2])=NaN; duration_search_shuffled([ind1,ind2])=NaN; 
duration_premove([ind1,ind2])=NaN; duration_premove_shuffled([ind1,ind2])=NaN; 
duration_move([ind1,ind2])=NaN; duration_move_shuffled([ind1,ind2])=NaN; 

for arnum=1:5
    for subj=1:13
        AUC_premove(arnum,subj)=calculate_AUC(squeeze(duration_premove(arnum,subj,:)),...
            squeeze(duration_premove_shuffled(arnum,subj,:)));
        AUC_move(arnum,subj)=calculate_AUC(squeeze(duration_move(arnum,subj,:)),...
            squeeze(duration_move_shuffled(arnum,subj,:)));
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

%% Compute stats: correlation between looking at target AUC and arena complexity

centrality_matrix=repmat(100*(complexity),1,13);
[R_premove,P_premove]=corrcoef(AUC_premove(:),centrality_matrix(:),'rows','complete');
disp(['correlation of looking-at-target AUC vs. arena complexity (df = 63) pre-movement is ',...
    num2str(R_premove(1,2)),', p_val = ',num2str(P_premove(1,2))])
[R_move,P_move]=corrcoef(AUC_move(:),centrality_matrix(:),'rows','complete');
disp(['correlation of looking-at-target AUC vs. arena complexity (df = 63) during movement is ',...
    num2str(R_move(1,2)),', p_val = ',num2str(P_move(1,2))])
