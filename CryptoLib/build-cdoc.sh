#!/bin/sh

export PATH=$PATH:/usr/local/bin:/opt/homebrew/bin
SOURCE_DIR=${DERIVED_SOURCES_DIR}/cdoc
if [ ! -d ${SOURCE_DIR} ]; then
    git clone -b mopp https://github.com/metsma/cdoc.git ${SOURCE_DIR};
fi
cmake \
    -DINSTALL_FRAMEWORKDIR=${BUILT_PRODUCTS_DIR} \
    -DCMAKE_INSTALL_PREFIX=${BUILT_PRODUCTS_DIR} \
    -DCMAKE_BUILD_TYPE=${CONFIGURATION} \
    -DCMAKE_OSX_SYSROOT=${PLATFORM_NAME} \
    -DCMAKE_OSX_ARCHITECTURES="${ARCHS// /;}" \
    -DCMAKE_OSX_DEPLOYMENT_TARGET=${IPHONEOS_DEPLOYMENT_TARGET} \
    -DBUILD_SHARED_LIBS=NO \
    -DOPENSSL_ROOT_DIR=${PROJECT_DIR}/../MoppLib/MoppLib/libdigidocpp/libdigidocpp.${PLATFORM_NAME} \
    -DCMAKE_DISABLE_FIND_PACKAGE_SWIG=YES \
    -DCMAKE_DISABLE_FIND_PACKAGE_Doxygen=YES \
    -S ${SOURCE_DIR} -B ${TARGET_TEMP_DIR}
cmake --build ${TARGET_TEMP_DIR}
cmake --install ${TARGET_TEMP_DIR}
