function f5b_dist_to_goal(blocks)
%% Interpolate trials turn-by-turn and find the distance of gaze to the 
% stopping location (subjective goal location)
% NOTE: Trials skipped by the subjects were excluded from the analysis
% NOTE: Error bounds show standard error across all trials included in the
% analysis

clrs=def_colors; subjvec=[2,4,6,9,10,11,13,14,15,16,17,20,21];
n_timepts_premove=200; % interpoloate all pre-movement periods to 200 time points
PREMOVE=nan(3500,n_timepts_premove); % pre-allocate a matrix larger than
% the total number of trials in the entire experiment
PREMOVE_bySubject=nan(13,n_timepts_premove);
n_timepts_subgoal=25; % interpolate all turn periods to 25 frames (each)
n_subgoals=5; % consider the first 5 subgoals
n_timepts_between=100; % interpolate all periods in-between turns to 100 frames (each)
n_between=n_subgoals+1; % if there are 5 turns, there will be 6 straight segments
MOVE=nan(3500,n_subgoals*n_timepts_subgoal+n_between*n_timepts_between);
MOVE_bySubject=nan(13,n_subgoals*n_timepts_subgoal+n_between*n_timepts_between);
cut_before_stop=23; % cut 23 frames before the end of the trial because the subject
% is occupied with button press

%% Loop over all arenas/subjects/trials

row=1; subj_rows=nan(13,1);
for subj=1:13
    for arnum=1:5
        subject=subjvec(subj); continuous=blocks{arnum}.continuous{subject};
        turns=blocks{arnum}.turns{subject};
        for trial=1:size(continuous,2)
            % Exclude skipped trials or trials in which subjects did not move
            if blocks{arnum}.discrete{subject}(trial).RewardZone==9 ...
                    || isempty(blocks{arnum}.discrete{subject}(trial).start_move)
                continue
            end
            detected=blocks{arnum}.discrete{subject}(trial).detect_frame;
            start_move=blocks{arnum}.discrete{subject}(trial).start_move;
            triallen=length(continuous{trial}.trialTime)-cut_before_stop;
            
            % Find the distance of gaze to the stopping location
            gazeX=continuous{trial}.gazeX_noblink;
            gazeY=continuous{trial}.gazeY_noblink;
            % The arena spans from -10 m to 10 m, and gaze points outside
            % this means that subjects are looking outside of the arena
            % (at mountains, sky, etc). Remove extreme points of gaze.
            % NOTE: X in MATLAB is Z in Unity, and Y in MATLAB is -X in Unity.
            gazeX(abs(gazeX)>15)=NaN; gazeY(abs(gazeY)>15)=NaN;
            dist2stop=sqrt((gazeX-continuous{trial}.SubPosZ(end)).^2+...
                (gazeY+continuous{trial}.SubPosX(end)).^2);
            
            % Interpolate the distance to stop pre-movement
            if ~isnan(start_move)
                PREMOVE(row,:)=interp1(detected:start_move,dist2stop(detected:start_move),...
                    linspace(detected,start_move,n_timepts_premove));
                if ~isempty(turns{trial})
                    % From the end of the last turn until stop
                    MOVE(row,(n_subgoals*(n_timepts_subgoal+n_timepts_between)+1):end)=...
                        interp1(turns{trial}.turn_end(height(turns{trial})):triallen,...
                        dist2stop(turns{trial}.turn_end(height(turns{trial})):triallen),...
                        linspace(turns{trial}.turn_end(height(turns{trial})),triallen,n_timepts_between));
                    % Go backwards to populate turns and straight segments
                    all_turns=flip(1:height(turns{trial}));
                    for trn=1:min([height(turns{trial}),n_subgoals])
                        t1=(n_subgoals-trn+1)*n_timepts_between+(n_subgoals-trn)*n_timepts_subgoal+1;
                        t2=t1+n_timepts_subgoal-1;
                        % Turns
                        MOVE(row,t1:t2)=interp1(turns{trial}.turn_start(all_turns(trn)):...
                            turns{trial}.turn_end(all_turns(trn)),dist2stop(...
                            turns{trial}.turn_start(all_turns(trn)):turns{trial}.turn_end(all_turns(trn))),...
                            linspace(turns{trial}.turn_start(all_turns(trn)),...
                            turns{trial}.turn_end(all_turns(trn)),n_timepts_subgoal));
                        t1=(n_subgoals-trn)*(n_timepts_between+n_timepts_subgoal)+1;
                        t2=t1+n_timepts_between-1;
                        % Straight segments between turns
                        if all_turns(trn)>1
                            MOVE(row,t1:t2)=interp1(turns{trial}.turn_end(all_turns(trn)-1):...
                                turns{trial}.turn_start(all_turns(trn)),dist2stop(...
                                turns{trial}.turn_end(all_turns(trn)-1):turns{trial}.turn_start(all_turns(trn))),...
                                linspace(turns{trial}.turn_end(all_turns(trn)-1),...
                                turns{trial}.turn_start(all_turns(trn)),n_timepts_between));
                        else % From movement start to the first turn
                            MOVE(row,t1:t2)=interp1(start_move:turns{trial}.turn_start(all_turns(trn)),...
                                dist2stop(start_move:turns{trial}.turn_start(all_turns(trn))),...
                                linspace(start_move,turns{trial}.turn_start(all_turns(trn)),n_timepts_between));
                        end
                    end
                else % If there are no turns...
                    MOVE(row,(n_subgoals*(n_timepts_subgoal+n_timepts_between)+1):end)=...
                        interp1(start_move:triallen,dist2stop(start_move:triallen),...
                        linspace(start_move,triallen,n_timepts_between));
                end
            else
                PREMOVE(row,:)=interp1(detected:triallen,dist2stop(detected:triallen),...
                    linspace(detected,triallen,n_timepts_premove));
            end
            row=row+1;
        end
    end
    subj_rows(subj)=row;
end

%% Calculate per-subject means in order to calculate standard deviations

subj_rows=[0;subj_rows];
for subj=1:13
    PREMOVE_bySubject(subj,:)=mean(PREMOVE(...
        (subj_rows(subj)+1):subj_rows(subj+1),:),'omitnan');
    MOVE_bySubject(subj,:)=mean(MOVE(...
        (subj_rows(subj)+1):subj_rows(subj+1),:),'omitnan');
end
sterr_premove=std(PREMOVE_bySubject,'omitnan')/sqrt(13);
sterr_move=std(MOVE_bySubject,'omitnan')/sqrt(13);

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

%% Plot movement

figure('position',[0 0 800 400]); hold on
% Mean
plot([1:size(MOVE,2)]/size(MOVE,2),...
    mean(MOVE,'omitnan'),'linewidth',3,'color',0.7*clrs.blue)
% Error bounds
fill([1:size(MOVE,2),flip([1:size(MOVE,2)])]/size(MOVE,2),...
    [mean(MOVE,'omitnan')-sterr_move,...
    flip([mean(MOVE,'omitnan')+sterr_move])],clrs.blue,'LineStyle','none')
% Label turn epochs
yl=ylim;
for trn=1:n_subgoals
    t1=(n_subgoals-trn+1)*n_timepts_between+(n_subgoals-trn)*n_timepts_subgoal+1;
    t2=t1+n_timepts_subgoal-1;
    f(trn)=fill([t1,t2,t2,t1]/size(MOVE,2),[yl(1),yl(1),yl(2),yl(2)],...
        clrs.lightgray,'LineStyle','none');
    set(f(trn),'facealpha',0.5)
end

movegui(gcf,'center')
graph_children=get(gca,'Children'); set(gca,'Children',flipud(graph_children))
set(gca,'color','w','fontsize',24,'Tickdir','out','Ticklength',[.03 .03]);
set(gcf,'color','w','InvertHardCopy','off')
xlim([0 1]); xticks([0 1]); xlabel('Norm time'); ylim(yl); ylabel('Distance (m)');
