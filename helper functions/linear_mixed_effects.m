function [fixed,random,R_vals,P_vals]=linear_mixed_effects(blocks,dependent_var,COLOR)
%% Fit a linear mixed effects model with random intercept by subject,
% fixed effects for number of turns, optimal path length, and trial angle,
% and random effects for the same qualities

subjID_matrix=repmat([1:13],5,1,60); clrs=def_colors;
[NTURNS,BEARING,LENGTH]=get_trial_qualities(blocks);
% [NTURNS,BEARING,LENGTH,OPTIONS]=get_trial_qualities(blocks);
dependent_var=zscore_reshape(dependent_var);
var_table=table(subjID_matrix(:),NTURNS(:),LENGTH(:),BEARING(:),dependent_var(:),...
    'VariableNames',{'SubjectID','NTurns','PathLength','TrialAngle','Dependent'});
% var_table=table(subjID_matrix(:),NTURNS(:),LENGTH(:),BEARING(:),OPTIONS(:),dependent_var(:),...
%     'VariableNames',{'SubjectID','NTurns','PathLength','TrialAngle','Options','Dependent'});
model=fitlme(var_table,'Dependent~NTurns+PathLength+TrialAngle+(NTurns-1|SubjectID)+(PathLength-1|SubjectID)+(TrialAngle-1|SubjectID)+(1|SubjectID)');
% model=fitlme(var_table,'Dependent~NTurns+PathLength+TrialAngle+Options+(NTurns-1|SubjectID)+(PathLength-1|SubjectID)+(TrialAngle-1|SubjectID)+(Options-1|SubjectID)+(1|SubjectID)');
fixed=fixedEffects(model); random=randomEffects(model);

figure('Position',[0 0 450 375]); hold on; 
% bar(1,fixed(1),'EdgeColor','none','FaceColor',COLOR)
bar(2,fixed(2),'EdgeColor','none','FaceColor',COLOR)
bar(3,fixed(3),'EdgeColor','none','FaceColor',COLOR)
bar(4,fixed(4),'EdgeColor','none','FaceColor',COLOR)
% bar(5,fixed(5),'EdgeColor','none','FaceColor',COLOR)
R_vals=nan(13,4); P_vals=nan(13,4);

for subj=1:13
%     scatter(1+(rand(1)-0.5)/3,fixed(1)+random(52+subj),35,'filled','MarkerFaceColor',clrs.gray)
    [R,P]=corrcoef(reshape(squeeze(NTURNS(:,subj,:)),5*60,1),reshape(squeeze(dependent_var(:,subj,:)),5*60,1),'rows','complete');
    R_vals(subj,1)=R(1,2); P_vals(subj,1)=P(1,2);
    if P_vals(subj,1)>0.05, scatter(2+(rand(1)-0.5)/3,fixed(2)+random(subj),35,'filled','MarkerFaceColor',0.7*COLOR)
    else, scatter(2+(rand(1)-0.5)/3,fixed(2)+random(subj),35,'filled','MarkerFaceColor',0.7*COLOR); end
    [R,P]=corrcoef(reshape(squeeze(LENGTH(:,subj,:)),5*60,1),reshape(squeeze(dependent_var(:,subj,:)),5*60,1),'rows','complete');
    R_vals(subj,2)=R(1,2); P_vals(subj,2)=P(1,2);
    if P_vals(subj,2)>0.05, scatter(3+(rand(1)-0.5)/3,fixed(3)+random(13+subj),35,'filled','MarkerFaceColor',0.7*COLOR)
    else, scatter(3+(rand(1)-0.5)/3,fixed(3)+random(13+subj),35,'filled','MarkerFaceColor',0.7*COLOR); end
    [R,P]=corrcoef(reshape(squeeze(BEARING(:,subj,:)),5*60,1),reshape(squeeze(dependent_var(:,subj,:)),5*60,1),'rows','complete');
    R_vals(subj,3)=R(1,2); P_vals(subj,3)=P(1,2);
    if P_vals(subj,3)>0.05, scatter(4+(rand(1)-0.5)/3,fixed(4)+random(26+subj),35,'filled','MarkerFaceColor',0.7*COLOR)
    else, scatter(4+(rand(1)-0.5)/3,fixed(4)+random(26+subj),35,'filled','MarkerFaceColor',0.7*COLOR); end
%     [R,P]=corrcoef(reshape(squeeze(OPTIONS(:,subj,:)),5*60,1),reshape(squeeze(dependent_var(:,subj,:)),5*60,1),'rows','complete');
%     R_vals(subj,4)=R(1,2); P_vals(subj,4)=P(1,2);
%     if P_vals(subj,4)>0.05, scatter(5+(rand(1)-0.5)/3,fixed(5)+random(39+subj),35,'filled','MarkerFaceColor','k')
%     else, scatter(5+(rand(1)-0.5)/3,fixed(5)+random(39+subj),35,'filled','MarkerFaceColor','k'); end
end

movegui(gcf,'center'); set(gca,'fontsize',24,'color','w','Tickdir','out','Ticklength',[.03 .03]);
set(gcf,'color','w','InvertHardCopy','off'); xtickangle(90)
xticklabels({'# Turns','Length','Bearing'}); xlim([1 5]); xticks([2:4]);
% xticklabels({'# Turns','Length','Bearing','# Options'}); xlim([1 6]); xticks([2:5]);
ax=gca; yax=ax.YAxis; set(yax,'TickDirection','out'); 

%% Check if residuals are normally distributed, and the number of significant correlations

% BTW: if the p value is < 5e-4, it will just return 5e-4 (this is what the warning says)
warning off stats:adtest:OutOfRangePLow 
RESIDUALS=residuals(model); varname=inputname(2);
[ISNORMAL,P_ad]=adtest(RESIDUALS); % Use an Anderson-Darling test
if ISNORMAL, disp(['residuals are normally distributed (p = ',num2str(P_ad),') for ',varname]); else
    disp(['residuals are NOT normally distributed (p = ',num2str(P_ad),') for ',varname]); end

disp(['The correlation between NTURNS and ',varname, ' is significant for ',num2str(sum(P_vals(:,1)<=0.05)),'/13 subjects'])
disp(['The correlation between LENGTH and ',varname, ' is significant for ',num2str(sum(P_vals(:,2)<=0.05)),'/13 subjects'])
disp(['The correlation between ANGLE and ',varname, ' is significant for ',num2str(sum(P_vals(:,3)<=0.05)),'/13 subjects'])
% disp(['The correlation between OPTIONS and ',varname, ' is significant for ',num2str(sum(P_vals(:,4)<=0.05)),'/13 subjects'])
