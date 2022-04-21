function f1c_complexity_bar(blocks)
%% Produces a bar plot of arena complexity values (negative centrality)
% Error bars show standard deviation (150 states)
% NOTE: the order of arenas in the dataset is the reverse of the order of
% arenas in this figure
% NOTE: Centrality values were multipled with -1 and shifted such that the
% least complex arena has a "complexity" value of 0

arenas=flip([1:5]); clrs=def_colors; figure; hold on
clr=[clrs.prim2mint1;clrs.prim2mint2;clrs.prim2mint3;clrs.prim2mint4;clrs.prim2mint5];
for arnum=1:5
    G=graph(blocks{arnum}.arena.neighbor); C=centrality(G,'closeness')*149; 
    mean_centrality=mean(C); std_centrality=std((-C+0.1115),'omitnan');
    bar(arenas(arnum),-mean_centrality+0.1115,'FaceColor',clr(arnum,:),'EdgeColor','none')
    errorbar(arenas(arnum),-mean_centrality+0.1115,std_centrality,'color','k','CapSize',0)
end

%% Format
movegui(gcf,'center')
set(gca,'fontsize',24,'color','w','Ticklength',[.03 .03]); 
set(gcf,'color','w','InvertHardCopy','off')
xticks(1:5); xticklabels({'1','2','3','4','5'}); box off;
ax=gca; yax=ax.YAxis; set(yax,'TickDirection','out'); ylim([-0.03 0.08])
ylabel('Complexity'); xlabel('Arena')