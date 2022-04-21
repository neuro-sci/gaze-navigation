function f1h_velocity_trace(blocks)
%% Plot an example velocity trace

arnum=1; subject=15; trial=3; clrs=def_colors; cmap=clrs.paradise;
velocity=abs(blocks{arnum}.continuous{subject}{trial}.dpos);
% Moving average kernel = 50 frames. Frame rate is 90 Hz.
v_smoothed=90*movmean(velocity,50); subjvec=[2,4,6,9,10,11,13,14,15,16,17,20,21]; 
trial_max_velocity=nan(5,13,60); trial_avg_velocity=nan(5,13,60);

start_move=blocks{arnum}.discrete{subject}(trial).start_move;
stop_move=blocks{arnum}.discrete{subject}(trial).stop_move;
detected=blocks{arnum}.discrete{subject}(trial).detect_frame;
time=blocks{arnum}.continuous{subject}{trial}.trialTime;

%% Plot
figure('position',[0 0 600 350]); hold on
% There is some noise in the joystick input, and thus velocity is not
% precisely zero at all times. However, for illustration, the velocity
% prior to target detection is plotted as zero because it is effectively zero.
v_smoothed(1:detected)=0; scatter(time,v_smoothed,12,time,'filled')
xline(time(detected),'--','color',clrs.red,'linewidth',2)
xline(time(start_move),'--','color',clrs.red,'linewidth',2)
xline(time(stop_move),'--','color',clrs.red,'linewidth',2)

%% Format
movegui(gcf,'center')
set(gca,'color','w','fontsize',24,'Tickdir','out','Ticklength',[.03 .03],'xtick',[]);
set(gcf,'color','w','InvertHardCopy','off'); 
xlim([0 blocks{arnum}.continuous{subject}{trial}.trialTime(end)]);
colormap(flipud(cmap)); c=colorbar; c.Ticks=[]; 
xlabel('Time'); ylabel('Velocity (m/s)');

%% Compute stats: average and max movement velocity

for arnum=1:5
    for subj=1:13
        subject=subjvec(subj);
        for trial=1:size(blocks{arnum}.continuous{subject},2)
            start_move=blocks{arnum}.discrete{subject}(trial).start_move;
            stop_move=blocks{arnum}.discrete{subject}(trial).stop_move;
            
            if ~isnan(start_move) && ~isnan(stop_move)
                trial_avg_velocity(arnum,subj,trial)=90*...
                    mean(abs(blocks{arnum}.continuous{subject}{trial}.dpos(start_move:stop_move)),'omitnan');
                trial_max_velocity(arnum,subj,trial)=90*...
                    max(abs(blocks{arnum}.continuous{subject}{trial}.dpos(start_move:stop_move)),[],'all','omitnan');
            elseif ~isnan(start_move)
                trial_avg_velocity(arnum,subj,trial)=90*...
                    mean(abs(blocks{arnum}.continuous{subject}{trial}.dpos(start_move:end)),'omitnan');
                trial_max_velocity(arnum,subj,trial)=90*...
                    max(abs(blocks{arnum}.continuous{subject}{trial}.dpos(start_move:end)),[],'all','omitnan');
            end
        end
    end
end

% Greater velocities than 6 m/s indicates technical glitch
abnormal_velocity=sum(trial_max_velocity>5,'all','omitnan')/nnz(~isnan(trial_max_velocity));
disp(['technical glitches leading to above-normal velocities occured in ',num2str(100*abnormal_velocity),...
    '% of trials'])

max_all_velocity=max(trial_max_velocity(trial_max_velocity<5),[],'all','omitnan');
disp(['the maximum subject velocity is ',num2str(max_all_velocity)])
percentile75=prctile(trial_max_velocity,97.5,'all');
disp(['the 97.5th percentile in subject velocity is ',num2str(percentile75)])

mean_velocity=mean(trial_avg_velocity,'all','omitnan');
velocity_STD=nan(13,1);
for subj=1:13
    velocity_STD(subj)=mean(trial_avg_velocity(:,subj,:),'all','omitnan');
end
velocity_STD=std(velocity_STD);
disp(['the average velocity is: ',num2str(mean_velocity),' +/- ',...
    num2str(velocity_STD)])
