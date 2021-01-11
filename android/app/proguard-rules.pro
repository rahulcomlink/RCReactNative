# Add project specific ProGuard rules here.
# By default, the flags in this file are appended to flags specified
# in /usr/local/Cellar/android-sdk/24.3.3/tools/proguard/proguard-android.txt
# You can edit the include path and order by changing the proguardFiles
# directive in build.gradle.
#
# For more details, see
#   http://developer.android.com/guide/developing/tools/proguard.html

# Add any project specific keep options here:


-keep class com.comlinkinc.android.pigeon** {*;}

-keep class com.comlinkinc.android.pigeon.generated** {*;}
-keep class com.comlinkinc.android.pigeon.networking** {*;}
-keep class com.comlinkinc.android.pigeon.share** {*;}

-keep class com.comlinkinc.android.pigeon.generated.BasePackageList {*;}
-keep class com.comlinkinc.android.pigeon.networking.SSLPinningModule {*;}
-keep class com.comlinkinc.android.pigeon.networking.SSLPinningPackage {*;}

-keep class com.comlinkinc.android.pigeon.share.ShareActivity {*;}
-keep class com.comlinkinc.android.pigeon.share.ShareApplication {*;}

-keep class com.comlinkinc.android.pigeon.MainActivity {*;}
-keep class com.comlinkinc.android.pigeon.MainApplication {*;}

-keep class com.tencent.mmkv** {*;}
-keep class com.bumptech.glide** {*;}
-keep class com.google.gson** {*;}
-keep class com.facebook.flipper** {*;}
-keep class com.bumptech.glide** {*;}
-keep class com.bumptech.glide** {*;}
-keep class com.reactnativejitsimeet** {*;}

-keepattributes *Annotation*, Signature, Exception
-keepattributes SourceFile, LineNumberTable

-repackageclasses
