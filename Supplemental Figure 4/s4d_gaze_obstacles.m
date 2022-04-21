function s4d_gaze_obstacles(blocks)
%% Fraction of time gazing at each obstacle
% NOTE: For all analyses in the paper, trials skipped by the subject were
% excluded
% NOTE: Error bars show standard error across subjects

clrs=def_colors; subjvec=[2,4,6,9,10,11,13,14,15,16,17,20,21]; mean_centrality=nan(5,1);
gazeobs_search=nan(5,13,60); gazeobs_premove=nan(5,13,60); gazeobs_move=nan(5,13,60);
gazeobs_search_byArena=nan(5,1); gazeobs_premove_byArena=nan(5,1); gazeobs_move_byArena=nan(5,1);
gazeobs_search_bySubject=nan(5,13); gazeobs_premove_bySubject=nan(13,1); gazeobs_move_bySubject=nan(13,1);
ste_gazeobs_search=nan(5,1); ste_gazeobs_premove=nan(5,1); ste_gazeobs_move=nan(5,1);
num_obs=nan(5,1);

%% Compute fraction of time
for arnum=1:5
    for subj=1:13
        subject=subjvec(subj); continuous=blocks{arnum}.continuous{subject};
        for trial=1:size(continuous,2)
            detected=blocks{arnum}.discrete{subject}(trial).detect_frame;
            start_move=blocks{arnum}.discrete{subject}(trial).start_move;
            stop_move=blocks{arnum}.discrete{subject}(trial).stop_move;
            
            gazeobs_search(arnum,subject,trial)=sum(continuous{trial}.ObjTags(1:detected)==3 & ...
                ~isnan(continuous{trial}.gazeX_noblink(1:detected)))/...
                sum(~isnan(continuous{trial}.gazeX_noblink(1:detected)));
            if ~isnan(start_move) 
                gazeobs_premove(arnum,subject,trial)=sum(continuous{trial}.ObjTags(detected:start_move)==3 & ...
                    ~isnan(continuous{trial}.gazeX_noblink(detected:start_move)))/...
                    sum(~isnan(continuous{trial}.gazeX_noblink(detected:start_move)));
                if ~isnan(stop_move)
                    gazeobs_move(arnum,subject,trial)=sum(continuous{trial}.ObjTags(start_move:stop_move)==3 & ...
                        ~isnan(continuous{trial}.gazeX_noblink(start_move:stop_move)))/...
                        sum(~isnan(continuous{trial}.gazeX_noblink(start_move:stop_move)));
                else % If the subject presses the end-trial button while still moving...
                    gazeobs_move(arnum,subject,trial)=sum(continuous{trial}.ObjTags(start_move:end)==3 & ...
                        ~isnan(continuous{trial}.gazeX_noblink(start_move:end)))/...
                        sum(~isnan(continuous{trial}.gazeX_noblink(start_move:end)));
                end
            else % If the subject does not move during the trial...
                gazeobs_premove(arnum,subject,trial)=sum(continuous{trial}.ObjTags(detected:end)==3 & ...
                    ~isnan(continuous{trial}.gazeX_noblink(detected:end)))/...
                    sum(~isnan(continuous{trial}.gazeX_noblink(detected:end)));
            end
        end
    end
    G=graph(blocks{arnum}.arena.neighbor); C=centrality(G,'closeness')*149; 
    mean_centrality(arnum)=mean(C); num_obs(arnum)=height(blocks{arnum}.arena.obstacles);
end

%% Take averages and standard errors
ind=exclude_skipped_trials(blocks);
gazeobs_search(ind)=NaN; gazeobs_premove(ind)=NaN; gazeobs_move(ind)=NaN;

for arnum=1:5
    for subj=1:13
        gazeobs_search_bySubject(arnum,subj)=mean(gazeobs_search(arnum,subj,:),'all','omitnan'); 
        gazeobs_premove_bySubject(arnum,subj)=mean(gazeobs_premove(arnum,subj,:),'all','omitnan'); 
        gazeobs_move_bySubject(arnum,subj)=mean(gazeobs_move(arnum,subj,:),'all','omitnan'); 
    end
    gazeobs_search_byArena(arnum)=mean(gazeobs_search(arnum,:,:),'all','omitnan');
    gazeobs_premove_byArena(arnum)=mean(gazeobs_premove(arnum,:,:),'all','omitnan'); 
    gazeobs_move_byArena(arnum)=mean(gazeobs_move(arnum,:,:),'all','omitnan');
    
    ste_gazeobs_search(arnum)=std(gazeobs_search_bySubject(arnum,:),'omitnan')/sqrt(13); 
    ste_gazeobs_premove(arnum)=std(gazeobs_premove_bySubject(arnum,:),'omitnan')/sqrt(13);
    ste_gazeobs_move(arnum)=std(gazeobs_move_bySubject(arnum,:),'omitnan')/sqrt(13); 
end

%% Plot
figure; hold on; box off
plot(flip(-mean_centrality+0.1115),flip(gazeobs_search_byArena./num_obs),'color','k')
plot(flip(-mean_centrality+0.1115),flip(gazeobs_premove_byArena./num_obs),'color','k')
plot(flip(-mean_centrality+0.1115),flip(gazeobs_move_byArena./num_obs),'color','k')

scatter(-mean_centrality+0.1115,gazeobs_search_byArena./num_obs,250,...
    'markerfacecolor',clrs.pink,'markeredgecolor','none')
errorbar(-mean_centrality+0.1115,gazeobs_search_byArena./num_obs,...
    ste_gazeobs_search./num_obs,'LineStyle','none','color','k','CapSize',0)
scatter(-mean_centrality+0.1115,gazeobs_premove_byArena./num_obs,250,...
    'markerfacecolor',clrs.gold,'markeredgecolor','none')
errorbar(-mean_centrality+0.1115,gazeobs_premove_byArena./num_obs,...
    ste_gazeobs_premove./num_obs,'LineStyle','none','color','k','CapSize',0)
scatter(-mean_centrality+0.1115,gazeobs_move_byArena./num_obs,250,...
    'markerfacecolor',clrs.blue,'markeredgecolor','none')
errorbar(-mean_centrality+0.1115,gazeobs_move_byArena./num_obs,...
    ste_gazeobs_move./num_obs,'LineStyle','none','color','k','CapSize',0)

%% Format
movegui(gcf,'center')
set(gca,'color','w','fontsize',24,'Tickdir','out','Ticklength',[.03 .03]); 
set(gcf,'color','w','InvertHardCopy','off'); 
xticks([0 0.03 0.06]); xlim([-0.01 0.07]); yticks([0 0.004 0.008]); ylim([0 0.008])
xlabel('Arena complexity'); ylabel('P(gaze) per obs.')
