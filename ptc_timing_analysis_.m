%%% ptc_timing_analysis.m performs all the analysis relevant to the timing
%%% of radial stop - ptc contact.

close all
clear all

% Load in data
load('C:\Users\jonny\Documents\JP_toTake\MATLAB\PtC Timing\PtC_data.mat');

%% Prepare data for analysis %%

% Adapt data to ensure that kinematics from the wingbeat following ptc contact
% are being analysed (i.e. the kinematics being influenced by contact timing).
% Do this by removing the first datapoint and adding a Null point to the end to
% make sure the dimensions agree.

% Wingbeat amplitude
amp_follow = amp_tot; # Initialise a new instance of the data
amp_follow(1) = []; # Remove the first datapoint...
amp_follow = [amp_follow; NaN]; # and add a Null point at the end

% Mean stroke deviation angle
meanDev_follow = meanDev_tot;
meanDev_follow(1) = [];
meanDev_follow = [meanDev_follow; NaN];

% Min stroke deviation angle
minDev_follow = minDev_tot;
minDev_follow(1) = [];
minDev_follow = [minDev_follow; NaN];

% Max stroke deviation angle
maxStrAng_follow = maxStrAng_tot;
maxStrAng_follow(1) = [];
maxStrAng_follow = [maxStrAng_follow; NaN];

% Min stroke deviation angle
minStrAng_follow = minStrAng_tot;
minStrAng_follow(1) = [];
minStrAng_follow = [minStrAng_follow; NaN];

% Downstroke angle of incidence
downAOI_follow = downAOI_tot;
downAOI_follow(1) = [];
downAOI_follow = [downAOI_follow; NaN];

% Minimum downstroke angle of incidence
minDownAOI_follow = minDownAOI_tot;
minDownAOI_follow(1) = [];
minDownAOI_follow = [minDownAOI_follow; NaN];

% Stroke plan angle
plane_follow = plane_tot;
plane_follow(1) = [];
plane_follow = [plane_follow; NaN];

% Supination timing
sup_tot(sup_tot<0.35)=NaN; # Remove definitive outliers (impossible values)

% Determine the latency between the timing of the downstroke end and PtC contact
downLatency = down_tot - ptc_tot;

% Determine the latency between the timing of wing supination and PtC contact
supLatency = sup_tot - ptc_tot;

# Initialise matrices to store data
downLatencyG1 = [];
downLatencyG2 = [];
downLatencyG3 = [];
supLatencyG1 = [];
supLatencyG2 = [];
supLatencyG3 = [];


%% Assign required data to appropriate gears %%

# Run through dataset and assign downstroke and supination data to appropriate
# wingbeat gear
for i=1:length(gear_tot)
    switch gear_tot(i)
        case 1
            downLatencyG1 = [downLatencyG1; downLatency(i)];
            supLatencyG1 = [supLatencyG1; supLatency(i)];
        case 2
            downLatencyG2 = [downLatencyG2; downLatency(i)];;
            supLatencyG2 = [supLatencyG2; supLatency(i)];
        case 3
            downLatencyG3 = [downLatencyG3; downLatency(i)];;
            supLatencyG3 = [supLatencyG3; supLatency(i)];
    end
end

%% Perform data regression %%

% regress data
[b bint r rint stats] = regress(ptc_tot(gear_tot==3),[ones(length(down_tot(gear_tot==3)),1) down_tot(gear_tot==3)]);

[b bint r rint stats] = regress(ptc_tot(gear_tot==3),[ones(length(sup_tot(gear_tot==3)),1) sup_tot(gear_tot==3)]);

[b bint r rint stats] = regress(ptc_tot(gear_tot==3),[ones(length(maxStrAng_tot(gear_tot==3)),1) maxStrAng_tot(gear_tot==3)]);

[b bint r rint stats] = regress(ptc_tot(gear_tot==3),[ones(length(amp_tot(gear_tot==3)),1) maxStrAng_tot(gear_tot==3)]);

% regress data with categorical variable
sup_tot(find(gear_tot==0))=NaN; % Remove inappropriate data (when gear=0)
down_tot(find(gear_tot==0))=NaN;
maxStrAng_tot(find(gear_tot==0))=NaN;

supTab = table(sup_tot,ptc_tot,gear_tot);
downTab = table(down_tot,ptc_tot,gear_tot);
angTab = table(maxStrAng_tot,ptc_tot,gear_tot);

supFit = fitlm(supTab,'sup_tot~ptc_tot*gear_tot');
angFit = fitlm(angTab,'maxStrAng_tot~ptc_tot*gear_tot');
downFit = fitlm(downTab,'down_tot~ptc_tot*gear_tot');


%% Plot data - Downstroke Timing %%

[b bint r rint stats] = regress(down_tot,[ones(length(ptc_tot),1) ptc_tot]);
nan_nos = find(isnan(ptc_tot));
w = linspace(min(ptc_tot),max(ptc_tot));

ptc_adj = ptc_tot;
ptc_adj(nan_nos) = NaN;

plot(ptc_tot(gear_tot==3),down_tot(gear_tot==3),'.g'); hold on;
plot(ptc_tot(gear_tot==2),down_tot(gear_tot==2),'.r');
plot(ptc_tot(gear_tot==1),down_tot(gear_tot==1),'.b');
xlim([0.24,0.6])
ylabel('End of Downstroke Timing \it{(t/T)}');
xlabel('Timing of \it{RS-PtC} \rm{Contact} \it{(t/T)}','Interpreter','tex')
hold on;
line(w,feval(downFit,w,1),'Color','b','LineWidth',2)
line(w,feval(downFit,w,2),'Color','r','LineWidth',2)
line(w,feval(downFit,w,3),'Color','g','LineWidth',2)


% Plot data - Supination Timing
[b bint r rint stats] = regress(sup_tot,[ones(length(ptc_tot),1) ptc_tot]);
nan_nos = find(isnan(ptc_tot));

ptc_adj = ptc_tot;
ptc_adj(nan_nos) = NaN;
x=linspace(min(ptc_adj),max(ptc_adj),100);
y = b(1)+b(2)*x;
plot(ptc_tot(gear_tot==3),sup_tot(gear_tot==3),'.g'); hold on;
plot(ptc_tot(gear_tot==2),sup_tot(gear_tot==2),'.r');
plot(ptc_tot(gear_tot==1),sup_tot(gear_tot==1),'.b');
xlim([0.24,0.6])
ylabel('Supination Timing \it{(t/T)}');
xlabel('Timing of \it{RS-PtC} \rm{Contact} \it{(t/T)}','Interpreter','tex')
hold on;
plot(x,y,'color',[0.6 0 0],'linewidth',2);


% Plot data - Max Stroke Angle
[b bint r rint stats] = regress(maxStrAng_tot,[ones(length(ptc_tot),1) ptc_tot]);
nan_nos = find(isnan(ptc_tot));
w = linspace(min(ptc_tot),max(ptc_tot));

ptc_adj = ptc_tot;
ptc_adj(nan_nos) = NaN;

plot(ptc_tot(gear_tot==3),maxStrAng_tot(gear_tot==3),'.g'); hold on;
plot(ptc_tot(gear_tot==2),maxStrAng_tot(gear_tot==2),'.r');
plot(ptc_tot(gear_tot==1),maxStrAng_tot(gear_tot==1),'.b');
xlim([0.24,0.6])
ylabel('Max Stroke Angle (Degrees)');
xlabel('Timing of \it{RS-PtC} \rm{Contact} \it{(t/T)}','Interpreter','tex');
hold on;
line(w,feval(angFit,w,1),'Color','b','LineWidth',2)
line(w,feval(angFit,w,2),'Color','r','LineWidth',2)
line(w,feval(angFit,w,3),'Color','g','LineWidth',2)


% Plot data - Amplitude
[b bint r rint stats] = regress(ptc_tot,[ones(length(amp_tot),1) amp_tot]);
nan_nos = find(isnan(ptc_tot));
amp_adj = amp_tot;
amp_adj(nan_nos) = NaN;
x=linspace(min(amp_adj),max(amp_adj),100);
y = b(1)+b(2)*x;
plot(amp_tot,ptc_tot,'.');
xlabel('Stroke Amplitude (Degrees)');
ylabel('Timing of PtC Contact \it{(t/T)}');
hold on;
plot(x,y,'r','linewidth',2)


% PtC Contact - Downstroke End Latency
histogram(downLatencyG1,'binwidth',0.01,'FaceAlpha',0.4,'FaceColor','b'); hold on;
histogram(downLatencyG2,'binwidth',0.01,'FaceAlpha',0.4,'FaceColor','r'); hold on;
histogram(downLatencyG3,'binwidth',0.01,'FaceAlpha',0.4,'FaceColor','g'); hold on;
xlim([0 0.3])
xlabel('Latency between the timings of {\itRS-PtC} contact and downstroke end {\it(t/T)}')
ylabel('Frequency')


% PtC Contact - Supination Latency
histogram(supLatencyG1,'binwidth',0.01,'FaceAlpha',0.4,'FaceColor','b'); hold on;
histogram(supLatencyG2,'binwidth',0.01,'FaceAlpha',0.4,'FaceColor','r'); hold on;
histogram(supLatencyG3,'binwidth',0.01,'FaceAlpha',0.4,'FaceColor','g'); hold on;
xlim([0 0.6])
xlabel('Latency between the timings of {\itRS-PtC} contact and wing supination {\it(t/T)}')
ylabel('Frequency')


% boxplots and ranges (not including outliers)
boxplot(supLatency,'PlotStyle','compact')
supLatency_noOuters = supLatency;
supLatency_noOuters(isoutlier(supLatency_noOuters)) = NaN;
supTime_iqRanges = iqr(supLatency_noOuters);
supTime_totRange = max(supLatency_noOuters) - min(supLatency_noOuters);

boxplot(downLatency)
downLatency_noOuters = downLatency;
downLatency_noOuters(isoutlier(downLatency_noOuters)) = NaN;
downTime_iqRanges = iqr(downLatency_noOuters);
downTime_totRange = max(downLatency_noOuters) - min(downLatency_noOuters);