function s9b_sweep_speed_LME(blocks)
%% Fit linear mixed models for trial-specific effects on sweep speeds
% NOTE: Only trials skipped by the subject were excluded from this analysis

clrs=def_colors; subjvec=[2,4,6,9,10,11,13,14,15,16,17,20,21];
speed_forward_premove=nan(5,13,60); speed_forward_move=nan(5,13,60);
speed_backward_premove=nan(5,13,60); speed_backward_move=nan(5,13,60);

%% Quantify the speed of sweeps

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
                if f1>0, speed_forward_premove(arnum,subj,trial)=f1/df1; end
                if f2>0, speed_forward_move(arnum,subj,trial)=f2/df2; end
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
                if b1>0, speed_backward_premove(arnum,subj,trial)=b1/db1; end
                if b2>0, speed_backward_move(arnum,subj,trial)=b2/db2; end
            end
        end
    end
end

ind=exclude_skipped_trials(blocks);
speed_forward_premove(ind)=NaN; speed_forward_move(ind)=NaN; 
speed_backward_premove(ind)=NaN; speed_backward_move(ind)=NaN; 

%% LME: trial-specific effects on sweep speed: forward premove

[fixed_forward_premove,random_forward_premove,R_vals_forward_premove,P_vals_forward_premove]=...
    linear_mixed_effects(blocks,speed_forward_premove,clrs.gold);
ylabel('Relative effect');

%% LME: trial-specific effects on sweep speed: backward premove

[fixed_backward_premove,random_backward_premove,R_vals_backward_premove,P_vals_backward_premove]=...
    linear_mixed_effects(blocks,speed_backward_premove,clrs.gold);
ylabel('Relative effect');

%% LME: trial-specific effects on sweep speed: forward move

[fixed_forward_move,random_forward_move,R_vals_forward_move,P_vals_forward_move]=...
    linear_mixed_effects(blocks,speed_forward_move,clrs.blue);
ylabel('Relative effect');

%% LME: trial-specific effects on sweep speed: backward move

[fixed_backward_move,random_backward_move,R_vals_backward_move,P_vals_backward_move]=...
    linear_mixed_effects(blocks,speed_backward_move,clrs.blue);
ylabel('Relative effect');
