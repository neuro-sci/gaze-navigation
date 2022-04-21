% Load "blocks" and "RL_vars" before running the code below

%% Produce Figure 1

f1b_arena_layout(blocks)
f1c_complexity_bar(blocks)
f1d_value_function(blocks,RL_vars)
f1e_example_trials(blocks,RL_vars)
f1f_path_lengths(blocks)
f1g_pathlen_ratio(blocks)
f1h_velocity_trace(blocks)
f1i_epoch_durations(blocks)
f1j_premove_duration(blocks)

%% Produce Figure 2

f2a_epoch_eyemvt_examples(blocks)
f2b_eyemvt_variance(blocks)
f2c_eyemvt_variance_LME(blocks)
f2d_gaze_atGoal_duration(blocks)
f2e_gaze_atGoal_duration_LME(blocks)
f2f_gaze_atGoal_distance(blocks)
f2g_gaze_atGoal_distance_LME(blocks)

%% Produce Figure 3

f3a_relevance_CDFs(blocks)
f3b_relevance_AUC(blocks)
f3c_duration_CDFs(blocks)
f3d_duration_AUC(blocks)
f3e_relevance_byArena(blocks)
f3f_duration_byArena(blocks)

%% Produce Figure 4

f4c_fraction_time_sweeping(blocks)
f4d_fraction_sweeping_backward_LME(blocks)
f4e_fraction_sweeping_forward_LME(blocks)

%% Produce Figure 5

f5a_sweep_probability(blocks)
f5b_dist_to_goal(blocks)
f5c_dist_to_subgoal(blocks)
f5d_prob_gaze_alternative(blocks)

%% Produce Figure S1

s1a_tesselation(blocks)
s1b_centrality_bar(blocks)
s1d_behavioral_performance(blocks)
s1e_behaviorial_performance_bySubject(blocks)
s1f_stopdist2goal_LME(blocks)

%% Produce Figure S2

s2a_performance_over_trials(blocks)
s2b_path_to_stop(blocks,RL_vars)
s2c_frac_rewarded(blocks)
s2d_epoch_pies(blocks)
s2e_premove_duration_effects(blocks)
s2f_premove_byRew(blocks)
s2g_epoch_duration_LMEs(blocks)

%% Produce Figure S3

s3a_variance_over_time

%% Produce Figure S4

s3a_gaze_atGoal_bySubgoal_bySubject(blocks)
s3b_premove_over_trials(blocks)
s3c_gaze_stacked_bar(blocks)
s3d_gaze_obstacles(blocks)

%% Produce Figure S7

s7_relevance_allArenas(blocks)

%% Produce Figure S8

s8a_gaze_trajectory(blocks)
s8b_trials_with_sweeps(blocks)
s8c_gaze_stacked_bar(blocks)
s8d_looktime_by_Nalternatives(blocks)

%% Produce Figure S9

s9a_sweep_statistics(blocks)
s9b_sweep_speed_LME(blocks)
s9c_sweep_duration_LME(blocks)
s9d_sweep_nsaccades_LME(blocks)
s9e_sweep_saccade_rate_LME(blocks)
s9f_sweep_saccade_rate(blocks)

%% Produce Figure S10

s10a_direction_first_sweep(blocks)
s10b_direction_first_sweep_bySubject(blocks)
s10c_first_sweep_time(blocks)
s10d_relevance_sweeps_traj_removed(blocks)

%% Produce Figure S11

s11a_MLR_premove_dur(blocks)
s11b_MLR_gaze_atGoal_duration(blocks)
s11c_MLR_fraction_time_sweeping(blocks)
