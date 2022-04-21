function s4b_premove_over_trials(blocks)
%% Produce a plot with relative pre-move duration across trials for each arena
% NOTE: For all analyses in the paper, trials skipped by the subject were
% excluded

clrs=def_colors; epoch_durations=get_epoch_durations(blocks);
premove_byTrial=nan(5,60);

for arnum=1:5
    for trial=1:60
        premove_byTrial(arnum,trial)=mean(epoch_durations.pre_move(arnum,:,trial),'all','omitnan');
    end
end

%% Plot

figure('Position',[0 0 450 375]); hold on; 
facecolor=[clrs.prim2mint1;clrs.prim2mint2;clrs.prim2mint3;clrs.prim2mint4;clrs.prim2mint5];
for arnum=1:5
    scatter([1:60],premove_byTrial(arnum,:),10,'markerfacecolor',facecolor(arnum,:),'markeredgecolor','none')
    plot([1:60],movmean(premove_byTrial(arnum,:),5),'color',facecolor(arnum,:),'linewidth',2)
end
set(gca,'color','w','fontsize',24,'Tickdir','out','Ticklength',[.03 .03]); 
ylim([0 6]); ylabel('Premove (s)'); xticks([20 40]); xlim([1 50]); xlabel('Trial number'); 
movegui(gcf,'center'); set(gcf,'color','w','InvertHardCopy','off'); 
