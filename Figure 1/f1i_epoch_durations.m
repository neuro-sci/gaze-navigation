function f1i_epoch_durations(blocks)
%% Produce a line plot showing epoch durations for each arena
% NOTE: Only skipped trials were excluded for this analysis

clrs=def_colors; epoch_durations=get_epoch_durations(blocks);
search_byArena=nan(5,1); premove_byArena=nan(5,1);
move_byArena=nan(5,1); postmove_byArena=nan(5,1);
search_bySubject=nan(5,13); premove_bySubject=nan(5,13);
move_bySubject=nan(5,13); postmove_bySubject=nan(5,13);
ste_search_overSubjects=nan(5,1); ste_premove_overSubjects=nan(5,1);
ste_move_overSubjects=nan(5,1); ste_postmove_overSubjects=nan(5,1);
mean_centrality=nan(5,1);

%% Compute means and errors
for arnum=1:5
    search_byArena(arnum)=mean(squeeze(epoch_durations.search(arnum,:,:)),'all','omitnan');
    premove_byArena(arnum)=mean(squeeze(epoch_durations.pre_move(arnum,:,:)),'all','omitnan');
    move_byArena(arnum)=mean(squeeze(epoch_durations.move(arnum,:,:)),'all','omitnan');
    postmove_byArena(arnum)=mean(squeeze(epoch_durations.post_move(arnum,:,:)),'all','omitnan');
    
    for subj=1:13
        search_bySubject(arnum,subj)=mean(squeeze(epoch_durations.search(arnum,subj,:)),'omitnan');
        premove_bySubject(arnum,subj)=mean(squeeze(epoch_durations.pre_move(arnum,subj,:)),'omitnan');
        move_bySubject(arnum,subj)=mean(squeeze(epoch_durations.move(arnum,subj,:)),'omitnan');
        postmove_bySubject(arnum,subj)=mean(squeeze(epoch_durations.post_move(arnum,subj,:)),'omitnan');
    end
    
    ste_search_overSubjects(arnum)=std(search_bySubject(arnum,:),'omitnan')/sqrt(13);
    ste_premove_overSubjects(arnum)=std(premove_bySubject(arnum,:),'omitnan')/sqrt(13);
    ste_move_overSubjects(arnum)=std(move_bySubject(arnum,:),'omitnan')/sqrt(13);
    ste_postmove_overSubjects(arnum)=std(postmove_bySubject(arnum,:),'omitnan')/sqrt(13);
    G=graph(blocks{arnum}.arena.neighbor); C=centrality(G,'closeness')*149; 
    mean_centrality(arnum)=mean(C); 
end

%% Plot
figure('Position',[0 0 375 400]); hold on; 
complexity=100*(-mean_centrality+0.1115);
plot(flip(complexity),flip(search_byArena),'color','k')
plot(flip(complexity),flip(premove_byArena),'color','k')
plot(flip(complexity),flip(move_byArena),'color','k')
plot(flip(complexity),flip(postmove_byArena),'color','k')

scatter(complexity,search_byArena,200,...
    'markerfacecolor',clrs.pink,'markeredgecolor','none')
errorbar(complexity,search_byArena,...
    ste_search_overSubjects,'LineStyle','none','color','k','CapSize',0)
scatter(complexity,premove_byArena,200,...
    'markerfacecolor',clrs.gold,'markeredgecolor','none')
errorbar(complexity,premove_byArena,...
    ste_premove_overSubjects,'LineStyle','none','color','k','CapSize',0)
scatter(complexity,move_byArena,200,...
    'markerfacecolor',clrs.blue,'markeredgecolor','none')
errorbar(complexity,move_byArena,...
    ste_move_overSubjects,'LineStyle','none','color','k','CapSize',0)
scatter(complexity,postmove_byArena,200,...
    'markerfacecolor',clrs.seafoam,'markeredgecolor','none')
errorbar(complexity,postmove_byArena,...
    ste_postmove_overSubjects,'LineStyle','none','color','k','CapSize',0)


%% Format
movegui(gcf,'center')
set(gca,'color','w','fontsize',24,'Tickdir','out','Ticklength',[.03 .03]); 
set(gcf,'color','w','InvertHardCopy','off'); 
xticks([0 3 6]); xlim([-1 7]); 
yticks([0 5 10 15]); ylim([-1.5 16])
xlabel('Arena complexity'); ylabel('Epoch duration (s)')

%% Compute stats: epoch durations

all_epochs=epoch_durations.search+epoch_durations.pre_move+epoch_durations.move+epoch_durations.post_move;
mean_search=mean(epoch_durations.search./all_epochs,'all','omitnan');
mean_premove=mean(epoch_durations.pre_move./all_epochs,'all','omitnan');
mean_move=mean(epoch_durations.move./all_epochs,'all','omitnan');
search_STD=nan(13,1); premove_STD=nan(13,1); move_STD=nan(13,1);
for subj=1:13
    search_STD(subj)=mean(epoch_durations.search(:,subj,:)./all_epochs(:,subj,:),'all','omitnan');
    premove_STD(subj)=mean(epoch_durations.pre_move(:,subj,:)./all_epochs(:,subj,:),'all','omitnan');
    move_STD(subj)=mean(epoch_durations.move(:,subj,:)./all_epochs(:,subj,:),'all','omitnan');
end
search_STD=std(search_STD); premove_STD=std(premove_STD); move_STD=std(move_STD);
disp(['search relative duration: ',num2str(mean_search),' +/- ',num2str(search_STD),...
    ', coefficient of variation: ',num2str(search_STD/mean_search)])
disp(['pre-movement relative duration: ',num2str(mean_premove),' +/- ',num2str(premove_STD),...
    ', coefficient of variation: ',num2str(premove_STD/mean_premove)])
disp(['movement relative duration: ',num2str(mean_move),' +/- ',num2str(move_STD),...
    ', coefficient of variation: ',num2str(move_STD/mean_move)])
