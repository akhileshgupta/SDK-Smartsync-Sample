#!/bin/bash

export OPTION=$1

# Helper functions
copy_and_fix ()
{
    echo "* Fixing and copying $1 to $2 directory"
    find tmp -name $1 | xargs sed 's/\#import\ \<Salesforce.*\/\(.*\)\>/#import "\1"/' > src/ios/$2/$1
}

copy_lib ()
{
    echo "* Copying $1"
    find tmp -name $1 -exec cp {} src/ios/frameworks/ \;
}

export ANDROID_SDK=../SalesforceMobileSDK-Android
export IOS_SDK=../SalesforceMobileSDK-iOS
export SHARED_SDK=../SalesforceMobileSDK-Shared

echo "*** Looking for tools and sdks"
if [ ! -d "tools" ]
then
    echo "You must run this tool from the root directory of your repo clone"
    exit 0
else
    echo "Found tools"
fi 

if [ ! -d "$IOS_SDK" ]
then
    echo "You must clone SalesforceMobileSDK-iOS next to SalesforceMobileSDK-CordovaPlugin"
    exit 0
else
    echo "Found SalesforceMobileSDK-iOS"
    if [ "$OPTION" != "nobuild" ] 
    then
        echo "Building SalesforceMobileSDK-iOS"
        cd $IOS_SDK
        ./install.sh
        cd build
        ant 
        cd ../../SalesforceMobileSDK-CordovaPlugin
    fi
fi
    ]
if [ ! -d "$ANDROID_SDK" ]
then
    echo "You must clone SalesforceMobileSDK-Android next to SalesforceMobileSDK-CordovaPlugin"
    exit 0
else
    echo "Found SalesforceMobileSDK-Android"
    cd $ANDROID_SDK
    ./install.sh
    cd ../SalesforceMobileSDK-CordovaPlugin
fi

if [ ! -d "$SHARED_SDK" ]
then
    echo "You must clone SalesforceMobileSDK-Shared next to SalesforceMobileSDK-CordovaPlugin"
    exit 0
else
    echo "Found SalesforceMobileSDK-Shared"
fi

echo "*** Creating directories ***"
echo "Starting clean"
rm -rf tmp src
echo "Creating tmp directory"
mkdir -p tmp
echo "Creating android directories"
mkdir -p src/android/libs
mkdir -p src/android/assets
echo "Creating ios directories"
mkdir -p src/ios/headers
mkdir -p src/ios/frameworks
mkdir -p src/ios/classes
mkdir -p src/ios/resources

echo "*** Android ***"
echo "Copying SalesforceSDK library"
cp -r $ANDROID_SDK/libs/SalesforceSDK src/android/libs/
echo "Copying SmartStore library"
cp -r $ANDROID_SDK/libs/SmartStore src/android/libs/
echo "Copying icu461.zip"
cp $ANDROID_SDK/external/sqlcipher/assets/icudt46l.zip src/android/assets/
echo "Copying sqlcipher"
cp -r $ANDROID_SDK/external/sqlcipher/libs/* src/android/libs/SmartStore/libs/    

echo "*** iOS ***"
echo "Copying SalesforceHybridSDK library"    
unzip $IOS_SDK/build/artifacts/SalesforceHybridSDK-Debug.zip -d tmp
echo "Copying SalesforceOAuth library"    
unzip $IOS_SDK/build/artifacts/SalesforceOAuth-Debug.zip -d tmp
echo "Copying SalesforceSDKCore library"    
unzip $IOS_SDK/build/artifacts/SalesforceSDKCore-Debug.zip -d tmp
echo "Copying SalesforceSecurity library"    
unzip $IOS_SDK/build/artifacts/SalesforceSecurity-Debug.zip -d tmp
echo "Copying SalesforceCommonUtils library"    
cp -r $IOS_SDK/external/ThirdPartyDependencies/SalesforceCommonUtils  tmp
echo "Copying openssl library"    
cp -r $IOS_SDK/external/ThirdPartyDependencies/openssl  tmp
echo "Copying sqlcipher library"    
cp -r $IOS_SDK/external/ThirdPartyDependencies/sqlcipher  tmp
echo "Copying AppDelegate+SalesforceHybridSDK"    
cp $IOS_SDK/shared/hybrid/AppDelegate+SalesforceHybridSDK.*  tmp
echo "Copying and fixing needed headers to src/ios/headers"
copy_and_fix AppDelegate+SalesforceHybridSDK.h headers
copy_and_fix SFAuthenticationManager.h headers
copy_and_fix SFCommunityData.h headers
copy_and_fix SFDefaultUserManagementViewController.h headers
copy_and_fix SFHybridViewConfig.h headers
copy_and_fix SFHybridViewController.h headers
copy_and_fix SFIdentityCoordinator.h headers
copy_and_fix SFIdentityData.h headers
copy_and_fix SFLocalhostSubstitutionCache.h headers
copy_and_fix SFLogger.h headers
copy_and_fix SFOAuthCoordinator.h headers
copy_and_fix SFOAuthCredentials.h headers
copy_and_fix SFOAuthInfo.h headers
copy_and_fix SFPushNotificationManager.h headers
copy_and_fix SFUserAccount.h headers
copy_and_fix SFUserAccountConstants.h headers
copy_and_fix SFUserAccountManager.h headers
copy_and_fix AppDelegate+SalesforceHybridSDK.m classes
echo "Copying needed libraries to src/ios/frameworks"
copy_lib libSalesforceCommonUtils.a
copy_lib libSalesforceHybridSDK.a
copy_lib libSalesforceOAuth.a
copy_lib libSalesforceSDKCore.a
copy_lib libSalesforceSecurity.a
copy_lib libcrypto.a
copy_lib libsqlcipher.a
copy_lib libssl.a
echo "Copying Images.xcassets"
cp -r $IOS_SDK/shared/resources/ImagesHybrid.xcassets src/ios/resources/Images.xcassets
echo "Copying Settings.bundle"
cp -r $IOS_SDK/shared/resources/Settings.bundle src/ios/resources/
echo "Copying SalesforceSDKResources.bundle"
cp -r $IOS_SDK/shared/resources/SalesforceSDKResources.bundle src/ios/resources/

echo "*** Shared ***"
echo "Copying split cordova.force.js out of bower_components"
cp $SHARED_SDK/gen/plugins/com.salesforce/*.js www/

echo "*** Cleanup ***"
rm -rf tmp


