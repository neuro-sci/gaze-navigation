function AUC=calculate_AUC(true_vals,shuffled_vals)
%% Calculate the area under the curve when shuffled data is plotted against true data

if ~all(ismissing(true_vals))
    [f1,x1,flo,fup]=ecdf(true_vals); x1(isnan(flo) | isnan(fup))=[];
    f1(isnan(flo) | isnan(fup))=[];
end
if ~all(ismissing(shuffled_vals))
    [f2,x2,flo,fup]=ecdf(shuffled_vals); x2(isnan(flo) | isnan(fup))=[];
    f2(isnan(flo) | isnan(fup))=[];
end

if exist('x1') && exist('x2') && length(x1)>2 && length(x2)>2
    xcommon=0.000001:0.0001:1;
    f1_interp=interp1(x1,f1,xcommon,'previous','extrap'); % true
    f2_interp=interp1(x2,f2,xcommon,'previous','extrap'); % shuffled
    f1_interp=[0,f1_interp,1]; f2_interp=[0,f2_interp,1];
    f2_interp(isnan(f1_interp))=NaN; f1_interp(isnan(f2_interp))=NaN;
    f1_interp(isnan(f1_interp))=[]; f2_interp(isnan(f2_interp))=[];
    AUC=trapz(f1_interp,f2_interp);
else, AUC=NaN; end