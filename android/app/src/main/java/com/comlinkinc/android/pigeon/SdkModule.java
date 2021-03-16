package com.comlinkinc.android.pigeon;

import android.app.Activity;
import android.media.AudioManager;
import android.os.Build;

import androidx.fragment.app.FragmentActivity;

import com.comlinkinc.communicator.dialer.Call;
import com.comlinkinc.communicator.dialer.Dialer;
import com.facebook.react.bridge.Callback;
import com.facebook.react.bridge.ReactApplicationContext;
import com.facebook.react.bridge.ReactContextBaseJavaModule;
import com.facebook.react.bridge.ReactMethod;

import static android.content.Context.AUDIO_SERVICE;
import static com.comlinkinc.android.pigeon.CallManager.mCallStatusHandler;

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

            if (mAudioManager == null){
                mAudioManager = (AudioManager) activity.getApplicationContext().getSystemService(AUDIO_SERVICE);
            }

            if (flag) {
                mAudioManager.setMicrophoneMute(true);
            } else {
                mAudioManager.setMicrophoneMute(false);
                mAudioManager.setMode(AudioManager.MODE_IN_CALL);
            }
        } catch (Exception e) {

        }
    }

    // Key Press
    @ReactMethod
    public void keyPressed(String str) {
        try {
            final Activity activity = getCurrentActivity();
            CallManager.keypad(str.charAt(0));
        } catch (Exception e) {

        }
    }


    // Key Press
    @ReactMethod
    public void setOnSpeker(boolean setSpecker) {
        try {
            final Activity activity = getCurrentActivity();

            if (mAudioManager == null){
                mAudioManager = (AudioManager) activity.getApplicationContext().getSystemService(AUDIO_SERVICE);
            }

            if (setSpecker) {
                mAudioManager.setSpeakerphoneOn(true);
                mAudioManager.setMode(AudioManager.MODE_IN_COMMUNICATION);
            } else {
                mAudioManager.setSpeakerphoneOn(false);
                mAudioManager.setMode(AudioManager.MODE_IN_CALL);
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

            boolean isDialerAlreadyStart = Prefs.getSharedPreferenceBoolean(activity, Prefs.PREFS_DIALER_SUCCESS, false);
            if (!isDialerAlreadyStart) {
//                stopDialer();
                CallManager.startDialer(activity);
            }

            Dialer.register();

            CallManager.ringing = false;
            CallManager.answered = false;
            CallManager.terminated = false;
            CallManager.declined = false;

            if (mCallStatusHandler != null) {
                mCallStatusHandler.sendEmptyMessage(1);//TIME_START
            }else{
                mCallStatusHandler = new CallManager.CallStatusHandler();
                mCallStatusHandler.sendEmptyMessage(1);//TIME_START
            }

            CallManager.call = Dialer.makeCall(sipUri);

            if (mAudioManager == null){
                mAudioManager = (AudioManager) activity.getApplicationContext().getSystemService(AUDIO_SERVICE);
            }
            mAudioManager.setMode(AudioManager.MODE_IN_CALL);
        } catch (Exception e) {

        }
    }



    // Ask runtime permissions for Storage and Mic
    @ReactMethod
    public void askStorageAndMicPermission() {
        String []permissions = {"android.permission.READ_EXTERNAL_STORAGE", "android.permission.RECORD_AUDIO"};

        final Activity activity = getCurrentActivity();
        if (Utilities.checkPermissionsGranted(activity, permissions)) {
            try {
                CallManager.copyRingtoneToPhoneStorage(MainApplication.getAppContext());
            } catch (Exception e) {
            }
        }else{
            Utilities.askForPermissions((FragmentActivity) activity, permissions);
        }
    }
}