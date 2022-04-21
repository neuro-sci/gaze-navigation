function f1g_pathlen_ratio(blocks)
%% Ratio of observed / predicted pathlengths by arena
% NOTE: The first trial for each run was excluded due to potential software 
% start-up effects on the path length variable (see Methods)
% NOTE: Trials for which the target is inaccessible were excluded
% NOTE: For all analyses in the paper, trials skipped by the subject were
% excluded
% NOTE: Stardard errors are across subjects

clrs=def_colors; 
pathlen=nan(5,13,60); optimal=nan(5,13,60); ratio_byArena=nan(5,1);
ratio_bySubject=nan(5,13); ste_ratio=nan(5,1);
subjvec=[2,4,6,9,10,11,13,14,15,16,17,20,21]; mean_centrality=nan(5,1);

for arnum=1:5
    for subj=1:13
        subject=subjvec(subj); discrete=blocks{arnum}.discrete{subject};
        % Trials for which the start and target locations were identitical were
        % exluded from the ratio to avoid dividing by zero
        goodtrials=find([discrete.RewardZone]~=9 & [discrete.dist2targ]~=0);
        pathlen(arnum,subj,goodtrials)=[discrete(goodtrials).pathlength];
        optimal(arnum,subj,goodtrials)=[discrete(goodtrials).dist2targ];
    end
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

%% Plot

figure('Position',[0 0 450 400]); hold on; 
complexity=100*(-mean_centrality+0.1115);
yline(1,'--','color',clrs.red)
plot(flip(complexity),flip(ratio_byArena),'color','k')
scatter(complexity,ratio_byArena,200,'markerfacecolor',clrs.lightgray,'markeredgecolor','k')
errorbar(complexity,ratio_byArena,ste_ratio,'LineStyle','none','color','k','CapSize',0)
ylabel('Observed / Predicted')
xticks([0 3 6]); xlim([-1 7]); xlabel('Arena complexity'); ylim([0 1.5])
movegui(gcf,'center')
set(gca,'color','w','fontsize',24,'Tickdir','out','Ticklength',[.03 .03]); 
set(gcf,'color','w','InvertHardCopy','off'); 
