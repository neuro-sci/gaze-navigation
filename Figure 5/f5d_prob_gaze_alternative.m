function f5d_prob_gaze_alternative(blocks,k,u)
%% Find the probability of gazing upon alternative trajectories as a function of time
% NOTE: Trials skipped by the subjects were excluded from the analysis
% NOTE: Error bounds show standard error across all trials included in the
% analysis

if nargin<3, u=0.5; if nargin<2, k=1.25; end; end
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
interpolation_granularity=0.1; 
% 1/granularity = number of steps between states in the trajectory
smooth_window=25; % how much to smooth the movement time series

%% Loop over all arenas/subjects/trials

row=1; subj_rows=nan(13,1);
for subj=1:13
    for arnum=2:4
        A=blocks{arnum}.arena.neighbor; G=graph(A);
        % Scale by 2 b/c the arena was scaled by 2 when loaded into Unity
        centroids=2*blocks{arnum}.arena.centroids;
        subject=subjvec(subj); continuous=blocks{arnum}.continuous{subject};
        turns=blocks{arnum}.turns{subject};
        for trial=1:size(continuous,2)
            % Exclude skipped trials or trials in which subjects did not move
            if blocks{arnum}.discrete{subject}(trial).RewardZone==9 ...
                    || isempty(blocks{arnum}.discrete{subject}(trial).start_move)
                continue
            end
            target=blocks{arnum}.discrete{subject}(trial).TargetStatenum+1;
            start=find(~isnan(continuous{trial}.subj_states),1,'first');
            start=continuous{trial}.subj_states(start);
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
            
            % Target gazing vector
            target_x=2*blocks{arnum}.arena.centroids(target,1);
            target_y=2*blocks{arnum}.arena.centroids(target,2);
            gaze_target=zeros(length(continuous{trial}.trialTime),1);
            gaze_target(sqrt((gazeX-target_x).^2+(gazeY-target_y).^2)<2)=1;

            % Trajectory gazing vector
            gaze_trajectory=zeros(length(continuous{trial}.trialTime),1);
            gaze_trajectory(continuous{trial}.idistfromtraj<2)=1;
            
            % Gaze alternative vector
            gaze_alternative=zeros(height(continuous{trial}),1);
            shortest_path=shortestpath(G,start,target);
            if ~isnan(shortest_path)
                paths=allpaths(G,start,target,'MaxPathLength',ceil(k*length(shortest_path)));
                if size(paths,1)>1
                    % Assign the first (shortest) path as unique
                    clear comparison_paths; comparison_paths{1}=paths{1};
                    for p=2:size(paths,1), is_unique=1;
                        % For each subsequent path, compare it against paths designated as unique. 
                        % If the overlap is greater than a certain percentage, then the path
                        % is not unique. Else, add the path to the list of unique paths.
                        for c=1:size(comparison_paths,2)
                            if length(intersect(comparison_paths{c},paths{p}))>(u*length(comparison_paths{c}))
                                is_unique=0;
                            end
                        end
                        if is_unique, comparison_paths{c+1}=paths{p}; end
                    end
                else
                    comparison_paths=paths{1};
                end

                % interpolate all paths to a finer spatial resolution
                paths_X=nan(size(comparison_paths,2),100*(1/interpolation_granularity));
                paths_Y=nan(size(comparison_paths,2),100*(1/interpolation_granularity));
                if iscell(comparison_paths)
                    for p=1:size(comparison_paths,2)
                        if length(comparison_paths{p})<2, continue; end
                        this_path_x=centroids(comparison_paths{p},1);
                        this_path_y=centroids(comparison_paths{p},2);
                        this_path_x=interp1(1:length(comparison_paths{p}),this_path_x,...
                            1:interpolation_granularity:length(comparison_paths{p}));
                        this_path_y=interp1(1:length(comparison_paths{p}),this_path_y,...
                            1:interpolation_granularity:length(comparison_paths{p}));
                        paths_X(p,1:length(this_path_x))=this_path_x;
                        paths_Y(p,1:length(this_path_y))=this_path_y;
                    end
                else
                    if length(comparison_paths)<2, continue; end
                    this_path_x=centroids(comparison_paths,1);
                    this_path_y=centroids(comparison_paths,2);
                    this_path_x=interp1(1:length(comparison_paths),this_path_x,...
                        1:interpolation_granularity:length(comparison_paths));
                    this_path_y=interp1(1:length(comparison_paths),this_path_y,...
                        1:interpolation_granularity:length(comparison_paths));
                    paths_X(1,1:length(this_path_x))=this_path_x;
                    paths_Y(1,1:length(this_path_y))=this_path_y;
                end
                if all(isnan(paths_X)), continue; end

                % Find whether the eye at each time point is on an
                % alternative trajectory and/or the chosen trajectory
                for t=1:height(continuous{trial})
                    if any(sqrt((paths_X-gazeX(t)).^2+(paths_Y-gazeY(t)).^2)<2,'all')
                        gaze_alternative(t)=1;
                    end
                end
            end
            gaze_alternative(gaze_target==1 | gaze_trajectory==1)=0;

            % Interpolate the probability of looking upon alternatives
            if ~isnan(start_move)
                PREMOVE(row,:)=interp1(detected:start_move,gaze_alternative(detected:start_move),...
                    linspace(detected,start_move,n_timepts_premove));
                if ~isempty(turns{trial})
                    % From the end of the last turn until stop
                    MOVE(row,(n_subgoals*(n_timepts_subgoal+n_timepts_between)+1):end)=...
                        interp1(turns{trial}.turn_end(height(turns{trial})):triallen,...
                        gaze_alternative(turns{trial}.turn_end(height(turns{trial})):triallen),...
                        linspace(turns{trial}.turn_end(height(turns{trial})),triallen,n_timepts_between));
                    % Go backwards to populate turns and straight segments
                    all_turns=flip(1:height(turns{trial}));
                    for trn=1:min([height(turns{trial}),n_subgoals])
                        t1=(n_subgoals-trn+1)*n_timepts_between+(n_subgoals-trn)*n_timepts_subgoal+1;
                        t2=t1+n_timepts_subgoal-1;
                        % Turns
                        MOVE(row,t1:t2)=interp1(turns{trial}.turn_start(all_turns(trn)):...
                            turns{trial}.turn_end(all_turns(trn)),gaze_alternative(...
                            turns{trial}.turn_start(all_turns(trn)):turns{trial}.turn_end(all_turns(trn))),...
                            linspace(turns{trial}.turn_start(all_turns(trn)),...
                            turns{trial}.turn_end(all_turns(trn)),n_timepts_subgoal));
                        t1=(n_subgoals-trn)*(n_timepts_between+n_timepts_subgoal)+1;
                        t2=t1+n_timepts_between-1;
                        % Straight segments between turns
                        if all_turns(trn)>1
                            MOVE(row,t1:t2)=interp1(turns{trial}.turn_end(all_turns(trn)-1):...
                                turns{trial}.turn_start(all_turns(trn)),gaze_alternative(...
                                turns{trial}.turn_end(all_turns(trn)-1):turns{trial}.turn_start(all_turns(trn))),...
                                linspace(turns{trial}.turn_end(all_turns(trn)-1),...
                                turns{trial}.turn_start(all_turns(trn)),n_timepts_between));
                        else % From movement start to the first turn
                            MOVE(row,t1:t2)=interp1(start_move:turns{trial}.turn_start(all_turns(trn)),...
                                gaze_alternative(start_move:turns{trial}.turn_start(all_turns(trn))),...
                                linspace(start_move,turns{trial}.turn_start(all_turns(trn)),n_timepts_between));
                        end
                    end
                else % If there are no turns...
                    MOVE(row,(n_subgoals*(n_timepts_subgoal+n_timepts_between)+1):end)=...
                        interp1(start_move:triallen,gaze_alternative(start_move:triallen),...
                        linspace(start_move,triallen,n_timepts_between));
                end
            else
                PREMOVE(row,:)=interp1(detected:triallen,gaze_alternative(detected:triallen),...
                    linspace(detected,triallen,n_timepts_premove));
            end
            row=row+1;
        end
        disp([num2str(arnum),',',num2str(subj)])
    end
    subj_rows(subj)=row;
end

%% Calculate per-subject means in order to calculate standard deviations

subj_rows=[0;subj_rows];
for subj=1:13
    PREMOVE_bySubject(subj,:)=sum(PREMOVE(...
        (subj_rows(subj)+1):subj_rows(subj+1),:),'omitnan')./...
        sum(~isnan([(subj_rows(subj)+1):subj_rows(subj+1)]));
    MOVE_bySubject(subj,:)=sum(MOVE(...
        (subj_rows(subj)+1):subj_rows(subj+1),:),'omitnan')./...
        sum(~isnan([(subj_rows(subj)+1):subj_rows(subj+1)]));
end
sterr_premove=std(PREMOVE_bySubject,'omitnan')/sqrt(13);
sterr_move=std(MOVE_bySubject,'omitnan')/sqrt(13);

%% Plot pre-movement

figure('position',[0 0 400 400]); hold on
% Error bounds
fill([1:size(PREMOVE,2),flip([1:size(PREMOVE,2)])]/size(PREMOVE,2),...
    [sum(PREMOVE,'omitnan')./sum(~isnan(PREMOVE))-sterr_premove,...
    flip([sum(PREMOVE,'omitnan')./sum(~isnan(PREMOVE))+sterr_premove])],...
    clrs.gold,'LineStyle','none')
% Mean
plot([1:size(PREMOVE,2)]/size(PREMOVE,2),...
    sum(PREMOVE,'omitnan')./sum(~isnan(PREMOVE)),'linewidth',3,'color',0.7*clrs.gold)

movegui(gcf,'center')
set(gca,'color','w','fontsize',24,'Tickdir','out','Ticklength',[.03 .03]);
set(gcf,'color','w','InvertHardCopy','off')
xlim([0 1]); xticks([0 1]); xlabel('Norm time'); ylabel('P(gaze alternative)');

%% Plot movement

figure('position',[0 0 800 400]); hold on
% Mean
plot([1:size(MOVE,2)]/size(MOVE,2),...
    movmean(sum(MOVE,'omitnan')./sum(~isnan(MOVE)),smooth_window),'linewidth',1,'color',0.7*clrs.blue)
% Error bounds
fill([1:size(MOVE,2),flip([1:size(MOVE,2)])]/size(MOVE,2),...
    [movmean(sum(MOVE,'omitnan')./sum(~isnan(MOVE))-sterr_move,smooth_window),...
    flip([movmean(sum(MOVE,'omitnan')./sum(~isnan(MOVE))+sterr_move,smooth_window)])],...
    clrs.blue,'LineStyle','none')
% Label turn epochs
yl=ylim;
for trn=1:n_subgoals
    t1=(n_subgoals-trn+1)*n_timepts_between+(n_subgoals-trn)*n_timepts_subgoal+1;
    t2=t1+n_timepts_subgoal-1;
    f(trn)=fill([t1,t2,t2,t1]/size(MOVE,2),[0,0,yl(2),yl(2)],...
        clrs.lightgray,'LineStyle','none');
    set(f(trn),'facealpha',0.5)
end

movegui(gcf,'center')
graph_children=get(gca,'Children'); set(gca,'Children',flipud(graph_children))
set(gca,'color','w','fontsize',24,'Tickdir','out','Ticklength',[.03 .03]);
set(gcf,'color','w','InvertHardCopy','off')
xlim([0 1]); xticks([0 1]); xlabel('Norm time'); ylim([0 yl(2)]); ylabel('P(gaze alternative)');
