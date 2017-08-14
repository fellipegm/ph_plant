%% pH neutralization pilot plant simulation
% Author: Fellipe Garcia Marques
% Based on Rodrigo Juliani and Claudio Garcia simulink model

%--------------------------------------------------------------------------
%% Initialization
%--------------------------------------------------------------------------
matlabrc;
close all;
clc;

%--------------------------------------------------------------------------
%% Model configuration
%--------------------------------------------------------------------------
Configuring_pH_and_level_model

%--------------------------------------------------------------------------
%% Simulation configuration
%--------------------------------------------------------------------------
% (s) period of integration
delta_sim = 0.05;
% (s) sampling time of the controllers
Ts = 0.5;
% decimation of the variables
Decim = Ts/delta_sim;
% simulation time
Tsim = 11000;


%--------------------------------------------------------------------------
%% Experiment configuration
%--------------------------------------------------------------------------
% TAPI to TR flow rate
t = 1:Tsim;
exc_Q_ap = 50/3600*ones(Tsim, 1);
% exc_Q_ap(6000:11000) = 0/3600;
exc_Q_ap(1:2000) = 10/3600;
exc_Q_ap(2001:3000) = 50/3600;
exc_Q_ap(3001:11000) = 10/3600;
exc_Q_ap = [t' exc_Q_ap];

% TASI to TR flow rate
exc_Q_as = 50/3600*ones(Tsim, 1);
% exc_Q_as(1:6000) = 0;
exc_Q_as(1:4000) = 0;
exc_Q_as(4001:5000) = 50/3600;
exc_Q_as(5001:6000) = 10/3600;
exc_Q_as(6001:11000) = 50/3600;
exc_Q_as = [t' exc_Q_as];

% Level setpoint
SP_Level = 75*ones(Tsim, 1);
SP_Level = [t' SP_Level];

% pH setpoint
SP_pH = 7*ones(Tsim, 1);
% SP_pH(1:2000) = 7;
% SP_pH(2001:3000) = 8;
% SP_pH(3001:4000) = 7;
% SP_pH(4001:5000) = 6;
% SP_pH(5001:6000) = 7;
% SP_pH(6001:7000) = 7;
% SP_pH(7001:8000) = 8;
% SP_pH(8001:9000) = 7;
% SP_pH(9001:10000) = 6;
% SP_pH(10001:11000) = 7;
SP_pH = [t' SP_pH];

mv0_teste = 50*ones(Tsim, 1);
mv0_teste = [t' mv0_teste];


Enable_PID_pH = zeros(Tsim, 1);
Enable_PID_pH(1:Tsim) = 1;
%Enable_PID_pH(4900:end) = 0;

Enable_PID_pH = [t' Enable_PID_pH];

Enable_Level_Controller = zeros(Tsim, 1);
Enable_Level_Controller(1:Tsim) = 1;
Enable_Level_Controller = [t' Enable_Level_Controller];

% Manual actuation on LV-16A
MANU_LV_16A = [t' zeros(Tsim,1)];

% Stirrer on/off -- affects the level meter only
mz81 = [t' ones(Tsim,1)];

% -------------------------------------------------------------------------
%% Simulation
% -------------------------------------------------------------------------
sim('Model_pH_and_level');

% uncoment if you wish to save the workspace
% save simulation_data;

% -------------------------------------------------------------------------
%% Plot the results
% -------------------------------------------------------------------------
fig = figure;
plot(t, pH_m, 'LineWidth', 2)
grid on
xlabel('Time (s)', 'FontSize', 12.5)
ylabel('pH', 'FontSize', 12.5)
xlim([0 Tsim])
ylim([5 9])
axes_handle = gca;
set(axes_handle, 'FontSize', 12.5);

fig = figure;
plot(t, MV_pump, 'LineWidth', 2)
grid on
xlabel('Time (s)', 'FontSize', 12.5)
ylabel('Metering pump frequency (%)', 'FontSize', 12.5)
xlim([0 Tsim])
ylim([0 100])
axes_handle = gca;
set(axes_handle, 'FontSize', 12.5);

fig = figure;
plot(t, Qap_m, ':', t, Qas_m, 'LineWidth', 2)
grid on
xlabel('Time (s)', 'FontSize', 12.5)
ylabel('Flow rate (l/h)', 'FontSize', 12.5)
xlim([0 Tsim])
ylim([min(min(Qap_m,Qas_m))*0.9 max(max(Qap_m,Qas_m))*1.1])
axes_handle = gca;
set(axes_handle, 'FontSize', 12.5);

fig = figure;
plot(t, h_m, 'LineWidth', 2)
grid on
xlabel('Time (s)', 'FontSize', 12.5)
ylabel('TR Level (%)', 'FontSize', 12.5)
xlim([0 Tsim])
ylim([min(h_m)*0.9 max(h_m)*1.1])
axes_handle = gca;
set(axes_handle, 'FontSize', 12.5);

fig = figure;
plot(t, squeeze(invariants_est'), ':', t, invariants, 'LineWidth', 2)
grid on
legend('w1e', 'w2e', 'w3e', 'w4e', 'w5e', 'w2_{TASI}', 'w1r', 'w2r', 'w3r', 'w4r', 'w5r', 'Location', 'eastoutside')
xlabel('Time (s)', 'FontSize', 12.5)
ylabel('Reaction Invariants', 'FontSize', 12.5)
xlim([0 Tsim])
ylim([-0.0185 0.0185])
axes_handle = gca;
set(axes_handle, 'FontSize', 12.5);

fig = figure;
plot(t, pH_m, t, pH_e, 'LineWidth', 2)
grid on
legend('pH medido', 'pH estimado')
xlabel('Time (s)', 'FontSize', 12.5)
ylabel('pH', 'FontSize', 12.5)
xlim([0 Tsim])
ylim([5 9])
axes_handle = gca;
set(axes_handle, 'FontSize', 12.5);

% fig = figure;
% plot(t, squeeze(estimation_1), '+', t, invariants, 'LineWidth', 2)
% grid on
% legend('w1e (1)', 'w2e (1)', 'w3e (1)', 'w4e (1)', 'w1r', 'w2r', 'w3r', 'w4r', 'w5r')
% xlabel('Time (s)', 'FontSize', 12.5)
% ylabel('Reaction Invariants', 'FontSize', 12.5)
% xlim([0 Tsim])
% %ylim([min(h_m)*0.9 max(h_m)*1.1])
% axes_handle = gca;
% set(axes_handle, 'FontSize', 12.5);
% 
% fig = figure;
% plot(t, pH_m, t, pH_e_1, 'LineWidth', 2)
% grid on
% legend('pH medido', 'pH estimado (1)')
% xlabel('Time (s)', 'FontSize', 12.5)
% ylabel('pH', 'FontSize', 12.5)
% xlim([0 Tsim])
% %ylim([min(h_m)*0.9 max(h_m)*1.1])
% axes_handle = gca;
% set(axes_handle, 'FontSize', 12.5);
% 
% fig = figure;
% plot(t, squeeze(estimation_2), '+', t, invariants, 'LineWidth', 2)
% grid on
% legend('w1e (2)', 'w2e (2)', 'w3e (2)', 'w4e (2)', 'w2_{TASI} (2)', 'w1r', 'w2r', 'w3r', 'w4r', 'w5r')
% xlabel('Time (s)', 'FontSize', 12.5)
% ylabel('Reaction Invariants', 'FontSize', 12.5)
% xlim([0 Tsim])
% %ylim([min(h_m)*0.9 max(h_m)*1.1])
% axes_handle = gca;
% set(axes_handle, 'FontSize', 12.5);
% 
% fig = figure;
% plot(t, pH_m, t, pH_e_2, 'LineWidth', 2)
% grid on
% legend('pH medido', 'pH estimado (2)')
% xlabel('Time (s)', 'FontSize', 12.5)
% ylabel('pH', 'FontSize', 12.5)
% xlim([0 Tsim])
% %ylim([min(h_m)*0.9 max(h_m)*1.1])
% axes_handle = gca;
% set(axes_handle, 'FontSize', 12.5);
% 
% fig = figure;
% plot(t, squeeze(estimation_3), '+', t, invariants, 'LineWidth', 2)
% grid on
% legend('w1e (3)', 'w2e (3)', 'w3e (3)', 'w4e (3)', 'w3_{TBB} (3)', 'w1r', 'w2r', 'w3r', 'w4r', 'w5r')
% xlabel('Time (s)', 'FontSize', 12.5)
% ylabel('Reaction Invariants', 'FontSize', 12.5)
% xlim([0 Tsim])
% %ylim([min(h_m)*0.9 max(h_m)*1.1])
% axes_handle = gca;
% set(axes_handle, 'FontSize', 12.5);
% 
% fig = figure;
% plot(t, pH_m, t, pH_e_3, 'LineWidth', 2)
% grid on
% legend('pH medido', 'pH estimado (3)')
% xlabel('Time (s)', 'FontSize', 12.5)
% ylabel('pH', 'FontSize', 12.5)
% xlim([0 Tsim])
% %ylim([min(h_m)*0.9 max(h_m)*1.1])
% axes_handle = gca;
% set(axes_handle, 'FontSize', 12.5);
% 
% 
% fig = figure;
% plot(t, squeeze(estimation_4), '+', t, invariants, 'LineWidth', 2)
% grid on
% legend('w1e (4)', 'w2e (4)', 'w3e (4)', 'w4e (4)', 'w2_{TASI} (4)', 'w3_{TBB} (4)', 'w1r', 'w2r', 'w3r', 'w4r', 'w5r')
% xlabel('Time (s)', 'FontSize', 12.5)
% ylabel('Reaction Invariants', 'FontSize', 12.5)
% xlim([0 Tsim])
% %ylim([min(h_m)*0.9 max(h_m)*1.1])
% axes_handle = gca;
% set(axes_handle, 'FontSize', 12.5);
% 
% fig = figure;
% plot(t, pH_m, t, pH_e_4, 'LineWidth', 2)
% grid on
% legend('pH medido', 'pH estimado (4)')
% xlabel('Time (s)', 'FontSize', 12.5)
% ylabel('pH', 'FontSize', 12.5)
% xlim([0 Tsim])
% %ylim([min(h_m)*0.9 max(h_m)*1.1])
% axes_handle = gca;
% set(axes_handle, 'FontSize', 12.5);

% fig = figure;
% plot(t, squeeze(luenberger_est), '+', t, invariants, 'LineWidth', 2)
% grid on
% legend('w1e', 'w2e', 'w3e', 'w4e', 'w1r', 'w2r', 'w3r', 'w4r', 'w5r')
% xlabel('Time (s)', 'FontSize', 12.5)
% ylabel('Reaction Invariants', 'FontSize', 12.5)
% xlim([0 Tsim])
% %ylim([min(h_m)*0.9 max(h_m)*1.1])
% axes_handle = gca;
% set(axes_handle, 'FontSize', 12.5);
% 
% fig = figure;
% plot(t, pH_m, t, pH_luen_e, 'LineWidth', 2)
% grid on
% legend('pH medido', 'pH estimado')
% xlabel('Time (s)', 'FontSize', 12.5)
% ylabel('pH', 'FontSize', 12.5)
% xlim([0 Tsim])
% %ylim([min(h_m)*0.9 max(h_m)*1.1])
% axes_handle = gca;
% set(axes_handle, 'FontSize', 12.5);