function s1e_behaviorial_performance_bySubject(blocks)
%% Plot behavioral variables against arena complexity by subject
% (1) Stopping distance from goal for rewarded and unrewarded trials
% (2) Percent of points obtained in each arena
% (3) Outcome frequencies per arena (zero, one, or two points)
% (4) P(rewarded) by arena
% NOTE: For the P(rewarded) plot, the first trial for each run was excluded due to 
% potential software start-up effects on the path length variable (see Methods)
% NOTE: For all analyses in the paper, trials skipped by the subject were
% excluded

clrs=def_colors; rewarded=nan(5,13,60); unrewarded=nan(5,13,60);
rewarded_byArena=nan(5,1); rewarded_bySubject=nan(5,13); ste_rewarded=nan(5,1);
pathlen=nan(5,13,60); optimal=nan(5,13,60); ratio_byArena=nan(5,1);
ratio_bySubject=nan(5,13); ste_ratio=nan(5,1);
zero_points=nan(5,13,60); one_point=nan(5,13,60); 
two_points=nan(5,13,60); stop_dist_from_goal=nan(5,13,60);
stop2goal_rew_byArena=nan(5,1); stop2goal_unrew_byArena=nan(5,1);
stop2goal_rew_bySubject=nan(5,13); stop2goal_unrew_bySubject=nan(5,13);
ste_stop2goal_rew=nan(5,1); ste_stop2goal_unrew=nan(5,1); 
frac_pts_byArena=nan(5,1); frac_pts_bySubject=nan(5,13); ste_frac_pts=nan(5,1);
zero_pts_byArena=nan(5,1); one_pt_byArena=nan(5,1); two_pts_byArena=nan(5,1); 
zero_pts_bySubject=nan(5,13); one_pt_bySubject=nan(5,13); two_pts_bySubject=nan(5,13); 
ste_zero_pts=nan(5,1); ste_one_pt=nan(5,1); ste_two_pts=nan(5,1);
subjvec=[2,4,6,9,10,11,13,14,15,16,17,20,21]; mean_centrality=nan(5,1);

for arnum=1:5
    for subj=1:13
        subject=subjvec(subj); discrete=blocks{arnum}.discrete{subject};
        rewarded(arnum,subj,([discrete.RewardZone]==1 | [discrete.RewardZone]==2))=1; 
        unrewarded(arnum,subj,[discrete.RewardZone]==0)=1; 
        rewarded_bySubject(arnum,subj)=sum(rewarded(arnum,subj,:),'omitnan')./...
            (sum(rewarded(arnum,subj,:),'omitnan')+sum(unrewarded(arnum,subj,:),'omitnan'));
        continuous=blocks{arnum}.continuous{subject};
        zero_points(arnum,subj,[discrete.RewardZone]==0)=1; 
        % reward zone 2 yields one point
        one_point(arnum,subj,[discrete.RewardZone]==2)=1; 
        % reward zone 1 yields two points
        two_points(arnum,subj,[discrete.RewardZone]==1)=1; 
        
        % Trials for which the start and target locations were identitical were
        % exluded from the ratio to avoid dividing by zero
        goodtrials=find([discrete.RewardZone]~=9 & [discrete.dist2targ]~=0);
        pathlen(arnum,subj,goodtrials)=[discrete(goodtrials).pathlength];
        optimal(arnum,subj,goodtrials)=[discrete(goodtrials).dist2targ];

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
    rewarded_byArena(arnum)=sum(rewarded(arnum,:,:),'all','omitnan')./...
        (sum(rewarded(arnum,:,:),'all','omitnan')+sum(unrewarded(arnum,:,:),'all','omitnan'));
    ste_rewarded(arnum)=std(rewarded_bySubject(arnum,:),'omitnan')/sqrt(13);

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
end

ind1=exclude_impossible_trials(blocks); ind2=exclude_first_runs; 
pathlen([ind1,ind2])=NaN; optimal([ind1,ind2])=NaN; 
for arnum=1:5
    for subj=1:13
        ratio_bySubject(arnum,subj)=mean(pathlen(arnum,subj,:)./optimal(arnum,subj,:),'all','omitnan');
    end
    ratio_byArena(arnum)=mean(pathlen(arnum,:,:)./optimal(arnum,:,:),'all','omitnan');
    ste_ratio(arnum)=std(ratio_bySubject(arnum,:),'omitnan')/sqrt(13);
    G=graph(blocks{arnum}.arena.neighbor); C=centrality(G,'closeness')*149; 
    mean_centrality(arnum)=mean(C); 
end

%% Line plots: P(outcome) by subject

figure('Position',[0 0 450 375]); hold on; 
complexity=100*(-mean_centrality+0.1115);
for subj=1:13
    plot(flip(complexity),flip(squeeze(one_pt_bySubject(:,subj))),...
        'color',[clrs.subjects(subj,:),0.7],'linewidth',2)
end

movegui(gcf,'center'); set(gcf,'color','w','InvertHardCopy','off'); 
set(gca,'color','w','fontsize',24,'Tickdir','out','Ticklength',[.03 .03]); 
xticks([0 3 6]); xlim([-1 7]); xlabel('Arena complexity'); ylabel('P(1 point)')

figure('Position',[0 0 450 375]); hold on; 
for subj=1:13
    plot(flip(complexity),flip(squeeze(two_pts_bySubject(:,subj))),...
        'color',[clrs.subjects(subj,:),0.7],'linewidth',2)
end

movegui(gcf,'center'); set(gcf,'color','w','InvertHardCopy','off'); 
set(gca,'color','w','fontsize',24,'Tickdir','out','Ticklength',[.03 .03]); 
xticks([0 3 6]); xlim([-1 7]); xlabel('Arena complexity'); ylabel('P(2 points)')

%% Line plot: % Points by subject

figure('Position',[0 0 450 375]); hold on; 
for subj=1:13
    plot(flip(complexity),flip(squeeze(frac_pts_bySubject(:,subj))),...
        'color',[clrs.subjects(subj,:),0.7],'linewidth',2)
end

movegui(gcf,'center'); set(gcf,'color','w','InvertHardCopy','off'); 
set(gca,'color','w','fontsize',24,'Tickdir','out','Ticklength',[.03 .03]); 
xticks([0 3 6]); xlim([-1 7]); xlabel('Arena complexity'); ylabel('% Points')

%% Line plot: P(rewarded) by subject

figure('Position',[0 0 450 375]); hold on; 
for subj=1:13
    plot(flip(complexity),flip(squeeze(rewarded_bySubject(:,subj))),...
        'color',[clrs.subjects(subj,:),0.7],'linewidth',2)
end

movegui(gcf,'center'); set(gcf,'color','w','InvertHardCopy','off'); 
set(gca,'color','w','fontsize',24,'Tickdir','out','Ticklength',[.03 .03]); 
xticks([0 3 6]); xlim([-1 7]); xlabel('Arena complexity'); ylabel('P(rewarded)')

%% LME: trial-specific effects on behaviorial variables

[fixed,random,R_vals,P_vals]=LME_complexity(complexity,one_pt_bySubject);
[fixed,random,R_vals,P_vals]=LME_complexity(complexity,two_pts_bySubject);
[fixed,random,R_vals,P_vals]=LME_complexity(complexity,frac_pts_bySubject);
[fixed,random,R_vals,P_vals]=LME_complexity(complexity,rewarded_bySubject);
