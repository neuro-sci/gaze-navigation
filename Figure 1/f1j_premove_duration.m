function f1j_premove_duration(blocks)
%% Produce a line plot showing pre-movement epoch durations for each arena
% NOTE: Only skipped trials were excluded for this analysis
% NOTE: Error bars show standard error across subjects

clrs=def_colors; epoch_durations=get_epoch_durations(blocks);
premove_byArena=nan(5,1); premove_bySubject=nan(5,13);
ste_premove_overSubjects=nan(5,1); mean_centrality=nan(5,1);

%% Compute mean and errors
for arnum=1:5
    premove_byArena(arnum)=mean(squeeze(epoch_durations.pre_move(arnum,:,:))./...
        (squeeze(epoch_durations.entire_trial(arnum,:,:))-...
        squeeze(epoch_durations.search(arnum,:,:))),'all','omitnan');
    for subj=1:13
        premove_bySubject(arnum,subj)=mean(squeeze(epoch_durations.pre_move(arnum,subj,:))./...
            (squeeze(epoch_durations.entire_trial(arnum,subj,:))-...
            squeeze(epoch_durations.search(arnum,subj,:))),'omitnan');
    end
    ste_premove_overSubjects(arnum)=std(premove_bySubject(arnum,:),'omitnan')/sqrt(13);
    G=graph(blocks{arnum}.arena.neighbor); C=centrality(G,'closeness')*149; 
    mean_centrality(arnum)=mean(C); 
end

%% Plot
figure('Position',[0 0 375 400]); hold on; 
complexity=100*(-mean_centrality+0.1115);
plot(flip(complexity),flip(premove_byArena),'color','k')
errorbar(complexity,premove_byArena,ste_premove_overSubjects,'LineStyle','none','color','k','CapSize',0)
scatter(complexity,premove_byArena,200,'markerfacecolor',clrs.gold,'markeredgecolor','k')

%% Format
movegui(gcf,'center')
set(gca,'color','w','fontsize',24,'Tickdir','out','Ticklength',[.03 .03]); 
set(gcf,'color','w','InvertHardCopy','off'); 
xticks([0 3 6]); xlim([-1 7]); 
yticks([0.12 0.16 0.2]); ylim([0.09 0.22])
xlabel('Arena complexity'); ylabel('Relative duration')
