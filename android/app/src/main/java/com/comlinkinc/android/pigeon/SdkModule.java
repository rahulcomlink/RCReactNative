package com.comlinkinc.android.pigeon;

import android.app.Activity;
import android.media.AudioManager;
import android.os.Build;

import com.comlinkinc.communicator.dialer.Dialer;
import com.facebook.react.bridge.Callback;
import com.facebook.react.bridge.ReactApplicationContext;
import com.facebook.react.bridge.ReactContextBaseJavaModule;
import com.facebook.react.bridge.ReactMethod;

import static android.content.Context.AUDIO_SERVICE;

public class SdkModule extends ReactContextBaseJavaModule {

    AudioManager mAudioManager;


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

    //End Call
    @ReactMethod
    public void endCall() {
        try {
            final Activity activity = getCurrentActivity();
            CallManager.hangup(activity);
        } catch (Exception e) {

        }
    }


    //Mute/Unmute Call
    @ReactMethod
    public void muteUnmuteCall(boolean flag) {
        try {
            final Activity activity = getCurrentActivity();
            CallManager.muteUnmuteCall(flag);
        } catch (Exception e) {

        }
    }

    // Key Press
    @ReactMethod
    public void keyPressed(char str) {
        try {
            final Activity activity = getCurrentActivity();
            CallManager.keypad(str);
        } catch (Exception e) {

        }
    }


    // Key Press
    @ReactMethod
    public void setOnSpeker(boolean setSpecker) {
        try {
            final Activity activity = getCurrentActivity();

            mAudioManager = (AudioManager) activity.getApplicationContext().getSystemService(AUDIO_SERVICE);
            if (setSpecker) {
                mAudioManager.setSpeakerphoneOn(false);
            } else {
                mAudioManager.setSpeakerphoneOn(true);
            }

        } catch (Exception e) {

        }
    }

    // Stop Dialer
    @ReactMethod
    public void startDialer(String sipUsername,
                            String sipPassword,
                            String sipServer,
                            String realm,
                            String stunServer,
                            String turnServer,
                            String turnUsername,
                            String turnPassword,
                            String turnRealm,
                            String iceEnabled,
                            String sipLocalPort,
                            String sipServerPort,
                            String sipTransport,
                            String turnPort,
                            String stunPort) {
        try {
            final Activity activity = getCurrentActivity();
//            CallManager.startDialerNew(activity, sipUsername,
//                    sipPassword,
//                    sipServer,
//                    realm,
//                    stunServer,
//                    turnServer,
//                    turnUsername,
//                    turnPassword,
//                    turnRealm,
//                    iceEnabled,
//                    Integer.parseInt(sipLocalPort),
//                    Integer.parseInt(sipServerPort),
//                    sipTransport,
//                    turnPort,
//                    stunPort);

            CallManager.startDialer(activity);
        } catch (Exception e) {

        }
    }

    // Stop Dialer
    @ReactMethod
    public void stopDialer() {
        try {
            final Activity activity = getCurrentActivity();
            CallManager.stopDialer();
        } catch (Exception e) {

        }
    }

    // MakeCall
    @ReactMethod
    public void makeCall(String sipUri) {
        try {
            final Activity activity = getCurrentActivity();
            Dialer.makeCall(sipUri);
        } catch (Exception e) {

        }
    }
}