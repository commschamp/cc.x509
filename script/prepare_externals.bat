rem Input
rem BUILD_DIR - Main build directory
rem GENERATOR - CMake generator
rem PLATFORM - CMake generator platform
rem QTDIR - Path to Qt installation
rem EXTERNALS_DIR - (Optional) Directory where externals need to be located
rem COMMS_REPO - (Optional) Repository of the COMMS library
rem COMMS_TAG - (Optional) Tag of the COMMS library
rem COMMSDSL_REPO - (Optional) Repository of the commsdsl code generators
rem COMMSDSL_TAG - (Optional) Tag of the commdsl
rem COMMSDSL_PLATFORM - (Optional) Tag of the commdsl
rem CC_ASN1_COMMSDSL_REPO - (Optional) Repository of the cc.asn1.commsdsl
rem CC_ASN1_COMMSDSL_TAG - (Optional) Tag of the cc.asn1.commsdsl
rem COMMON_INSTALL_DIR - (Optional) Common directory to perform installations
rem COMMON_BUILD_TYPE - (Optional) CMake build type
rem COMMON_CXX_STANDARD - (Optional) CMake C++ standard

rem -----------------------------------------------------

if [%BUILD_DIR%] == [] echo "BUILD_DIR hasn't been specified" & exit /b 1

if NOT [%GENERATOR%] == [] set GENERATOR_PARAM=-G %GENERATOR%

if NOT [%PLATFORM%] == [] set PLATFORM_PARAM=-A %PLATFORM%

if [%EXTERNALS_DIR%] == [] set EXTERNALS_DIR=%BUILD_DIR%/externals

if [%COMMS_REPO%] == [] set COMMS_REPO="https://github.com/commschamp/comms.git"

if [%COMMS_TAG%] == [] set COMMS_TAG="master"

if [%COMMSDSL_REPO%] == [] set COMMSDSL_REPO="https://github.com/commschamp/commsdsl.git"

if [%COMMSDSL_TAG%] == [] set COMMSDSL_TAG="master"

set COMMSDSL_PLATFORM_PARAM=%PLATFORM_PARAM%
if NOT [%COMMSDSL_PLATFORM%] == [] set COMMSDSL_PLATFORM_PARAM=-A %COMMSDSL_PLATFORM%

if [%CC_ASN1_COMMSDSL_REPO%] == [] set CC_ASN1_COMMSDSL_REPO="https://github.com/commschamp/cc.asn1.commsdsl.git"

if [%CC_ASN1_COMMSDSL_TAG%] == [] set CC_ASN1_COMMSDSL_TAG="master"

if [%COMMON_BUILD_TYPE%] == [] set COMMON_BUILD_TYPE=Debug

set COMMS_SRC_DIR=%EXTERNALS_DIR%/comms
set COMMS_BUILD_DIR=%BUILD_DIR%/externals/comms/build
set COMMS_INSTALL_DIR=%COMMS_BUILD_DIR%/install
if NOT [%COMMON_INSTALL_DIR%] == [] set COMMS_INSTALL_DIR=%COMMON_INSTALL_DIR%

set COMMSDSL_SRC_DIR=%EXTERNALS_DIR%/commsdsl
set COMMSDSL_BUILD_DIR=%BUILD_DIR%/externals/commsdsl/build
set COMMSDSL_INSTALL_DIR=%COMMSDSL_BUILD_DIR%/install
if NOT [%COMMON_INSTALL_DIR%] == [] set COMMSDSL_INSTALL_DIR=%COMMON_INSTALL_DIR%

set CC_ASN1_COMMSDSL_SRC_DIR=%EXTERNALS_DIR%/cc.asn1.commsdsl
set CC_ASN1_COMMSDSL_BUILD_DIR=%BUILD_DIR%/externals/cc.asn1.commsdsl/build
set CC_ASN1_COMMSDSL_INSTALL_DIR=%CC_ASN1_COMMSDSL_BUILD_DIR%/install
if NOT [%COMMON_INSTALL_DIR%] == [] set CC_ASN1_COMMSDSL_INSTALL_DIR=%COMMON_INSTALL_DIR%

rem ----------------------------------------------------

mkdir "%EXTERNALS_DIR%"
if exist %COMMS_SRC_DIR%/.git (
    echo "Updating COMMS library..."
    cd "%COMMS_SRC_DIR%"
    git fetch --all
    git checkout .    
    git checkout %COMMS_TAG%
    git pull --all
    if %errorlevel% neq 0 exit /b %errorlevel%    
) else (
    echo "Cloning COMMS library..."
    git clone -b %COMMS_TAG% %COMMS_REPO% %COMMS_SRC_DIR%
    if %errorlevel% neq 0 exit /b %errorlevel%
)

echo "Building COMMS library..."
mkdir "%COMMS_BUILD_DIR%"
cd %COMMS_BUILD_DIR%
cmake %GENERATOR_PARAM% %PLATFORM_PARAM% -S %COMMS_SRC_DIR% -B %COMMS_BUILD_DIR% -DCMAKE_INSTALL_PREFIX=%COMMS_INSTALL_DIR% ^
    -DCMAKE_BUILD_TYPE=%COMMON_BUILD_TYPE% -DCMAKE_CXX_STANDARD=%COMMON_CXX_STANDARD%
if %errorlevel% neq 0 exit /b %errorlevel%
cmake --build %COMMS_BUILD_DIR% --config %COMMON_BUILD_TYPE% --target install
if %errorlevel% neq 0 exit /b %errorlevel%

rem ----------------------------------------------------

if exist %COMMSDSL_SRC_DIR%/.git (
    echo "Updating commsdsl..."
    cd %COMMSDSL_SRC_DIR%
    git fetch --all
    git checkout .
    git checkout %COMMSDSL_TAG%
    git pull --all
) else (
    echo "Cloning commsdsl ..."
    git clone -b %COMMSDSL_TAG% %COMMSDSL_REPO% %COMMSDSL_SRC_DIR%
    if %errorlevel% neq 0 exit /b %errorlevel%
)

echo "Building commsdsl ..."
mkdir "%COMMSDSL_BUILD_DIR%"
cd %COMMSDSL_BUILD_DIR%
cmake %GENERATOR_PARAM% %COMMSDSL_PLATFORM_PARAM% -S %COMMSDSL_SRC_DIR% -B %COMMSDSL_BUILD_DIR% ^
    -DCMAKE_INSTALL_PREFIX=%COMMSDSL_INSTALL_DIR% -DCMAKE_BUILD_TYPE=%COMMON_BUILD_TYPE% ^
    -DCOMMSDSL_INSTALL_LIBRARY=OFF -DCOMMSDSL_BUILD_COMMSDSL2TEST=ON
if %errorlevel% neq 0 exit /b %errorlevel%
cmake --build %COMMSDSL_BUILD_DIR% --config %COMMON_BUILD_TYPE% --target install
if %errorlevel% neq 0 exit /b %errorlevel%

rem ----------------------------------------------------

if exist %CC_ASN1_COMMSDSL_SRC_DIR%/.git (
    echo "Updating cc.asn1.commsdsl ..."
cd "%CC_ASN1_COMMSDSL_SRC_DIR%"
    git fetch --all
    git checkout .
    git checkout %CC_TOOLS_QT_TAG%
    git pull --all
) else (
    echo "Cloning cc.asn1.commsdsl ..."
    git clone -b %CC_ASN1_COMMSDSL_TAG% %CC_ASN1_COMMSDSL_REPO% %CC_ASN1_COMMSDSL_SRC_DIR%
    if %errorlevel% neq 0 exit /b %errorlevel%
)

echo "Building cc.asn1.commsdsl ..."
mkdir "%CC_ASN1_COMMSDSL_BUILD_DIR%"
cd %CC_ASN1_COMMSDSL_BUILD_DIR%
cmake %GENERATOR_PARAM% %PLATFORM_PARAM% -S %CC_ASN1_COMMSDSL_SRC_DIR% -B %CC_ASN1_COMMSDSL_BUILD_DIR% ^
    -DCMAKE_INSTALL_PREFIX=%CC_ASN1_COMMSDSL_INSTALL_DIR% -DCMAKE_BUILD_TYPE=%COMMON_BUILD_TYPE% ^
    -DCMAKE_CXX_STANDARD=%COMMON_CXX_STANDARD%
if %errorlevel% neq 0 exit /b %errorlevel%
cmake --build %CC_ASN1_COMMSDSL_BUILD_DIR% --config %COMMON_BUILD_TYPE% --target install
if %errorlevel% neq 0 exit /b %errorlevel%
