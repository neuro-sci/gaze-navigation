function s1a_tesselation(blocks)
%% Plot the tesselation

clrs=def_colors; arena=blocks{1}.arena; figure; hold on
plot([arena.inner_edges.x1';arena.inner_edges.x2'],...
    [arena.inner_edges.y1';arena.inner_edges.y2'],'--','color',clrs.lightgray)
plot([arena.boundary_edges.x1';arena.boundary_edges.x2'],... % boundary
        [arena.boundary_edges.y1';arena.boundary_edges.y2'],'color','k')
    
% Format and save
movegui(gcf,'center'); axis equal; set(gca,'visible','off','color','w');
set(gcf,'visible','on','color','w','InvertHardCopy','off')
