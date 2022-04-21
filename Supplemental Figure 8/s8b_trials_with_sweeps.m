function s8b_trials_with_sweeps(blocks)
%% Plot the percent of trials with sweeps
% NOTE: For all analyses in the paper, trials skipped by the subject were
% excluded
% NOTE: Error bars show standard error across subjects

clrs=def_colors; subjvec=[2,4,6,9,10,11,13,14,15,16,17,20,21]; mean_centrality=nan(5,1);
trial_sweep=nan(5,13,60); % Dim 3: 0 = no sweep, 1 = sweep on that trial
trial_sweep_byArena=nan(5,1); trial_sweep_bySubject=nan(5,13); sterr_sweep=nan(5,1);

%% Label trials with sweeps
for arnum=1:5
    for subj=1:13
        subject=subjvec(subj); sweeps=blocks{arnum}.sweeps{subject};
        for trial=1:size(sweeps,2)
            if ~isempty(sweeps{trial}.forward_sweeps) || ~isempty(sweeps{trial}.backward_sweeps)
                trial_sweep(arnum,subj,trial)=1;
            else, trial_sweep(arnum,subj,trial)=0;
            end
        end
    end
    G=graph(blocks{arnum}.arena.neighbor); C=centrality(G,'closeness')*149; 
    mean_centrality(arnum)=mean(C); 
end

ind=exclude_skipped_trials(blocks); trial_sweep(ind)=NaN;
for arnum=1:5
    for subj=1:13
        trial_sweep_bySubject(arnum,subj)=sum(squeeze(trial_sweep(arnum,subj,:)),'all','omitnan')./...
            nnz(~isnan(trial_sweep(arnum,subj,:)));
    end
    trial_sweep_byArena(arnum)=mean(trial_sweep_bySubject(arnum,:),'all','omitnan');
    sterr_sweep(arnum)=std(trial_sweep_bySubject(arnum,:),'omitnan')/sqrt(13);
end

%% Plot
figure('position',[0 0 450 375]); hold on
complexity=100*(-mean_centrality+0.1115);
plot(flip(complexity),flip(100*trial_sweep_byArena),'color','k')
scatter(complexity,100*trial_sweep_byArena,300,...
    'markerfacecolor',clrs.lightgray,'markeredgecolor','k')
errorbar(complexity,100*trial_sweep_byArena,...
    100*sterr_sweep,'LineStyle','none','color','k','CapSize',0)

%% Format
movegui(gcf,'center')
set(gca,'color','w','fontsize',24,'Tickdir','out','Ticklength',[.03 .03]); 
set(gcf,'color','w','InvertHardCopy','off'); 
xticks([0 3 6]); xlim([-1 7]); yticks([0 50 100]); ylim([0 100])
xlabel('Arena complexity'); ylabel('% trials')

%% Compute stats: correlation between fraction of trials with sweeps and complexity
complexity_matrix=repmat(complexity,1,13);
[R,P]=corrcoef(trial_sweep_bySubject(:),complexity_matrix(:));
disp(['correlation of fraction of trials with sweeps vs. arena complexity (df = 63) is ',...
    num2str(R(1,2)),', p_val = ',num2str(P(1,2))])

%% Line plot: Sweep fraction by subject

figure('Position',[0 0 450 375]); hold on; 
for subj=1:13
    plot(flip(complexity),flip(squeeze(trial_sweep_bySubject(:,subj))),...
        'color',[clrs.subjects(subj,:),0.7],'linewidth',2)
end

movegui(gcf,'center'); set(gcf,'color','w','InvertHardCopy','off'); 
set(gca,'color','w','fontsize',24,'Tickdir','out','Ticklength',[.03 .03]); 
xticks([0 3 6]); xlim([-1 7]); xlabel('Arena complexity'); ylabel('% trials with sweeps')

%% Linear mixed effects model: fraction of trials with sweeps

[fixed,random,R_vals,P_vals]=LME_complexity(complexity,trial_sweep_bySubject);
