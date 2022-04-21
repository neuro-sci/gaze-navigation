function z_scored_var=zscore_reshape(original_var)
%% Z score a matrix of dimensions (arenas, subjects, trials) by subject
% through reshaping the matrix to (arenas x trials, subjects), z-scoring
% each column, and reshaping back to the original shape.

temp_var=nan(5*60,13); z_scored_var=nan(5,13,60);
for subj=1:13
    temp_var(:,subj)=reshape(squeeze(original_var(:,subj,:))',5*60,1);
end
temp_var=bsxfun(@minus,temp_var,nanmean(temp_var,1));
temp_var=bsxfun(@rdivide,temp_var,nanstd(temp_var,[],1));

for subj=1:13
    for arnum=1:5
        z_scored_var(arnum,subj,:)=temp_var((arnum-1)*60+[1:60],subj);
    end
end