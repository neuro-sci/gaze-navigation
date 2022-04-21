function f5a_sweep_probability(blocks)
%% Interpolate trials turn-by-turn and find the probability of sweeping
% during pre-movement and movement
% NOTE: Trials skipped by the subjects were excluded from the analysis
% NOTE: Error bounds show standard error across all trials included in the
% analysis

clrs=def_colors; subjvec=[2,4,6,9,10,11,13,14,15,16,17,20,21];
n_timepts_premove=200; % interpoloate all pre-movement periods to 200 time points
PREMOVE_forward=nan(3500,n_timepts_premove); % pre-allocate a matrix larger than
% the total number of trials in the entire experiment
PREMOVE_backward=nan(3500,n_timepts_premove);
PREMOVE_forward_bySubject=nan(13,n_timepts_premove);
PREMOVE_backward_bySubject=nan(13,n_timepts_premove);
n_timepts_subgoal=25; % interpolate all turn periods to 25 frames (each)
n_subgoals=5; % consider the first 5 subgoals
n_timepts_between=100; % interpolate all periods in-between turns to 100 frames (each)
n_between=n_subgoals+1; % if there are 5 turns, there will be 6 straight segments
MOVE_forward=nan(3500,n_subgoals*n_timepts_subgoal+n_between*n_timepts_between);
MOVE_backward=nan(3500,n_subgoals*n_timepts_subgoal+n_between*n_timepts_between);
MOVE_forward_bySubject=nan(13,n_subgoals*n_timepts_subgoal+n_between*n_timepts_between);
MOVE_backward_bySubject=nan(13,n_subgoals*n_timepts_subgoal+n_between*n_timepts_between);
cut_before_stop=23; % cut 23 frames before the end of the trial because the subject
% is occupied with button press

%% Loop over all arenas/subjects/trials

row=1; subj_rows=nan(13,1);
for subj=1:13
    for arnum=1:5
        subject=subjvec(subj); continuous=blocks{arnum}.continuous{subject};
        sweeps=blocks{arnum}.sweeps{subject}; turns=blocks{arnum}.turns{subject};
        for trial=1:size(continuous,2)
            % Exclude skipped trials or trials in which subjects did not move
            if blocks{arnum}.discrete{subject}(trial).RewardZone==9 ...
                    || isempty(blocks{arnum}.discrete{subject}(trial).start_move)
                continue
            end
            detected=blocks{arnum}.discrete{subject}(trial).detect_frame;
            start_move=blocks{arnum}.discrete{subject}(trial).start_move;
            triallen=length(continuous{trial}.trialTime)-cut_before_stop;
            
            % Find when/if the subject is sweeping
            is_sweeping_forward=zeros(triallen,1);
            is_sweeping_backward=zeros(triallen,1);
            if ~isempty(sweeps{trial}.forward_sweeps)
                for sw=1:size(sweeps{trial}.forward_sweeps,1)
                    is_sweeping_forward(sweeps{trial}.forward_sweeps(sw,1):...
                        sweeps{trial}.forward_sweeps(sw,2))=1;
                end
            end
            if ~isempty(sweeps{trial}.backward_sweeps)
                for sw=1:size(sweeps{trial}.backward_sweeps,1)
                    is_sweeping_backward(sweeps{trial}.backward_sweeps(sw,1):...
                        sweeps{trial}.backward_sweeps(sw,2))=1;
                end
            end
            
            
            % Interpolate the occurrence of sweeps pre-movement
            if ~isnan(start_move)
                PREMOVE_backward(row,:)=interp1(detected:start_move,is_sweeping_backward(detected:start_move),...
                    linspace(detected,start_move,n_timepts_premove));
                PREMOVE_forward(row,:)=interp1(detected:start_move,is_sweeping_forward(detected:start_move),...
                    linspace(detected,start_move,n_timepts_premove));
                if ~isempty(turns{trial})
                    % From the end of the last turn until stop
                    MOVE_backward(row,(n_subgoals*(n_timepts_subgoal+n_timepts_between)+1):end)=...
                        interp1(turns{trial}.turn_end(height(turns{trial})):triallen,...
                        is_sweeping_backward(turns{trial}.turn_end(height(turns{trial})):triallen),...
                        linspace(turns{trial}.turn_end(height(turns{trial})),triallen,n_timepts_between));
                    MOVE_forward(row,(n_subgoals*(n_timepts_subgoal+n_timepts_between)+1):end)=...
                        interp1(turns{trial}.turn_end(height(turns{trial})):triallen,...
                        is_sweeping_forward(turns{trial}.turn_end(height(turns{trial})):triallen),...
                        linspace(turns{trial}.turn_end(height(turns{trial})),triallen,n_timepts_between));
                    % Go backwards to populate turns and straight segments
                    all_turns=flip(1:height(turns{trial}));
                    for trn=1:min([height(turns{trial}),n_subgoals])
                        t1=(n_subgoals-trn+1)*n_timepts_between+(n_subgoals-trn)*n_timepts_subgoal+1;
                        t2=t1+n_timepts_subgoal-1;
                        % Turns
                        MOVE_backward(row,t1:t2)=interp1(turns{trial}.turn_start(all_turns(trn)):...
                            turns{trial}.turn_end(all_turns(trn)),is_sweeping_backward(...
                            turns{trial}.turn_start(all_turns(trn)):turns{trial}.turn_end(all_turns(trn))),...
                            linspace(turns{trial}.turn_start(all_turns(trn)),...
                            turns{trial}.turn_end(all_turns(trn)),n_timepts_subgoal));
                        MOVE_forward(row,t1:t2)=interp1(turns{trial}.turn_start(all_turns(trn)):...
                            turns{trial}.turn_end(all_turns(trn)),is_sweeping_forward(...
                            turns{trial}.turn_start(all_turns(trn)):turns{trial}.turn_end(all_turns(trn))),...
                            linspace(turns{trial}.turn_start(all_turns(trn)),...
                            turns{trial}.turn_end(all_turns(trn)),n_timepts_subgoal));
                        t1=(n_subgoals-trn)*(n_timepts_between+n_timepts_subgoal)+1;
                        t2=t1+n_timepts_between-1;
                        % Straight segments between turns
                        if all_turns(trn)>1
                            MOVE_backward(row,t1:t2)=interp1(turns{trial}.turn_end(all_turns(trn)-1):...
                                turns{trial}.turn_start(all_turns(trn)),is_sweeping_backward(...
                                turns{trial}.turn_end(all_turns(trn)-1):turns{trial}.turn_start(all_turns(trn))),...
                                linspace(turns{trial}.turn_end(all_turns(trn)-1),...
                                turns{trial}.turn_start(all_turns(trn)),n_timepts_between));
                            MOVE_forward(row,t1:t2)=interp1(turns{trial}.turn_end(all_turns(trn)-1):...
                                turns{trial}.turn_start(all_turns(trn)),is_sweeping_forward(...
                                turns{trial}.turn_end(all_turns(trn)-1):turns{trial}.turn_start(all_turns(trn))),...
                                linspace(turns{trial}.turn_end(all_turns(trn)-1),...
                                turns{trial}.turn_start(all_turns(trn)),n_timepts_between));
                        else % From movement start to the first turn
                            MOVE_backward(row,t1:t2)=interp1(start_move:turns{trial}.turn_start(all_turns(trn)),...
                                is_sweeping_backward(start_move:turns{trial}.turn_start(all_turns(trn))),...
                                linspace(start_move,turns{trial}.turn_start(all_turns(trn)),n_timepts_between));
                            MOVE_forward(row,t1:t2)=interp1(start_move:turns{trial}.turn_start(all_turns(trn)),...
                                is_sweeping_forward(start_move:turns{trial}.turn_start(all_turns(trn))),...
                                linspace(start_move,turns{trial}.turn_start(all_turns(trn)),n_timepts_between));
                        end
                    end
                else % If there are no turns...
                    MOVE_backward(row,(n_subgoals*(n_timepts_subgoal+n_timepts_between)+1):end)=...
                        interp1(start_move:triallen,is_sweeping_backward(start_move:triallen),...
                        linspace(start_move,triallen,n_timepts_between));
                    MOVE_forward(row,(n_subgoals*(n_timepts_subgoal+n_timepts_between)+1):end)=...
                        interp1(start_move:triallen,is_sweeping_forward(start_move:triallen),...
                        linspace(start_move,triallen,n_timepts_between));
                end
            else
                PREMOVE_backward(row,:)=interp1(detected:triallen,is_sweeping_backward(detected:triallen),...
                    linspace(detected,triallen,n_timepts_premove));
                PREMOVE_forward(row,:)=interp1(detected:triallen,is_sweeping_forward(detected:triallen),...
                    linspace(detected,triallen,n_timepts_premove));
            end
            row=row+1;
        end
    end
    subj_rows(subj)=row;
end

%% Calculate per-subject means in order to calculate standard deviations

subj_rows=[0;subj_rows];
for subj=1:13
    PREMOVE_forward_bySubject(subj,:)=mean(PREMOVE_forward(...
        (subj_rows(subj)+1):subj_rows(subj+1),:),'omitnan');
    PREMOVE_backward_bySubject(subj,:)=mean(PREMOVE_backward(...
        (subj_rows(subj)+1):subj_rows(subj+1),:),'omitnan');
    MOVE_forward_bySubject(subj,:)=mean(MOVE_forward(...
        (subj_rows(subj)+1):subj_rows(subj+1),:),'omitnan');
    MOVE_backward_bySubject(subj,:)=mean(MOVE_backward(...
        (subj_rows(subj)+1):subj_rows(subj+1),:),'omitnan');
end
sterr_premove_forward=std(PREMOVE_forward_bySubject,'omitnan')/sqrt(13);
sterr_premove_backward=std(PREMOVE_backward_bySubject,'omitnan')/sqrt(13);
sterr_move_forward=std(MOVE_forward_bySubject,'omitnan')/sqrt(13);
sterr_move_backward=std(MOVE_backward_bySubject,'omitnan')/sqrt(13);

%% Plot pre-movement, backward

figure('position',[0 0 400 400]); hold on
% Error bounds
fill([1:size(PREMOVE_backward,2),flip([1:size(PREMOVE_backward,2)])]/size(PREMOVE_backward,2),...
    [mean(PREMOVE_backward,'omitnan')-sterr_premove_backward,...
    flip([mean(PREMOVE_backward,'omitnan')+sterr_premove_backward])],clrs.gold,'LineStyle','none')
% Mean
plot([1:size(PREMOVE_backward,2)]/size(PREMOVE_backward,2),...
    mean(PREMOVE_backward,'omitnan'),'linewidth',3,'color',0.7*clrs.gold)

movegui(gcf,'center')
set(gca,'color','w','fontsize',24,'Tickdir','out','Ticklength',[.03 .03]);
set(gcf,'color','w','InvertHardCopy','off')
xlim([0 1]); xticks([0 1]); xlabel('Norm time'); ylabel('P(sweep)');

%% Plot pre-movement, forward (plot not included in paper)

figure('position',[0 0 400 400]); hold on
% Error bounds
fill([1:size(PREMOVE_forward,2),flip([1:size(PREMOVE_forward,2)])]/size(PREMOVE_forward,2),...
    [mean(PREMOVE_forward,'omitnan')-sterr_premove_forward,...
    flip([mean(PREMOVE_forward,'omitnan')+sterr_premove_forward])],clrs.gold,'LineStyle','none')
% Mean
plot([1:size(PREMOVE_forward,2)]/size(PREMOVE_forward,2),...
    mean(PREMOVE_forward,'omitnan'),'linewidth',3,'color',0.7*clrs.gold)

movegui(gcf,'center')
set(gca,'color','w','fontsize',24,'Tickdir','out','Ticklength',[.03 .03]);
set(gcf,'color','w','InvertHardCopy','off')
xlim([0 1]); xticks([0 1]); xlabel('Norm time'); ylabel('P(sweep)');

%% Plot movement, backward (plot not included in paper)

figure('position',[0 0 800 400]); hold on
% Mean
plot([1:size(MOVE_backward,2)]/size(MOVE_backward,2),...
    mean(MOVE_backward,'omitnan'),'linewidth',3,'color',0.7*clrs.blue)
% Error bounds
fill([1:size(MOVE_backward,2),flip([1:size(MOVE_backward,2)])]/size(MOVE_backward,2),...
    [mean(MOVE_backward,'omitnan')-sterr_move_backward,...
    flip([mean(MOVE_backward,'omitnan')+sterr_move_backward])],clrs.blue,'LineStyle','none')
% Label turn epochs
yl=ylim;
for trn=1:n_subgoals
    t1=(n_subgoals-trn+1)*n_timepts_between+(n_subgoals-trn)*n_timepts_subgoal+1;
    t2=t1+n_timepts_subgoal-1;
    f(trn)=fill([t1,t2,t2,t1]/size(MOVE_backward,2),[yl(1),yl(1),yl(2),yl(2)],...
        clrs.lightgray,'LineStyle','none');
    set(f(trn),'facealpha',0.5)
end

movegui(gcf,'center')
graph_children=get(gca,'Children'); set(gca,'Children',flipud(graph_children))
set(gca,'color','w','fontsize',24,'Tickdir','out','Ticklength',[.03 .03]);
set(gcf,'color','w','InvertHardCopy','off')
xlim([0 1]); xticks([0 1]); xlabel('Norm time'); ylabel('P(sweep)');

%% Plot movement, forward 

figure('position',[0 0 800 400]); hold on
% Mean
plot([1:size(MOVE_forward,2)]/size(MOVE_forward,2),...
    mean(MOVE_forward,'omitnan'),'linewidth',3,'color',0.7*clrs.blue)
% Error bounds
fill([1:size(MOVE_forward,2),flip([1:size(MOVE_forward,2)])]/size(MOVE_forward,2),...
    [mean(MOVE_forward,'omitnan')-sterr_move_forward,...
    flip([mean(MOVE_forward,'omitnan')+sterr_move_forward])],clrs.blue,'LineStyle','none')
% Label turn epochs
yl=ylim;
for trn=1:n_subgoals
    t1=(n_subgoals-trn+1)*n_timepts_between+(n_subgoals-trn)*n_timepts_subgoal+1;
    t2=t1+n_timepts_subgoal-1;
    f(trn)=fill([t1,t2,t2,t1]/size(MOVE_backward,2),[yl(1),yl(1),yl(2),yl(2)],...
        clrs.lightgray,'LineStyle','none');
    set(f(trn),'facealpha',0.5)
end

movegui(gcf,'center')
graph_children=get(gca,'Children'); set(gca,'Children',flipud(graph_children))
set(gca,'color','w','fontsize',24,'Tickdir','out','Ticklength',[.03 .03]);
set(gcf,'color','w','InvertHardCopy','off')
xlim([0 1]); xticks([0 1]); xlabel('Norm time'); ylabel('P(sweep)');
