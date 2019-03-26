setlocal

pushd %~dp0

set BASEDIR=%~dp0\..\..\

set PYDIR=%BASEDIR%python27\
set path=%PYDIR%;%PATH%

python setup.py build_ext %*

popd