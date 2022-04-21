function f2a_epoch_eyemvt_examples(blocks)
%% Plot the point of gaze during each epoch of an example trial

arnum=2; subject=15; trial=36; clrs=def_colors;
sub_x=0.5*blocks{arnum}.continuous{subject}{trial}.SubPosZ;
sub_y=-0.5*blocks{arnum}.continuous{subject}{trial}.SubPosX;
eye_x=0.5*blocks{arnum}.continuous{subject}{trial}.gazeX_noblink;
eye_y=0.5*blocks{arnum}.continuous{subject}{trial}.gazeY_noblink;

target=blocks{arnum}.discrete{subject}(trial).TargetStatenum+1;
start=blocks{arnum}.continuous{subject}{trial}.subj_states(1);
detected=blocks{arnum}.discrete{subject}(trial).detect_frame;
start_move=blocks{arnum}.discrete{subject}(trial).start_move;
stop_move=blocks{arnum}.discrete{subject}(trial).stop_move;

%% Plot

% Search epoch:
arena=blocks{arnum}.arena; display_arena(arena,start,target); 
scatter(eye_x(1:detected),eye_y(1:detected),10,'d',...
    'markerfacecolor',clrs.pink,'markeredgecolor',clrs.pink)

% Pre-move epoch:
arena=blocks{arnum}.arena; display_arena(arena,start,target); 
scatter(eye_x(detected:start_move),eye_y(detected:start_move),10,'d',...
    'markerfacecolor',clrs.gold,'markeredgecolor',clrs.gold)

% Move epoch:
arena=blocks{arnum}.arena; display_arena(arena,start,target); 
plot(sub_x(start_move:stop_move),sub_y(start_move:stop_move),'color','k','linewidth',3); 
scatter(eye_x(start_move:stop_move),eye_y(start_move:stop_move),10,'d',...
    'markerfacecolor',clrs.blue,'markeredgecolor',clrs.blue)
