function s1f_stopdist2goal_LME(blocks)
%% Fit linear mixed model for the effect of trial-specific variables
% on the distance of stop from goal

%% Preallocate

clrs=def_colors; stop_dist_from_goal=nan(5,13,60);
subjvec=[2,4,6,9,10,11,13,14,15,16,17,20,21];

%% Save the variables for plotting

for arnum=1:5
    for subj=1:13
        subject=subjvec(subj); discrete=blocks{arnum}.discrete{subject};
        continuous=blocks{arnum}.continuous{subject};
        
        for trial=1:size(continuous,2)
            % NOTE: Matlab x = Unity z, and Matlab y = Unity -x
            % NOTE: Scale goal location by two b/c the arena was scaled by
            % two when loaded into Unity
            stop_dist_from_goal(arnum,subj,trial)=...
                sqrt((2*blocks{arnum}.arena.centroids(discrete(trial).TargetStatenum+1,1)-...
                continuous{trial}.SubPosZ(end))^2+...
                (2*blocks{arnum}.arena.centroids(discrete(trial).TargetStatenum+1,2)+...
                continuous{trial}.SubPosX(end))^2);
        end
    end
end

%% Fit LME

[fixed,random,R_vals,P_vals]=linear_mixed_effects(blocks,stop_dist_from_goal,clrs.gold);
ylabel('Relative effect');
