function s2b_path_to_stop(blocks,RL_vars)
%% Produce a scatter plot of path lengths to the stopping location for 
% unrewarded trials, and produce a plot of the ratio of observed vs.
% predicted path lengths for unrewarded trials w.r.t. the stopping location
% NOTE: Error bars show standard error (across subjects)
% NOTE: For this plot, the first trial for each run was excluded due to 
% potential software start-up effects on the path length variable (see Methods)
% NOTE: For this plot, trials for which the target is inaccessible were
% excluded
% NOTE: This plot may take several minutes to generate due to nested loops
% for the purpose of aesthetics

clrs=def_colors;
clr=[clrs.prim2mint1;clrs.prim2mint2;clrs.prim2mint3;clrs.prim2mint4;clrs.prim2mint5];
subjvec=[2,4,6,9,10,11,13,14,15,16,17,20,21];
pathlen_unrewarded=nan(5,13,60); optimal_unrewarded=nan(5,13,60);

for arnum=1:5
    trajectories=RL_vars{arnum}.trajectories;
    for subj=1:13
        subject=subjvec(subj); discrete=blocks{arnum}.discrete{subject};
        continuous=blocks{arnum}.continuous{subject};
        unrew=find([discrete.RewardZone]==0); 
        pathlen_unrewarded(arnum,subj,unrew)=[discrete(unrew).pathlength];
        for trial=1:size(discrete,2)
            if discrete(trial).RewardZone~=0, continue; end
            starting_state=find(~isnan(continuous{trial}.subj_states),1); 
            stopping_state=find(~isnan(continuous{trial}.subj_states),1,'last');
            
            traj=trajectories{continuous{trial}.subj_states(stopping_state),...
                continuous{trial}.subj_states(starting_state)}; path_to_stop=0;
            if length(traj)>1
                for step=2:length(traj)
                    path_to_stop=path_to_stop+...
                        sqrt((blocks{arnum}.arena.centroids(traj(step),1)-...
                        blocks{arnum}.arena.centroids(traj(step-1),1))^2+...
                        (blocks{arnum}.arena.centroids(traj(step),2)-...
                        blocks{arnum}.arena.centroids(traj(step-1),2))^2);
                end
            end
            % scale by two as the arena was scaled by two when imported into Unity
            optimal_unrewarded(arnum,subj,trial)=2*path_to_stop;
        end
    end
end

ind1=exclude_impossible_trials(blocks); ind2=exclude_first_runs; 
pathlen_unrewarded([ind1,ind2])=NaN; optimal_unrewarded([ind1,ind2])=NaN; 

%% Plot path lengths in different arenas

figure; hold on; x=0:100; y=x;
% Shade the reward zone size in gray
rew_zone=fill([x,flip(x),x(1)],[y-4*sqrt(3)/3,flip(y+4*sqrt(3)/3),y(1)-4*sqrt(3)/3],clrs.lightgray);
set(rew_zone,'edgecolor','w')
% Rather than scattering all points pertaining to one arena as one layer,
% intersperse points from different arenas to help with visualization.
for trial=1:60, for subj=1:13, for arnum=1:5
    scatter(optimal_unrewarded(arnum,subj,trial),pathlen_unrewarded(arnum,subj,trial),...
        5,'MarkerFaceColor',clr(arnum,:),'MarkerEdgeColor',clr(arnum,:))
end; end; end

movegui(gcf,'center'); axis equal
set(gca,'color','w','fontsize',24,'Tickdir','out','Ticklength',[.03 .03]); 
set(gcf,'color','w','InvertHardCopy','off'); 
xlim([0 40]); ylim([0 40]); xlabel('Predicted (m)'); ylabel('Observed (m)'); 

%% Calculate the ratio of observed vs. predicted path lengths

mean_centrality=nan(5,1); ratio_byArena=nan(5,1); 
ratio_bySubject=nan(5,13); ste_overSubjects=nan(5);
for arnum=1:5
    G=graph(blocks{arnum}.arena.neighbor); C=centrality(G,'closeness')*149; 
    mean_centrality(arnum)=mean(C); 
    
    % Trials for which the start and target locations were identitical were
    % exluded from the ratio to avoid dividing by zero
    pathlen_unrewarded(optimal_unrewarded==0)=NaN;
    optimal_unrewarded(optimal_unrewarded==0)=NaN;
    ratio_byArena(arnum)=mean(squeeze(pathlen_unrewarded(arnum,:,:))./...
        squeeze(optimal_unrewarded(arnum,:,:)),'all','omitnan');
    
    for subj=1:13
        subject=subjvec(subj);
        ratio_bySubject(arnum,subj)=mean(squeeze(pathlen_unrewarded(arnum,subj,:))./...
            squeeze(optimal_unrewarded(arnum,subj,:)),'omitnan');
    end
    ste_overSubjects(arnum)=std(ratio_bySubject(arnum,:),'omitnan')/sqrt(13);
end

%% Plot

figure('Position',[0 0 375 400]); hold on; 
plot(flip(-mean_centrality+0.1115),flip(ratio_byArena),'color','k')
for arnum=1:5
    scatter(-mean_centrality(arnum)+0.1115,ratio_byArena(arnum),200,...
        'markerfacecolor',clr(arnum,:),'markeredgecolor','k')
    errorbar(-mean_centrality(arnum)+0.1115,ratio_byArena(arnum),...
        ste_overSubjects(arnum),'color','k','CapSize',0)
end

movegui(gcf,'center')
set(gca,'color','w','fontsize',18,'Tickdir','out','Ticklength',[.03 .03]); 
set(gcf,'color','w','InvertHardCopy','off'); 
xticks([0 0.03 0.06]); xlim([-0.01 0.07]); ylim([0 1.5])
xlabel('Arena complexity'); ylabel('Observed / Predicted')

%% Compute stats: % frac of optimal for unrewarded trials

mean_ratio_all=100*mean(pathlen_unrewarded./optimal_unrewarded,'all','omitnan');
STD_ratio_all=nan(13,1);
for subj=1:13
    STD_ratio_all(subj)=100*mean(pathlen_unrewarded(:,subj,:)./optimal_unrewarded(:,subj,:),'all','omitnan');
end
STD_ratio_all=std(STD_ratio_all);
disp(['Mean ratio of pathlen to optimal trajectory to the subject stopping location, all unrewarded trials is ',...
    num2str(mean_ratio_all),' +/- ',num2str(STD_ratio_all)])
