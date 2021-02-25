package com.comlinkinc.android.pigeon;

import android.app.Activity;
import android.os.Build;

import com.facebook.react.bridge.Callback;
import com.facebook.react.bridge.ReactApplicationContext;
import com.facebook.react.bridge.ReactContextBaseJavaModule;
import com.facebook.react.bridge.ReactMethod;

public class SdkModule extends ReactContextBaseJavaModule {
    //constructor
    public SdkModule(ReactApplicationContext reactContext) {
        super(reactContext);
    }

    //Mandatory function getName that specifies the module name
    @Override
    public String getName() {
        return "Sdk";
    }

    //Custom function that we are going to export to JS
    @ReactMethod
    public void startDialerMethod(Callback cb) {
        try {
            final Activity activity = getCurrentActivity();

            String funCall = CallManager.startDialer(activity);

            cb.invoke(null, "Application run on - " + Build.MANUFACTURER +
                    "\n\n is comlink SDK method called -  " + funCall);
        } catch (Exception e) {
            cb.invoke(e.toString(), null);
        }
    }
}