function s2c_frac_rewarded(blocks)
%% P(rewarded) by arena
% NOTE: For all analyses in the paper, trials skipped by the subject were
% excluded
% NOTE: Stardard errors are across subjects

clrs=def_colors; rewarded=nan(5,13,60); unrewarded=nan(5,13,60);
rewarded_byArena=nan(5,1); rewarded_bySubject=nan(5,13); ste_rewarded=nan(5,1);
subjvec=[2,4,6,9,10,11,13,14,15,16,17,20,21]; mean_centrality=nan(5,1);

for arnum=1:5
    for subj=1:13
        subject=subjvec(subj); discrete=blocks{arnum}.discrete{subject};
        rewarded(arnum,subj,([discrete.RewardZone]==1 | [discrete.RewardZone]==2))=1; 
        unrewarded(arnum,subj,[discrete.RewardZone]==0)=1; 
        rewarded_bySubject(arnum,subj)=sum(rewarded(arnum,subj,:),'omitnan')./...
            (sum(rewarded(arnum,subj,:),'omitnan')+sum(unrewarded(arnum,subj,:),'omitnan'));
    end
    rewarded_byArena(arnum)=sum(rewarded(arnum,:,:),'all','omitnan')./...
        (sum(rewarded(arnum,:,:),'all','omitnan')+sum(unrewarded(arnum,:,:),'all','omitnan'));
    ste_rewarded(arnum)=std(rewarded_bySubject(arnum,:),'omitnan')/sqrt(13);

    G=graph(blocks{arnum}.arena.neighbor); C=centrality(G,'closeness')*149; 
    mean_centrality(arnum)=mean(C); 
end

ind1=exclude_impossible_trials(blocks); ind2=exclude_first_runs; 

%% Plot

figure('Position',[0 0 450 400]); hold on; 
complexity=100*(-mean_centrality+0.1115);
plot(flip(complexity),flip(rewarded_byArena),'color','k')
errorbar(complexity,rewarded_byArena,...
    ste_rewarded,'LineStyle','none','color','k','CapSize',0)
scatter(complexity,rewarded_byArena,200,...
    'markerfacecolor',clrs.green,'markeredgecolor','k')
set(gca,'color','w','fontsize',24,'Tickdir','out','Ticklength',[.03 .03]); 
yticks([0.7 0.8 0.9 1]); ylim([0.65 1]); ylabel('P(rewarded)')

movegui(gcf,'center'); set(gcf,'color','w','InvertHardCopy','off'); 
xticks([0 3 6]); xlim([-1 7]); xlabel('Arena complexity'); 

%% Compute stats: correlation between fraction of rewarded trials and arena complexity

complexity_matrix=repmat(complexity,1,13);
[R,P]=corrcoef(rewarded_bySubject(:),complexity_matrix(:));
disp(['correlation of fraction of rewarded trials vs. arena complexity (df = 63) is ',num2str(R(1,2)),...
    ', p_val = ',num2str(P(1,2))])
