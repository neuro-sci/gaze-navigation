function s2a_performance_over_trials(blocks)
%% Produce a plot with two y axes -- P(rewarded) and observed / predicted pathlengths
% across trials
% NOTE: For the right y axis, the first trial for each run was excluded due to 
% potential software start-up effects on the path length variable (see Methods)
% NOTE: For the right y axis, trials for which the target is inaccessible were
% excluded
% NOTE: For all analyses in the paper, trials skipped by the subject were
% excluded

clrs=def_colors; rewarded=nan(5,13,60); unrewarded=nan(5,13,60);
rewarded_byTrial=nan(60,1); pathlen=nan(5,13,60); optimal=nan(5,13,60); 
subjvec=[2,4,6,9,10,11,13,14,15,16,17,20,21]; 
ratio_byTrial=nan(60,1); mean_centrality=nan(5,1);

%% Analyze performance

for arnum=1:5
    for subj=1:13
        subject=subjvec(subj); discrete=blocks{arnum}.discrete{subject};
        rewarded(arnum,subj,([discrete.RewardZone]==1 | [discrete.RewardZone]==2))=1; 
        unrewarded(arnum,subj,[discrete.RewardZone]==0)=1; 
        % Trials for which the start and target locations were identitical were
        % exluded from the ratio to avoid dividing by zero
        goodtrials=find([discrete.RewardZone]~=9 & [discrete.dist2targ]~=0);
        pathlen(arnum,subj,goodtrials)=[discrete(goodtrials).pathlength];
        optimal(arnum,subj,goodtrials)=[discrete(goodtrials).dist2targ];
    end
    G=graph(blocks{arnum}.arena.neighbor); C=centrality(G,'closeness')*149; 
    mean_centrality(arnum)=mean(C); 
end

ind1=exclude_impossible_trials(blocks); ind2=exclude_first_runs; 
pathlen([ind1,ind2])=NaN; optimal([ind1,ind2])=NaN; 
for trial=1:60
    rewarded_byTrial(trial)=sum(rewarded(:,:,trial),'all','omitnan')./...
            (sum(rewarded(:,:,trial),'all','omitnan')+sum(unrewarded(:,:,trial),'all','omitnan'));
    ratio_byTrial(trial)=mean(pathlen(:,:,trial)./optimal(:,:,trial),'all','omitnan');
end

%% Plot

figure('Position',[0 0 600 450]); hold on; 
scatter([1:60],rewarded_byTrial,10,'markerfacecolor',clrs.green,'markeredgecolor','none')
plot([1:60],movmean(rewarded_byTrial,5),'color',clrs.green,'linewidth',2)
set(gca,'color','w','fontsize',24,'Tickdir','out','Ticklength',[.03 .03]); 
yticks([0.7 0.8 0.9 1]); ylim([0.6 1]); ylabel('P(rewarded)')

yyaxis right; scatter([1:60],ratio_byTrial,10,'markerfacecolor',clrs.lightgray,'markeredgecolor','none')
plot([1:60],movmean(ratio_byTrial,5),'-','color',clrs.lightgray,'linewidth',2)
set(gca,'ycolor','k'); yticks([1 1.25 1.5]); ylim([1 1.5]); 
ylabel('Observed / Predicted')

movegui(gcf,'center'); set(gcf,'color','w','InvertHardCopy','off'); 
xticks([20 40]); xlim([1 50]); xlabel('Trial number'); 
