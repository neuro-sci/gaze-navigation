function [NTURNS,BEARING,LENGTH,OPTIONS]=get_trial_qualities(blocks,k,u)
%% Find qualities of trials such as the number of turns, the angle that
% the subject must initially travel relative to the angle that they must
% travel to the target, the length of the optimal trajectory, and the
% number of alternative paths.
% k is the largest allowable ratio of the alternative path to the optimal
% path (default = 1.25)
% u is the maximum state overlap between alternative paths (default = 0.5 = 50%)

% NOTE: These quantities are normalized by subject across all arenas, such
% that they take on a value between 0 and 1. I.e. the normalized LENGTH
% value corresponds to the length of the optimal trajectory on a trial
% divided by the length of the longest optimal trajectory ever experienced
% by that subject.

load('RL_vars.mat')
%% 

if nargin<3, u=0.5; if nargin<2, k=1.25; end; end
NTURNS=nan(5,13,60); BEARING=nan(5,13,60); LENGTH=nan(5,13,60); OPTIONS=nan(5,13,60);
subjvec=[2,4,6,9,10,11,13,14,15,16,17,20,21];


for arnum=1:5
    A=blocks{arnum}.arena.neighbor; G=graph(A);
    % Scale by 2 b/c the arena was scaled by 2 when loaded into Unity
    centroids=2*blocks{arnum}.arena.centroids;
    for subj=1:13
        subject=subjvec(subj); continuous=blocks{arnum}.continuous{subject};
        for trial=1:size(continuous,2)
            NTURNS(arnum,subj,trial)=height(blocks{arnum}.turns{subject}{trial});
            LENGTH(arnum,subj,trial)=blocks{arnum}.discrete{subject}(trial).dist2targ;
            
            target=blocks{arnum}.discrete{subject}(trial).TargetStatenum+1;
            start=find(~isnan(continuous{trial}.subj_states),1,'first');
            start=continuous{trial}.subj_states(start);

            % Look up the optimal trajectory
            trajectory=RL_vars{arnum}.trajectories{target,start};
            if length(trajectory)>2
                % Find how subjects should leave their current position
                x1=centroids(trajectory(1),1); y1=centroids(trajectory(1),2);
                x2=centroids(trajectory(2),1); y2=centroids(trajectory(2),2);
                path_start=[x2-x1,y2-y1,0];
                % Find how subjects should approach the target
                x3=centroids(trajectory(end-1),1); y3=centroids(trajectory(end-1),2);
                x4=centroids(trajectory(end),1); y4=centroids(trajectory(end),2);
                path_end=[x4-x3,y4-y3,0];
                % Find the angle between the two lines of travel
                BEARING(arnum,subj,trial)=abs(atan(norm(cross(path_start,path_end))/dot(path_start,path_end)));
            else
                BEARING(arnum,subj,trial)=0;
            end
            
            if arnum~=5
                shortest_path=shortestpath(G,start,target);
                if ~isnan(shortest_path)
                    paths=allpaths(G,start,target,'MaxPathLength',ceil(k*length(shortest_path)));
                    if size(paths,1)>1
                        % Assign the first (shortest) path as unique
                        clear comparison_paths; comparison_paths{1}=paths{1};
                        for p=2:size(paths,1), is_unique=1;
                            % For each subsequent path, compare it against
                            % paths designated as unique. If the overlap is
                            % greater than a certain percentage, then the path
                            % is not unique. Else, add the path to the list of
                            % unique paths.
                            for c=1:size(comparison_paths,2)
                                if length(intersect(comparison_paths{c},paths{p}))>(u*length(comparison_paths{c}))
                                    is_unique=0;
                                end
                            end
                            if is_unique, comparison_paths{c+1}=paths{p}; end
                        end
                        % Count the number of unique paths
                        OPTIONS(arnum,subj,trial)=size(comparison_paths,2);
                    else
                        OPTIONS(arnum,subj,trial)=1;
                    end
                else
                    OPTIONS(arnum,subj,trial)=nan;
                end
            else
                OPTIONS(arnum,subj,trial)=1;
            end
        end
    end
    disp(['arena ',num2str(arnum),' done'])
end

% Z-score each independent variable by subject
NTURNS=zscore_reshape(NTURNS);
LENGTH=zscore_reshape(LENGTH);
BEARING=zscore_reshape(BEARING);
OPTIONS=zscore_reshape(OPTIONS);
