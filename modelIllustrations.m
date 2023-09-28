function modelIllustrations
% Make the plots which illustrate the model in the derivations paper

framesA = (randn(8, 1)*2)+2;
framesB = (randn(8, 1)*2)+1;

framesA = repmat(framesA', 20, 1);
framesB = repmat(framesB', 20, 1);

framesA = framesA(:);
framesB = framesB(:);

incAccumA = framesA + randn(size(framesA));
incAccumB = framesB + randn(size(framesA));

diffInc = incAccumB - incAccumA;

accum = cumsum(diffInc);

close all
figure; hold on

t = 1 : length(framesA);

subplot(1, 3, 1)
plot(t, framesB - framesA);
ylim([-6, 6])
ax = gca;
ax.YLabel.String = {'Difference in', 'stimulus evidence'};

subplot(1, 3, 2)
plot(t, diffInc)
ylim([-10, 10])
ax = gca;
ax.YLabel.String = 'Noisy evidence measurement';

subplot(1, 3, 3)
plot(t, accum)
ylim([-400, 400])
ax = gca;
ax.YLabel.String = 'Accumulator state';

for i = 1 : 3
    subplot(1, 3, i)
    ax = gca;
    ax.XAxisLocation = 'origin';
    ax.XTick = [];
    ax.YTick = [];
    ax.XLabel.String = 'Time';
    currentY = ax.XLabel.Position(2); 
    ax.XLabel.Position(2) = -currentY*3; 
    box off
    set(findall(gcf, 'Type', 'Line'), 'LineWidth', 1, 'Color', 'k');
    set(gca, 'linewidth', 1)
end