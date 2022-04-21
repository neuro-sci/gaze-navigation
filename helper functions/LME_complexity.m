function [fixed,random,R_vals,P_vals]=LME_complexity(independent_var,dependent_var)
%% Fit a linear mixed effects model with random intercept by subject,
% fixed effects for arena complexity (or number of turns remaining),
% and random effects for arena complexity by subject

independent_var=bsxfun(@minus,independent_var,nanmean(independent_var,1));
independent_var=bsxfun(@rdivide,independent_var,nanstd(independent_var,[],1));
dependent_var=bsxfun(@minus,dependent_var,nanmean(dependent_var,1));
dependent_var=bsxfun(@rdivide,dependent_var,nanstd(dependent_var,[],1));
independent_matrix=repmat(independent_var,1,13);
subjID_matrix=repmat([1:13],length(independent_var),1); clrs=def_colors();
var_table=table(subjID_matrix(:),independent_matrix(:),dependent_var(:),...
    'VariableNames',{'SubjectID','Independent','Dependent'});
model=fitlme(var_table,'Dependent~Independent+(1|SubjectID)+(Independent-1|SubjectID)');
fixed=fixedEffects(model); random=randomEffects(model);
R_vals=nan(13,1); P_vals=nan(13,1);

% figure('Position',[0 0 300 375]); hold on; 
% bar(1,fixed(2),'FaceColor',clrs.lightgray,'EdgeColor','none')
for subj=1:13
    [R,P]=corrcoef(independent_var,...
        squeeze(dependent_var(:,subj)),'rows','complete');
    R_vals(subj)=R(1,2); P_vals(subj)=P(1,2);
%     if P_vals(subj)<0.05
%         scatter((1+(rand(1)-0.5)/2),fixed(2)+random(13+subj),100,...
%             'filled','MarkerFaceColor',clrs.subjects(subj,:),'MarkerEdgeColor','k')
%     else
%         scatter((1+(rand(1)-0.5)/2),fixed(2)+random(13+subj),100,...
%             'filled','MarkerFaceColor',0.5*([1,1,1]-clrs.subjects(subj,:))+...
%             clrs.subjects(subj,:),'MarkerEdgeColor','w')
%     end
end
% movegui(gcf,'center'); set(gca,'fontsize',24,'color','w','Ticklength',[.03 .03]);
% set(gcf,'color','w','InvertHardCopy','off'); xticks([])
% ax=gca; yax=ax.YAxis; set(yax,'TickDirection','out'); 
varname1=inputname(1); varname2=inputname(2);
disp(['The correlation between ',varname1,' and ',varname2, ' is significant for ',num2str(sum(P_vals<=0.05)),'/13 subjects'])


slopes=fixed(2)+random(14:26);
slopes_CV=std(slopes,'omitnan')/mean(slopes,'omitnan');
disp(['Subject-specific slopes: mean = ',num2str(mean(slopes,'omitnan')),', CV = ',num2str(slopes_CV)])