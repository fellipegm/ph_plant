%% Configuration of the Pilot Plant Model
% Author: Fellipe Marques
% Modelling based on qualification exam
% Based on Rodrigo Juliani and Claudio Garcia simulink model

%--------------------------------------------------------------------------
%% Reaction invariants parameters initialization
%--------------------------------------------------------------------------

% (l) TBB solvent volume - TBB height = 0,9 m -- solvent height = 0,65 m
%     TBB diameter = 0,595 m
V_TBB = pi*(59.5e-2)^2/4*65e-2*1000;

% (l) TAP solvent volume - TAP height = 0,647 m -- solvent height = 0,548 m
%     TAP diameter = 0,648 m (same for TAS)
V_TAP = pi*(64.8e-2)^2/4*54.8e-2*1000;
V_TAS = pi*(64.8e-2)^2/4*54.8e-2*1000;

% (l) HCl 30-33% added in TAP
V_HCl = 101e-3;
% (l) CH3COOH added in TAS
V_CH3COOH = 70e-3;
% (g) NaOH 99% added in TBB
M_NaOH = 134.5;

%--------------------------------------------------------------------------
% Acid and base concentrations
%--------------------------------------------------------------------------
% Please note that the reaction invariants are time varying. A good control
% design must take it into account. It is possible to test many different
% situations in the pilot plant by changing the concentration of the
% titration curves perturbations

% (mol/l) NaOH concentration in TBB -- w_1
c_NaOH = M_NaOH*0.99/39.9971/V_TBB;
% (mol/l) HCl concentration in TAP -- w_1
c_HCl = V_HCl*364.44/36.46/V_TAP;
% (mol/l) CH3COOH concentration in TAS -- w_2
c_CH3COOH = V_CH3COOH*1049/60.05/V_TAS;
% (mol/l) CH3COOH concentration in TBB and TAP -- 0<w2<2.8e-4 mol/l
c_CH3COOH_r = 1e-4;
% (mol/l) H2CO3 concentration in TBB -- 0<w_3<10e-4 mol/l
c_H2CO3 = 5e-4;
% (mol/l) H2CO3 concentration in TAP and TAS -- 0<w_3<6e-4 mol/l
c_H2CO3_r = 9e-4;
% (mol/l) NH4+ concentration in solutions -- 0<w_4<3e-4 mol/l
c_NH4 = 2e-4;
% (mol/l) H3PO4 concentration in solutions -- 0<w_5<0.5e-4 mol/l 
c_H3PO4 = 0.1e-4;


%--------------------------------------------------------------------------
% Dissociation constants calculation
%--------------------------------------------------------------------------
% (°C) temperature of the solutions
T = 20.5;

Temp = [15, 20, 25, 30];
pK_H2O = [14.34 14.163 13.995 13.836];
pK_CH3COOH = [4.758 4.757 4.756 4.757];
pK_H2CO3 = [6.429 6.382 6.352 6.327];
pK_HCO3 = [10.431 10.377 10.329 10.290];
pK_NH4 = [9.564 9.4 9.245 9.093];
pK_H3PO4 = [2.107 2.127 2.148 2.171];
pK_H2PO4 = [7.231 7.213 7.198 7.189];
pK_HPO4 = [12.45 12.38 12.32 12.26];

pKw = interp1(Temp,pK_H2O,T);
pka1_CH3COOH = interp1(Temp,pK_CH3COOH,T);
pka1_H2CO3 = interp1(Temp,pK_H2CO3,T);
pka2_H2CO3 = interp1(Temp,pK_HCO3,T);
pka1_NH4 = interp1(Temp,pK_NH4,T);
pka1_H3PO4 = interp1(Temp,pK_H3PO4,T);
pka2_H3PO4 = interp1(Temp,pK_H2PO4,T);
pka3_H3PO4 = interp1(Temp,pK_HPO4,T);

%--------------------------------------------------------------------------
% Invariants vectors initialization
%--------------------------------------------------------------------------
w_ap1 = c_HCl;
w_ap2 = c_CH3COOH_r;
w_ap3 = c_H2CO3_r;
w_ap4 = c_NH4;
w_ap5 = c_H3PO4;

w_as1 = 0;
w_as2 = c_CH3COOH;
w_as3 = c_H2CO3_r;
w_as4 = c_NH4;
w_as5 = c_H3PO4;

w_b1 = -c_NaOH;
w_b2 = c_CH3COOH_r;
w_b3 = c_H2CO3;
w_b4 = c_NH4;
w_b5 = c_H3PO4;

w1_r1_0 = double(feval(symengine,'numeric::solve',['-x-',...
        num2str(c_H2CO3_r), '*(1+2*10^(7-', num2str(pka2_H2CO3),...
        '))/(1+10^(', num2str(pka1_H2CO3), '-7)+10^(7-', num2str(pka2_H2CO3),...
        '))-', num2str(c_NH4), '/(1+10^(', num2str(pka1_NH4), '-7))-' ...
        num2str(c_CH3COOH_r), '/(1+10^(', num2str(pka1_CH3COOH), ...
        '-7))-', num2str(c_H3PO4), '*(1+2*10^(7-', num2str(pka2_H3PO4), ')+' ...
        '3*10^(2*7-', num2str(pka2_H3PO4), '-', num2str(pka3_H3PO4), '))'...
        '/(1+10^(', num2str(pka1_H3PO4), '-7)+10^(7-', num2str(pka2_H3PO4), ')+', ...
        '10^(2*7-', num2str(pka2_H3PO4), '-' num2str(pka3_H3PO4) '))'], 'x'));

% initial value for the reactor invariant vectors
w_r1_0 = [w1_r1_0; c_CH3COOH_r; c_H2CO3_r; c_NH4; c_H3PO4];


%--------------------------------------------------------------------------
%% TR parameters
%--------------------------------------------------------------------------
% (m^2) TR base area - diameter = 0,4m - height = 0,65m
A_TR = pi*0.4^2/4;

% (m^2) stirrer shaft area - diameter = 9,6 mm
A_stirrer = pi*(9.6e-3)^2/4;
% (m^2) condutivimeter instrument area - diameter = 33,5 mm
A_cond = pi*(33.5e-3)^2/4;
% (m^2) pHmeter instrument area - diameter = 34 mm
A_pHmeter = pi*(34e-3)^2/4;
% (m^2) heater resistor area - diameter = 11,4 mm (x2)
A_heater = 2*pi*(11.4e-3)^2/4;

% (m^2) approximate util area of the CSTR
A_util_TR = A_TR-A_stirrer-A_cond-A_pHmeter-A_heater;

% maximum allowed level of the TR
% (%)
h_max_TR = 100;
% (m)
h_max_TR_m = 0.5;

% (%) nominal value of the TR level
h_nom = 75;

% (l) maximum allowed volume in TR
V_max_CSTR = A_util_TR*h_max_TR_m*1000;
% (l) initial value of the TR level
V0_CSTR = V_max_CSTR*h_nom/h_max_TR;

% (adim) active volume of the TR (from residence time distribution
% experiments)
Vm = 0.836;

% (s) mixing time
Tmix = 1.34;

%--------------------------------------------------------------------------
%% Instruments parameters
%--------------------------------------------------------------------------
% pHmeter parameters
%--------------------------------------------------------------------------
% gain
K_meter_pH = 1;
% (s) time constant
tau_meter_pH = 5;
% (s) dead time
td_meter_pH = 3.5;
% noise parameters
var_noise_pH = 6.25e-5;
seed_noise_pH = 67890;
T_noise_pH = 3;
% (pH) nominal value of pH
pH_nom = 7; 
% (%) initial output of the pH meter
pH_m0 = pH_nom*K_meter_pH;

%--------------------------------------------------------------------------
% Parameters of the level meter
%--------------------------------------------------------------------------
% gain
K_meter_level = 1;
% (s) time constant
tau_meter_level = 16;
% (s) dead time
td_meter_level = 6;
% noise parameters
var_noise_level = 1.1e-3;
seed_noise_level = 12345;
T_noise_level = 2;

%--------------------------------------------------------------------------
% Parameters of the flow meters
%--------------------------------------------------------------------------
% gain -- l/s to l/h
K_meter_flow = 3600;
% (s) time constant
tau_meter_flow = 1.4;
% (s) dead time
td_meter_flow = 3.5;
% noise parameters
var_noise_Q_ap  = 1.56e-2;
seed_noise_Q_ap = 357;
var_noise_Q_as  = 1.56e-2;
seed_noise_Q_as = 349;

%--------------------------------------------------------------------------
% Parameters of the pump
%--------------------------------------------------------------------------
x_MV_pump = [0 10 20 40 50 60 80 100];
y_t_f = [Inf 19+51/60 9+02/60 4+21/60 3+28/60 2+53/60 2+12/60 1+59/60];
Q_l_h = 1./(y_t_f./60);
y_Q_pump = Q_l_h/3600;


%--------------------------------------------------------------------------
% Flow coefficient of the level control valve (l/s/sqrt(m))
%--------------------------------------------------------------------------
Kv = 11e-2;

%--------------------------------------------------------------------------
% Parameters of the level control valve actuator
%--------------------------------------------------------------------------
% gain
K_at = 0.01;
% (s) time constant of the valve actuator
tau_at = 0.8;

%--------------------------------------------------------------------------
%% Nomimal values of the pH plant variables
%--------------------------------------------------------------------------
% (l/s) nominal flow from TAPI to TR
Q_ap_nom = 49/3600;
% (l/s) nominal flow from TASI to TR
Q_as_nom = 49/3600;
% (l/s) nominal base flow rate
Qb_nom = c_HCl/c_NaOH*Q_ap_nom;         

%--------------------------------------------------------------------------
% Tuning parameters of the pH controller (PI)
%--------------------------------------------------------------------------
e1 = 50;
e2 = 300;

w1_ff_tap = 0.0056;
w2_ff_tap = 0.5e-4;
w3_ff_tap = 3e-4;
w4_ff_tap = 2e-4;

w1_ff_tas = 0;
w3_ff_tas = 3e-4;
w4_ff_tas = 2e-4;

w1_ff_tbb = -0.0185;
w2_ff_tbb = 0.5e-4;
w3_ff_tbb = 3e-4;
w4_ff_tbb = 2e-4;

w_fb_tap = [w1_ff_tap w2_ff_tap w3_ff_tap w4_ff_tap];
w_fb_tas = [w1_ff_tas 0 w3_ff_tas w4_ff_tas];


%% Projeto do filtro dos sinais
% Filtro para as variáveis medidas
filtro_med_F_TAPI = 1;%fir1(1,1/500);
filtro_med_F_TASI = 1;%fir1(1,1/500);
filtro_med_pH = 1;%fir1(5,1/50);

Ts_F_TAPI = 1;
Ts_F_TASI = 1;
Ts_pH_m = 1;

Ts_F_TBB = 1;

filter_estimator1 = 1;%fir1(20,1/50);
filter_estimator2 = 1;%fir1(20,1/50);
filter_estimator3 = 1;%fir1(20,1/50);
filter_estimator4 = 1;%fir1(20,1/50);
filter_estimator5 = 1;%fir1(20,1/50);
filter_estimator6 = 1;%fir1(7,1/50);

Ts_w1 = 1;
Ts_w2 = 1;
Ts_w3 = 1;
Ts_w4 = 1;
Ts_w5 = 1;
Ts_w6 = 25;


Ts_Kp = 5;
Ts_Ti = 5;

filtro_Kp = fir1(5,1/50);
filtro_Ti = fir1(5,1/50);


%--------------------------------------------------------------------------
% Tuning parameters of the level controller (PI)
%--------------------------------------------------------------------------
P_l = 11.65;                            % [adim.] Proportional gain of the PI controller
I_l = 271.52;                           % [adim.] Integrative gain parameter of the PI controller
T_PWM = 10;                             % [s] Period of the PWM in the level controller



%--------------------------------------------------------------------------
% Tuning parameters of the pH controller (PI)
%--------------------------------------------------------------------------
% adimentionalization to 100%
Kn = 100/14;
% gain
Kc = 2.5;
% integration time
Ti = 250;
% derivative time
Td = 120;
% filtro
N = 1/500;
% (%) initial output of the pH controller
mv0 = 50;

K_transmissor=3.6*10^3; % [(l/h)/(l/s)]
Kc=3.5;
Ti=150;
Td=120;
b=0;
c=0;
N=1/500;
