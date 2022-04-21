function s10c_first_sweep_time(blocks)
%% Find the average time until the first sweep if the sweep is forward vs. backwards
% Also fit linear mixed effects models
% NOTE: Only trials skipped by the subject were excluded from this analysis
% NOTE: Error bars represent standard error across subjects

clrs=def_colors; subjvec=[2,4,6,9,10,11,13,14,15,16,17,20,21];
first_forward=nan(5,13,60); first_backward=nan(5,13,60);
forward_byArena=nan(5,1); backward_byArena=nan(5,1);
forward_bySubject=nan(5,13); backward_bySubject=nan(5,13);
sterr_forward=nan(5,1); sterr_backward=nan(5,1); mean_centrality=nan(5,1);

%% Find the time to first sweep

for arnum=1:5
    for subj=1:13
        subject=subjvec(subj); continuous=blocks{arnum}.continuous{subject};
        sweeps=blocks{arnum}.sweeps{subject};
        for trial=1:size(continuous,2)
            time=continuous{trial}.trialTime;
            detected=blocks{arnum}.discrete{subject}(trial).detect_frame;
            first_forward_sweep=NaN; first_backward_sweep=NaN;
            
            % Because sweeps are algorithmically labeled, it is possible
            % for a sweep to begin prior to target detection. Sweeps which
            % begin before target detection will be excluded from this
            % analysis.
            if ~isempty(sweeps{trial}.forward_sweeps)
                sw=find(sweeps{trial}.forward_sweeps(:,1)>=detected,1,'first');
                if ~isempty(sw)
                    first_forward_sweep=sweeps{trial}.forward_sweeps(sw,1);
                end
            end
            if ~isempty(sweeps{trial}.backward_sweeps)
                sw=find(sweeps{trial}.backward_sweeps(:,1)>=detected,1,'first');
                if ~isempty(sw)
                    first_backward_sweep=sweeps{trial}.backward_sweeps(sw,1);
                end
            end
            
            events=[first_forward_sweep,first_backward_sweep,1000^2];
            [~,idx]=sort(events);
            switch idx(1)
                case 1, first_forward(arnum,subj,trial)=time(first_forward_sweep)-time(detected);
                case 2, first_backward(arnum,subj,trial)=time(first_backward_sweep)-time(detected);
            end
        end
    end
    G=graph(blocks{arnum}.arena.neighbor); C=centrality(G,'closeness')*149; 
    mean_centrality(arnum)=mean(C); 
end

%% Compute averages and standard deviations

ind=exclude_skipped_trials(blocks); first_forward(ind)=NaN; first_backward(ind)=NaN;
for arnum=1:5
    for subj=1:13
        forward_bySubject(arnum,subj)=mean(squeeze(first_forward(arnum,subj,:)),'omitnan');
        backward_bySubject(arnum,subj)=mean(squeeze(first_backward(arnum,subj,:)),'omitnan');
    end
    forward_byArena(arnum)=mean(squeeze(first_forward(arnum,:,:)),'all','omitnan');
    backward_byArena(arnum)=mean(squeeze(first_backward(arnum,:,:)),'all','omitnan');
    sterr_forward(arnum)=std(forward_bySubject(arnum,:),'omitnan')/sqrt(13);
    sterr_backward(arnum)=std(backward_bySubject(arnum,:),'omitnan')/sqrt(13);
end

%% Make scatter plot

figure('position',[0 0 450 375]); hold on
complexity=100*(-mean_centrality+0.1115);
plot(complexity,forward_byArena,'color','k')
plot(complexity,backward_byArena,'color','k')
errorbar(complexity,forward_byArena,...
    sterr_forward,'LineStyle','none','color','k','CapSize',0)
errorbar(complexity,backward_byArena,...
    sterr_backward,'LineStyle','none','color','k','CapSize',0)
scatter(complexity,forward_byArena,300,...
    'markerfacecolor',clrs.green,'markeredgecolor','none')
scatter(complexity,backward_byArena,300,...
    'markerfacecolor',clrs.red,'markeredgecolor','none')

movegui(gcf,'center')
set(gca,'color','w','fontsize',24,'Tickdir','out','Ticklength',[.03 .03]); 
set(gcf,'color','w','InvertHardCopy','off'); 
xticks([0 3 6]); xlim([-1 7]); yticks([0 2 4 6]); ylim([0 6])
xlabel('Arena complexity'); ylabel('Time (s)')

%% Make CDF

figure('position',[0 0 450 375]); hold on
facecolor=[clrs.prim2mint1;clrs.prim2mint2;clrs.prim2mint3;clrs.prim2mint4;clrs.prim2mint5];
for arnum=1:4
    time_to_first_sweep=[squeeze(first_forward(arnum,:,:));squeeze(first_backward(arnum,:,:))];
    [f,x,flo,fup]=ecdf(time_to_first_sweep(:)); x(isnan(flo) | isnan(fup))=[];
    f(isnan(flo) | isnan(fup))=[]; flo(isnan(fup))=[]; fup(isnan(fup))=[];
    fup(isnan(flo))=[]; flo(isnan(flo))=[];
    if length(x)>1
        FILL=fill([x(2:end-1);flip(x(2:end-1));x(2)],...
            [flo(2:end-1);flip(fup(2:end-1));flo(2)],facecolor(arnum,:));
        set(FILL,'facealpha',0.35,'edgecolor','none')
        plot(x,f,'linewidth',2,'color',facecolor(arnum,:))
    end
end

movegui(gcf,'center')
set(gca,'color','w','fontsize',24,'Tickdir','out','Ticklength',[.03 .03]); 
set(gcf,'color','w','InvertHardCopy','off'); 
xticks([0 5 10 15]); xlim([0 15]); yticks([0.6 0.8 1]); ylim([0.5 1])
xlabel('Time (s)'); ylabel('CDF')

%% LME: trial-specific effects on time to first sweep: forward

[fixed_forward,random_forward,R_vals_forward,P_vals_forward]=linear_mixed_effects(blocks,first_forward,clrs.green);
ylabel('Relative effect');

%% LME: trial-specific effects on time to first sweep: backward

[fixed_backward,random_backward,R_vals_backward,P_vals_backward]=linear_mixed_effects(blocks,first_backward,clrs.red);
ylabel('Relative effect');
