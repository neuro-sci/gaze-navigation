function f4c_fraction_time_sweeping(blocks)
%% Plot the fraction of time in pre-movement and movement that the subjects
% spend sweeping their trajectories in the forwards and backwards
% directions
% NOTE: Only trials skipped by the subject were excluded from this analysis
% NOTE: Error bars represent standard error across subjects

clrs=def_colors; subjvec=[2,4,6,9,10,11,13,14,15,16,17,20,21];
frac_forward_premove=nan(5,13,60); frac_forward_move=nan(5,13,60);
frac_backward_premove=nan(5,13,60); frac_backward_move=nan(5,13,60);
frac_forward_premove_byArena=nan(5,1); frac_forward_move_byArena=nan(5,1);
frac_backward_premove_byArena=nan(5,1); frac_backward_move_byArena=nan(5,1);
frac_forward_premove_bySubject=nan(5,13); frac_forward_move_bySubject=nan(5,13);
frac_backward_premove_bySubject=nan(5,13); frac_backward_move_bySubject=nan(5,13);
sterr_forward_premove=nan(5,1); sterr_forward_move=nan(5,1); 
sterr_backward_premove=nan(5,1); sterr_backward_move=nan(5,1);
mean_centrality=nan(5,1);

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

%% Remove skipped trials, compute averages and standard deviations

ind=exclude_skipped_trials(blocks);
frac_forward_premove(ind)=NaN; frac_backward_premove(ind)=NaN; 
frac_forward_move(ind)=NaN; frac_backward_move(ind)=NaN; 

for arnum=1:5
    for subj=1:13
        frac_forward_premove_bySubject(arnum,subj)=mean(squeeze(frac_forward_premove(arnum,subj,:)),'omitnan');
        frac_forward_move_bySubject(arnum,subj)=mean(squeeze(frac_forward_move(arnum,subj,:)),'omitnan');
        frac_backward_premove_bySubject(arnum,subj)=mean(squeeze(frac_backward_premove(arnum,subj,:)),'omitnan');
        frac_backward_move_bySubject(arnum,subj)=mean(squeeze(frac_backward_move(arnum,subj,:)),'omitnan');
    end
    frac_forward_premove_byArena(arnum)=mean(squeeze(frac_forward_premove(arnum,:,:)),'all','omitnan');
    frac_forward_move_byArena(arnum)=mean(squeeze(frac_forward_move(arnum,:,:)),'all','omitnan');
    frac_backward_premove_byArena(arnum)=mean(squeeze(frac_backward_premove(arnum,:,:)),'all','omitnan');
    frac_backward_move_byArena(arnum)=mean(squeeze(frac_backward_move(arnum,:,:)),'all','omitnan');
    
    sterr_forward_premove(arnum)=std(squeeze(frac_forward_premove_bySubject(arnum,:)),'omitnan')/sqrt(13);
    sterr_forward_move(arnum)=std(squeeze(frac_forward_move_bySubject(arnum,:)),'omitnan')/sqrt(13);
    sterr_backward_premove(arnum)=std(squeeze(frac_backward_premove_bySubject(arnum,:)),'omitnan')/sqrt(13);
    sterr_backward_move(arnum)=std(squeeze(frac_backward_move_bySubject(arnum,:)),'omitnan')/sqrt(13);
end

%% Perform linear regression
X=[-1:7]'; complexity=100*(-mean_centrality+0.1115);
forward_premove_line=fitlm(complexity,frac_forward_premove_byArena); 
forward_premove_pred=predict(forward_premove_line,X);
forward_move_line=fitlm(complexity,frac_forward_move_byArena); 
forward_move_pred=predict(forward_move_line,X);
backward_premove_line=fitlm(complexity,frac_backward_premove_byArena); 
backward_premove_pred=predict(backward_premove_line,X);
backward_move_line=fitlm(complexity,frac_backward_move_byArena); 
backward_move_pred=predict(backward_move_line,X);

%% Plot for forward sweeps

figure; hold on;
plot(X,forward_premove_pred,'color',clrs.gold);
plot(X,forward_move_pred,'color',clrs.blue);
scatter(complexity,frac_forward_premove_byArena,200,...
    'markerfacecolor',clrs.gold,'markeredgecolor','none')
scatter(complexity,frac_forward_move_byArena,200,...
    'markerfacecolor',clrs.blue,'markeredgecolor','none')
errorbar(complexity,frac_forward_premove_byArena,...
    sterr_forward_premove,'LineStyle','none','color','k','CapSize',0)
errorbar(complexity,frac_forward_move_byArena,...
    sterr_forward_move,'LineStyle','none','color','k','CapSize',0)

movegui(gcf,'center')
set(gca,'color','w','fontsize',24,'Tickdir','out','Ticklength',[.03 .03]); 
set(gcf,'color','w','InvertHardCopy','off'); 
xticks([0 3 6]); xlim([-1 7]); yticks([0 0.1 0.2]); ylim([0 0.2])
xlabel('Arena complexity'); ylabel('Fraction of time')

%% Plot for backward sweeps

figure; hold on;
plot(X,backward_premove_pred,'color',clrs.gold)
plot(X,backward_move_pred,'color',clrs.blue)
scatter(complexity,frac_backward_premove_byArena,200,...
    'markerfacecolor',clrs.gold,'markeredgecolor','none')
scatter(complexity,frac_backward_move_byArena,200,...
    'markerfacecolor',clrs.blue,'markeredgecolor','none')
errorbar(complexity,frac_backward_premove_byArena,...
    sterr_backward_premove,'LineStyle','none','color','k','CapSize',0)
errorbar(complexity,frac_backward_move_byArena,...
    sterr_backward_move,'LineStyle','none','color','k','CapSize',0)

movegui(gcf,'center')
set(gca,'color','w','fontsize',24,'Tickdir','out','Ticklength',[.03 .03]); 
set(gcf,'color','w','InvertHardCopy','off'); 
xticks([0 3 6]); xlim([-1 7]); yticks([0 0.1 0.2]); ylim([0 0.2])
xlabel('Arena complexity'); ylabel('Fraction of time')

%% Compute stats: correlation between fraction of time sweeping forward pre-movement and complexity
centrality_matrix=repmat(100*(complexity),1,13);
[R_premove_forward,P_premove_forward]=corrcoef(frac_forward_premove_bySubject(:),centrality_matrix(:));
disp(['correlation of fraction of time sweeping forward during pre-movement vs. arena complexity (df = 63) is ',...
    num2str(R_premove_forward(1,2)),', p_val = ',num2str(P_premove_forward(1,2))])

[R_move_forward,P_move_forward]=corrcoef(frac_forward_move_bySubject(:),centrality_matrix(:));
disp(['correlation of fraction of time sweeping forward during movement vs. arena complexity (df = 63) is ',...
    num2str(R_move_forward(1,2)),', p_val = ',num2str(P_move_forward(1,2))])

[R_premove_backward,P_premove_backward]=corrcoef(frac_backward_premove_bySubject(:),centrality_matrix(:));
disp(['correlation of fraction of time sweeping backward during pre-movement vs. arena complexity (df = 63) is ',...
    num2str(R_premove_backward(1,2)),', p_val = ',num2str(P_premove_backward(1,2))])

[R_move_backward,P_move_backward]=corrcoef(frac_backward_move_bySubject(:),centrality_matrix(:));
disp(['correlation of fraction of time sweeping backward during movement vs. arena complexity (df = 63) is ',...
    num2str(R_move_backward(1,2)),', p_val = ',num2str(P_move_backward(1,2))])

%% Compute stats: duration sweeping pre-movement vs movement, forward vs. backward

mean_forward_premove=mean(frac_forward_premove,'all','omitnan');
forward_premove_STD=nan(13,1);
for subj=1:13
    forward_premove_STD(subj)=mean(frac_forward_premove(:,subj,:),'all','omitnan');
end
forward_premove_STD=std(forward_premove_STD);
disp(['fraction of pre-movement spent sweeping forwards: ',num2str(mean_forward_premove),' +/- ',...
    num2str(forward_premove_STD)])

mean_forward_move=mean(frac_forward_move,'all','omitnan');
forward_move_STD=nan(13,1);
for subj=1:13
    forward_move_STD(subj)=mean(frac_forward_move(:,subj,:),'all','omitnan');
end
forward_move_STD=std(forward_move_STD);
disp(['fraction of movement spent sweeping forwards: ',num2str(mean_forward_move),' +/- ',...
    num2str(forward_move_STD)])

mean_backward_premove=mean(frac_backward_premove,'all','omitnan');
backward_premove_STD=nan(13,1);
for subj=1:13
    backward_premove_STD(subj)=mean(frac_backward_premove(:,subj,:),'all','omitnan');
end
backward_premove_STD=std(backward_premove_STD);
disp(['fraction of pre-movement spent sweeping backwards: ',num2str(mean_backward_premove),' +/- ',...
    num2str(backward_premove_STD)])

mean_backward_move=mean(frac_backward_move,'all','omitnan');
backward_move_STD=nan(13,1);
for subj=1:13
    backward_move_STD(subj)=mean(frac_backward_move(:,subj,:),'all','omitnan');
end
backward_move_STD=std(backward_move_STD);
disp(['fraction of movement spent sweeping backwards: ',num2str(mean_backward_move),' +/- ',...
    num2str(backward_move_STD)])
