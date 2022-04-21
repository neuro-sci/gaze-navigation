function s1d_behavioral_performance(blocks)
%% Produce three plots:
% (1) Stopping distance from goal for rewarded and unrewarded trials
% (2) Percent of points obtained in each arena
% (3) Outcome frequencies per arena (zero, one, or two points)
% NOTE: Standard errors are across subjects

%% Preallocate

clrs=def_colors; zero_points=nan(5,13,60); one_point=nan(5,13,60); 
two_points=nan(5,13,60); stop_dist_from_goal=nan(5,13,60);
stop2goal_rew_byArena=nan(5,1); stop2goal_unrew_byArena=nan(5,1);
stop2goal_rew_bySubject=nan(5,13); stop2goal_unrew_bySubject=nan(5,13);
ste_stop2goal_rew=nan(5,1); ste_stop2goal_unrew=nan(5,1); 
frac_pts_byArena=nan(5,1); frac_pts_bySubject=nan(5,13); ste_frac_pts=nan(5,1);
zero_pts_byArena=nan(5,1); one_pt_byArena=nan(5,1); two_pts_byArena=nan(5,1); 
zero_pts_bySubject=nan(5,13); one_pt_bySubject=nan(5,13); two_pts_bySubject=nan(5,13); 
ste_zero_pts=nan(5,1); ste_one_pt=nan(5,1); ste_two_pts=nan(5,1);
subjvec=[2,4,6,9,10,11,13,14,15,16,17,20,21]; mean_centrality=nan(5,1);

%% Save the variables for plotting

for arnum=1:5
    for subj=1:13
        subject=subjvec(subj); discrete=blocks{arnum}.discrete{subject};
        continuous=blocks{arnum}.continuous{subject};
        zero_points(arnum,subj,[discrete.RewardZone]==0)=1; 
        % reward zone 2 yields one point
        one_point(arnum,subj,[discrete.RewardZone]==2)=1; 
        % reward zone 1 yields two points
        two_points(arnum,subj,[discrete.RewardZone]==1)=1; 
        
        for trial=1:size(continuous,2)
            % NOTE: Matlab x = Unity z, and Matlab y = Unity -x
            % NOTE: Scale goal location by two b/c the arena was scaled by
            % two when loaded into Unity
            stop_dist_from_goal(arnum,subj,trial)=...
                sqrt((2*blocks{arnum}.arena.centroids(discrete(trial).TargetStatenum+1,1)-...
                continuous{trial}.SubPosZ(end))^2+...
                (2*blocks{arnum}.arena.centroids(discrete(trial).TargetStatenum+1,2)+...
                continuous{trial}.SubPosX(end))^2);
        end
        stop2goal_rew_bySubject(arnum,subj)=mean(squeeze(stop_dist_from_goal(arnum,subj,...
            (squeeze(one_point(arnum,subj,:))==1 | squeeze(two_points(arnum,subj,:))==1))),'all','omitnan');
        stop2goal_unrew_bySubject(arnum,subj)=mean(squeeze(stop_dist_from_goal(arnum,subj,...
            squeeze(zero_points(arnum,subj,:))==1)),'all','omitnan');
        frac_pts_bySubject(arnum,subj)=(sum(one_point(arnum,subj,:),'all','omitnan')+...
            2*sum(two_points(arnum,subj,:),'all','omitnan'))./(2*sum(one_point(arnum,subj,:),'all','omitnan')...
            +2*sum(two_points(arnum,subj,:),'all','omitnan')+2*sum(zero_points(arnum,subj,:),'all','omitnan'));
        
        zero_pts_bySubject(arnum,subj)=sum(zero_points(arnum,subj,:),'all','omitnan')./...
            (sum(one_point(arnum,subj,:),'all','omitnan')+sum(two_points(arnum,subj,:),'all','omitnan')+...
            sum(zero_points(arnum,subj,:),'all','omitnan'));
        one_pt_bySubject(arnum,subj)=sum(one_point(arnum,subj,:),'all','omitnan')./...
            (sum(one_point(arnum,subj,:),'all','omitnan')+sum(two_points(arnum,subj,:),'all','omitnan')+...
            sum(zero_points(arnum,subj,:),'all','omitnan'));
        two_pts_bySubject(arnum,subj)=sum(two_points(arnum,subj,:),'all','omitnan')./...
            (sum(one_point(arnum,subj,:),'all','omitnan')+sum(two_points(arnum,subj,:),'all','omitnan')+...
            sum(zero_points(arnum,subj,:),'all','omitnan'));
    end
    
    stop2goal_rew_byArena(arnum)=mean(squeeze(stop_dist_from_goal(arnum,...
        (squeeze(one_point(arnum,:,:))==1 | squeeze(two_points(arnum,:,:))==1))),'all','omitnan');
    stop2goal_unrew_byArena(arnum)=mean(squeeze(stop_dist_from_goal(arnum,...
        squeeze(zero_points(arnum,:,:))==1)),'all','omitnan');
    ste_stop2goal_rew(arnum)=std(stop2goal_rew_bySubject(arnum,:),'omitnan')/sqrt(13);
    ste_stop2goal_unrew(arnum)=std(stop2goal_unrew_bySubject(arnum,:),'omitnan')/sqrt(13);
    frac_pts_byArena(arnum)=(sum(one_point(arnum,:,:),'all','omitnan')+...
        2*sum(two_points(arnum,:,:),'all','omitnan'))/(2*sum(one_point(arnum,:,:),'all','omitnan')...
        +2*sum(two_points(arnum,:,:),'all','omitnan')+2*sum(zero_points(arnum,:,:),'all','omitnan'));
    ste_frac_pts(arnum)=std(frac_pts_bySubject(arnum,:),'omitnan')/sqrt(13);
    
    zero_pts_byArena(arnum)=sum(zero_points(arnum,:,:),'all','omitnan')./...
        (sum(one_point(arnum,:,:),'all','omitnan')+sum(two_points(arnum,:,:),'all','omitnan')+...
        sum(zero_points(arnum,:,:),'all','omitnan'));
    one_pt_byArena(arnum)=sum(one_point(arnum,:,:),'all','omitnan')./...
        (sum(one_point(arnum,:,:),'all','omitnan')+sum(two_points(arnum,:,:),'all','omitnan')+...
        sum(zero_points(arnum,:,:),'all','omitnan'));
    two_pts_byArena(arnum)=sum(two_points(arnum,:,:),'all','omitnan')./...
        (sum(one_point(arnum,:,:),'all','omitnan')+sum(two_points(arnum,:,:),'all','omitnan')+...
        sum(zero_points(arnum,:,:),'all','omitnan'));
    ste_zero_pts(arnum)=std(zero_pts_bySubject(arnum,:),'omitnan')/sqrt(13);
    ste_one_pt(arnum)=std(one_pt_bySubject(arnum,:),'omitnan')/sqrt(13);
    ste_two_pts(arnum)=std(two_pts_bySubject(arnum,:),'omitnan')/sqrt(13);
    
    G=graph(blocks{arnum}.arena.neighbor); C=centrality(G,'closeness')*149; 
    mean_centrality(arnum)=mean(C); 
end

%% Plot 1 -- Stopping distance from goal

figure('Position',[0 0 450 350]); hold on
complexity=100*(-mean_centrality+0.1115);
plot(flip(complexity),flip(stop2goal_rew_byArena),'color','k')
plot(flip(complexity),flip(stop2goal_unrew_byArena),'color','k')

scatter(complexity,stop2goal_rew_byArena,200,...
    'markerfacecolor',clrs.green,'markeredgecolor','k')
errorbar(complexity,stop2goal_rew_byArena,...
    ste_stop2goal_rew,'LineStyle','none','color','k','CapSize',0)
scatter(complexity,stop2goal_unrew_byArena,200,...
    'markerfacecolor',clrs.red,'markeredgecolor','k')
errorbar(complexity,stop2goal_unrew_byArena,...
    ste_stop2goal_unrew,'LineStyle','none','color','k','CapSize',0)

%% Format and save
movegui(gcf,'center')
set(gca,'color','w','fontsize',24,'Tickdir','out','Ticklength',[.03 .03]); 
set(gcf,'color','w','InvertHardCopy','off'); 
xticks([0 3 6]); xlim([-1 7]); yticks([0 1 2 3]); ylim([0 3])
xlabel('Arena complexity'); ylabel('Stop2Goal (m)')

%% Plot 2 -- Percent of points

figure('Position',[0 0 450 350]); hold on
plot(flip(complexity),flip(100*frac_pts_byArena),'color','k')
errorbar(complexity,100*frac_pts_byArena,...
    100*ste_frac_pts,'LineStyle','none','color','k','CapSize',0)
scatter(complexity,100*frac_pts_byArena,300,...
    'markerfacecolor',clrs.lilac,'markeredgecolor','k')

%% Format and save
movegui(gcf,'center')
set(gca,'color','w','fontsize',24,'Tickdir','out','Ticklength',[.03 .03]); 
set(gcf,'color','w','InvertHardCopy','off'); 
xticks([0 3 6]); xlim([-1 7]); 
yticks([50 75 100]); yticklabels({'50','','100'}); ylim([50 100])
xlabel('Arena complexity'); ylabel('% points')

%% Plot 3 -- Frequency of each trial outcome
 
figure('Position',[0 0 450 350]); hold on
plot(flip(complexity),flip(one_pt_byArena),'color','k')
plot(flip(complexity),flip(two_pts_byArena),'color','k')

scatter(complexity,one_pt_byArena,200,...
    'markerfacecolor',clrs.green,'markeredgecolor','none')
errorbar(complexity,one_pt_byArena,...
    ste_one_pt,'LineStyle','none','color','k','CapSize',0)
scatter(complexity,two_pts_byArena,200,...
    'markerfacecolor',clrs.darkgreen,'markeredgecolor','none')
errorbar(complexity,two_pts_byArena,...
    ste_two_pts,'LineStyle','none','color',clrs.lightgray,'CapSize',0)

%% Format and save
movegui(gcf,'center')
set(gca,'color','w','fontsize',24,'Tickdir','out','Ticklength',[.03 .03]); 
set(gcf,'color','w','InvertHardCopy','off'); 
xticks([0 3 6]); xlim([-1 7]); yticks([0 0.4 0.8]); ylim([0 0.8])
xlabel('Arena complexity'); ylabel('P(outcome)')
