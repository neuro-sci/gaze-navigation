function s10a_direction_first_sweep(blocks)
%% Quantify the direction of the first sweep, whether it occured 
% prior to movement or during movement.
% NOTE: Only trials skipped by the subject were excluded from this analysis
% NOTE: Error bars represent standard error across subjects

clrs=def_colors; subjvec=[2,4,6,9,10,11,13,14,15,16,17,20,21];
% Coding for "first_sweep_status":
% 1 = first sweep is premove, forward. 2 = first sweep is premove, backward
% 3 = first sweep is move, forward. 4 = first sweep is move, backward
% 5 = no sweeps in trial
first_sweep_status=nan(5,13,60); 
forward_premove_byArena=nan(5,1); backward_premove_byArena=nan(5,1);
forward_move_byArena=nan(5,1); backward_move_byArena=nan(5,1);
forward_premove_bySubject=nan(5,13); backward_premove_bySubject=nan(5,13); 
forward_move_bySubject=nan(5,13); backward_move_bySubject=nan(5,13); 
sterr_forward_premove=nan(5,1); sterr_backward_premove=nan(5,1);
sterr_forward_move=nan(5,1); sterr_backward_move=nan(5,1);
mean_centrality=nan(5,1);

%% Classify each trial

for arnum=1:5
    for subj=1:13
        subject=subjvec(subj); continuous=blocks{arnum}.continuous{subject};
        sweeps=blocks{arnum}.sweeps{subject};
        for trial=1:size(continuous,2)
            detected=blocks{arnum}.discrete{subject}(trial).detect_frame;
            start_move=blocks{arnum}.discrete{subject}(trial).start_move;
            first_forward_sweep=NaN; first_backward_sweep=NaN;
            
            % Because sweeps are algorithmically labeled, it is possible
            % for a sweep to begin prior to target detection. Sweeps which
            % terminate before target detection will be excluded from this
            % analysis.
            if ~isempty(sweeps{trial}.forward_sweeps)
                sw=find(sweeps{trial}.forward_sweeps(:,2)>=detected,1,'first');
                if ~isempty(sw)
                    first_forward_sweep=sweeps{trial}.forward_sweeps(sw,1);
                end
            end
            if ~isempty(sweeps{trial}.backward_sweeps)
                sw=find(sweeps{trial}.backward_sweeps(:,2)>=detected,1,'first');
                if ~isempty(sw)
                    first_backward_sweep=sweeps{trial}.backward_sweeps(sw,1);
                end
            end
            
            events=[start_move,first_forward_sweep,first_backward_sweep,1000^2];
            [~,idx]=sort(events);
            switch idx(1)
                case 1, switch idx(2)
                        case 2, first_sweep_status(arnum,subj,trial)=3;
                        case 3, first_sweep_status(arnum,subj,trial)=4;
                        case 4, first_sweep_status(arnum,subj,trial)=5; end
                case 2, first_sweep_status(arnum,subj,trial)=1;
                case 3, first_sweep_status(arnum,subj,trial)=2;
                case 4, first_sweep_status(arnum,subj,trial)=5;
            end
        end
    end
    G=graph(blocks{arnum}.arena.neighbor); C=centrality(G,'closeness')*149; 
    mean_centrality(arnum)=mean(C); 
end

%% Compute averages and standard deviations

ind=exclude_skipped_trials(blocks); first_sweep_status(ind)=NaN;
for arnum=1:5
    for subj=1:13
        forward_premove_bySubject(arnum,subj)=sum(squeeze(first_sweep_status(arnum,subj,:))==1)/...
            nnz(~isnan(squeeze(first_sweep_status(arnum,subj,:))));
        backward_premove_bySubject(arnum,subj)=sum(squeeze(first_sweep_status(arnum,subj,:))==2)/...
            nnz(~isnan(squeeze(first_sweep_status(arnum,subj,:))));
        forward_move_bySubject(arnum,subj)=sum(squeeze(first_sweep_status(arnum,subj,:))==3)/...
            nnz(~isnan(squeeze(first_sweep_status(arnum,subj,:))));
        backward_move_bySubject(arnum,subj)=sum(squeeze(first_sweep_status(arnum,subj,:))==4)/...
            nnz(~isnan(squeeze(first_sweep_status(arnum,subj,:))));
    end
    forward_premove_byArena(arnum)=mean(forward_premove_bySubject(arnum,:),'omitnan');
    backward_premove_byArena(arnum)=mean(backward_premove_bySubject(arnum,:),'omitnan');
    forward_move_byArena(arnum)=mean(forward_move_bySubject(arnum,:),'omitnan');
    backward_move_byArena(arnum)=mean(backward_move_bySubject(arnum,:),'omitnan');
    
    sterr_forward_premove(arnum)=std(forward_premove_bySubject(arnum,:),'omitnan')/sqrt(13);
    sterr_backward_premove(arnum)=std(backward_premove_bySubject(arnum,:),'omitnan')/sqrt(13);
    sterr_forward_move(arnum)=std(forward_move_bySubject(arnum,:),'omitnan')/sqrt(13);
    sterr_backward_move(arnum)=std(backward_move_bySubject(arnum,:),'omitnan')/sqrt(13);
end

%% Plot for pre-movement

figure('position',[0 0 450 375]); hold on
complexity=100*(-mean_centrality+0.1115);
plot(complexity,100*forward_premove_byArena,'color','k')
plot(complexity,100*backward_premove_byArena,'color','k')
errorbar(complexity,100*forward_premove_byArena,...
    100*sterr_forward_premove,'LineStyle','none','color','k','CapSize',0)
errorbar(complexity,100*backward_premove_byArena,...
    100*sterr_backward_premove,'LineStyle','none','color','k','CapSize',0)
scatter(complexity,100*forward_premove_byArena,300,...
    'markerfacecolor',clrs.green,'markeredgecolor','none')
scatter(complexity,100*backward_premove_byArena,300,...
    'markerfacecolor',clrs.red,'markeredgecolor','none')

movegui(gcf,'center')
set(gca,'color','w','fontsize',24,'Tickdir','out','Ticklength',[.03 .03]); 
set(gcf,'color','w','InvertHardCopy','off'); 
xticks([0 3 6]); xlim([-1 7]); yticks([0 15 30]); ylim([0 30])
xlabel('Arena complexity'); ylabel('% trials')

%% Plot for movement

figure('position',[0 0 450 375]); hold on
plot(complexity,100*forward_move_byArena,'color','k')
plot(complexity,100*backward_move_byArena,'color','k')
errorbar(complexity,100*forward_move_byArena,...
    100*sterr_forward_move,'LineStyle','none','color','k','CapSize',0)
errorbar(complexity,100*backward_move_byArena,...
    100*sterr_backward_move,'LineStyle','none','color','k','CapSize',0)
scatter(complexity,100*forward_move_byArena,300,...
    'markerfacecolor',clrs.green,'markeredgecolor','none')
scatter(complexity,100*backward_move_byArena,300,...
    'markerfacecolor',clrs.red,'markeredgecolor','none')

movegui(gcf,'center')
set(gca,'color','w','fontsize',24,'Tickdir','out','Ticklength',[.03 .03]); 
set(gcf,'color','w','InvertHardCopy','off'); 
xticks([0 3 6]); xlim([-1 7]); yticks([0 10 20]); ylim([0 20])
xlabel('Arena complexity'); ylabel('% trials')
