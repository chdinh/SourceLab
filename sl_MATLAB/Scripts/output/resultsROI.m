%%
clear all;
close all;
clc;

%%
%load('resultROI_20120626T073038.mat');
load('resultROI_20120626T235524.mat');


%%
SNR = zeros(length(result),1);

err_RMSE = zeros(length(result),2);

for k = 1:length(result)
    dist = (result(k,1).err(1,1).distance).^2;
    for i = 2:1000
        dist = [dist; (result(k,1).err(i,1).distance).^2];
    end
    snr(k) = result(k,1).snr;
    err_RMSE(k,:) = mean(dist).^0.5;
end

%%
figure('Name','RMSE 1');
plot(snr, err_RMSE(:,1)*1000);
axis([-20 20 18 30])
title('root-mean-square error (RMSE)');
ylabel('error [mm]');
xlabel('signal-to-noise ratio [dB]');

figure('Name','RMSE 2');
plot(snr, err_RMSE(:,2)*1000);
axis([-20 20 18 30])
title('root-mean-square error (RMSE)');
ylabel('error [mm]');
xlabel('signal-to-noise ratio [dB]');


figure('Name','RMSE ALL');
plot(snr, err_RMSE(:,1)*1000,'d','MarkerSize',20,'LineWidth',4);
hold on;
plot(snr, err_RMSE(:,2)*1000,'r*','MarkerSize',20,'LineWidth',4);
axis([-25 25 18 30])
title('root-mean-square error (RMSE)');
ylabel('error [mm]');
xlabel('signal-to-noise ratio [dB]');