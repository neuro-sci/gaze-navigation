function s2d_epoch_pies(blocks)
%% Produce pie charts of epoch durations by arena, and fit linear mixed
% effects models on epoch durations
% NOTE: Only skipped trials were excluded for this analysis

clrs=def_colors; epoch_durations=get_epoch_durations(blocks);
colors=[clrs.pink;clrs.gold;clrs.blue;clrs.seafoam];
search_frac=epoch_durations.search./epoch_durations.entire_trial;
premove_frac=epoch_durations.pre_move./epoch_durations.entire_trial;
move_frac=epoch_durations.move./epoch_durations.entire_trial;
postmove_frac=epoch_durations.post_move./epoch_durations.entire_trial;

%% Compute means
search_frac_byArena=nan(5,1); premove_frac_byArena=nan(5,1);
move_frac_byArena=nan(5,1); postmove_frac_byArena=nan(5,1);
for arnum=1:5
    search_frac_byArena(arnum)=mean(squeeze(search_frac(arnum,:,:)),'all','omitnan');
    premove_frac_byArena(arnum)=mean(squeeze(premove_frac(arnum,:,:)),'all','omitnan');
    move_frac_byArena(arnum)=mean(squeeze(move_frac(arnum,:,:)),'all','omitnan');
    postmove_frac_byArena(arnum)=mean(squeeze(postmove_frac(arnum,:,:)),'all','omitnan');
end

%% Plot pie charts
arenas=flip([1:5]); figure('Position',[0 0 1000 600]);
for arnum=1:5; subplot(1,5,arnum)
    this_pie=PIE([search_frac_byArena(arenas(arnum)),premove_frac_byArena(arenas(arnum)),...
        move_frac_byArena(arenas(arnum)),postmove_frac_byArena(arenas(arnum))]);
    for slice=1:4
        set(this_pie(slice*2-1),'FaceColor',colors(slice,:),'EdgeColor','k')
    end
    delete(findobj(this_pie,'Type','text'));
end
movegui(gcf,'center'); set(gcf,'color','w','InvertHardCopy','off')
