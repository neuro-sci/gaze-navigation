function s9d_sweep_nsaccades_LME(blocks)
%% Fit linear mixed models for trial-specific effects on the number of saccades
% during sweeps.
% NOTE: Only trials skipped by the subject were excluded from this analysis

clrs=def_colors; subjvec=[2,4,6,9,10,11,13,14,15,16,17,20,21];
nsaccades_forward_premove=nan(5,13,60); nsaccades_forward_move=nan(5,13,60);
nsaccades_backward_premove=nan(5,13,60); nsaccades_backward_move=nan(5,13,60);

%% Quantify the number of saccades

for arnum=1:5
    for subj=1:13
        subject=subjvec(subj); continuous=blocks{arnum}.continuous{subject};
        sweeps=blocks{arnum}.sweeps{subject};
        for trial=1:size(continuous,2)
            detected=blocks{arnum}.discrete{subject}(trial).detect_frame;
            start_move=blocks{arnum}.discrete{subject}(trial).start_move;
            time=continuous{trial}.trialTime;
            saccading=zeros(length(continuous{trial}.trialTime),1);
            is_sweeping=zeros(length(continuous{trial}.trialTime),1);
            
            % NOTE: x in MATLAB is z in Unity. y in MATLAB is -x in Unity.
            % Algorithmically define saccades by smoothing the relative eye
            % position with a moving average window of size 9 frames. Then
            % detect when speeds exceed a threshold of 200 deg/s.
            x=continuous{trial}.gazeX_noblink-continuous{trial}.SubPosZ; x=movmedian(x,9);
            y=continuous{trial}.gazeY_noblink+continuous{trial}.SubPosX; y=movmedian(y,9);
            z=continuous{trial}.hitPointsY-continuous{trial}.SubPosY; z=movmedian(z,9);
            alpha=atan2d(x,sqrt(y.^2+z.^2)); beta=atan2d(z,sqrt(x.^2+y.^2));
            eye_speeds=sqrt([0;diff(alpha)].^2+[0;diff(beta)].^2)*90;
            saccading([0;diff(eye_speeds>200)]==1)=1;
            
            % Sweeps whose midpoint is beyond the start of movement are
            % classified as movement sweeps.
            if ~isempty(sweeps{trial}.forward_sweeps), f1=0; f2=0; sf1=0; sf2=0; df1=0; df2=0;
                for sw=1:size(sweeps{trial}.forward_sweeps,1)
                    is_sweeping(sweeps{trial}.forward_sweeps(sw,1):...
                        sweeps{trial}.forward_sweeps(sw,2))=1;
                    if ~isnan(start_move) && sweeps{trial}.forward_sweeps(sw,1)+...
                            0.5*(sweeps{trial}.forward_sweeps(sw,2)-...
                            sweeps{trial}.forward_sweeps(sw,1))>=start_move
                        f2=f2+1; sf2=sf2+sum(saccading(sweeps{trial}.forward_sweeps(sw,1):...
                            sweeps{trial}.forward_sweeps(sw,2)));
                        df2=df2+time(sweeps{trial}.forward_sweeps(sw,2))-...
                            time(sweeps{trial}.forward_sweeps(sw,1));
                    elseif sweeps{trial}.forward_sweeps(sw,1)+...
                            0.5*(sweeps{trial}.forward_sweeps(sw,2)-...
                            sweeps{trial}.forward_sweeps(sw,1))>=detected
                        f1=f1+1; sf1=sf1+sum(saccading(sweeps{trial}.forward_sweeps(sw,1):...
                            sweeps{trial}.forward_sweeps(sw,2)));
                        df1=df1+time(sweeps{trial}.forward_sweeps(sw,2))-...
                            time(sweeps{trial}.forward_sweeps(sw,1));
                    end     
                end
                if f1>0, nsaccades_forward_premove(arnum,subj,trial)=sf1/f1; end
                if f2>0, nsaccades_forward_move(arnum,subj,trial)=sf2/f2; end
            end
            if ~isempty(sweeps{trial}.backward_sweeps), b1=0; b2=0; sb1=0; sb2=0; db1=0; db2=0;
                for sw=1:size(sweeps{trial}.backward_sweeps,1)
                    is_sweeping(sweeps{trial}.backward_sweeps(sw,1):...
                        sweeps{trial}.backward_sweeps(sw,2))=1;
                    if ~isnan(start_move) && sweeps{trial}.backward_sweeps(sw,1)+...
                            0.5*(sweeps{trial}.backward_sweeps(sw,2)-...
                            sweeps{trial}.backward_sweeps(sw,1))>=start_move
                        b2=b2+1; sb2=sb2+sum(saccading(sweeps{trial}.backward_sweeps(sw,1):...
                            sweeps{trial}.backward_sweeps(sw,2)));
                        db2=db2+time(sweeps{trial}.backward_sweeps(sw,2))-...
                            time(sweeps{trial}.backward_sweeps(sw,1));
                    elseif sweeps{trial}.backward_sweeps(sw,1)+...
                            0.5*(sweeps{trial}.backward_sweeps(sw,2)-...
                            sweeps{trial}.backward_sweeps(sw,1))>=detected
                        b1=b1+1; sb1=sb1+sum(saccading(sweeps{trial}.backward_sweeps(sw,1):...
                            sweeps{trial}.backward_sweeps(sw,2)));
                        db1=db1+time(sweeps{trial}.backward_sweeps(sw,2))-...
                            time(sweeps{trial}.backward_sweeps(sw,1));
                    end 
                end
                if b1>0, nsaccades_backward_premove(arnum,subj,trial)=sb1/b1; end
                if b2>0, nsaccades_backward_move(arnum,subj,trial)=sb2/b2; end
            end
        end
    end
end

ind=exclude_skipped_trials(blocks);
nsaccades_forward_premove(ind)=NaN; nsaccades_forward_move(ind)=NaN; 
nsaccades_backward_premove(ind)=NaN; nsaccades_backward_move(ind)=NaN; 

%% LME: trial-specific effects on number of saccades per sweep: forward premove

[fixed_forward_premove,random_forward_premove,R_vals_forward_premove,P_vals_forward_premove]=...
    linear_mixed_effects(blocks,nsaccades_forward_premove,clrs.gold);
ylabel('Relative effect');

%% LME: trial-specific effects on number of saccades per sweep: backward premove

[fixed_backward_premove,random_backward_premove,R_vals_backward_premove,P_vals_backward_premove]=...
    linear_mixed_effects(blocks,nsaccades_backward_premove,clrs.gold);
ylabel('Relative effect');

%% LME: trial-specific effects on number of saccades per sweep: forward move

[fixed_forward_move,random_forward_move,R_vals_forward_move,P_vals_forward_move]=...
    linear_mixed_effects(blocks,nsaccades_forward_move,clrs.blue);
ylabel('Relative effect');

%% LME: trial-specific effects on number of saccades per sweep: backward move

[fixed_backward_move,random_backward_move,R_vals_backward_move,P_vals_backward_move]=...
    linear_mixed_effects(blocks,nsaccades_backward_move,clrs.blue);
ylabel('Relative effect');
