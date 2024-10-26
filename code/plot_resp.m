function [fh, varminmax] = plot_resp(Cm, Cl, Cu, vmaturities, opt)
% PURPOSE: Plot the impact response of the yield curve and other variables
% INPUTS:
% Cm, Cl, Cu - matrix C (Ns x Nv): median, lower, upper
% vmaturities - Nv vector with maturities of interest rates and NaN for others
arguments
    Cm double
    Cl double
    Cu double
    vmaturities double
    opt.variableNames string = ""
    opt.varminmax double = []
    opt.showTitles logical = true
    opt.RowLabels string = ""
end
vmaturities = vmaturities(:)';
vnoty = find(isnan(vmaturities));
vylds = find(~isnan(vmaturities));
xxylds = vmaturities(vylds);
xxnoty = [-0.5 0.5];

xxylds_lab = arrayfun(@(x) sprintf('%dY',x), xxylds, 'UniformOutput', false);
xxylds_lab(logical(rem(xxylds,1))) = {''};
xxylds_lab = [{'0'} xxylds_lab];

Ns = size(Cm,1);
Nnoty = length(vnoty);

if opt.variableNames == ""
    opt.variableNames = "var" + (1:size(Cm,2));
end

if isempty(opt.varminmax)
    scl = 1.01;
    %varminmax = [min([Cl*scl; Cu*scl; -ones(1,Nv)]); max([Cl*scl; Cu*scl; ones(1,Nv)])]';
    opt.varminmax = [min([Cl*scl; Cu*scl]); max([Cl*scl; Cu*scl])]';
end

pos = [5, 1, 6+max(3,3*length(vnoty)), Ns*3.3];
fh = figure('Units','centimeters','Position',pos);

if Nnoty==0
    tl = tiledlayout("vertical");
    yldspan = [1,1];
elseif Nnoty==1
    tl = tiledlayout(Ns, 3);
    yldspan = [1,2];
else
    tl = tiledlayout(Ns, 2*Nnoty);
    yldspan = [1,Nnoty];
end
tl.OuterPosition = [0.03 0 1 1]; % make room for RowLabels

for ss = 1:Ns
    % plot the yield curve
    nexttile(yldspan)
    toplot = [Cm(ss,vylds); Cl(ss,vylds); Cu(ss,vylds)];
    hold on
    fill([xxylds fliplr(xxylds)], [toplot(2,:) fliplr(toplot(3,:))], [0.7, 0.8, 1], 'EdgeColor', 'none')
    plot(xxylds, toplot(1,:), '-b', 'LineWidth', 1.5, 'Marker', '.', 'MarkerSize',14)
    ylim([floor(min(opt.varminmax(vylds,1))) ceil(max(opt.varminmax(vylds,2)))])
    yline(0)
    xticks([0 xxylds])
    xticklabels(xxylds_lab)
    ylabel('basis points')
    set(gca, 'YGrid', 'on', 'XGrid', 'off')
    if ss==1 && opt.showTitles, title('yield curve'), end
    % plot the other variables
    for ivv = 1:Nnoty
        vv = vnoty(ivv);
        toplot = [Cm(ss,vv); Cl(ss,vv); Cu(ss,vv)];
        nexttile
        hold on
        fill([xxnoty fliplr(xxnoty)], [toplot(2) toplot(2) toplot(3) toplot(3)], [0.7 0.8 1], 'EdgeColor', 'none')
        plot(xxnoty, [toplot(1) toplot(1)], '-b', 'LineWidth', 1.5)
        yline(0)
        ylim(opt.varminmax(vv,:))
        xlim([-1 1])
        xticks([])
        grid on
        if ss==1 && opt.showTitles, title(opt.variableNames(vv), 'Interpreter', 'none'), end
    end
end


% add row labels
if not(opt.RowLabels=="")
    ppos = [];
    for c = 1:length(fh.Children.Children)
        ppos = [ppos; fh.Children.Children(c).Position];
    end
    rowlocs = sort(unique(ppos(:,2)), 1, 'descend');
    rowheight = ppos(1,end);

    for ss = 1:length(rowlocs)
        annotation('textbox', [0 rowlocs(ss)+0.4*rowheight 0.1 0.05], ...
            String=opt.RowLabels(ss), FontSize=11, EdgeColor='none', HorizontalAlignment='left');
    end
end