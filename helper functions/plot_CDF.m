function [f1_interp,f2_interp]=plot_CDF(true_vals,shuffled_vals,clr1,clr2)
%% Plot a CDF with shaded confidence intervals.
% Also return CDF functions f1 (true) and f2 (shuffled) as an option.

if ~all(ismissing(true_vals))
    [f1,x1,flo,fup]=ecdf(true_vals); x1(isnan(flo) | isnan(fup))=[];
    f1(isnan(flo) | isnan(fup))=[]; flo(isnan(fup))=[]; fup(isnan(fup))=[];
    fup(isnan(flo))=[]; flo(isnan(flo))=[];
    if length(x1)>1
        FILL=fill([x1(2:end-1);flip(x1(2:end-1));x1(2)],...
            [flo(2:end-1);flip(fup(2:end-1));flo(2)],clr1);
        set(FILL,'facealpha',0.35,'edgecolor','none')
        plot(x1,f1,'linewidth',2,'color',clr1)
    end
end

if ~all(ismissing(shuffled_vals))
    [f2,x2,flo,fup]=ecdf(shuffled_vals); x2(isnan(flo) | isnan(fup))=[];
    f2(isnan(flo) | isnan(fup))=[]; flo(isnan(fup))=[]; fup(isnan(fup))=[];
    fup(isnan(flo))=[]; flo(isnan(flo))=[];
    if length(x2)>1
        FILL=fill([x2(2:end-1);flip(x2(2:end-1));x2(2)],...
            [flo(2:end-1);flip(fup(2:end-1));flo(2)],clr2);
        set(FILL,'facealpha',0.35,'edgecolor','none')
        plot(x2,f2,'linewidth',2,'color',clr2)
    end
end

set(gca,'color','w','fontsize',24,'XScale','log','Tickdir','out','Ticklength',[.03 .03]);
ax=gca; ax.XMinorTick='off'; xlim([0.001 1]); xticks([0.01,0.1,1]); 
xticklabels({'10^{-2}','10^{-1}','10^{0}'}); xlabel('Relevance (log)')
ylabel('CDF'); ylim([0 1]);

%% Interpolate

xcommon=0.000001:0.0001:1;
f1_interp=interp1(x1,f1,xcommon,'previous','extrap'); % true
f2_interp=interp1(x2,f2,xcommon,'previous','extrap'); % shuffled
f1_interp=[0,f1_interp,1]; f2_interp=[0,f2_interp,1];
f2_interp(isnan(f1_interp))=NaN; f1_interp(isnan(f2_interp))=NaN;
f1_interp(isnan(f1_interp))=[]; f2_interp(isnan(f2_interp))=[];