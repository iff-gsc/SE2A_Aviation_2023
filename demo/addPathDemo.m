function [] = addPathDemo()

% go to correct directory
init_scripts_path = fileparts(mfilename('fullpath'));
cd(init_scripts_path);

% go to main directory
cd ..

% add path for fdm initialization
addpath(genpath(pwd));

% add to path TiGL and TiXI
addPathTiGL('2.2.2')

end