function ind=exclude_skipped_trials(blocks)
%% Find the unrolled indices of trials which subjects skipped because
% they did not see the target at all

subjvec=[2,4,6,9,10,11,13,14,15,16,17,20,21];
I_arena=[]; I_subj=[]; I_trial=[];

for arnum=1:5
    for subj=1:13
        subject=subjvec(subj);
        skipped=find([blocks{arnum}.discrete{subject}.RewardZone]==9);
        I_arena=[I_arena,arnum*ones(1,length(skipped))];
        I_subj=[I_subj,subj*ones(1,length(skipped))];
        I_trial=[I_trial,skipped];
    end
end
ind=sub2ind([5,13,60],I_arena,I_subj,I_trial);