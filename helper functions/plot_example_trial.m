function plot_example_trial(blocks,RL_vars,arnum,subject,trial)
%% Plot the optimal trajectory for a trial with the subject's trajectory superimposed

% Process inputs
arena=blocks{arnum}.arena; clrs=def_colors; cmap=clrs.paradise;
start=blocks{arnum}.continuous{subject}{trial}.subj_states(1); 
% Add one because Unity indexes from zero
target=blocks{arnum}.discrete{subject}(trial).TargetStatenum+1;
start_move=blocks{arnum}.discrete{subject}(trial).start_move;
traj=RL_vars{arnum}.trajectories{target,start};

% Continuous variables (divide by two because the arena was scaled by two 
% when loaded into Unity)
sub_x=0.5*blocks{arnum}.continuous{subject}{trial}.SubPosZ;
sub_y=-0.5*blocks{arnum}.continuous{subject}{trial}.SubPosX;
time=blocks{arnum}.continuous{subject}{trial}.trialTime;

% Arena structure
figure; hold on
plot([arena.obstacles.x1';arena.obstacles.x2'],...
    [arena.obstacles.y1';arena.obstacles.y2'],'color',clrs.gray,'LineWidth',5)
plot([arena.boundary_edges.x1';arena.boundary_edges.x2'],...
    [arena.boundary_edges.y1';arena.boundary_edges.y2'],'color',clrs.gray)

% Trajectory
for step=2:length(traj) 
    plot([arena.centroids(traj(step),1),arena.centroids(traj(step-1),1)],...
        [arena.centroids(traj(step),2),arena.centroids(traj(step-1),2)],'--','linewidth',2,'color','k')
end

% Start and target
scatter(arena.centroids(target,1),arena.centroids(target,2),150,...
    'MarkerFaceColor','k','MarkerEdgeColor','k')
scatter(arena.centroids(start,1),arena.centroids(start,2),150,...
    'MarkerFaceColor','none','MarkerEdgeColor','k','linewidth',3)
scatter(sub_x(start_move:end),sub_y(start_move:end),12,time(start_move:end)-time(start_move)); 

% Format
movegui(gcf,'center'); axis equal; colormap(flipud(cmap));
set(gca,'visible','off','color','w'); set(gcf,'color','w','InvertHardCopy','off')