#!/usr/bin/env bash

# NDK
#if [ "$ANDROID_NDK_HOME" = "" ]; then
#    echo "NOTE: ANDROID_NDK_HOME is not set in environment, export by self:"
#    export ANDROID_NDK_HOME=/Users/liwendong/tools/adt-bundle/sdk/ndk/19.2.5345600
#    echo "ANDROID_NDK_HOME = $ANDROID_NDK_HOME"
#    # r18b / 19.2.5345600 / 21.3.6528147
#fi

echo "ANDROID_NDK_HOME = $ANDROID_NDK_HOME"
ANDROID_TOOLCHAIN=$ANDROID_NDK_HOME/build/cmake/android.toolchain.cmake
IOS_TOOLCHAIN=./cmake/ios/ios.toolchain.cmake
QNX_TOOLCHAIN=./cmake/arm-unknown-nto-qnx700eabi.toolchain.cmake

# default setting
TARGET_INDEX="6"
BUILD_TARGET_OS=""
BUILD_TARGET_ARCH=""
BUILD_TYPE="release"
BUILD_CMAKE_ARGS=""
BUILD_PRODUCT="mainline"
INSTALL_DIR="./install/"

show_help() {
    echo "Usage: $0 [option...]" >&2
    echo
    echo "   -h, --help              show help message"
    echo "   -r, --release           Set build type to Release [default]"
    echo "   -d, --debug             Set build type to Debug"
    echo "   --RelWithDebInfo        Set build type to RelWithDebInfo"
    echo "   -t, --target            Set build target:"
    echo "                              0 - osx or ubuntu"
    echo "                              1 - android-armv7a"
    echo "                              2 - android-armv8a"
    echo "                              3 - android-x86"
    echo "                              4 - android-x86_64"
    echo "                              5 - qnx-armv7le"
    echo "                              6 - qnx-aarch64"
    echo "                              7 - ios-armv7"
    echo "                              8 - ios-armv8"
    echo "   -p                     Set build product type (default: mainline) jidu_qnn mainline"
    echo "   -a                      Other cmake args"
    echo
}

# parse arguments
while [ $# != 0 ]
do
  case "$1" in
    -a)
        BUILD_CMAKE_ARGS=$2
        shift
        ;;
    -t)
        TARGET_INDEX=$2
        shift
        ;;
    --target)
        TARGET_INDEX=$2
        shift
        ;;
    -p)
        BUILD_PRODUCT=$2
        ;;
    -r)
        BUILD_TYPE="release"
        ;;
    --release)
        BUILD_TYPE="release"
        ;;
    -d)
        BUILD_TYPE="debug"
        ;;
    --debug)
        BUILD_TYPE="debug"
        ;;
    --RelWithDebInfo)
        BUILD_TYPE="RelWithDebInfo"
        ;;
    -h)
        show_help
        exit 1
        ;;
    --help)
        show_help
        exit 1
        ;;
    *)
        ;;
  esac
  shift
done

case "$TARGET_INDEX" in
0)
    if [ "$(uname)" == "Darwin" ]; then
        BUILD_TARGET_OS="osx"
        BUILD_TARGET_ARCH="x86_64"
    elif [ "$(expr substr $(uname -s) 1 5)" == "Linux" ]; then
        BUILD_TARGET_OS="linux"
        BUILD_TARGET_ARCH="x86_64"
    fi
    ;;
1)
    BUILD_TARGET_OS="android"
    BUILD_TARGET_ARCH="armeabi-v7a"
    ;;
2)
    BUILD_TARGET_OS="android"
    BUILD_TARGET_ARCH="arm64-v8a"
    ;;
3)
    BUILD_TARGET_OS="android"
    BUILD_TARGET_ARCH="x86"
    ;;
4)
    BUILD_TARGET_OS="android"
    BUILD_TARGET_ARCH="x86_64"
    ;;
5)
    BUILD_TARGET_OS="qnx"
    BUILD_TARGET_ARCH="armv7le"
    ;;
6)
    BUILD_TARGET_OS="qnx"
    BUILD_TARGET_ARCH="aarch64le"
    ;;
7)
    BUILD_TARGET_OS="ios"
    BUILD_TARGET_ARCH="x86_64"
    ;;
8)
    BUILD_TARGET_OS="ios"
    BUILD_TARGET_ARCH="arm64"
    ;;
esac
TARGET=$BUILD_TARGET_OS-$BUILD_TARGET_ARCH

echo "build target is $TARGET, build type is $BUILD_TYPE"

# create build dir if not exists
if [ ! -d build ]; then
    mkdir -p build
fi
cd build

BUILD_DIR="$TARGET-$BUILD_TYPE"
#if [ -d $BUILD_DIR ]; then
#    rm -rf $BUILD_DIR
#fi

mkdir -p $BUILD_DIR
mkdir -p $BUILD_DIR/symbol
cd $BUILD_DIR

if [ "$(uname)" == "Darwin" ]; then
  cpu="$(sysctl -n hw.ncpu)"
elif [ "$(expr substr $(uname -s) 1 5)" == "Linux" ]; then
  cpu=$(cat /proc/cpuinfo | grep processor | wc -l)
fi

# compile & install
if [ "$TARGET" = "osx-x86_64" ]; then
    echo "cmake target: osx-x86_64"
     cmake   -DICP_TARGET_OS=osx \
             -DICP_TARGET_ARCH=x86_64 \
             -DCMAKE_BUILD_TYPE=$BUILD_TYPE \
             $BUILD_CMAKE_ARGS \
             $BUILD_PRAMA \
             ../..

elif [ "$TARGET" = "linux-x86_64" ]; then
    echo "cmake target: linux-x86_64"
     cmake   -DICP_TARGET_OS=linux \
             -DICP_TARGET_ARCH=x86_64 \
             -DCMAKE_BUILD_TYPE=$BUILD_TYPE \
             -DCMAKE_INSTALL_PREFIX=$INSTALL_DIR \
            `cat ../../../opencv4_cmake_options.txt` \
             ../..

elif [ "$TARGET" = "agl-arm" ]; then
    echo "cmake target: agl-arm"
     cmake   -DICP_TARGET_OS=agl \
             -DICP_TARGET_ARCH=arm \
             -DCMAKE_BUILD_TYPE=$BUILD_TYPE \
             $BUILD_CMAKE_ARGS \
             $BUILD_PRAMA \
             ../..

elif [ "$TARGET" = "android-armeabi-v7a" ]; then
    echo "cmake target: android-armeabi-v7a"
     cmake   \
             -DTARGET_OS=android \
             -DTARGET_ARCH=armeabi-v7a \
             -DANDROID_ABI=armeabi-v7a \
             -DCMAKE_BUILD_TYPE=$BUILD_TYPE \
             -DANDROID_STL=c++_static \
             -DBUILD_SHARED_LIBS=ON \
             -DCMAKE_CXX_FLAGS="-std=c++11 -frtti -fexceptions" \
             -DANDROID_PLATFORM=android-23 \
             -DANDROID_ARM_NEON=ON \
             -DCMAKE_TOOLCHAIN_FILE=$ANDROID_TOOLCHAIN \
             -DANDROID_ARM_NEON=ON \
            `cat ../../../opencv4_cmake_options.txt` \
             ../..

elif [ "$TARGET" = "android-arm64-v8a" ]; then
    echo "cmake target: android-arm64-v8a"
     cmake   \
             -DTARGET_OS=android \
             -DTARGET_ARCH=arm64-v8a \
             -DANDROID_ABI=arm64-v8a \
             -DCMAKE_BUILD_TYPE=$BUILD_TYPE \
             -DANDROID_STL=c++_static \
             -DBUILD_SHARED_LIBS=OFF \
             -DCMAKE_CXX_FLAGS="-std=c++11 -frtti -fexceptions" \
             -DANDROID_PLATFORM=android-28 \
             -DANDROID_ARM_NEON=ON \
             -DCMAKE_TOOLCHAIN_FILE=$ANDROID_TOOLCHAIN \
            `cat ../../../opencv4_cmake_options.txt` \
             ../..

elif [ "$TARGET" = "android-x86_64" ]; then
    echo "cmake target: android-x86_64"
     cmake   \
             -DTARGET_OS=Android \
             -DTARGET_ARCH=x86 \
             -DANDROID_ABI=x86_64 \
             -DCMAKE_BUILD_TYPE=$BUILD_TYPE \
             -DCMAKE_CXX_FLAGS="-std=c++11 -frtti -fexceptions" \
             -DANDROID_PLATFORM=android-23 \
             -DCMAKE_TOOLCHAIN_FILE=$ANDROID_TOOLCHAIN \
            `cat ../../../opencv4_cmake_options.txt` \
             ../..

elif [ "$TARGET" = "android-x86" ]; then
    echo "cmake target: android-x86"
     cmake   -DTARGET_OS=android \
             -DTARGET_ARCH=x86 \
             -DANDROID_ABI=x86 \
             -DCMAKE_BUILD_TYPE=$BUILD_TYPE \
             -DCMAKE_CXX_FLAGS="-std=c++11 -frtti -fexceptions" \
             -DANDROID_PLATFORM=android-23 \
             -DCMAKE_TOOLCHAIN_FILE=$ANDROID_TOOLCHAIN \
             `cat ../../../opencv4_cmake_options.txt` \
             ../..

elif [ "$TARGET" = "qnx-armv7le" ]; then
  echo "===== cmake target: qnx-armv7le"
   cmake   -DCMAKE_BUILD_TYPE=$BUILD_TYPE \
           -DCMAKE_CXX_FLAGS="-std=c++11 -frtti -fexceptions" \
           -DCMAKE_TOOLCHAIN_FILE=$QNX_TOOLCHAIN \
           -DCMAKE_INSTALL_PREFIX=$INSTALL_DIR \
           `cat ../../../opencv4_cmake_options.txt` \
           ../..

elif [ "$TARGET" = "qnx-aarch64le" ]; then
  echo "===== cmake target: qnx-aarch64le"
  cmake -DCMAKE_BUILD_TYPE=$BUILD_TYPE \
        -DCMAKE_CXX_FLAGS="-std=c++11 -frtti -fexceptions" \
        -DCMAKE_TOOLCHAIN_FILE=$QNX_TOOLCHAIN \
        -DCMAKE_INSTALL_PREFIX=$INSTALL_DIR \
        `cat ../../opencv4_cmake_options.txt` \
        ../..

elif [ "$TARGET" = "ios-x86_64" ]; then
    echo "cmake target: ios-x86_64"
    cmake -G Xcode -DICP_TARGET_OS=ios \
             -DICP_TARGET_ARCH=x86_64 \
             -DCMAKE_BUILD_TYPE=$BUILD_TYPE \
             -DVISION_TARGET_TYPE=SHARED \
             -DWITH_DB=OFF \
             -DCMAKE_CXX_FLAGS="-std=c++11 -frtti -fexceptions" \
             -DCMAKE_TOOLCHAIN_FILE=$IOS_TOOLCHAIN \
             -DPLATFORM=SIMULATOR64 \
             $BUILD_CMAKE_ARGS \
             $BUILD_PRAMA \
             ../..

    if [ "$BUILD_TYPE" = "debug" ]; then
        cmake --build . --config Debug --target install -- -j $cpu
    else
        cmake --build . --config Release --target install -- -j $cpu
    fi
    exit 0

elif [ "$TARGET" = "ios-arm64" ]; then
    echo "cmake target: ios-arm64"
    cmake -G Xcode -DICP_TARGET_OS=ios \
             -DICP_TARGET_ARCH=arm64 \
             -DCMAKE_BUILD_TYPE=$BUILD_TYPE \
             -DVISION_TARGET_TYPE=SHARED \
             -DWITH_DB=OFF \
             -DCMAKE_CXX_FLAGS="-std=c++11 -frtti -fexceptions" \
             -DCMAKE_TOOLCHAIN_FILE=$IOS_TOOLCHAIN \
             -DPLATFORM=OS64 \
             $BUILD_CMAKE_ARGS \
             $BUILD_PRAMA \
             ../..

    if [ "$BUILD_TYPE" = "debug" ]; then
        cmake --build . --config Debug --target install -- -j $cpu
    else
        cmake --build . --config Release --target install -- -j $cpu
    fi
    exit 0

fi

make -j "$cpu"

make install

exit 0
