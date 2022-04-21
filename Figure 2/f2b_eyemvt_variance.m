function f2b_eyemvt_variance(blocks)
%% Plot bar graphs showing variance in the point of gaze within trials
% vs. across trials for different epochs
% NOTE: For all analyses in the paper, trials skipped by the subject were
% excluded

clrs=def_colors; subjvec=[2,4,6,9,10,11,13,14,15,16,17,20,21];
within_search=nan(5,13,60); within_premove=nan(5,13,60); within_move=nan(5,13,60);
within_search_bySubject=nan(13,1); within_premove_bySubject=nan(13,1); within_move_bySubject=nan(13,1);
% For the fourth dimension: index 1 = x, index 2 = y
across_search=nan(5,13,60,2); across_premove=nan(5,13,60,2); across_move=nan(5,13,60,2);
across_search_bySubject=nan(13,1); across_premove_bySubject=nan(13,1); across_move_bySubject=nan(13,1);

%% Compute variances
for arnum=1:5
    for subj=1:13
        subject=subjvec(subj); continuous=blocks{arnum}.continuous{subject};
        for trial=1:size(continuous,2)
            gazeX=continuous{trial}.gazeX_noblink; gazeY=continuous{trial}.gazeY_noblink;
            detected=blocks{arnum}.discrete{subject}(trial).detect_frame;
            start_move=blocks{arnum}.discrete{subject}(trial).start_move;
            stop_move=blocks{arnum}.discrete{subject}(trial).stop_move;
            
            within_search(arnum,subj,trial)=sqrt(var(gazeX(1:detected),'omitnan')+var(gazeY(1:detected),'omitnan'));
            across_search(arnum,subj,trial,1)=mean(gazeX(1:detected),'omitnan');
            across_search(arnum,subj,trial,2)=mean(gazeY(1:detected),'omitnan');
            if ~isnan(start_move)
                within_premove(arnum,subj,trial)=sqrt(var(gazeX(detected:start_move),'omitnan')+var(gazeY(detected:start_move),'omitnan'));
                across_premove(arnum,subj,trial,1)=mean(gazeX(detected:start_move),'omitnan');
                across_premove(arnum,subj,trial,2)=mean(gazeY(detected:start_move),'omitnan');
                if ~isnan(stop_move)
                    within_move(arnum,subj,trial)=sqrt(var(gazeX(start_move:stop_move),'omitnan')+var(gazeY(start_move:stop_move),'omitnan'));
                    across_move(arnum,subj,trial,1)=mean(gazeX(start_move:stop_move),'omitnan');
                    across_move(arnum,subj,trial,2)=mean(gazeY(start_move:stop_move),'omitnan');
                else % If the subject presses the end-trial button while still moving...
                    within_move(arnum,subj,trial)=sqrt(var(gazeX(start_move:end),'omitnan')+var(gazeY(start_move:end),'omitnan'));
                    across_move(arnum,subj,trial,1)=mean(gazeX(start_move:end),'omitnan');
                    across_move(arnum,subj,trial,2)=mean(gazeY(start_move:end),'omitnan');
                end
            else % If the subject does not move during the trial...
                within_premove(arnum,subj,trial)=sqrt(var(gazeX(detected:end),'omitnan')+var(gazeY(detected:end),'omitnan'));
                across_premove(arnum,subj,trial,1)=mean(gazeX(detected:end),'omitnan');
                across_premove(arnum,subj,trial,2)=mean(gazeY(detected:end),'omitnan');
            end
        end
    end
end

%% Exclude skipped trials
ind=exclude_skipped_trials(blocks);
within_search(ind)=NaN; within_premove(ind)=NaN; within_move(ind)=NaN;
X=squeeze(across_search(:,:,:,1)); Y=squeeze(across_search(:,:,:,2));
X(ind)=NaN; Y(ind)=NaN; across_search(:,:,:,1)=X; across_search(:,:,:,2)=Y;
X=squeeze(across_premove(:,:,:,1)); Y=squeeze(across_premove(:,:,:,2));
X(ind)=NaN; Y(ind)=NaN; across_premove(:,:,:,1)=X; across_premove(:,:,:,2)=Y;
X=squeeze(across_move(:,:,:,1)); Y=squeeze(across_move(:,:,:,2));
X(ind)=NaN; Y(ind)=NaN; across_move(:,:,:,1)=X; across_move(:,:,:,2)=Y;

%% Take averages within trials and variances across trials
for subj=1:13
    within_search_bySubject(subj)=mean(squeeze(within_search(:,subj,:)),'all','omitnan');
    within_premove_bySubject(subj)=mean(squeeze(within_premove(:,subj,:)),'all','omitnan');
    within_move_bySubject(subj)=mean(squeeze(within_move(:,subj,:)),'all','omitnan');
    across_search_bySubject(subj)=sqrt(var(squeeze(across_search(:,subj,:,1)),0,'all','omitnan')+...
        var(squeeze(across_search(:,subj,:,2)),0,'all','omitnan'));
    across_premove_bySubject(subj)=sqrt(var(squeeze(across_premove(:,subj,:,1)),0,'all','omitnan')+...
        var(squeeze(across_premove(:,subj,:,2)),0,'all','omitnan'));
    across_move_bySubject(subj)=sqrt(var(squeeze(across_move(:,subj,:,1)),0,'all','omitnan')+...
        var(squeeze(across_move(:,subj,:,2)),0,'all','omitnan'));
end

%% Plot variance within trials

figure('Position',[0 0 450 350]); hold on; 
bar(1,median(within_search_bySubject),'FaceColor',clrs.pink,'EdgeColor','none')
scatter(ones(13,1).*(1+(rand(13,1)-0.5)/3),within_search_bySubject,50,'filled','MarkerFaceColor',clrs.pink-0.3*clrs.pink)
bar(2,median(within_premove_bySubject),'FaceColor',clrs.gold,'EdgeColor','none')
scatter(ones(13,1).*(2+(rand(13,1)-0.5)/3),within_premove_bySubject,50,'filled','MarkerFaceColor',clrs.gold-0.3*clrs.gold)
bar(3,median(within_move_bySubject),'FaceColor',clrs.blue,'EdgeColor','none')
scatter(ones(13,1).*(3+(rand(13,1)-0.5)/3),within_move_bySubject,50,'filled','MarkerFaceColor',clrs.blue-0.3*clrs.blue)

movegui(gcf,'center'); set(gca,'fontsize',24,'color','w','Ticklength',[.03 .03]);
set(gcf,'color','w','InvertHardCopy','off');
xlim([0 4]); xticks([1:3]); xticklabels({'search','plan','move'})
ylim([0 8]); yticks([0 4 8]); ax=gca; yax=ax.YAxis; set(yax,'TickDirection','out'); ylabel('Gaze spread (m)');

%% Plot variance across trials

figure('Position',[0 0 450 350]); hold on; 
bar(1,median(across_search_bySubject),'FaceColor',clrs.pink,'EdgeColor','none')
scatter(ones(13,1).*(1+(rand(13,1)-0.5)/3),across_search_bySubject,50,'filled','MarkerFaceColor',clrs.pink-0.3*clrs.pink)
bar(2,median(across_premove_bySubject),'FaceColor',clrs.gold,'EdgeColor','none')
scatter(ones(13,1).*(2+(rand(13,1)-0.5)/3),across_premove_bySubject,50,'filled','MarkerFaceColor',clrs.gold-0.3*clrs.gold)
bar(3,median(across_move_bySubject),'FaceColor',clrs.blue,'EdgeColor','none')
scatter(ones(13,1).*(3+(rand(13,1)-0.5)/3),across_move_bySubject,50,'filled','MarkerFaceColor',clrs.blue-0.3*clrs.blue)

movegui(gcf,'center'); set(gca,'fontsize',24,'color','w','Ticklength',[.03 .03]);
set(gcf,'color','w','InvertHardCopy','off');
xlim([0 4]); xticks([1:3]); xticklabels({'search','plan','move'})
ylim([4 8]); yticks([4 6 8]); ax=gca; yax=ax.YAxis; set(yax,'TickDirection','out'); ylabel('Gaze spread (m)');

%% Compute stats: variance by epoch

mean_search=mean(within_search,'all','omitnan');
mean_premove=mean(within_premove,'all','omitnan');
mean_move=mean(within_move,'all','omitnan');
search_STD=std(within_search_bySubject); premove_STD=std(within_premove_bySubject); 
move_STD=std(within_move_bySubject);
disp(['search within-trial variance: ',num2str(mean_search),' +/- ',num2str(search_STD)])
disp(['pre-movement within-trial variance: ',num2str(mean_premove),' +/- ',num2str(premove_STD)])
disp(['movement within-trial variance: ',num2str(mean_move),' +/- ',num2str(move_STD)])

mean_search=mean(across_search_bySubject,'all','omitnan');
mean_premove=mean(across_premove_bySubject,'all','omitnan');
mean_move=mean(across_move_bySubject,'all','omitnan');
search_STD=std(across_search_bySubject); premove_STD=std(across_premove_bySubject); 
move_STD=std(across_move_bySubject);
disp(['search across-trial variance: ',num2str(mean_search),' +/- ',num2str(search_STD)])
disp(['pre-movement across-trial variance: ',num2str(mean_premove),' +/- ',num2str(premove_STD)])
disp(['movement across-trial variance: ',num2str(mean_move),' +/- ',num2str(move_STD)])
