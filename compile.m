clear mex
clear functions

%you need to have the pylon library and a MS C++ compiler installed that is
%compatible with your matlab version.

%run mex -setup in the matlab prompt first

%this was tested with MATLAB 2015b, Windows SDK 7.1 (contains the C, C++
%compiler) and pylon version 4

%where is your pylon library installed?
pylondir = 'C:\Program Files\Basler\pylon 4';

includes = ['-I"' pylondir '\pylon\include" -I"' pylondir '\genicam\library\cpp\include"'];
libs = ['-L"' pylondir '\pylon\lib\x64" "' pylondir '\genicam\library\cpp\lib\win64_x64"'];

disp 'Compiling mex wrapper functions for Pylon Proxy :'
disp 'Pylon Proxy...'
mex(includes, libs, '-win64', '-DUSE_GIGE', '-c', '../PylonProxy/PylonProxy.cpp');
disp 'Pylon Setup...'
mex(includes, libs, '-win64', '-DUSE_GIGE', 'PylonSetup.cpp', 'PylonProxy.obj');
disp 'Pylon Use...'
mex(includes, libs, '-win64', '-DUSE_GIGE', 'PylonUse.cpp', 'PylonProxy.obj');
disp 'Pylon End...'
mex(includes, libs, '-win64', '-DUSE_GIGE', 'PylonEnd.cpp', 'PylonProxy.obj');
disp 'Pylon SetInfo...'
mex(includes, libs, '-win64', '-DUSE_GIGE', 'PylonSetInfo.cpp', 'PylonProxy.obj');
disp 'Pylon StartCont...'
mex(includes, libs, '-win64', '-DUSE_GIGE', 'PylonStartCont.cpp', 'PylonProxy.obj');
disp 'Pylon StopCont...'
mex(includes, libs, '-win64', '-DUSE_GIGE', 'PylonStopCont.cpp', 'PylonProxy.obj');
disp 'Pylon GetFrame...'
mex(includes, libs, '-win64', '-DUSE_GIGE', 'PylonGetFrame.cpp', 'PylonProxy.obj');
disp 'Pylon ReQ...'
mex(includes, libs, '-win64', '-DUSE_GIGE', 'PylonReQ.cpp', 'PylonProxy.obj');
