function f1b_arena_layout(blocks)
%% Produces plots of the layout of all five arenas

clrs=def_colors;
clr=[clrs.prim2mint1;clrs.prim2mint2;clrs.prim2mint3;clrs.prim2mint4;clrs.prim2mint5];
for arnum=1:5
    arena=blocks{arnum}.arena; figure; hold on
    plot([arena.obstacles.x1';arena.obstacles.x2'],... % obstacles
        [arena.obstacles.y1';arena.obstacles.y2'],'color',clr(arnum,:),'LineWidth',5)
    plot([arena.boundary_edges.x1';arena.boundary_edges.x2'],... % boundary
        [arena.boundary_edges.y1';arena.boundary_edges.y2'],'color',clr(arnum,:),'LineWidth',5)
    % format
    movegui(gcf,'center'); axis equal; set(gca,'visible','off','color','w');
    set(gcf,'visible','on','color','w','InvertHardCopy','off')
end