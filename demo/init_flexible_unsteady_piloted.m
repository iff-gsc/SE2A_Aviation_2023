clear all;

% add folders to path
addPathDemo();

%% aircraft parameters
[aircraft,structure] = aircraftSe2aCreate( 'flexible', true, 'unsteady', true, 'stall', true );

%% environment parameters
envir = envirLoadParams('envir_params_default');

%% reference position lat, lon, alt
pos_ref = loadParams('reference_position_params_se2a');

%% control model
% configure joystick
joystick = joystickLoadParams( 'joystick_params_Xbox_360', 2, 0 );

%% trim aircraft
fp_spec.Altitude    = 6000; % m
fp_spec.EAS         = 177; % m/s

trimPoint = trimFlexibleUnsteady(aircraft,structure,fp_spec,'sim_flexible_unsteady_piloted');

% adjust initial conditions struct (ic.V_Kb required for wind delays)
ic = tpGenerateIC(trimPoint);

%% open Simulink model

open('sim_flexible_unsteady_piloted');
