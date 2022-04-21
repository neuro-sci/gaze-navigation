function s8d_looktime_by_Nalternatives(blocks,k,u)
%% Plot the fraction of time looking at alternative trajectories or the 
% chosen trajectory or the target location as a function of the number of 
% trajectory options
% k is the largest allowable ratio of the alternative path to the optimal
% path (default = 1.25)
% u is the maximum state overlap between alternative paths (default = 0.5 = 50%)
% NOTE: Trials for which the target and starting state are the same are
% excluded from this analysis.
% NOTE: This analysis excludes blinks (eyes open only).

%%

if nargin<3, u=0.5; if nargin<2, k=1.25; end; end
subjvec=[2,4,6,9,10,11,13,14,15,16,17,20,21]; clrs=def_colors();
N_alternatives=nan(5,13,60); noptions=1:6; % number of trajectory options vector
frac_on_alternative_premove=nan(5,13,60); frac_on_alternative_move=nan(5,13,60);
frac_on_alternative_premove_bySubject=nan(5,13,length(noptions)); frac_on_alternative_move_bySubject=nan(5,13,length(noptions));
alternative_premove_byArena=nan(5,length(noptions)); alternative_move_byArena=nan(5,length(noptions));
ste_alternative_premove=nan(5,length(noptions)); ste_alternative_move=nan(5,length(noptions));

frac_on_traj_premove=nan(5,13,60); frac_on_traj_move=nan(5,13,60);
frac_on_traj_premove_bySubject=nan(5,13,length(noptions)); frac_on_traj_move_bySubject=nan(5,13,length(noptions));
traj_premove_byArena=nan(5,length(noptions)); traj_move_byArena=nan(5,length(noptions));
ste_traj_premove=nan(5,length(noptions)); ste_traj_move=nan(5,length(noptions));

frac_on_target_premove=nan(5,13,60); frac_on_target_move=nan(5,13,60);
frac_on_target_premove_bySubject=nan(5,13,length(noptions)); frac_on_target_move_bySubject=nan(5,13,length(noptions));
target_premove_byArena=nan(5,length(noptions)); target_move_byArena=nan(5,length(noptions));
ste_target_premove=nan(5,length(noptions)); ste_target_move=nan(5,length(noptions));

interpolation_granularity=0.1;
% 1/granularity = number of steps between states in the trajectory

for arnum=2:4
    A=blocks{arnum}.arena.neighbor; G=graph(A);
    % Scale by 2 b/c the arena was scaled by 2 when loaded into Unity
    centroids=2*blocks{arnum}.arena.centroids;
    for subj=1:13
        subject=subjvec(subj); continuous=blocks{arnum}.continuous{subject};
        for trial=1:size(continuous,2)
            target=blocks{arnum}.discrete{subject}(trial).TargetStatenum+1;
            start=find(~isnan(continuous{trial}.subj_states),1,'first');
            start=continuous{trial}.subj_states(start);
            detected=blocks{arnum}.discrete{subject}(trial).detect_frame;
            start_move=blocks{arnum}.discrete{subject}(trial).start_move;
            stop_move=blocks{arnum}.discrete{subject}(trial).stop_move;

            gazeX=continuous{trial}.gazeX_noblink; gazeY=continuous{trial}.gazeY_noblink;

            % Target gazing vector
            target_x=2*blocks{arnum}.arena.centroids(target,1);
            target_y=2*blocks{arnum}.arena.centroids(target,2);
            gaze_target=zeros(length(continuous{trial}.trialTime),1);
            gaze_target(sqrt((gazeX-target_x).^2+(gazeY-target_y).^2)<2)=1;

            % Trajectory gazing vector
            gaze_trajectory=zeros(length(continuous{trial}.trialTime),1);
            gaze_trajectory(continuous{trial}.idistfromtraj<2)=1;

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
                if iscell(comparison_paths) % If there is more than one path
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
                    N_alternatives(arnum,subj,trial)=size(comparison_paths,2);
                else % If there is only one path (the shortest path) -- it's still possible
                    % that the participant didn't take it, so it could have
                    % been an alternative. If the participant took the
                    % path, it would be counted as the chosen trajectory if
                    % they look at it. Else it would be counted as an
                    % alternative trajectory.
                    if length(comparison_paths)<2, continue; end
                    this_path_x=centroids(comparison_paths,1);
                    this_path_y=centroids(comparison_paths,2);
                    this_path_x=interp1(1:length(comparison_paths),this_path_x,...
                        1:interpolation_granularity:length(comparison_paths));
                    this_path_y=interp1(1:length(comparison_paths),this_path_y,...
                        1:interpolation_granularity:length(comparison_paths));
                    paths_X(1,1:length(this_path_x))=this_path_x;
                    paths_Y(1,1:length(this_path_y))=this_path_y;
                    N_alternatives(arnum,subj,trial)=1;
                end
                if all(isnan(paths_X)), continue; end

                % Find whether the eye at each time point is on an
                % alternative trajectory and/or the chosen trajectory
                gaze_alternative=zeros(height(continuous{trial}),1);
                for t=1:height(continuous{trial})
                    if any(sqrt((paths_X-gazeX(t)).^2+(paths_Y-gazeY(t)).^2)<2,'all')
                        gaze_alternative(t)=1;
                    end
                end

                % Hierarchy: (1) Gazing at the target, regardless of
                % how it is likely on both the chosen and alternative paths
                % (2) Gazing at the chosen trajectory but not the target,
                % regardless of whether the gaze overlaps with the
                % alternative paths
                % (3) Gazing at alternative paths and definitely not the
                % target nor the chosen path
                if ~isnan(start_move) && ~isempty(start_move)
                    frac_on_alternative_premove(arnum,subj,trial)=...
                        sum(gaze_alternative(detected:start_move) & ...
                        ~gaze_trajectory(detected:start_move) & ~gaze_target(detected:start_move))/...
                        nnz(~isnan(gazeX(detected:start_move)));
                    frac_on_traj_premove(arnum,subj,trial)=...
                        sum(gaze_trajectory(detected:start_move) & ~gaze_target(detected:start_move))/...
                        nnz(~isnan(gazeX(detected:start_move)));
                    frac_on_target_premove(arnum,subj,trial)=...
                        sum(gaze_target(detected:start_move))/nnz(~isnan(gazeX(detected:start_move)));
                    if ~isnan(stop_move) && ~isempty(stop_move)
                        frac_on_alternative_move(arnum,subj,trial)=...
                            sum(gaze_alternative(start_move:stop_move) & ...
                            ~gaze_trajectory(start_move:stop_move) & ~gaze_target(start_move:stop_move))/...
                            nnz(~isnan(gazeX(start_move:stop_move)));
                        frac_on_traj_move(arnum,subj,trial)=...
                            sum(gaze_trajectory(start_move:stop_move) & ~gaze_target(start_move:stop_move))/...
                            nnz(~isnan(gazeX(start_move:stop_move)));
                        frac_on_target_move(arnum,subj,trial)=...
                            sum(gaze_target(start_move:stop_move))/nnz(~isnan(gazeX(start_move:stop_move)));
                    else
                        frac_on_alternative_move(arnum,subj,trial)=...
                            sum(gaze_alternative(start_move:end) & ...
                            ~gaze_trajectory(start_move:end) & ~gaze_target(start_move:end))/...
                            nnz(~isnan(gazeX(start_move:end)));
                        frac_on_traj_move(arnum,subj,trial)=...
                            sum(gaze_trajectory(start_move:end) & ~gaze_target(start_move:end))/...
                            nnz(~isnan(gazeX(start_move:end)));
                        frac_on_target_move(arnum,subj,trial)=...
                            sum(gaze_target(start_move:end))/nnz(~isnan(gazeX(start_move:end)));
                    end
                else
                    frac_on_alternative_premove(arnum,subj,trial)=...
                        sum(gaze_alternative(detected:end) & ...
                        ~gaze_trajectory(detected:end) & ~gaze_target(detected:end))/...
                        nnz(~isnan(gazeX(detected:end)));
                    frac_on_traj_premove(arnum,subj,trial)=...
                        sum(gaze_trajectory(detected:end) & ~gaze_target(detected:end))/...
                        nnz(~isnan(gazeX(detected:end)));
                    frac_on_target_premove(arnum,subj,trial)=...
                        sum(gaze_target(detected:end))/nnz(~isnan(gazeX(detected:end)));
                end
            else
                continue
            end
        end
    end
    disp(['arena ',num2str(arnum),' done'])
end

%% Compute mean and errors

how_many=nan(3,length(noptions));
for arnum=2:4
    this_arnum=squeeze(N_alternatives(arnum,:,:));
    this_alt_premove=squeeze(frac_on_alternative_premove(arnum,:,:)); this_alt_premove=this_alt_premove(:);
    this_alt_move=squeeze(frac_on_alternative_move(arnum,:,:)); this_alt_move=this_alt_move(:);
    this_traj_premove=squeeze(frac_on_traj_premove(arnum,:,:)); this_traj_premove=this_traj_premove(:);
    this_traj_move=squeeze(frac_on_traj_move(arnum,:,:)); this_traj_move=this_traj_move(:);
    this_target_premove=squeeze(frac_on_target_premove(arnum,:,:)); this_target_premove=this_target_premove(:);
    this_target_move=squeeze(frac_on_target_move(arnum,:,:)); this_target_move=this_target_move(:);
    for nopt=1:length(noptions)
        these_idx=find(this_arnum(:)==noptions(nopt)); how_many(arnum-1,nopt)=length(these_idx);
        alternative_premove_byArena(arnum,nopt)=mean(this_alt_premove(these_idx),'all','omitnan');
        alternative_move_byArena(arnum,nopt)=mean(this_alt_move(these_idx),'all','omitnan');
        traj_premove_byArena(arnum,nopt)=mean(this_traj_premove(these_idx),'all','omitnan');
        traj_move_byArena(arnum,nopt)=mean(this_traj_move(these_idx),'all','omitnan');
        target_premove_byArena(arnum,nopt)=mean(this_target_premove(these_idx),'all','omitnan');
        target_move_byArena(arnum,nopt)=mean(this_target_move(these_idx),'all','omitnan');
        for subj=1:13
            subj_arnum=squeeze(N_alternatives(arnum,subj,:));
            subj_idx=find(subj_arnum==noptions(nopt));
            subj_alt_premove=squeeze(frac_on_alternative_premove(arnum,subj,:));
            subj_alt_move=squeeze(frac_on_alternative_move(arnum,subj,:));
            subj_traj_premove=squeeze(frac_on_traj_premove(arnum,subj,:));
            subj_traj_move=squeeze(frac_on_traj_move(arnum,subj,:));
            subj_target_premove=squeeze(frac_on_target_premove(arnum,subj,:));
            subj_target_move=squeeze(frac_on_target_move(arnum,subj,:));
            frac_on_alternative_premove_bySubject(arnum,subj,nopt)=mean(subj_alt_premove(subj_idx),'omitnan');
            frac_on_alternative_move_bySubject(arnum,subj,nopt)=mean(subj_alt_move(subj_idx),'omitnan');
            frac_on_traj_premove_bySubject(arnum,subj,nopt)=mean(subj_traj_premove(subj_idx),'omitnan');
            frac_on_traj_move_bySubject(arnum,subj,nopt)=mean(subj_traj_move(subj_idx),'omitnan');
            frac_on_target_premove_bySubject(arnum,subj,nopt)=mean(subj_target_premove(subj_idx),'omitnan');
            frac_on_target_move_bySubject(arnum,subj,nopt)=mean(subj_target_move(subj_idx),'omitnan');
        end
        ste_alternative_premove(arnum,nopt)=std(squeeze(frac_on_alternative_premove_bySubject(arnum,:,nopt)),'omitnan')/sqrt(13);
        ste_alternative_move(arnum,nopt)=std(squeeze(frac_on_alternative_move_bySubject(arnum,:,nopt)),'omitnan')/sqrt(13);
        ste_traj_premove(arnum,nopt)=std(squeeze(frac_on_traj_premove_bySubject(arnum,:,nopt)),'omitnan')/sqrt(13);
        ste_traj_move(arnum,nopt)=std(squeeze(frac_on_traj_move_bySubject(arnum,:,nopt)),'omitnan')/sqrt(13);
        ste_target_premove(arnum,nopt)=std(squeeze(frac_on_target_premove_bySubject(arnum,:,nopt)),'omitnan')/sqrt(13);
        ste_target_move(arnum,nopt)=std(squeeze(frac_on_target_move_bySubject(arnum,:,nopt)),'omitnan')/sqrt(13);
    end
end

%% Compute stats: correlation between number of alternatives and the fraction of time looking at alternatives and the goal location

alternatives_matrix=repmat(noptions,5,1);
alternative_premove_byArena(2,end)=NaN; alternative_premove_byArena(2,end-1)=NaN; 
[R,P]=corrcoef(alternative_premove_byArena(:),alternatives_matrix(:),'rows','complete');
disp(['correlation of fraction of time gazing at alternative trajectories during pre-movement vs. the number of alternatives is ',...
    num2str(R(1,2)),', p_val = ',num2str(P(1,2))])

alternative_move_byArena(2,end)=NaN; alternative_move_byArena(2,end-1)=NaN; 
[R,P]=corrcoef(alternative_move_byArena(:),alternatives_matrix(:),'rows','complete');
disp(['correlation of fraction of time gazing at alternative trajectories during movement vs. the number of alternatives is ',...
    num2str(R(1,2)),', p_val = ',num2str(P(1,2))])

alternatives_matrix=repmat(noptions,5,1);
target_premove_byArena(2,end)=NaN; target_premove_byArena(2,end-1)=NaN; 
[R,P]=corrcoef(target_premove_byArena(:),alternatives_matrix(:),'rows','complete');
disp(['correlation of fraction of time gazing at the goal during pre-movement vs. the number of alternatives is ',...
    num2str(R(1,2)),', p_val = ',num2str(P(1,2))])

target_move_byArena(2,end)=NaN; target_move_byArena(2,end-1)=NaN; 
[R,P]=corrcoef(target_move_byArena(:),alternatives_matrix(:),'rows','complete');
disp(['correlation of fraction of time gazing at the goal during movement vs. the number of alternatives is ',...
    num2str(R(1,2)),', p_val = ',num2str(P(1,2))])


%% Plot pre-move

figure('Position',[0 0 375 375]); hold on;
colors=[clrs.prim2mint1;clrs.prim2mint2;clrs.prim2mint3;clrs.prim2mint4;clrs.prim2mint5];
for arnum=2:4
    if arnum==2 % Exclude 5 alternatives for arena 2 because there is only one subject with trials with 5 alternatives
        plot(1:nopt-2,100*alternative_premove_byArena(arnum,1:nopt-2),'color',colors(arnum,:))
        errorbar(1:nopt-2,100*alternative_premove_byArena(arnum,1:nopt-2),100*ste_alternative_premove(arnum,1:nopt-2),...
            'LineStyle','none','color','k','CapSize',0)
        scatter(1:nopt-2,100*alternative_premove_byArena(arnum,1:nopt-2),...
            150,'markerfacecolor',colors(arnum,:),'markeredgecolor','none')
    else
        plot(1:nopt,100*alternative_premove_byArena(arnum,:),'color',colors(arnum,:))
        errorbar(1:nopt,100*alternative_premove_byArena(arnum,:),100*ste_alternative_premove(arnum,:),...
            'LineStyle','none','color','k','CapSize',0)
        scatter(1:nopt,100*alternative_premove_byArena(arnum,:),...
            150,'markerfacecolor',colors(arnum,:),'markeredgecolor','none')
    end
end
movegui(gcf,'center')
set(gca,'color','w','fontsize',20,'Tickdir','out','Ticklength',[.03 .03]);
set(gcf,'color','w','InvertHardCopy','off');
xlim([0 7]); xticks([1 2 3 4 5 6]); xticklabels({'1','2','3','4','5','6'})
xlabel('# Options'); ylabel('% Gaze @ alternatives')

figure('Position',[0 0 375 375]); hold on;
for arnum=2:4
    if arnum==2
        plot(1:nopt-2,100*traj_premove_byArena(arnum,1:nopt-2),'color',colors(arnum,:))
        errorbar(1:nopt-2,100*traj_premove_byArena(arnum,1:nopt-2),100*ste_traj_premove(arnum,1:nopt-2),...
            'LineStyle','none','color','k','CapSize',0)
        scatter(1:nopt-2,100*traj_premove_byArena(arnum,1:nopt-2),...
            150,'markerfacecolor',colors(arnum,:),'markeredgecolor','none')
    else
        plot(1:nopt,100*traj_premove_byArena(arnum,:),'color',colors(arnum,:))
        errorbar(1:nopt,100*traj_premove_byArena(arnum,:),100*ste_traj_premove(arnum,:),...
            'LineStyle','none','color','k','CapSize',0)
        scatter(1:nopt,100*traj_premove_byArena(arnum,:),...
            150,'markerfacecolor',colors(arnum,:),'markeredgecolor','none')
    end
end
movegui(gcf,'center')
set(gca,'color','w','fontsize',20,'Tickdir','out','Ticklength',[.03 .03]);
set(gcf,'color','w','InvertHardCopy','off');
xlim([0 7]); xticks([1 2 3 4 5 6]); xticklabels({'1','2','3','4','5','6'})
xlabel('# Options'); ylabel('% Gaze @ trajectory')

figure('Position',[0 0 375 375]); hold on;
for arnum=2:4
    if arnum==2
        plot(1:nopt-2,100*target_premove_byArena(arnum,1:nopt-2),'color',colors(arnum,:))
        errorbar(1:nopt-2,100*target_premove_byArena(arnum,1:nopt-2),100*ste_target_premove(arnum,1:nopt-2),...
            'LineStyle','none','color','k','CapSize',0)
        scatter(1:nopt-2,100*target_premove_byArena(arnum,1:nopt-2),...
            150,'markerfacecolor',colors(arnum,:),'markeredgecolor','none')
    else
        plot(1:nopt,100*target_premove_byArena(arnum,:),'color',colors(arnum,:))
        errorbar(1:nopt,100*target_premove_byArena(arnum,:),100*ste_target_premove(arnum,:),...
            'LineStyle','none','color','k','CapSize',0)
        scatter(1:nopt,100*target_premove_byArena(arnum,:),...
            150,'markerfacecolor',colors(arnum,:),'markeredgecolor','none')
    end
end
movegui(gcf,'center')
set(gca,'color','w','fontsize',20,'Tickdir','out','Ticklength',[.03 .03]);
set(gcf,'color','w','InvertHardCopy','off');
xlim([0 7]); xticks([1 2 3 4 5 6]); xticklabels({'1','2','3','4','5','6'})
xlabel('# Options'); ylabel('% Gaze @ target')

figure('Position',[0 0 375 375]); hold on;
for arnum=2:4
    if arnum==2
        plot(1:nopt-2,100*(1-alternative_premove_byArena(arnum,1:nopt-2)-...
            traj_premove_byArena(arnum,1:nopt-2)-target_premove_byArena(arnum,1:nopt-2)),...
            'color',colors(arnum,:))
        scatter(1:nopt-2,100*(1-alternative_premove_byArena(arnum,1:nopt-2)-...
            traj_premove_byArena(arnum,1:nopt-2)-target_premove_byArena(arnum,1:nopt-2)),...
            150,'markerfacecolor',colors(arnum,:),'markeredgecolor','none')
    else
        plot(1:nopt,100*(1-alternative_premove_byArena(arnum,:)-...
            traj_premove_byArena(arnum,:)-target_premove_byArena(arnum,:)),...
            'color',colors(arnum,:))
        scatter(1:nopt,100*(1-alternative_premove_byArena(arnum,:)-...
            traj_premove_byArena(arnum,:)-target_premove_byArena(arnum,:)),...
            150,'markerfacecolor',colors(arnum,:),'markeredgecolor','none')
    end
end
movegui(gcf,'center')
set(gca,'color','w','fontsize',20,'Tickdir','out','Ticklength',[.03 .03]);
set(gcf,'color','w','InvertHardCopy','off');
xlim([0 7]); xticks([1 2 3 4 5 6]); xticklabels({'1','2','3','4','5','6'})
xlabel('# Options'); ylabel('% Gaze @ other')

%% Plot move

figure('Position',[0 0 375 375]); hold on;
for arnum=2:4
    if arnum==2
        plot(1:nopt-2,100*alternative_move_byArena(arnum,1:nopt-2),'color',colors(arnum,:))
        errorbar(1:nopt-2,100*alternative_move_byArena(arnum,1:nopt-2),100*ste_alternative_move(arnum,1:nopt-2),...
            'LineStyle','none','color','k','CapSize',0)
        scatter(1:nopt-2,100*alternative_move_byArena(arnum,1:nopt-2),...
            150,'markerfacecolor',colors(arnum,:),'markeredgecolor','none')
    else
        plot(1:nopt,100*alternative_move_byArena(arnum,:),'color',colors(arnum,:))
        errorbar(1:nopt,100*alternative_move_byArena(arnum,:),100*ste_alternative_move(arnum,:),...
            'LineStyle','none','color','k','CapSize',0)
        scatter(1:nopt,100*alternative_move_byArena(arnum,:),...
            150,'markerfacecolor',colors(arnum,:),'markeredgecolor','none')
    end
end
movegui(gcf,'center')
set(gca,'color','w','fontsize',20,'Tickdir','out','Ticklength',[.03 .03]);
set(gcf,'color','w','InvertHardCopy','off');
xlim([0 7]); xticks([1 2 3 4 5 6]); xticklabels({'1','2','3','4','5','6'})
xlabel('# Options'); ylabel('% Gaze @ alternatives')

figure('Position',[0 0 375 375]); hold on;
for arnum=2:4
    if arnum==2
        plot(1:nopt-2,100*traj_move_byArena(arnum,1:nopt-2),'color',colors(arnum,:))
        errorbar(1:nopt-2,100*traj_move_byArena(arnum,1:nopt-2),100*ste_traj_move(arnum,1:nopt-2),...
            'LineStyle','none','color','k','CapSize',0)
        scatter(1:nopt-2,100*traj_move_byArena(arnum,1:nopt-2),...
            150,'markerfacecolor',colors(arnum,:),'markeredgecolor','none')
    else
        plot(1:nopt,100*traj_move_byArena(arnum,:),'color',colors(arnum,:))
        errorbar(1:nopt,100*traj_move_byArena(arnum,:),100*ste_traj_move(arnum,:),...
            'LineStyle','none','color','k','CapSize',0)
        scatter(1:nopt,100*traj_move_byArena(arnum,:),...
            150,'markerfacecolor',colors(arnum,:),'markeredgecolor','none')
    end
end
movegui(gcf,'center')
set(gca,'color','w','fontsize',20,'Tickdir','out','Ticklength',[.03 .03]);
set(gcf,'color','w','InvertHardCopy','off');
xlim([0 7]); xticks([1 2 3 4 5 6]); xticklabels({'1','2','3','4','5','6'})
xlabel('# Options'); ylabel('% Gaze @ trajectory')

figure('Position',[0 0 375 375]); hold on;
for arnum=2:4
    if arnum==2
        plot(1:nopt-2,100*target_move_byArena(arnum,1:nopt-2),'color',colors(arnum,:))
        errorbar(1:nopt-2,100*target_move_byArena(arnum,1:nopt-2),100*ste_target_move(arnum,1:nopt-2),...
            'LineStyle','none','color','k','CapSize',0)
        scatter(1:nopt-2,100*target_move_byArena(arnum,1:nopt-2),...
            150,'markerfacecolor',colors(arnum,:),'markeredgecolor','none')
    else
        plot(1:nopt,100*target_move_byArena(arnum,:),'color',colors(arnum,:))
        errorbar(1:nopt,100*target_move_byArena(arnum,:),100*ste_target_move(arnum,:),...
            'LineStyle','none','color','k','CapSize',0)
        scatter(1:nopt,100*target_move_byArena(arnum,:),...
            150,'markerfacecolor',colors(arnum,:),'markeredgecolor','none')
    end
end
movegui(gcf,'center')
set(gca,'color','w','fontsize',20,'Tickdir','out','Ticklength',[.03 .03]);
set(gcf,'color','w','InvertHardCopy','off');
xlim([0 7]); xticks([1 2 3 4 5 6]); xticklabels({'1','2','3','4','5','6'})
xlabel('# Options'); ylabel('% Gaze @ target')

figure('Position',[0 0 375 375]); hold on;
for arnum=2:4
    if arnum==2
        plot(1:nopt-2,100*(1-alternative_move_byArena(arnum,1:nopt-2)-...
            traj_move_byArena(arnum,1:nopt-2)-target_move_byArena(arnum,1:nopt-2)),...
            'color',colors(arnum,:))
        scatter(1:nopt-2,100*(1-alternative_move_byArena(arnum,1:nopt-2)-...
            traj_move_byArena(arnum,1:nopt-2)-target_move_byArena(arnum,1:nopt-2)),...
            150,'markerfacecolor',colors(arnum,:),'markeredgecolor','none')
    else
        plot(1:nopt,100*(1-alternative_move_byArena(arnum,:)-...
            traj_move_byArena(arnum,:)-target_move_byArena(arnum,:)),...
            'color',colors(arnum,:))
        scatter(1:nopt,100*(1-alternative_move_byArena(arnum,:)-...
            traj_move_byArena(arnum,:)-target_move_byArena(arnum,:)),...
            150,'markerfacecolor',colors(arnum,:),'markeredgecolor','none')
    end
end
movegui(gcf,'center')
set(gca,'color','w','fontsize',20,'Tickdir','out','Ticklength',[.03 .03]);
set(gcf,'color','w','InvertHardCopy','off');
xlim([0 7]); xticks([1 2 3 4 5 6]); xticklabels({'1','2','3','4','5','6'})
xlabel('# Options'); ylabel('% Gaze @ other')
