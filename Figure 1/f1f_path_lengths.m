function f1f_path_lengths(blocks)
%% Produces a scatter plot of path lengths in different arenas, 
% and another scatter plot of path lengths for rewarded vs. unrewarded trials
% NOTE: For this plot, the first trial for each run was excluded due to 
% potential software start-up effects on the path length variable (see Methods)
% NOTE: For this plot, trials for which the target is inaccessible were
% excluded
% NOTE: This plot may take several minutes to generate due to nested loops
% for the purpose of aesthetics

clrs=def_colors;
clr=[clrs.prim2mint1;clrs.prim2mint2;clrs.prim2mint3;clrs.prim2mint4;clrs.prim2mint5];
subjvec=[2,4,6,9,10,11,13,14,15,16,17,20,21];
pathlen_rewarded=nan(5,13,60); pathlen_unrewarded=nan(5,13,60);
optimal_rewarded=nan(5,13,60); optimal_unrewarded=nan(5,13,60);

for arnum=1:5
    for subj=1:13
        subject=subjvec(subj); discrete=blocks{arnum}.discrete{subject};
        rew=find([discrete.RewardZone]==1 | [discrete.RewardZone]==2);
        pathlen_rewarded(arnum,subj,rew)=[discrete(rew).pathlength]; 
        optimal_rewarded(arnum,subj,rew)=[discrete(rew).dist2targ]; 
        unrew=find([discrete.RewardZone]==0); 
        pathlen_unrewarded(arnum,subj,unrew)=[discrete(unrew).pathlength];
        optimal_unrewarded(arnum,subj,unrew)=[discrete(unrew).dist2targ];
    end
end

ind1=exclude_impossible_trials(blocks); ind2=exclude_first_runs; 
pathlen_rewarded([ind1,ind2])=NaN; pathlen_unrewarded([ind1,ind2])=NaN; 
optimal_rewarded([ind1,ind2])=NaN; optimal_unrewarded([ind1,ind2])=NaN; 

%% Plot path lengths in different arenas

figure; hold on; x=0:100; y=x;
% Shade the reward zone size in gray
rew_zone=fill([x,flip(x),x(1)],[y-4*sqrt(3)/3,flip(y+4*sqrt(3)/3),y(1)-4*sqrt(3)/3],clrs.lightgray);
set(rew_zone,'edgecolor','w')
% Rather than scattering all points pertaining to one arena as one layer,
% intersperse points from different arenas to help with visualization.
for trial=1:60, for subj=1:13, for arnum=1:5
    scatter(optimal_rewarded(arnum,subj,trial),pathlen_rewarded(arnum,subj,trial),...
        5,'MarkerFaceColor',clr(arnum,:),'MarkerEdgeColor',clr(arnum,:))
    scatter(optimal_unrewarded(arnum,subj,trial),pathlen_unrewarded(arnum,subj,trial),...
        5,'MarkerFaceColor',clr(arnum,:),'MarkerEdgeColor',clr(arnum,:))
end; end; end

movegui(gcf,'center'); axis equal
set(gca,'color','w','fontsize',24,'Tickdir','out','Ticklength',[.03 .03]); 
set(gcf,'color','w','InvertHardCopy','off'); 
xlim([0 40]); ylim([0 40]); xlabel('Predicted (m)'); ylabel('Observed (m)'); 

%% Plot path lengths for rewarded vs. unrewarded trials
% NOTE: The rare rewarded trials for which the predicted path length is
% greater than the observed path length result from imprecise
% classification of the subject's starting state

figure; hold on; 
rew_zone=fill([x,flip(x),x(1)],[y-4*sqrt(3)/3,flip(y+4*sqrt(3)/3),y(1)-4*sqrt(3)/3],clrs.lightgray);
set(rew_zone,'edgecolor','w')
for trial=1:60, for subj=1:13, for arnum=1:5
    scatter(optimal_rewarded(arnum,subj,trial),pathlen_rewarded(arnum,subj,trial),...
        5,'MarkerFaceColor',clrs.green,'MarkerEdgeColor',clrs.green)
    scatter(optimal_unrewarded(arnum,subj,trial),pathlen_unrewarded(arnum,subj,trial),...
        5,'MarkerFaceColor',clrs.red,'MarkerEdgeColor',clrs.red)
end; end; end

movegui(gcf,'center'); axis equal
set(gca,'color','w','fontsize',24,'Tickdir','out','Ticklength',[.03 .03]); 
set(gcf,'color','w','InvertHardCopy','off'); 
xlim([0 40]); ylim([0 40]); xlabel('Predicted (m)'); ylabel('Observed (m)');

%% Compute stats: ratio pathlen vs. optimal for rewarded trials

disp(['(exclude ',num2str(sum(optimal_rewarded==0,'all')),' of ',...
    num2str(sum(~isnan(optimal_rewarded),'all')),' trials to avoid division by zero)'])
pathlen_rewarded(optimal_rewarded==0)=NaN;
optimal_rewarded(optimal_rewarded==0)=NaN;
mean_ratio_all=mean(pathlen_rewarded./optimal_rewarded,'all','omitnan');
STD_ratio_all=nan(13,1);
for subj=1:13
    STD_ratio_all(subj)=mean(pathlen_rewarded(:,subj,:)./optimal_rewarded(:,subj,:),'all','omitnan');
end
STD_ratio_all=std(STD_ratio_all);
disp(['Mean ratio of pathlen to optimal trajectory to the subject stopping location, all rewarded trials is ',...
    num2str(mean_ratio_all),' +/- ',num2str(STD_ratio_all)])
