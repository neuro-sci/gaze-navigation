function s9f_sweep_saccade_rate(blocks)
%% Quantify the average rate of saccades per forward and backward sweep
% during pre-movement and movement. 
% NOTE: Only trials skipped by the subject were excluded from this analysis
% NOTE: Error bars represent standard error across subjects

clrs=def_colors; subjvec=[2,4,6,9,10,11,13,14,15,16,17,20,21];
rate_forward_premove=nan(5,13,60); rate_forward_move=nan(5,13,60);
rate_backward_premove=nan(5,13,60); rate_backward_move=nan(5,13,60);
rate_nosweep_premove=nan(5,13,60); rate_nosweep_move=nan(5,13,60);
rate_forward_premove_byArena=nan(5,1); rate_forward_move_byArena=nan(5,1);
rate_backward_premove_byArena=nan(5,1); rate_backward_move_byArena=nan(5,1);
rate_nosweep_premove_byArena=nan(5,1); rate_nosweep_move_byArena=nan(5,1);
rate_forward_premove_bySubject=nan(5,13); rate_forward_move_bySubject=nan(5,13);
rate_backward_premove_bySubject=nan(5,13); rate_backward_move_bySubject=nan(5,13);
rate_nosweep_premove_bySubject=nan(5,13); rate_nosweep_move_bySubject=nan(5,13);
sterr_rate_forward_premove=nan(5,1); sterr_rate_forward_move=nan(5,1);
sterr_rate_backward_premove=nan(5,1); sterr_rate_backward_move=nan(5,1);
sterr_rate_nosweep_premove=nan(5,1); sterr_rate_nosweep_move=nan(5,1);
mean_centrality=nan(5,1);

%% Quantify the number of saccades

for arnum=1:5
    for subj=1:13
        subject=subjvec(subj); continuous=blocks{arnum}.continuous{subject};
        sweeps=blocks{arnum}.sweeps{subject};
        for trial=1:size(continuous,2)
            detected=blocks{arnum}.discrete{subject}(trial).detect_frame;
            start_move=blocks{arnum}.discrete{subject}(trial).start_move;
            time=continuous{trial}.trialTime;
            saccading=zeros(length(continuous{trial}.trialTime),1);
            is_sweeping=zeros(length(continuous{trial}.trialTime),1);
            
            % NOTE: x in MATLAB is z in Unity. y in MATLAB is -x in Unity.
            % Algorithmically define saccades by smoothing the relative eye
            % position with a moving average window of size 9 frames. Then
            % detect when speeds exceed a threshold of 200 deg/s.
            x=continuous{trial}.gazeX_noblink-continuous{trial}.SubPosZ; x=movmedian(x,9);
            y=continuous{trial}.gazeY_noblink+continuous{trial}.SubPosX; y=movmedian(y,9);
            z=continuous{trial}.hitPointsY-continuous{trial}.SubPosY; z=movmedian(z,9);
            alpha=atan2d(x,sqrt(y.^2+z.^2)); beta=atan2d(z,sqrt(x.^2+y.^2));
            eye_speeds=sqrt([0;diff(alpha)].^2+[0;diff(beta)].^2)*90;
            saccading([0;diff(eye_speeds>200)]==1)=1;
            
            % Sweeps whose midpoint is beyond the start of movement are
            % classified as movement sweeps.
            if ~isempty(sweeps{trial}.forward_sweeps), f1=0; f2=0; sf1=0; sf2=0; df1=0; df2=0;
                for sw=1:size(sweeps{trial}.forward_sweeps,1)
                    is_sweeping(sweeps{trial}.forward_sweeps(sw,1):...
                        sweeps{trial}.forward_sweeps(sw,2))=1;
                    if ~isnan(start_move) && sweeps{trial}.forward_sweeps(sw,1)+...
                            0.5*(sweeps{trial}.forward_sweeps(sw,2)-...
                            sweeps{trial}.forward_sweeps(sw,1))>=start_move
                        f2=f2+1; sf2=sf2+sum(saccading(sweeps{trial}.forward_sweeps(sw,1):...
                            sweeps{trial}.forward_sweeps(sw,2)));
                        df2=df2+time(sweeps{trial}.forward_sweeps(sw,2))-...
                            time(sweeps{trial}.forward_sweeps(sw,1));
                    elseif sweeps{trial}.forward_sweeps(sw,1)+...
                            0.5*(sweeps{trial}.forward_sweeps(sw,2)-...
                            sweeps{trial}.forward_sweeps(sw,1))>=detected
                        f1=f1+1; sf1=sf1+sum(saccading(sweeps{trial}.forward_sweeps(sw,1):...
                            sweeps{trial}.forward_sweeps(sw,2)));
                        df1=df1+time(sweeps{trial}.forward_sweeps(sw,2))-...
                            time(sweeps{trial}.forward_sweeps(sw,1));
                    end     
                end
                if f1>0, rate_forward_premove(arnum,subj,trial)=sf1/df1; end
                if f2>0, rate_forward_move(arnum,subj,trial)=sf2/df2; end
            end
            if ~isempty(sweeps{trial}.backward_sweeps), b1=0; b2=0; sb1=0; sb2=0; db1=0; db2=0;
                for sw=1:size(sweeps{trial}.backward_sweeps,1)
                    is_sweeping(sweeps{trial}.backward_sweeps(sw,1):...
                        sweeps{trial}.backward_sweeps(sw,2))=1;
                    if ~isnan(start_move) && sweeps{trial}.backward_sweeps(sw,1)+...
                            0.5*(sweeps{trial}.backward_sweeps(sw,2)-...
                            sweeps{trial}.backward_sweeps(sw,1))>=start_move
                        b2=b2+1; sb2=sb2+sum(saccading(sweeps{trial}.backward_sweeps(sw,1):...
                            sweeps{trial}.backward_sweeps(sw,2)));
                        db2=db2+time(sweeps{trial}.backward_sweeps(sw,2))-...
                            time(sweeps{trial}.backward_sweeps(sw,1));
                    elseif sweeps{trial}.backward_sweeps(sw,1)+...
                            0.5*(sweeps{trial}.backward_sweeps(sw,2)-...
                            sweeps{trial}.backward_sweeps(sw,1))>=detected
                        b1=b1+1; sb1=sb1+sum(saccading(sweeps{trial}.backward_sweeps(sw,1):...
                            sweeps{trial}.backward_sweeps(sw,2)));
                        db1=db1+time(sweeps{trial}.backward_sweeps(sw,2))-...
                            time(sweeps{trial}.backward_sweeps(sw,1));
                    end 
                end
                if b1>0, rate_backward_premove(arnum,subj,trial)=sb1/db1; end
                if b2>0, rate_backward_move(arnum,subj,trial)=sb2/db2; end
            end
            % The frame rate is 90 Hz.
            rate_nosweep_premove(arnum,subj,trial)=90*sum(is_sweeping==0 & ...
                saccading==1 & time<time(detected))/sum(is_sweeping==0 & time<time(detected));
            rate_nosweep_move(arnum,subj,trial)=90*sum(is_sweeping==0 & ...
                saccading==1 & time>=time(detected))/sum(is_sweeping==0 & time>=time(detected));
        end
    end
    G=graph(blocks{arnum}.arena.neighbor); C=centrality(G,'closeness')*149;
    mean_centrality(arnum)=mean(C);
end

%% Remove skipped trials, compute averages and standard deviations

ind=exclude_skipped_trials(blocks);
rate_forward_premove(ind)=NaN; rate_forward_move(ind)=NaN;
rate_backward_premove(ind)=NaN; rate_backward_move(ind)=NaN;
rate_nosweep_premove(ind)=NaN; rate_nosweep_move(ind)=NaN;

for arnum=1:5
    for subj=1:13
        rate_forward_premove_bySubject(arnum,subj)=mean(squeeze(rate_forward_premove(arnum,subj,:)),'omitnan');
        rate_forward_move_bySubject(arnum,subj)=mean(squeeze(rate_forward_move(arnum,subj,:)),'omitnan');
        rate_backward_premove_bySubject(arnum,subj)=mean(squeeze(rate_backward_premove(arnum,subj,:)),'omitnan');
        rate_backward_move_bySubject(arnum,subj)=mean(squeeze(rate_backward_move(arnum,subj,:)),'omitnan');
        rate_nosweep_premove_bySubject(arnum,subj)=mean(squeeze(rate_nosweep_premove(arnum,subj,:)),'omitnan');
        rate_nosweep_move_bySubject(arnum,subj)=mean(squeeze(rate_nosweep_move(arnum,subj,:)),'omitnan');
    end
    
    rate_forward_premove_byArena(arnum)=mean(squeeze(rate_forward_premove(arnum,:,:)),'all','omitnan');
    rate_forward_move_byArena(arnum)=mean(squeeze(rate_forward_move(arnum,:,:)),'all','omitnan');
    rate_backward_premove_byArena(arnum)=mean(squeeze(rate_backward_premove(arnum,:,:)),'all','omitnan');
    rate_backward_move_byArena(arnum)=mean(squeeze(rate_backward_move(arnum,:,:)),'all','omitnan');
    rate_nosweep_premove_byArena(arnum)=mean(squeeze(rate_nosweep_premove(arnum,:,:)),'all','omitnan');
    rate_nosweep_move_byArena(arnum)=mean(squeeze(rate_nosweep_move(arnum,:,:)),'all','omitnan');
    
    sterr_rate_forward_premove(arnum)=std(squeeze(rate_forward_premove_bySubject(arnum,:)),'omitnan')/sqrt(13);
    sterr_rate_forward_move(arnum)=std(squeeze(rate_forward_move_bySubject(arnum,:)),'omitnan')/sqrt(13);
    sterr_rate_backward_premove(arnum)=std(squeeze(rate_backward_premove_bySubject(arnum,:)),'omitnan')/sqrt(13);
    sterr_rate_backward_move(arnum)=std(squeeze(rate_backward_move_bySubject(arnum,:)),'omitnan')/sqrt(13);
    sterr_rate_nosweep_premove(arnum)=std(squeeze(rate_nosweep_premove_bySubject(arnum,:)),'omitnan')/sqrt(13);
    sterr_rate_nosweep_move(arnum)=std(squeeze(rate_nosweep_move_bySubject(arnum,:)),'omitnan')/sqrt(13);
end

%% Plot saccade rate pre-movement

figure('position',[0 0 450 375]); hold on
complexity=100*(-mean_centrality+0.1115);
plot(complexity(1:4),rate_forward_premove_byArena(1:4),'color','k')
plot(complexity(1:4),rate_backward_premove_byArena(1:4),'color','k')
plot(complexity(1:4),rate_nosweep_premove_byArena(1:4),'color','k')

errorbar(complexity(1:4),rate_forward_premove_byArena(1:4),...
    sterr_rate_forward_premove(1:4),'LineStyle','none','color','k','CapSize',0)
errorbar(complexity(1:4),rate_backward_premove_byArena(1:4),...
    sterr_rate_backward_premove(1:4),'LineStyle','none','color','k','CapSize',0)
errorbar(complexity(1:4),rate_nosweep_premove_byArena(1:4),...
    sterr_rate_nosweep_premove(1:4),'LineStyle','none','color','k','CapSize',0)

scatter(complexity(1:4),rate_forward_premove_byArena(1:4),300,...
    'markerfacecolor',clrs.green,'markeredgecolor','none')
scatter(complexity(1:4),rate_backward_premove_byArena(1:4),300,...
    'markerfacecolor',clrs.red,'markeredgecolor','none')
scatter(complexity(1:4),rate_nosweep_premove_byArena(1:4),300,...
    'markerfacecolor',clrs.gray,'markeredgecolor','none')

movegui(gcf,'center')
set(gca,'color','w','fontsize',24,'Tickdir','out','Ticklength',[.03 .03]); 
set(gcf,'color','w','InvertHardCopy','off'); 
xticks([2 4 6]); xlim([1 7]); 
xlabel('Arena complexity'); ylabel('Saccade rate (/s)')

%% Plot saccade rate during movement

figure('position',[0 0 450 375]); hold on
plot(complexity(1:4),rate_forward_move_byArena(1:4),'color','k')
plot(complexity(1:4),rate_backward_move_byArena(1:4),'color','k')
plot(complexity(1:4),rate_nosweep_move_byArena(1:4),'color','k')

scatter(complexity(1:4),rate_forward_move_byArena(1:4),300,...
    'markerfacecolor',clrs.green,'markeredgecolor','none')
scatter(complexity(1:4),rate_backward_move_byArena(1:4),300,...
    'markerfacecolor',clrs.red,'markeredgecolor','none')
scatter(complexity(1:4),rate_nosweep_move_byArena(1:4),300,...
    'markerfacecolor',clrs.gray,'markeredgecolor','none')

errorbar(complexity(1:4),rate_forward_move_byArena(1:4),...
    sterr_rate_forward_move(1:4),'LineStyle','none','color','k','CapSize',0)
errorbar(complexity(1:4),rate_backward_move_byArena(1:4),...
    sterr_rate_backward_move(1:4),'LineStyle','none','color','k','CapSize',0)
errorbar(complexity(1:4),rate_nosweep_move_byArena(1:4),...
    sterr_rate_nosweep_move(1:4),'LineStyle','none','color','k','CapSize',0)

movegui(gcf,'center')
set(gca,'color','w','fontsize',24,'Tickdir','out','Ticklength',[.03 .03]); 
set(gcf,'color','w','InvertHardCopy','off'); 
xticks([2 4 6]); xlim([1 7]); 
xlabel('Arena complexity'); ylabel('Saccade rate (/s)')
