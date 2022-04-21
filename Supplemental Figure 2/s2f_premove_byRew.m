function s2f_premove_byRew(blocks)
%% Produce a line plot showing pre-movement epoch durations for each arena,
% comparing rewarded trials vs. unrewarded trials
% NOTE: No trials were excluded for this analysis
% NOTE: Error bars show standard error across subjects

clrs=def_colors; epoch_durations=get_epoch_durations(blocks);
subjvec=[2,4,6,9,10,11,13,14,15,16,17,20,21];
premove_byArena_rew=nan(5,1); premove_bySubject_rew=nan(5,13);
premove_byArena_unrew=nan(5,1); premove_bySubject_unrew=nan(5,13);
ste_premove_overSubjects_rew=nan(5,1); ste_premove_overSubjects_unrew=nan(5,1); 
mean_centrality=nan(5,1);

%% Compute mean and errors
for arnum=1:5
    rewarded=zeros(13,60); unrewarded=zeros(13,60);
    for subj=1:13
        subject=subjvec(subj); discrete=blocks{arnum}.discrete{subject};
        rewarded(subj,[discrete.RewardZone]==1 | [discrete.RewardZone]==2)=1; 
        unrewarded(subj,[discrete.RewardZone]==0)=1;
        
        premove_bySubject_rew(arnum,subj)=mean(squeeze(epoch_durations.pre_move(arnum,subj,rewarded(subj,:)==1))./...
            (squeeze(epoch_durations.entire_trial(arnum,subj,rewarded(subj,:)==1))-...
            squeeze(epoch_durations.search(arnum,subj,rewarded(subj,:)==1))),'omitnan');
        premove_bySubject_unrew(arnum,subj)=mean(squeeze(epoch_durations.pre_move(arnum,subj,unrewarded(subj,:)==1))./...
            (squeeze(epoch_durations.entire_trial(arnum,subj,unrewarded(subj,:)==1))-...
            squeeze(epoch_durations.search(arnum,subj,unrewarded(subj,:)==1))),'omitnan');
    end
    premove_byArena_rew(arnum)=mean(squeeze(epoch_durations.pre_move(arnum,rewarded==1))./...
        (squeeze(epoch_durations.entire_trial(arnum,rewarded==1))-...
        squeeze(epoch_durations.search(arnum,rewarded==1))),'all','omitnan');
    premove_byArena_unrew(arnum)=mean(squeeze(epoch_durations.pre_move(arnum,unrewarded==1))./...
        (squeeze(epoch_durations.entire_trial(arnum,unrewarded==1))-...
        squeeze(epoch_durations.search(arnum,unrewarded==1))),'all','omitnan');
    ste_premove_overSubjects_rew(arnum)=std(premove_bySubject_rew(arnum,:),'omitnan')/sqrt(13);
    ste_premove_overSubjects_unrew(arnum)=std(premove_bySubject_unrew(arnum,:),'omitnan')/sqrt(13);
    G=graph(blocks{arnum}.arena.neighbor); C=centrality(G,'closeness')*149; 
    mean_centrality(arnum)=mean(C); 
end

%% Plot
figure('Position',[0 0 600 450]); hold on; 
plot(flip(-mean_centrality+0.1115),flip(premove_byArena_rew),'color','k')
plot(flip(-mean_centrality+0.1115),flip(premove_byArena_unrew),'color','k')
errorbar(-mean_centrality+0.1115,premove_byArena_rew,...
    ste_premove_overSubjects_rew,'LineStyle','none','color','k','CapSize',0)
scatter(-mean_centrality+0.1115,premove_byArena_rew,300,...
    'markerfacecolor',clrs.green,'markeredgecolor','none')
errorbar(-mean_centrality+0.1115,premove_byArena_unrew,...
    ste_premove_overSubjects_unrew,'LineStyle','none','color','k','CapSize',0)
scatter(-mean_centrality+0.1115,premove_byArena_unrew,300,...
    'markerfacecolor',clrs.red,'markeredgecolor','none')

%% Format
movegui(gcf,'center')
set(gca,'color','w','fontsize',24,'Tickdir','out','Ticklength',[.03 .03]); 
set(gcf,'color','w','InvertHardCopy','off'); 
xticks([0 0.03 0.06]); xlim([-0.01 0.07]); 
yticks([0.1 0.2]); ylim([0.04 0.25])
xlabel('Arena complexity'); ylabel('Relative duration')
