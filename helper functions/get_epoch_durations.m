function epoch_durations=get_epoch_durations(blocks)
%% Get the epoch durations for each arena, subject, and trial

search=nan(5,13,60); pre_move=nan(5,13,60); move=nan(5,13,60); 
post_move=nan(5,13,60); entire_trial=nan(5,13,60);
subjvec=[2,4,6,9,10,11,13,14,15,16,17,20,21];

for arnum=1:5
    for subj=1:13
        subject=subjvec(subj); discrete=blocks{arnum}.discrete{subject};
        continuous=blocks{arnum}.continuous{subject};
        for trial=1:size(continuous,2)
            search(arnum,subj,trial)=continuous{trial}.trialTime(discrete(trial).detect_frame);
            if ~isnan(discrete(trial).start_move)
                pre_move(arnum,subj,trial)=continuous{trial}.trialTime(discrete(trial).start_move)-...
                    continuous{trial}.trialTime(discrete(trial).detect_frame);
                if ~isnan(discrete(trial).stop_move)
                    move(arnum,subj,trial)=continuous{trial}.trialTime(discrete(trial).stop_move)-...
                        continuous{trial}.trialTime(discrete(trial).start_move);
                    post_move(arnum,subj,trial)=continuous{trial}.trialTime(end)-...
                        continuous{trial}.trialTime(discrete(trial).stop_move);
                else % If the subject presses the end-trial button while still moving...
                    move(arnum,subj,trial)=continuous{trial}.trialTime(end)-...
                        continuous{trial}.trialTime(discrete(trial).start_move);
                    post_move(arnum,subj,trial)=0;
                end
            else % If the subject does not move during the trial...
                 pre_move(arnum,subj,trial)=continuous{trial}.trialTime(end)-...
                     continuous{trial}.trialTime(discrete(trial).detect_frame);
                 move(arnum,subj,trial)=0; post_move(arnum,subj,trial)=0;
            end
            entire_trial(arnum,subj,trial)=continuous{trial}.trialTime(end);
        end
    end
end
ind=exclude_skipped_trials(blocks);
search(ind)=NaN; pre_move(ind)=NaN; move(ind)=NaN; post_move(ind)=NaN;

epoch_durations.search=search; epoch_durations.pre_move=pre_move;
epoch_durations.move=move; epoch_durations.post_move=post_move;
epoch_durations.entire_trial=entire_trial;
