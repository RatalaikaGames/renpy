setlocal

pushd %~dp0

set BASEDIR=%~dp0..\..\

set PYDIR=%BASEDIR%python27-for-tools\
set path=%PYDIR%;%PYDIR%Scripts;%PATH%
set PYTHONPATH=%PYDIR%Lib\site-packages

rem sigh..... @#&*(@#ing python.
rmdir c:\python27
mklink /D c:\python27 %PYDIR%

python setup.py build_ext %*

del gen\_renpybidi.c

popd