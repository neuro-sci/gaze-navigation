function s2e_premove_duration_effects(blocks)
%% Produce a plot with two y axes -- P(rewarded) and observed / predicted pathlengths
% w.r.t. relative pre-move durations exhibited by subjects
% NOTE: For the right y axis, the first trial for each run was excluded due to 
% potential software start-up effects on the path length variable (see Methods)
% NOTE: For the right y axis, trials for which the target is inaccessible were
% excluded
% NOTE: For all analyses in the paper, trials skipped by the subject were
% excluded

clrs=def_colors; rewarded=nan(5,13,60); unrewarded=nan(5,13,60);
rewarded_bySubject=nan(13,1); pathlen=nan(5,13,60); optimal=nan(5,13,60); 
subjvec=[2,4,6,9,10,11,13,14,15,16,17,20,21]; premove_dur=nan(13,1);
ratio_bySubject=nan(13,1); mean_centrality=nan(5,1);

epoch_durations=get_epoch_durations(blocks);
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
for subj=1:13
    rewarded_bySubject(subj)=sum(rewarded(:,subj,:),'all','omitnan')./...
            (sum(rewarded(:,subj,:),'all','omitnan')+sum(unrewarded(:,subj,:),'all','omitnan'));
    ratio_bySubject(subj)=mean(pathlen(:,subj,:)./optimal(:,subj,:),'all','omitnan');
    premove_dur(subj)=mean(squeeze(epoch_durations.pre_move(:,subj,:))./...
        (squeeze(epoch_durations.entire_trial(:,subj,:))-...
        squeeze(epoch_durations.search(:,subj,:))),'all','omitnan');
end

%% Plot

figure('Position',[0 0 600 450]); hold on; 
scatter(premove_dur,rewarded_bySubject,75,'markerfacecolor',clrs.green,'markeredgecolor','none')
set(gca,'color','w','fontsize',24,'Tickdir','out','Ticklength',[.03 .03]); 
yticks([0.7 0.8 0.9 1]); ylim([0.65 1]); ylabel('P(rewarded)')

yyaxis right; scatter(premove_dur,ratio_bySubject,75,'markerfacecolor',clrs.lightgray,'markeredgecolor','none')
set(gca,'ycolor','k'); yticks([1 1.15 1.3]); ylim([0.9 1.3])
ylabel('Observed / Predicted')

movegui(gcf,'center'); set(gcf,'color','w','InvertHardCopy','off'); 
xlabel('Rel. pre-move. dur.'); xticks([0.1 0.2 0.3]); xlim([0.1 0.3])
