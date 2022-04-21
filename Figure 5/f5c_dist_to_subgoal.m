function f5c_dist_to_subgoal(blocks)
%% %% Interpolate trials turn-by-turn and find the distance of gaze to the
% immediate next subgoal
% NOTE: Trials skipped by the subjects were excluded from the analysis, as
% well as trials in which subjects did not move
% NOTE: Error bounds show standard error across all trials included in the
% analysis (applies to pre-move plot only)

clrs=def_colors; subjvec=[2,4,6,9,10,11,13,14,15,16,17,20,21];
n_timepts_premove=200; % interpoloate all pre-movement periods to 200 time points
PREMOVE=nan(3500,n_timepts_premove); % pre-allocate a matrix larger than
% the total number of trials in the entire experiment
PREMOVE_bySubject=nan(13,n_timepts_premove);
MOVE=cell(6,1); for subgoal=1:6, MOVE{subgoal}=nan(6,13,300); end
MOVE_bySubgoal=nan(6,6);
cut_before_stop=23; % cut 23 frames before the end of the trial because the subject
% is occupied with button press

%% Loop over all arenas/subjects/trials

row=1; subj_rows=nan(13,1);
for subj=1:13, idx=1;
    for arnum=1:5
        subject=subjvec(subj); continuous=blocks{arnum}.continuous{subject};
        turns=blocks{arnum}.turns{subject};
        for trial=1:size(continuous,2)
            % Exclude skipped trials or trials in which subjects did not move
            if blocks{arnum}.discrete{subject}(trial).RewardZone==9 ...
                    || isnan(blocks{arnum}.discrete{subject}(trial).start_move)
                continue
            end
            detected=blocks{arnum}.discrete{subject}(trial).detect_frame;
            start_move=blocks{arnum}.discrete{subject}(trial).start_move;
            triallen=length(continuous{trial}.trialTime)-cut_before_stop;
            
            % Find the distance of gaze to the stop location\
            gazeX=continuous{trial}.gazeX_noblink;
            gazeY=continuous{trial}.gazeY_noblink;
            % The arena spans from -10 m to 10 m, and gaze points outside
            % this means that subjects are looking outside of the arena
            % (at mountains, sky, etc). Remove extreme points of gaze.
            gazeX(abs(gazeX)>15)=NaN; gazeY(abs(gazeY)>15)=NaN;
            % NOTE: X in MATLAB is Z in Unity, and Y in MATLAB is -X in Unity.
            dist2stop=sqrt((gazeX-continuous{trial}.SubPosZ(end)).^2+...
                (gazeY+continuous{trial}.SubPosX(end)).^2);
            
            if ~isempty(turns{trial})
                % For pre-movement, the first turn is the first subgoal
                % (if there are turns)
                turn_midpointX=mean(continuous{trial}.SubPosZ(turns{trial}.turn_start(1):...
                    turns{trial}.turn_end(1)),'omitnan');
                turn_midpointY=mean(-continuous{trial}.SubPosX(turns{trial}.turn_start(1):...
                    turns{trial}.turn_end(1)),'omitnan');
                dist2turn=sqrt((gazeX-turn_midpointX).^2+(gazeY-turn_midpointY).^2);
                PREMOVE(row,:)=interp1(detected:start_move,dist2turn(detected:start_move),...
                    linspace(detected,start_move,n_timepts_premove));
                
                % Find the distance to each subgoal
                all_turns=flip(1:height(turns{trial}));
                dist2turns=nan(5,length(continuous{trial}.trialTime));
                for turn=1:min([height(turns{trial}),5])
                    turn_midpointX=mean(continuous{trial}.SubPosZ(turns{trial}.turn_start(all_turns(turn)):...
                        turns{trial}.turn_end(all_turns(turn))),'omitnan');
                    turn_midpointY=mean(-continuous{trial}.SubPosX(turns{trial}.turn_start(all_turns(turn)):...
                        turns{trial}.turn_end(all_turns(turn))),'omitnan');
                    dist2turns(6-turn,:)=sqrt((gazeX-turn_midpointX).^2+(gazeY-turn_midpointY).^2);
                end
                
                % From the last turn to the end of the trial
                for turn=1:5
                    MOVE{turn}(6,subj,idx)=mean(dist2turns(turn,turns{trial}.turn_start(all_turns(1)):triallen),'all','omitnan');
                end
                MOVE{6}(6,subj,idx)=mean(dist2stop(turns{trial}.turn_start(all_turns(1)):triallen),'omitnan');
                if length(all_turns)>1
                    for subgoal=2:min([height(turns{trial}),5]) % Preceeding each turn
                        for turn=1:5
                            MOVE{turn}(6-subgoal+1,subj,idx)=mean(dist2turns(turn,turns{trial}.turn_start(all_turns(subgoal)):...
                                turns{trial}.turn_start(all_turns(subgoal-1))),'all','omitnan');
                        end
                        MOVE{6}(6-subgoal+1,subj,idx)=mean(dist2stop(turns{trial}.turn_start(all_turns(subgoal)):...
                            turns{trial}.turn_start(all_turns(subgoal-1))),'omitnan');
                    end
                    if height(turns{trial})<=5 % From the start of movement to the first turn
                        for turn=1:5
                            MOVE{turn}(6-height(turns{trial}),subj,idx)=mean(dist2turns(turn,start_move:...
                                turns{trial}.turn_start(all_turns(subgoal-1))),'all','omitnan');
                        end
                        MOVE{6}(6-height(turns{trial}),subj,idx)=mean(dist2stop(start_move:...
                            turns{trial}.turn_start(all_turns(subgoal-1))),'omitnan');
                    end
                else % If there is only one turn
                    for turn=1:5
                        MOVE{turn}(5,subj,idx)=mean(dist2turns(turn,start_move:...
                            turns{trial}.turn_start(all_turns(1))),'all','omitnan');
                    end
                    MOVE{6}(5,subj,idx)=mean(dist2stop(start_move:turns{trial}.turn_start(all_turns(1))),'omitnan');
                end
            else % If there are no turns, only populate the last column
                MOVE{6}(6,subj,idx)=mean(dist2stop(start_move:triallen),'omitnan');
            end
            row=row+1; idx=idx+1;
        end
    end
    subj_rows(subj)=row;
end

%% Calculate per-subject means in order to calculate standard deviations

subj_rows=[0;subj_rows];
for subj=1:13
    PREMOVE_bySubject(subj,:)=mean(PREMOVE(...
        (subj_rows(subj)+1):subj_rows(subj+1),:),'omitnan');
end
sterr_premove=std(PREMOVE_bySubject,'omitnan')/sqrt(13);

for subgoal=1:6
    for sg=1:6
        MOVE_bySubgoal(subgoal,sg)=mean(MOVE{subgoal}(sg,:,:),'all','omitnan');
    end
end

%% Plot pre-movement

figure('position',[0 0 400 400]); hold on
% Error bounds
fill([1:size(PREMOVE,2),flip([1:size(PREMOVE,2)])]/size(PREMOVE,2),...
    [mean(PREMOVE,'omitnan')-sterr_premove,...
    flip([mean(PREMOVE,'omitnan')+sterr_premove])],clrs.gold,'LineStyle','none')
% Mean
plot([1:size(PREMOVE,2)]/size(PREMOVE,2),...
    mean(PREMOVE,'omitnan'),'linewidth',3,'color',0.7*clrs.gold)

movegui(gcf,'center')
set(gca,'color','w','fontsize',24,'Tickdir','out','Ticklength',[.03 .03]);
set(gcf,'color','w','InvertHardCopy','off')
xlim([0 1]); xticks([0 1]); xlabel('Norm time'); ylabel('Distance (m)');

%% Plot distance of gaze to subgoal for each subgoal separately

figure('position',[0 0 800 400]); hold on
colors=[clrs.gray;clrs.purp2blue1;clrs.purp2blue2;clrs.purp2blue3;clrs.purp2blue4;clrs.blue];
% Distance to each subgoal
for subgoal=2:6
    plot(1:6,MOVE_bySubgoal(subgoal,:),'color',colors(subgoal,:),'linewidth',3)
end

% Label the current turn
for subgoal=2:6
    scatter(subgoal,MOVE_bySubgoal(subgoal,subgoal),200,'markerfacecolor',colors(subgoal,:),...
        'markeredgecolor','k','linewidth',3)
end

movegui(gcf,'center')
set(gca,'color','w','fontsize',24,'Tickdir','out','Ticklength',[.03 .03]);
set(gcf,'color','w','InvertHardCopy','off')
xlim([1.5 6.5]); xticks([2 3 4 5 6]); xticklabels({'4','3','2','1','0'}); 
ylim([0 10]); yticks([0 5 10])
xlabel('Norm time'); ylabel('Distance (m)');
