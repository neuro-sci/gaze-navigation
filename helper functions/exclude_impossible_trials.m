function ind=exclude_impossible_trials(blocks)
%% Remove trials for which targets or starting locations are not accessible 
% due to the obstacle configuration

subjvec=[2,4,6,9,10,11,13,14,15,16,17,20,21];
I_arena=[]; I_subj=[]; I_trial=[];

arnum=3;
for subj=1:13
    subject=subjvec(subj); discrete=blocks{arnum}.discrete{subject};
    continuous=blocks{arnum}.continuous{subject};
    exclude=find([discrete.TargetStatenum]+1==110 | [discrete.TargetStatenum]+1==111);
    for trial=1:size(discrete,2)
       if continuous{trial}.subj_states(1)==110 || continuous{trial}.subj_states(1)==111
           exclude=[exclude,trial];
       end
    end
    I_trial=[I_trial,exclude]; I_subj=[I_subj,subj*ones(1,length(exclude))];
end
I_arena=[I_arena,arnum*ones(1,length(I_subj))];

arnum=4;
for subj=1:13
    subject=subjvec(subj); discrete=blocks{arnum}.discrete{subject};
    continuous=blocks{arnum}.continuous{subject};
    exclude=find([discrete.TargetStatenum]+1==148);
    for trial=1:size(discrete,2)
       if continuous{trial}.subj_states(1)==148
           exclude=[exclude,trial];
       end
    end
    I_trial=[I_trial,exclude]; I_subj=[I_subj,subj*ones(1,length(exclude))];
end
I_arena=[I_arena,arnum*ones(1,length(I_subj)-length(I_arena))];
ind=sub2ind([5,13,60],I_arena,I_subj,I_trial);