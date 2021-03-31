package com.comlinkinc.android.pigeon;

import android.app.NotificationChannel;
import android.app.NotificationManager;
import android.content.Context;
import android.content.Intent;
import android.content.SharedPreferences;
import android.content.res.Configuration;
import android.os.Build;
import android.os.Bundle;
import android.os.Handler;

import com.facebook.react.ReactActivityDelegate;
import com.facebook.react.ReactFragmentActivity;
import com.facebook.react.ReactInstanceManager;
import com.facebook.react.ReactRootView;
import com.facebook.react.bridge.Arguments;
import com.facebook.react.bridge.ReactContext;
import com.facebook.react.bridge.WritableMap;
import com.facebook.react.modules.core.DeviceEventManagerModule;
import com.google.gson.Gson;
import com.swmansion.gesturehandler.react.RNGestureHandlerEnabledRootView;
import com.tencent.mmkv.MMKV;
import com.zoontek.rnbootsplash.RNBootSplash;

import static com.comlinkinc.android.pigeon.SdkModule.reactContext;

class ThemePreferences {
  String currentTheme;
  String darkLevel;
}

class SortPreferences {
  String sortBy;
  Boolean groupByType;
  Boolean showFavorites;
  Boolean showUnread;
}

public class MainActivity extends ReactFragmentActivity implements ReactInstanceManager.ReactInstanceEventListener {

    public static MainActivity instance;
    boolean isIncomingCall = false;
    String phoneNumber = "";
    boolean called = false;

    @Override
    protected void onCreate(Bundle savedInstanceState) {
        // https://github.com/software-mansion/react-native-screens/issues/17#issuecomment-424704067
        super.onCreate(null);
        RNBootSplash.init(R.drawable.splash_screen, MainActivity.this);

        MMKV.initialize(MainActivity.this);

        instance = MainActivity.this;

        if (getIntent() != null && getIntent().getExtras() != null){
            isIncomingCall = getIntent().getExtras().getBoolean("incoming_call");
            phoneNumber = getIntent().getExtras().getString("phoneNumber");
        }


        // Start the MMKV container
        MMKV defaultMMKV = MMKV.defaultMMKV();
        boolean alreadyMigrated = defaultMMKV.decodeBool("alreadyMigrated");

        if (!alreadyMigrated) {
            // MMKV Instance that will be used by JS
            MMKV mmkv = MMKV.mmkvWithID("default");

            // SharedPreferences -> MMKV (Migration)
            SharedPreferences sharedPreferences = getSharedPreferences("react-native", Context.MODE_PRIVATE);
            mmkv.importFromSharedPreferences(sharedPreferences);

            // SharedPreferences only save strings, so we saved this value as a String and now we'll need to cast into a MMKV object

            // Theme preferences object
            String THEME_PREFERENCES_KEY = "RC_THEME_PREFERENCES_KEY";
            String themeJson = sharedPreferences.getString(THEME_PREFERENCES_KEY, "");
            if (!themeJson.isEmpty()) {
              ThemePreferences themePreferences = new Gson().fromJson(themeJson, ThemePreferences.class);
              WritableMap themeMap = new Arguments().createMap();
              themeMap.putString("currentTheme", themePreferences.currentTheme);
              themeMap.putString("darkLevel", themePreferences.darkLevel);
              Bundle bundle = Arguments.toBundle(themeMap);
              mmkv.encode(THEME_PREFERENCES_KEY, bundle);
            }

            // Sort preferences object
            String SORT_PREFS_KEY = "RC_SORT_PREFS_KEY";
            String sortJson = sharedPreferences.getString(SORT_PREFS_KEY, "");
            if (!sortJson.isEmpty()) {
              SortPreferences sortPreferences = new Gson().fromJson(sortJson, SortPreferences.class);
              WritableMap sortMap = new Arguments().createMap();
              sortMap.putString("sortBy", sortPreferences.sortBy);
              if (sortPreferences.groupByType != null) {
                sortMap.putBoolean("groupByType", sortPreferences.groupByType);
              }
              if (sortPreferences.showFavorites != null) {
                sortMap.putBoolean("showFavorites", sortPreferences.showFavorites);
              }
              if (sortPreferences.showUnread != null) {
                sortMap.putBoolean("showUnread", sortPreferences.showUnread);
              }
              Bundle bundle = Arguments.toBundle(sortMap);
              mmkv.encode(SORT_PREFS_KEY, bundle);
            }

            // Remove all our keys of SharedPreferences
            sharedPreferences.edit().clear().commit();
          
            // Mark migration complete
            defaultMMKV.encode("alreadyMigrated", true);
        }

        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.O) {
            NotificationChannel notificationChannel = new NotificationChannel("500", "MainChannel", NotificationManager.IMPORTANCE_HIGH);
            notificationChannel.setShowBadge(true);
            notificationChannel.setDescription("Test Notifications");
            notificationChannel.enableVibration(true);
            notificationChannel.enableLights(true);
            notificationChannel.setVibrationPattern(new long[]{400, 200, 400});
            //notificationChannel.setLockscreenVisibility(Notification.VISIBILITY_PUBLIC);
            NotificationManager manager = getSystemService(NotificationManager.class);
            manager.createNotificationChannel(notificationChannel);
        }

        String []permissions = {"android.permission.READ_EXTERNAL_STORAGE", "android.permission.RECORD_AUDIO"};

        if (Utilities.checkPermissionsGranted(MainActivity.this, permissions)) {
            try {
                CallManager.copyRingtoneToPhoneStorage(MainApplication.getAppContext());
            } catch (Exception e) {
            }
        }else{
            Utilities.askForPermissions(MainActivity.this, permissions);
        }
    }

    /**
    * Returns the name of the main component registered from JavaScript. This is used to schedule
    * rendering of the component.
    */
    @Override
    protected String getMainComponentName() {
        return "RocketChatRN";
    }

    @Override
    protected ReactActivityDelegate createReactActivityDelegate() {
      return new ReactActivityDelegate(this, getMainComponentName()) {
        @Override
        protected ReactRootView createRootView() {
         return new RNGestureHandlerEnabledRootView(MainActivity.this);
        }
      };
    }

    // from react-native-orientation
    @Override
    public void onConfigurationChanged(Configuration newConfig) {
        super.onConfigurationChanged(newConfig);
        Intent intent = new Intent("onConfigurationChanged");
        intent.putExtra("newConfig", newConfig);
        this.sendBroadcast(intent);
    }

    @Override
    public void onResume() {
        super.onResume();
        getReactInstanceManager().addReactInstanceEventListener(this);
    }

    @Override
    public void onPause() {
        super.onPause();
        getReactInstanceManager().removeReactInstanceEventListener(this);
    }

    @Override
    public void onReactContextInitialized(ReactContext context) {
        if (isIncomingCall && context != null){
            new Handler().postDelayed(new Runnable() {
                @Override
                public void run() {
                    if (!called) {
                        called = true;
                        context
                                .getJSModule(DeviceEventManagerModule.RCTDeviceEventEmitter.class)
                                .emit("CallAnswered", phoneNumber);
                    }
                }
            }, 1500);
        }
    }
}

