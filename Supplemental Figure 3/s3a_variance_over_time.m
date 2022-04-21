function s3a_variance_over_time(blocks)
%% Interpolate trials and find the variance of gaze across trials throughout
% the duration of the pre-move epoch
% NOTE: Trials skipped by the subjects were excluded from the analysis
% NOTE: Trials in which subjects did not move were excluded from the
% analysis

clrs=def_colors; subjvec=[2,4,6,9,10,11,13,14,15,16,17,20,21];
n_timepts_premove=200; % interpoloate all pre-movement periods to 200 time points
PREMOVE=nan(700,5,n_timepts_premove); % pre-allocate a matrix larger than
% the total number of trials in the entire experiment
PREMOVE_mean=nan(5,n_timepts_premove);
PREMOVE_bySubject=nan(13,5,n_timepts_premove);
sterr=nan(5,n_timepts_premove);
var_within_ntimepts=[61,53,45,37,29]; % sliding window size for taking variance
% -- this should always be an odd number. Have the option to choose
% different window sizes per arena
% NOTE: variance is taken prior to interpolation.

%% Loop over all arenas/subjects/trials

row=1; subj_rows=nan(13,5);
for arnum=1:5
    for subj=1:13
        subject=subjvec(subj); continuous=blocks{arnum}.continuous{subject};
        for trial=1:size(continuous,2)
            % Exclude skipped trials or trials in which subjects did not move
            if blocks{arnum}.discrete{subject}(trial).RewardZone==9 ...
                    || isnan(blocks{arnum}.discrete{subject}(trial).start_move) || ...
                    isempty(blocks{arnum}.discrete{subject}(trial).start_move)
                continue
            end
            detected=blocks{arnum}.discrete{subject}(trial).detect_frame;
            start_move=blocks{arnum}.discrete{subject}(trial).start_move;
            % Find the distance of gaze to the stopping location
            gazeX=continuous{trial}.gazeX_noblink;
            gazeY=continuous{trial}.gazeY_noblink;
            % Clip the gaze beyond the confines of the arena so that gaze
            % variance is not biased by outliers (when subjects look at the
            % sky, etc.)
            premove_len=start_move-detected+1; 
            gazeX(gazeX>25)=NaN; gazeY(gazeY>25)=NaN; gazevar=nan(premove_len,1);

            % REMOVE GAZE WITHIN 2 M FROM THE TRAJECTORY
            trajX=continuous{trial}.SubPosZ;
            trajY=-continuous{trial}.SubPosX;
            idx=find(sqrt((gazeX-trajX).^2+(gazeY-trajY).^2)<2);
            gazeX(idx)=NaN; gazeY(idx)=NaN;

            % Pad nans so that variance could be taken using a moving window
            gazeX=[nan(floor(var_within_ntimepts(arnum)/2),1);gazeX(detected:start_move);nan(floor(var_within_ntimepts(arnum)/2),1)];
            gazeY=[nan(floor(var_within_ntimepts(arnum)/2),1);gazeY(detected:start_move);nan(floor(var_within_ntimepts(arnum)/2),1)];
            for t=1:premove_len
                gazevar(t)=sqrt(var(gazeX(t:(t+var_within_ntimepts(arnum)-1)),'omitnan')+...
                    var(gazeY(t:(t+var_within_ntimepts(arnum)-1)),'omitnan'));
            end
            if (detected+floor(var_within_ntimepts(arnum)/2))+2 > (start_move-floor(var_within_ntimepts(arnum)/2))
                continue; end
            PREMOVE(row,arnum,:)=interp1((detected+floor(var_within_ntimepts(arnum)/2)):...
                (start_move-floor(var_within_ntimepts(arnum)/2)),gazevar((floor(var_within_ntimepts(arnum)/2)+1):...
                (premove_len-floor(var_within_ntimepts(arnum)/2))),linspace(detected+...
                floor(var_within_ntimepts(arnum)/2),start_move-floor(var_within_ntimepts(arnum)/2),n_timepts_premove));
            row=row+1;
        end
        subj_rows(subj,arnum)=row;
    end
    row=1; 
end

%% Calculate per-subject means in order to calculate standard deviations

subj_rows=[[0,0,0,0,0];subj_rows];
for arnum=1:5
    for subj=1:13
        PREMOVE_bySubject(subj,arnum,:)=mean(squeeze(PREMOVE((subj_rows(subj,arnum)+1):...
            subj_rows(subj+1,arnum),arnum,:)),'omitnan');
    end
    PREMOVE_mean(arnum,:)=mean(squeeze(PREMOVE_bySubject(:,arnum,:)),'omitnan');
    sterr(arnum,:)=std(squeeze(PREMOVE_bySubject(:,arnum,:)),'omitnan')/sqrt(13);
end

%% Plot

figure('position',[0 0 450 350]); hold on
colors=[clrs.prim2mint1;clrs.prim2mint2;clrs.prim2mint3;clrs.prim2mint4;clrs.prim2mint5];
for arnum=1:5
    % Error bounds
    h=fill([1:n_timepts_premove,flip([1:n_timepts_premove])]/n_timepts_premove,...
        [PREMOVE_mean(arnum,:)-sterr(arnum,:),flip([PREMOVE_mean(arnum,:)+sterr(arnum,:)])],...
        colors(arnum,:),'LineStyle','none'); set(h,'facealpha',.5)
    % Mean
    plot([1:n_timepts_premove]/n_timepts_premove,...
        PREMOVE_mean(arnum,:),'linewidth',3,'color',0.7*colors(arnum,:))
end

movegui(gcf,'center');
set(gca,'color','w','fontsize',20,'Tickdir','out','Ticklength',[.03 .03]);
set(gcf,'color','w','InvertHardCopy','off')
xlim([0 1]); xticks([0 1]); xlabel('Normalized pre-move time'); ylabel('Spread w/in trials (m)');
