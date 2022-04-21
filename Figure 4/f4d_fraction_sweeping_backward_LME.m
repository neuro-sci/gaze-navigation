function f4d_fraction_sweeping_backward_LME(blocks)
%% Fit linear mixed effects models for trial-specific effects on the 
% fraction of time in pre-movement and movement that the subjects
% spend sweeping their trajectories in the backwards direction
% NOTE: Only trials skipped by the subject were excluded from this analysis

clrs=def_colors; subjvec=[2,4,6,9,10,11,13,14,15,16,17,20,21];
frac_backward_premove=nan(5,13,60); frac_backward_move=nan(5,13,60);

%% Quantify the fraction of time spent sweeping

for arnum=1:5
    for subj=1:13
        subject=subjvec(subj);
        continuous=blocks{arnum}.continuous{subject};
        sweeps=blocks{arnum}.sweeps{subject};
        for trial=1:size(continuous,2)
            is_sweeping_forward=zeros(length(continuous{trial}.trialTime),1);
            is_sweeping_backward=zeros(length(continuous{trial}.trialTime),1);
            detected=blocks{arnum}.discrete{subject}(trial).detect_frame;
            start_move=blocks{arnum}.discrete{subject}(trial).start_move;
            stop_move=blocks{arnum}.discrete{subject}(trial).stop_move;
            
            if ~isempty(sweeps{trial}.forward_sweeps)
                for sw=1:size(sweeps{trial}.forward_sweeps,1)
                    is_sweeping_forward(sweeps{trial}.forward_sweeps(sw,1):sweeps{trial}.forward_sweeps(sw,2))=1;
                end
            end
            if ~isempty(sweeps{trial}.backward_sweeps)
                for sw=1:size(sweeps{trial}.backward_sweeps,1)
                    is_sweeping_backward(sweeps{trial}.backward_sweeps(sw,1):sweeps{trial}.backward_sweeps(sw,2))=1;
                end
            end
            
            if ~isnan(start_move)
                frac_backward_premove(arnum,subj,trial)=sum(is_sweeping_backward(detected:start_move))/...
                    length(is_sweeping_backward(detected:start_move));
                if ~isnan(stop_move)
                    frac_backward_move(arnum,subj,trial)=sum(is_sweeping_backward(start_move:stop_move))/...
                        length(is_sweeping_backward(start_move:stop_move));
                else % If the subject presses the end-trial button while still moving...
                    frac_backward_move(arnum,subj,trial)=sum(is_sweeping_backward(start_move:end))/...
                        length(is_sweeping_backward(start_move:end));
                end
            else % If the subject does not move during the trial...
                frac_backward_premove(arnum,subj,trial)=sum(is_sweeping_backward(detected:end))/...
                    length(is_sweeping_backward(detected:end));
            end
        end
    end
end

ind=exclude_skipped_trials(blocks);
frac_backward_premove(ind)=NaN; 
frac_backward_move(ind)=NaN; 

%% LME: trial-specific effects on fraction of time sweeping: backward premove

[fixed_backward_premove,random_backward_premove,R_vals_backward_premove,P_vals_backward_premove]=...
    linear_mixed_effects(blocks,frac_backward_premove,clrs.gold);
ylabel('Relative effect');

%% LME: trial-specific effects on fraction of time sweeping: backward move

[fixed_backward_move,random_backward_move,R_vals_backward_move,P_vals_backward_move]=...
    linear_mixed_effects(blocks,frac_backward_move,clrs.blue);
ylabel('Relative effect');
