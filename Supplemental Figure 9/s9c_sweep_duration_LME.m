function s9c_sweep_duration_LME(blocks)
%% Fit linear mixed models for trial-specific effects on sweep durations
% NOTE: Only trials skipped by the subject were excluded from this analysis

clrs=def_colors; subjvec=[2,4,6,9,10,11,13,14,15,16,17,20,21];
duration_forward_premove=nan(5,13,60); duration_forward_move=nan(5,13,60);
duration_backward_premove=nan(5,13,60); duration_backward_move=nan(5,13,60);

%% Quantify the duration of sweeps

for arnum=1:5
    for subj=1:13
        subject=subjvec(subj); continuous=blocks{arnum}.continuous{subject};
        sweeps=blocks{arnum}.sweeps{subject};
        for trial=1:size(continuous,2)
            detected=blocks{arnum}.discrete{subject}(trial).detect_frame;
            start_move=blocks{arnum}.discrete{subject}(trial).start_move;
            time=continuous{trial}.trialTime;
            x=continuous{trial}.gazeX_noblink;
            y=continuous{trial}.gazeY_noblink;
            eye_dist_traveled=sqrt([0;diff(x)].^2+[0;diff(y)].^2);
            
            % Sweeps whose midpoint is beyond the start of movement are
            % classified as movement sweeps.
            if ~isempty(sweeps{trial}.forward_sweeps), f1=0; f2=0; nf1=0; nf2=0; df1=0; df2=0;
                for sw=1:size(sweeps{trial}.forward_sweeps,1)
                    if ~isnan(start_move) && sweeps{trial}.forward_sweeps(sw,1)+...
                            0.5*(sweeps{trial}.forward_sweeps(sw,2)-...
                            sweeps{trial}.forward_sweeps(sw,1))>=start_move
                        f2=f2+sum(eye_dist_traveled(sweeps{trial}.forward_sweeps(sw,1):...
                            sweeps{trial}.forward_sweeps(sw,2)),'omitnan');
                        nf2=nf2+1; df2=df2+time(sweeps{trial}.forward_sweeps(sw,2))-...
                            time(sweeps{trial}.forward_sweeps(sw,1));
                    elseif sweeps{trial}.forward_sweeps(sw,2)>=detected
                        f1=f1+sum(eye_dist_traveled(sweeps{trial}.forward_sweeps(sw,1):...
                            sweeps{trial}.forward_sweeps(sw,2)),'omitnan');
                        nf1=nf1+1; df1=df1+time(sweeps{trial}.forward_sweeps(sw,2))-...
                            time(sweeps{trial}.forward_sweeps(sw,1));
                    end     
                end
                if f1>0, duration_forward_premove(arnum,subj,trial)=df1/nf1; end
                if f2>0, duration_forward_move(arnum,subj,trial)=df2/nf2; end
            end
            if ~isempty(sweeps{trial}.backward_sweeps), b1=0; b2=0; nb1=0; nb2=0; db1=0; db2=0;
                for sw=1:size(sweeps{trial}.backward_sweeps,1)
                    if ~isnan(start_move) && sweeps{trial}.backward_sweeps(sw,1)+...
                            0.5*(sweeps{trial}.backward_sweeps(sw,2)-...
                            sweeps{trial}.backward_sweeps(sw,1))>=start_move
                        b2=b2+sum(eye_dist_traveled(sweeps{trial}.backward_sweeps(sw,1):...
                            sweeps{trial}.backward_sweeps(sw,2)),'omitnan');
                        nb2=nb2+1; db2=db2+time(sweeps{trial}.backward_sweeps(sw,2))-...
                            time(sweeps{trial}.backward_sweeps(sw,1));
                    elseif sweeps{trial}.backward_sweeps(sw,2)>=detected
                        b1=b1+sum(eye_dist_traveled(sweeps{trial}.backward_sweeps(sw,1):...
                            sweeps{trial}.backward_sweeps(sw,2)),'omitnan');
                        nb1=nb1+1; db1=db1+time(sweeps{trial}.backward_sweeps(sw,2))-...
                            time(sweeps{trial}.backward_sweeps(sw,1));
                    end 
                end
                if b1>0, duration_backward_premove(arnum,subj,trial,1)=db1/nb1; end
                if b2>0, duration_backward_move(arnum,subj,trial,1)=db2/nb2; end
            end
        end
    end
end

ind=exclude_skipped_trials(blocks);
duration_forward_premove(ind)=NaN; duration_forward_move(ind)=NaN;
duration_backward_premove(ind)=NaN; duration_backward_move(ind)=NaN;

%% LME: trial-specific effects on sweep duration: forward premove

[fixed_forward_premove_duration,random_forward_premove_duration,R_vals_forward_premove_duration,P_vals_forward_premove_duration]=...
    linear_mixed_effects(blocks,duration_forward_premove,clrs.gold);
ylabel('Relative effect');

%% LME: trial-specific effects on sweep duration: backward premove

[fixed_backward_premove_duration,random_backward_premove_duration,R_vals_backward_premove_duration,P_vals_backward_premove_duration]=...
    linear_mixed_effects(blocks,duration_backward_premove,clrs.gold);
ylabel('Relative effect');

%% LME: trial-specific effects on sweep duration: forward move

[fixed_forward_move_duration,random_forward_move_duration,R_vals_forward_move_duration,P_vals_forward_move_duration]=...
    linear_mixed_effects(blocks,duration_forward_move,clrs.blue);
ylabel('Relative effect');

%% LME: trial-specific effects on sweep duration: backward move

[fixed_backward_move_duration,random_backward_move_duration,R_vals_backward_move_duration,P_vals_backward_move_duration]=...
    linear_mixed_effects(blocks,duration_backward_move,clrs.blue);
ylabel('Relative effect');
