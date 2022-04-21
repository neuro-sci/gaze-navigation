function f1d_value_function(blocks,RL_vars)
%% Produce a value function for the corresponding trial depicted

arena=blocks{2}.arena; clrs=def_colors; cmap=clrs.paradise;
poly_xvals=[arena.state_vertices.x1';arena.state_vertices.x2';arena.state_vertices.x3'];
poly_yvals=[arena.state_vertices.y1';arena.state_vertices.y2';arena.state_vertices.y3'];
start=135; target=70; value_function=max(RL_vars{2}.Qvalues{target},[],2,'omitnan');
traj=RL_vars{2}.trajectories{target,start};

%% Plot
figure; hold on
patch(poly_xvals,poly_yvals,value_function,'Edgecolor','none') % values
plot([arena.obstacles.x1';arena.obstacles.x2'],...
    [arena.obstacles.y1';arena.obstacles.y2'],'color','k','LineWidth',3)
plot([arena.boundary_edges.x1';arena.boundary_edges.x2'],...
    [arena.boundary_edges.y1';arena.boundary_edges.y2'],'color','k')

for step=2:length(traj) % trajectory
    plot([arena.centroids(traj(step),1),arena.centroids(traj(step-1),1)],...
        [arena.centroids(traj(step),2),arena.centroids(traj(step-1),2)],':','linewidth',3,'color','k')
end

% Start and target
scatter(arena.centroids(target,1),arena.centroids(target,2),150,...
    'MarkerFaceColor','k','MarkerEdgeColor','k')
scatter(arena.centroids(start,1),arena.centroids(start,2),150,...
    'MarkerFaceColor','none','MarkerEdgeColor','k','linewidth',3)

%% Format
movegui(gcf,'center'); axis equal
set(gca,'visible','off','color','w'); set(gcf,'color','w','InvertHardCopy','off')
colormap(flipud(cmap)); c=colorbar; c.Ticks=[]; 
