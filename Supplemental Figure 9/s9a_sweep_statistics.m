function s9a_sweep_statistics(blocks)
%% Quantify the average speed and duration of forward and backward sweeps
% during pre-movement and movement. Also quantify the number of saccades.s9a_sweep_statistics(blocks)
% NOTE: Only trials skipped by the subject were excluded from this analysis
% NOTE: Error bars represent standard error across subjects
% NOTE: For these plots, the opne arena was excluded due to a low number of
% sweeps.

clrs=def_colors; subjvec=[2,4,6,9,10,11,13,14,15,16,17,20,21];
% Preallocate for sweep speed analysis
speed_forward_premove=nan(5,13,60); speed_forward_move=nan(5,13,60);
speed_backward_premove=nan(5,13,60); speed_backward_move=nan(5,13,60);
forward_premove_byArena=nan(5,1); forward_move_byArena=nan(5,1);
backward_premove_byArena=nan(5,1); backward_move_byArena=nan(5,1);
forward_premove_bySubject=nan(5,13); forward_move_bySubject=nan(5,13);
backward_premove_bySubject=nan(5,13); backward_move_bySubject=nan(5,13);
sterr_forward_premove=nan(5,1); sterr_backward_premove=nan(5,1);
sterr_forward_move=nan(5,1); sterr_backward_move=nan(5,1);

% Preallocate for sweep duration
duration_forward_premove=nan(5,13,60); duration_forward_move=nan(5,13,60);
duration_backward_premove=nan(5,13,60); duration_backward_move=nan(5,13,60);
duration_forward_premove_byArena=nan(5,1); duration_forward_move_byArena=nan(5,1);
duration_backward_premove_byArena=nan(5,1); duration_backward_move_byArena=nan(5,1);
duration_forward_premove_bySubject=nan(5,13); duration_forward_move_bySubject=nan(5,13);
duration_backward_premove_bySubject=nan(5,13); duration_backward_move_bySubject=nan(5,13);
sterr_duration_forward_premove=nan(5,1); sterr_duration_forward_move=nan(5,1);
sterr_duration_backward_premove=nan(5,1); sterr_duration_backward_move=nan(5,1);
mean_centrality=nan(5,1);

% Preallocate for number of saccades analysis
nsaccades_forward_premove=nan(5,13,60); nsaccades_forward_move=nan(5,13,60);
nsaccades_backward_premove=nan(5,13,60); nsaccades_backward_move=nan(5,13,60);
nsaccades_forward_premove_byArena=nan(5,1); nsaccades_forward_move_byArena=nan(5,1);
nsaccades_backward_premove_byArena=nan(5,1); nsaccades_backward_move_byArena=nan(5,1);
nsaccades_forward_premove_bySubject=nan(5,13); nsaccades_forward_move_bySubject=nan(5,13);
nsaccades_backward_premove_bySubject=nan(5,13); nsaccades_backward_move_bySubject=nan(5,13);
nsaccades_sterr_forward_premove=nan(5,1); nsaccades_sterr_backward_premove=nan(5,1);
nsaccades_sterr_forward_move=nan(5,1); nsaccades_sterr_backward_move=nan(5,1);

%% Quantify the duration and speed of sweeps

for arnum=1:5
    for subj=1:13
        subject=subjvec(subj); continuous=blocks{arnum}.continuous{subject};
        sweeps=blocks{arnum}.sweeps{subject};
        for trial=1:size(continuous,2)
            detected=blocks{arnum}.discrete{subject}(trial).detect_frame;
            start_move=blocks{arnum}.discrete{subject}(trial).start_move;
            time=continuous{trial}.trialTime;
            x=continuous{trial}.gazeX_noblink;
            y=continuous{trial}.gazeY_noblink;
            eye_dist_traveled=sqrt([0;diff(x)].^2+[0;diff(y)].^2);
            
            % Sweeps whose midpoint is beyond the start of movement are
            % classified as movement sweeps.
            if ~isempty(sweeps{trial}.forward_sweeps), f1=0; f2=0; nf1=0; nf2=0; df1=0; df2=0;
                for sw=1:size(sweeps{trial}.forward_sweeps,1)
                    if ~isnan(start_move) && sweeps{trial}.forward_sweeps(sw,1)+...
                            0.5*(sweeps{trial}.forward_sweeps(sw,2)-...
                            sweeps{trial}.forward_sweeps(sw,1))>=start_move
                        f2=f2+sum(eye_dist_traveled(sweeps{trial}.forward_sweeps(sw,1):...
                            sweeps{trial}.forward_sweeps(sw,2)),'omitnan');
                        nf2=nf2+1; df2=df2+time(sweeps{trial}.forward_sweeps(sw,2))-...
                            time(sweeps{trial}.forward_sweeps(sw,1));
                    elseif sweeps{trial}.forward_sweeps(sw,2)>=detected
%                     elseif sweeps{trial}.forward_sweeps(sw,1)+...
%                             0.5*(sweeps{trial}.forward_sweeps(sw,2)-...
%                             sweeps{trial}.forward_sweeps(sw,1))>=detected
                        f1=f1+sum(eye_dist_traveled(sweeps{trial}.forward_sweeps(sw,1):...
                            sweeps{trial}.forward_sweeps(sw,2)),'omitnan');
                        nf1=nf1+1; df1=df1+time(sweeps{trial}.forward_sweeps(sw,2))-...
                            time(sweeps{trial}.forward_sweeps(sw,1));
                    end     
                end
                if f1>0, speed_forward_premove(arnum,subj,trial)=f1/df1;
                    duration_forward_premove(arnum,subj,trial)=df1/nf1; end
                if f2>0, speed_forward_move(arnum,subj,trial)=f2/df2; 
                    duration_forward_move(arnum,subj,trial)=df2/nf2; end
            end
            if ~isempty(sweeps{trial}.backward_sweeps), b1=0; b2=0; nb1=0; nb2=0; db1=0; db2=0;
                for sw=1:size(sweeps{trial}.backward_sweeps,1)
                    if ~isnan(start_move) && sweeps{trial}.backward_sweeps(sw,1)+...
                            0.5*(sweeps{trial}.backward_sweeps(sw,2)-...
                            sweeps{trial}.backward_sweeps(sw,1))>=start_move
                        b2=b2+sum(eye_dist_traveled(sweeps{trial}.backward_sweeps(sw,1):...
                            sweeps{trial}.backward_sweeps(sw,2)),'omitnan');
                        nb2=nb2+1; db2=db2+time(sweeps{trial}.backward_sweeps(sw,2))-...
                            time(sweeps{trial}.backward_sweeps(sw,1));
                    elseif sweeps{trial}.backward_sweeps(sw,2)>=detected
%                     elseif sweeps{trial}.backward_sweeps(sw,1)+...
%                             0.5*(sweeps{trial}.backward_sweeps(sw,2)-...
%                             sweeps{trial}.backward_sweeps(sw,1))>=detected
                        b1=b1+sum(eye_dist_traveled(sweeps{trial}.backward_sweeps(sw,1):...
                            sweeps{trial}.backward_sweeps(sw,2)),'omitnan');
                        nb1=nb1+1; db1=db1+time(sweeps{trial}.backward_sweeps(sw,2))-...
                            time(sweeps{trial}.backward_sweeps(sw,1));
                    end 
                end
                if b1>0, speed_backward_premove(arnum,subj,trial)=b1/db1; 
                    duration_backward_premove(arnum,subj,trial,1)=db1/nb1; end
                if b2>0, speed_backward_move(arnum,subj,trial)=b2/db2; 
                    duration_backward_move(arnum,subj,trial,1)=db2/nb2; end
            end
        end
    end
    G=graph(blocks{arnum}.arena.neighbor); C=centrality(G,'closeness')*149;
    mean_centrality(arnum)=mean(C);
end

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
                if f1>0, nsaccades_forward_premove(arnum,subj,trial)=sf1/f1; end
                if f2>0, nsaccades_forward_move(arnum,subj,trial)=sf2/f2; end
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
                if b1>0, nsaccades_backward_premove(arnum,subj,trial)=sb1/b1; end
                if b2>0, nsaccades_backward_move(arnum,subj,trial)=sb2/b2; end
            end
        end
    end
end

%% Remove skipped trials, compute averages and standard deviations

ind=exclude_skipped_trials(blocks);
speed_forward_premove(ind)=NaN; speed_forward_move(ind)=NaN; 
speed_backward_premove(ind)=NaN; speed_backward_move(ind)=NaN; 
duration_forward_premove(ind)=NaN; duration_forward_move(ind)=NaN;
duration_backward_premove(ind)=NaN; duration_backward_move(ind)=NaN;
nsaccades_forward_premove(ind)=NaN; nsaccades_forward_move(ind)=NaN; 
nsaccades_backward_premove(ind)=NaN; nsaccades_backward_move(ind)=NaN; 

for arnum=1:5
    for subj=1:13
        forward_premove_bySubject(arnum,subj)=mean(squeeze(speed_forward_premove(arnum,subj,:)),'omitnan');
        forward_move_bySubject(arnum,subj)=mean(squeeze(speed_forward_move(arnum,subj,:)),'omitnan');
        backward_premove_bySubject(arnum,subj)=mean(squeeze(speed_backward_premove(arnum,subj,:)),'omitnan');
        backward_move_bySubject(arnum,subj)=mean(squeeze(speed_backward_move(arnum,subj,:)),'omitnan');
        
        duration_forward_premove_bySubject(arnum,subj)=mean(squeeze(duration_forward_premove(arnum,subj,:)),'omitnan');
        duration_forward_move_bySubject(arnum,subj)=mean(squeeze(duration_forward_move(arnum,subj,:)),'omitnan');
        duration_backward_premove_bySubject(arnum,subj)=mean(squeeze(duration_backward_premove(arnum,subj,:)),'omitnan');
        duration_backward_move_bySubject(arnum,subj)=mean(squeeze(duration_backward_move(arnum,subj,:)),'omitnan');
    end
    forward_premove_byArena(arnum)=mean(squeeze(speed_forward_premove(arnum,:,:)),'all','omitnan');
    forward_move_byArena(arnum)=mean(squeeze(speed_forward_move(arnum,:,:)),'all','omitnan');
    backward_premove_byArena(arnum)=mean(squeeze(speed_backward_premove(arnum,:,:)),'all','omitnan');
    backward_move_byArena(arnum)=mean(squeeze(speed_backward_move(arnum,:,:)),'all','omitnan');
    
    duration_forward_premove_byArena(arnum)=mean(squeeze(duration_forward_premove(arnum,:,:)),'all','omitnan');
    duration_forward_move_byArena(arnum)=mean(squeeze(duration_forward_move(arnum,:,:)),'all','omitnan');
    duration_backward_premove_byArena(arnum)=mean(squeeze(duration_backward_premove(arnum,:,:)),'all','omitnan');
    duration_backward_move_byArena(arnum)=mean(squeeze(duration_backward_move(arnum,:,:)),'all','omitnan');
    
    sterr_forward_premove(arnum)=std(squeeze(forward_premove_bySubject(arnum,:)),'omitnan')/sqrt(13);
    sterr_forward_move(arnum)=std(squeeze(forward_move_bySubject(arnum,:)),'omitnan')/sqrt(13);
    sterr_backward_premove(arnum)=std(squeeze(backward_premove_bySubject(arnum,:)),'omitnan')/sqrt(13);
    sterr_backward_move(arnum)=std(squeeze(backward_move_bySubject(arnum,:)),'omitnan')/sqrt(13);
    
    sterr_duration_forward_premove(arnum)=std(squeeze(duration_forward_premove_bySubject(arnum,:)),'omitnan')/sqrt(13);
    sterr_duration_forward_move(arnum)=std(squeeze(duration_forward_move_bySubject(arnum,:)),'omitnan')/sqrt(13);
    sterr_duration_backward_premove(arnum)=std(squeeze(duration_backward_premove_bySubject(arnum,:)),'omitnan')/sqrt(13);
    sterr_duration_backward_move(arnum)=std(squeeze(duration_backward_move_bySubject(arnum,:)),'omitnan')/sqrt(13);
end

for arnum=1:5
    for subj=1:13
        nsaccades_forward_premove_bySubject(arnum,subj)=mean(squeeze(nsaccades_forward_premove(arnum,subj,:)),'omitnan');
        nsaccades_forward_move_bySubject(arnum,subj)=mean(squeeze(nsaccades_forward_move(arnum,subj,:)),'omitnan');
        nsaccades_backward_premove_bySubject(arnum,subj)=mean(squeeze(nsaccades_backward_premove(arnum,subj,:)),'omitnan');
        nsaccades_backward_move_bySubject(arnum,subj)=mean(squeeze(nsaccades_backward_move(arnum,subj,:)),'omitnan');
    end
    nsaccades_forward_premove_byArena(arnum)=mean(squeeze(nsaccades_forward_premove(arnum,:,:)),'all','omitnan');
    nsaccades_forward_move_byArena(arnum)=mean(squeeze(nsaccades_forward_move(arnum,:,:)),'all','omitnan');
    nsaccades_backward_premove_byArena(arnum)=mean(squeeze(nsaccades_backward_premove(arnum,:,:)),'all','omitnan');
    nsaccades_backward_move_byArena(arnum)=mean(squeeze(nsaccades_backward_move(arnum,:,:)),'all','omitnan');
    
    nsaccades_sterr_forward_premove(arnum)=std(squeeze(nsaccades_forward_premove_bySubject(arnum,:)),'omitnan')/sqrt(13);
    nsaccades_sterr_forward_move(arnum)=std(squeeze(nsaccades_forward_move_bySubject(arnum,:)),'omitnan')/sqrt(13);
    nsaccades_sterr_backward_premove(arnum)=std(squeeze(nsaccades_backward_premove_bySubject(arnum,:)),'omitnan')/sqrt(13);
    nsaccades_sterr_backward_move(arnum)=std(squeeze(nsaccades_backward_move_bySubject(arnum,:)),'omitnan')/sqrt(13);
end

%% Plot average speed of forward sweeps

figure('position',[0 0 450 375]); hold on
complexity=100*(-mean_centrality+0.1115);
plot(complexity(1:4),forward_premove_byArena(1:4),'color','k')
plot(complexity(1:4),forward_move_byArena(1:4),'color','k')

scatter(complexity(1:4),forward_premove_byArena(1:4),300,...
    'markerfacecolor',clrs.gold,'markeredgecolor','none')
scatter(complexity(1:4),forward_move_byArena(1:4),300,...
    'markerfacecolor',clrs.blue,'markeredgecolor','none')

errorbar(complexity(1:4),forward_premove_byArena(1:4),...
    sterr_forward_premove(1:4),'LineStyle','none','color','k','CapSize',0)
errorbar(complexity(1:4),forward_move_byArena(1:4),...
    sterr_forward_move(1:4),'LineStyle','none','color','k','CapSize',0)

movegui(gcf,'center')
set(gca,'color','w','fontsize',24,'Tickdir','out','Ticklength',[.03 .03]); 
set(gcf,'color','w','InvertHardCopy','off'); 
xticks([2 4 6]); xlim([1 7]); 
xlabel('Arena complexity'); ylabel('Speed (m/s)')

%% Plot average speed of backward sweeps

figure('position',[0 0 450 375]); hold on
plot(complexity(1:4),backward_premove_byArena(1:4),'color','k')
plot(complexity(1:4),backward_move_byArena(1:4),'color','k')

scatter(complexity(1:4),backward_premove_byArena(1:4),300,...
    'markerfacecolor',clrs.gold,'markeredgecolor','none')
scatter(complexity(1:4),backward_move_byArena(1:4),300,...
    'markerfacecolor',clrs.blue,'markeredgecolor','none')

errorbar(complexity(1:4),backward_premove_byArena(1:4),...
    sterr_backward_premove(1:4),'LineStyle','none','color','k','CapSize',0)
errorbar(complexity(1:4),backward_move_byArena(1:4),...
    sterr_backward_move(1:4),'LineStyle','none','color','k','CapSize',0)

movegui(gcf,'center')
set(gca,'color','w','fontsize',24,'Tickdir','out','Ticklength',[.03 .03]); 
set(gcf,'color','w','InvertHardCopy','off'); 
xticks([2 4 6]); xlim([1 7]); 
xlabel('Arena complexity'); ylabel('Speed (m/s)')

%% Plot duration of forward sweeps

figure('position',[0 0 450 375]); hold on
plot(complexity(1:4),duration_forward_premove_byArena(1:4),'color','k')
plot(complexity(1:4),duration_forward_move_byArena(1:4),'color','k')

scatter(complexity(1:4),duration_forward_premove_byArena(1:4),300,...
    'markerfacecolor',clrs.gold,'markeredgecolor','none')
scatter(complexity(1:4),duration_forward_move_byArena(1:4),300,...
    'markerfacecolor',clrs.blue,'markeredgecolor','none')

errorbar(complexity(1:4),duration_forward_premove_byArena(1:4),...
    sterr_duration_forward_premove(1:4),'LineStyle','none','color','k','CapSize',0)
errorbar(complexity(1:4),duration_forward_move_byArena(1:4),...
    sterr_duration_forward_move(1:4),'LineStyle','none','color','k','CapSize',0)

movegui(gcf,'center')
set(gca,'color','w','fontsize',24,'Tickdir','out','Ticklength',[.03 .03]); 
set(gcf,'color','w','InvertHardCopy','off'); 
xticks([2 4 6]); xlim([1 7]); 
xlabel('Arena complexity'); ylabel('Duration (s)')

%% Plot duration of backward sweeps

figure('position',[0 0 450 375]); hold on
plot(complexity(1:4),duration_backward_premove_byArena(1:4),'color','k')
plot(complexity(1:4),duration_backward_move_byArena(1:4),'color','k')

scatter(complexity(1:4),duration_backward_premove_byArena(1:4),300,...
    'markerfacecolor',clrs.gold,'markeredgecolor','none')
scatter(complexity(1:4),duration_backward_move_byArena(1:4),300,...
    'markerfacecolor',clrs.blue,'markeredgecolor','none')

errorbar(complexity(1:4),duration_backward_premove_byArena(1:4),...
    sterr_duration_backward_premove(1:4),'LineStyle','none','color','k','CapSize',0)
errorbar(complexity(1:4),duration_backward_move_byArena(1:4),...
    sterr_duration_backward_move(1:4),'LineStyle','none','color','k','CapSize',0)

movegui(gcf,'center')
set(gca,'color','w','fontsize',24,'Tickdir','out','Ticklength',[.03 .03]); 
set(gcf,'color','w','InvertHardCopy','off'); 
xticks([2 4 6]); xlim([1 7]); 
xlabel('Arena complexity'); ylabel('Duration (s)')

%% Compute stats: speed of forward and backward sweeps

mean_forward=mean([speed_forward_premove(:);speed_forward_move(:)],'all','omitnan');
forward_STD=nan(13,1);
for subj=1:13
    forward_STD(subj)=mean([squeeze(speed_forward_premove(:,subj,:));...
        squeeze(speed_forward_move(:,subj,:))],'all','omitnan');
end
forward_STD=std(forward_STD);
disp(['speed of forward sweeps: ',num2str(mean_forward),' +/- ',num2str(forward_STD)])

mean_backward=mean([speed_backward_premove(:);speed_backward_move(:)],'all','omitnan');
backward_STD=nan(13,1);
for subj=1:13
    backward_STD(subj)=mean([squeeze(speed_backward_premove(:,subj,:));...
        squeeze(speed_backward_move(:,subj,:))],'all','omitnan');
end
backward_STD=std(backward_STD);
disp(['speed of backward sweeps: ',num2str(mean_backward),' +/- ',num2str(backward_STD)])

%% Plot number of saccades during forward sweeps

figure('position',[0 0 450 375]); hold on
complexity=100*(-mean_centrality+0.1115);
plot(complexity(1:4),nsaccades_forward_premove_byArena(1:4),'color','k')
plot(complexity(1:4),nsaccades_forward_move_byArena(1:4),'color','k')

scatter(complexity(1:4),nsaccades_forward_premove_byArena(1:4),300,...
    'markerfacecolor',clrs.gold,'markeredgecolor','none')
scatter(complexity(1:4),nsaccades_forward_move_byArena(1:4),300,...
    'markerfacecolor',clrs.blue,'markeredgecolor','none')

errorbar(complexity(1:4),nsaccades_forward_premove_byArena(1:4),...
    nsaccades_sterr_forward_premove(1:4),'LineStyle','none','color','k','CapSize',0)
errorbar(complexity(1:4),nsaccades_forward_move_byArena(1:4),...
    nsaccades_sterr_forward_move(1:4),'LineStyle','none','color','k','CapSize',0)

movegui(gcf,'center')
set(gca,'color','w','fontsize',24,'Tickdir','out','Ticklength',[.03 .03]); 
set(gcf,'color','w','InvertHardCopy','off'); 
xticks([2 4 6]); xlim([1 7]); 
xlabel('Arena complexity'); ylabel('# of saccades')

%% Plot number of saccades during backward sweeps

figure('position',[0 0 450 375]); hold on
plot(complexity(1:4),nsaccades_backward_premove_byArena(1:4),'color','k')
plot(complexity(1:4),nsaccades_backward_move_byArena(1:4),'color','k')

scatter(complexity(1:4),nsaccades_backward_premove_byArena(1:4),300,...
    'markerfacecolor',clrs.gold,'markeredgecolor','none')
scatter(complexity(1:4),nsaccades_backward_move_byArena(1:4),300,...
    'markerfacecolor',clrs.blue,'markeredgecolor','none')

errorbar(complexity(1:4),nsaccades_backward_premove_byArena(1:4),...
    nsaccades_sterr_backward_premove(1:4),'LineStyle','none','color','k','CapSize',0)
errorbar(complexity(1:4),nsaccades_backward_move_byArena(1:4),...
    nsaccades_sterr_backward_move(1:4),'LineStyle','none','color','k','CapSize',0)

movegui(gcf,'center')
set(gca,'color','w','fontsize',24,'Tickdir','out','Ticklength',[.03 .03]); 
set(gcf,'color','w','InvertHardCopy','off'); 
xticks([2 4 6]); xlim([1 7]); 
xlabel('Arena complexity'); ylabel('# of saccades')
