function display_arena(arena,start,target)
%% Plot the layout of an arena

clrs=def_colors; figure; hold on
plot([arena.obstacles.x1';arena.obstacles.x2'],... % obstacles
    [arena.obstacles.y1';arena.obstacles.y2'],'color',clrs.lightgray,'LineWidth',3)
plot([arena.boundary_edges.x1';arena.boundary_edges.x2'],... % boundary
    [arena.boundary_edges.y1';arena.boundary_edges.y2'],'color',clrs.lightgray,'LineWidth',2)

if nargin==3
    scatter(arena.centroids(start,1),arena.centroids(start,2),150,'markeredgecolor','k','linewidth',3)
    scatter(arena.centroids(target,1),arena.centroids(target,2),150,'markerfacecolor','k','markeredgecolor','k')
end
movegui(gcf,'center'); axis equal; set(gca,'visible','off','color','w');
set(gcf,'visible','on','color','w','InvertHardCopy','off')