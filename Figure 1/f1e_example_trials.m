function f1e_example_trials(blocks,RL_vars)
%% Plot example trials in each arena (generates five figures)

subjvec=[2,4,6,9,10,11,13,14,15,16,17,20,21];
subj=6; subject=subjvec(subj); trials=[29,21,9,24,22];

for arnum=1:5
     plot_example_trial(blocks,RL_vars,arnum,subject,trials(arnum))
end