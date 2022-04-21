function MLR_slopes=MLR_length_complexity(dependent_var,LENGTH,complexity,COLOR)
%% Perform multiple linear regression to disambiguate the effects of 
% complexity vs. path length on behavioral variables

complexity_matrix=repmat(complexity,[1 13 60]); MLR_slopes=nan(13,2);
for subj=1:13
    y=dependent_var(:,subj,:); x1=LENGTH(:,subj,:); x2=complexity_matrix(:,subj,:);
    z_scored_y=(y(:)-mean(y,'all','omitnan'))/std(y,[],'all','omitnan');
    z_scored_x1=(x1(:)-mean(x1,'all','omitnan'))/std(x1,[],'all','omitnan');
    z_scored_x2=(x2(:)-mean(x2,'all','omitnan'))/std(x2,[],'all','omitnan');
    MLR_slopes(subj,:)=regress(z_scored_y,[z_scored_x1 z_scored_x2]);
end

%% Plot the regression slopes
figure('Position',[0 0 300 400]); hold on; 
bar(1,mean(MLR_slopes(:,1),'omitnan'),'EdgeColor','none','FaceColor',COLOR)
scatter(ones(13,1).*(1+(rand(13,1)-0.5)/3),MLR_slopes(:,1),50,'filled','MarkerFaceColor',COLOR-0.3*COLOR)
bar(2,mean(MLR_slopes(:,2),'omitnan'),'EdgeColor','none','FaceColor',COLOR)
scatter(ones(13,1).*(2+(rand(13,1)-0.5)/3),MLR_slopes(:,2),50,'filled','MarkerFaceColor',COLOR-0.3*COLOR)
movegui(gcf,'center'); ylabel('Relative effect')
xlim([0 3]); xticks([1,2]); xticklabels({'Length','Complexity'}); xtickangle(90)
set(gca,'color','w','fontsize',24,'Tickdir','out','Ticklength',[.03 .03]); 
set(gcf,'color','w','InvertHardCopy','off'); 