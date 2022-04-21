function s11c_MLR_fraction_time_sweeping(blocks)
%% Produce a bar plot showing the relative effect of arena complexity vs.
% path length on the fraction of time spent sweeping forward and backward
% during pre-movement and movement
% NOTE: Only trials skipped by the subject were excluded from this analysis

subjvec=[2,4,6,9,10,11,13,14,15,16,17,20,21];
frac_forward_premove=nan(5,13,60); frac_forward_move=nan(5,13,60);
frac_backward_premove=nan(5,13,60); frac_backward_move=nan(5,13,60);
mean_centrality=nan(5,1); clrs=def_colors; 

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
                frac_forward_premove(arnum,subj,trial)=sum(is_sweeping_forward(detected:start_move))/...
                    length(is_sweeping_forward(detected:start_move));
                frac_backward_premove(arnum,subj,trial)=sum(is_sweeping_backward(detected:start_move))/...
                    length(is_sweeping_backward(detected:start_move));
                if ~isnan(stop_move)
                    frac_forward_move(arnum,subj,trial)=sum(is_sweeping_forward(start_move:stop_move))/...
                        length(is_sweeping_forward(start_move:stop_move));
                    frac_backward_move(arnum,subj,trial)=sum(is_sweeping_backward(start_move:stop_move))/...
                        length(is_sweeping_backward(start_move:stop_move));
                else % If the subject presses the end-trial button while still moving...
                    frac_forward_move(arnum,subj,trial)=sum(is_sweeping_forward(start_move:end))/...
                        length(is_sweeping_forward(start_move:end));
                    frac_backward_move(arnum,subj,trial)=sum(is_sweeping_backward(start_move:end))/...
                        length(is_sweeping_backward(start_move:end));
                end
            else % If the subject does not move during the trial...
                frac_forward_premove(arnum,subj,trial)=sum(is_sweeping_forward(detected:end))/...
                    length(is_sweeping_forward(detected:end));
                frac_backward_premove(arnum,subj,trial)=sum(is_sweeping_backward(detected:end))/...
                    length(is_sweeping_backward(detected:end));
            end
        end
    end
    G=graph(blocks{arnum}.arena.neighbor); C=centrality(G,'closeness')*149; 
    mean_centrality(arnum)=mean(C); 
end

%% Fit regression models and plot
complexity=100*(-mean_centrality+0.1115);
[~,~,LENGTH]=get_trial_qualities(blocks);
MLR_slopes=MLR_length_complexity(frac_forward_premove,LENGTH,complexity,clrs.green);
MLR_slopes=MLR_length_complexity(frac_forward_move,LENGTH,complexity,clrs.green);
MLR_slopes=MLR_length_complexity(frac_backward_premove,LENGTH,complexity,clrs.red);
MLR_slopes=MLR_length_complexity(frac_backward_move,LENGTH,complexity,clrs.red);
