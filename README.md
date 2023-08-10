# An Aeroelastic Flight Dynamics Model for Gust Load Alleviation of Energy-Efficient Passenger Airplanes

This repository contains the source code used for the research results in [1].
It provides a simulation model for aeroelastic aircraft with gust simulation implemented in Matlab/Simulink.

<div align="center">
<h3>Paper Summary Video</h3>
  <a href="https://youtu.be/cO5q06Qkkgk">
    <img 
      src="https://img.youtube.com/vi/cO5q06Qkkgk/0.jpg" 
      alt="Flight test" 
      style="width:50%;">
  </a>
</div>

<br>

[1] Beyer, Y., Cavaliere, D., Bramsiepe, K., Khalil, K., Bauknecht, A., Fezans, N., Steen, M. & Hecker, P. (2023). An Aeroelastic Flight Dynamics Model for Gust Load Alleviation of Energy-Efficient Passenger Airplanes. <i>AIAA AVIATION 2023 Forum</i>. AIAA Paper 2023-4452.  
https://doi.org/10.2514/6.2023-4452


## Installation

- MATLAB: You need MATLAB/Simulink 2018b or later. You do not need any additional toolboxes.
- TiXI: You need to install TiXI 2.2.3: https://github.com/DLR-SC/tixi
- TiGL: You need to install TiGL 2.2.3: https://github.com/DLR-SC/tigl
- Clone project including the submodules:
  ```
  git clone --recursive https://github.com/iff-gsc/SE2A_Aviation_2023.git
  ```
- FlexiFlightVis 0.1 for visualization (optional): https://github.com/iff-gsc/FlexiFlightVis

## Demo

- Initialize the simulation model:  
  1. Open MATLAB
  2. Navigate to the project folder and then to the subfolder [demo](demo)
  ```
  cd('demo')
  ```
  3. Run the initialization script [init_flexible_unsteady_piloted](demo/init_flexible_unsteady_piloted.m) (Click `Change Folder` or `Add to Path` if requested.).
  ```
  init_flexible_unsteady_piloted
  ```
- Run the Simulink simulation:
  1. The Simulink model [sim_flexible_unsteady_piloted](models/sim_flexible_unsteady_piloted.slx) should already open during the initialization.
  2. Run the Simulink model.
  3. Several signals are logged in the `Scopes` subsystem.
- Run FlexiFlightVis to see what happens.
  
## How to use?

The flight dynamics model is based on CPACS data which is located in *libraries/SE2A_library/data/CPACS/*.
This data is imported by the TiGL and TiXI by functions like `wingCreateWithCPACS` that is located in the submodule LADAC.
Note that the control surface parameters are not included in CPACS but in `wingControls_params_mainDefault`.  
The structural model is imported from NASTRAN files which are located in *libraries/SE2A_library/data/NASTRAN/*.
The parameters are loaded via the function `structureCreateFromNastran`.

The workspace variable `aircraft` is created by the function `aircraftSe2aCreate` which takes optional Name-Value Arguments.

The aircraft can be piloted using a joystick.
To enable this, the Simulink block 'Joystick' must be uncommented.
The default joystick is an Xbox 360 joystick (see [init_flexible_unsteady_piloted](demo/init_flexible_unsteady_piloted.m)) and you may have to calibrate your joystick, see https://github.com/iff-gsc/LADAC/tree/main/control/joystick.

The Simulink model can be trimmed at a specified flight point using the function `trimFlexibleUnsteady` (see [init_flexible_unsteady_piloted](demo/init_flexible_unsteady_piloted.m)).



Please note the following:
- Most of the code is written in Matlab and this code is then integrated in Simulink models.
- During initialization of the Simulink model a bunch of bus objects will be assigned to the base workspace.
This can not be avoided in the current Simulink implementation with Matlab function blocks using the sub-structs like `aircraft.wing_main.state`.
- Most Matlab functions are documented, please have a look inside in case of questions.
- For several subprojects there is also a README, especially in LADAC. Please check if there is a README located at the file location in case of questions.
- For debugging it is recommended to debug the pure Matlab code first (usually there are example or test scripts).
- If you want to use a joystick in Rapid Accelerator mode, use the `joystick_udp_rapid_accelerator` model.
- Variable step solvers do not work for the unsteady aircraft simulations; for ODE4 the sample rate should be at least 600 Hz.


## Known issues

The following issues are known and my be fixed in the future.
- **The wind delay assumes constant airspeed:**  
  The wind is delayed for each aerodynamic control point depending on the airspeed so that a gust hits the nose first.
  However, the variable time transport delay block (multiple variables are delayed) in Simulink slowed down the simulation significantly.
  That is why the initial airspeed is currently used as constant delay time.
- **Compilation problems:**  
  There is one huge Matlab function for the aerodynamics model (`wingSetState`) that can currently only be compiled for fixed array sizes of the wing struct.
  Consequently, the function is compiled three times if three wings are used.
  The first run takes a long time because everything has to be compiled.
  After that it is much faster.
  However, the compilation process starts from the beginning if only one line of code in `wingSetState` or its subfunctions changes.
  Furthermore, the compilation starts from the beginning if the wing struct array sizes change due to changed discretization (number of wing panels or number of structural eigenmodes).
  The compilation of the whole model can take several minutes.
- **Computation time:**  
  We have already spent much time on speeding up the code. However, it would be desirable if the code would run faster.
  Some parts of the model could be called at much lower sample rate, e.g. the Mach number scheduling of the airfoil data is currently called at each time step.
  Some values are still computed more than once in different functions. These values could be computed once and stored.
  The general optimization of the code performance could be continued by using the profiler and finding the current bottlenecks.
- **The drag coefficient is probably not modeled well:**  
  For the tail there is no good airfoil coefficients data available.
  The drag coefficient is estimated and not scheduled.
  However, the drag coefficient should not be very important for this application.
- **Actuators can not be mixed along the span:**  
  Although in the parameters of the wing, both the airfoil and the 2nd actuator are specified as array per segment, the code only uses the first entry for the whole wing.
  Some time ago it was implemented such that the airfoil could be varied per wing segment, however, this feature was removed since the code became complicated.
  It is possible to "deactivate" the 2nd actuator for specific segments  (elements in `wing.params.control_input_index(2,:)` can be set to zero; same as for the flaps in the first row).
    
	
