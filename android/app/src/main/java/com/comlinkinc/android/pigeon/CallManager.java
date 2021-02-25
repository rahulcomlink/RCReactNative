package com.comlinkinc.android.pigeon;

import android.content.Context;
import android.media.MediaPlayer;
import android.util.Log;

import androidx.core.content.ContextCompat;

import com.comlinkinc.communicator.dialer.Call;
import com.comlinkinc.communicator.dialer.Dialer;
import com.comlinkinc.communicator.dialer.DialerException;

import java.io.File;

public class CallManager {

    // Variables
    public static Call call;
    public static MediaPlayer ringtone;


    /********************************************************************************************
     * SDK Class: Dialer.class
     *******************************************************************************************
     * @param mContext*/
    public static boolean startDialer(Context mContext) {
        try {
            Dialer.start(getDefaultConfig(mContext));
            return true;

//            Prefs.setSharedPreferenceBoolean(mContext, Prefs.PREFS_DIALER_SUCCESS, true);
//
//            Dialer.setInboundCallHandler(CallActivity::onInboundCall);
//            Dialer.setCallTerminatedHandler(CallActivity::onCallTerminated);
//            Dialer.setCallDeclinedHandler(CallActivity::onCallDeclined);
//            Dialer.setCallAnsweredHandler(CallActivity::onCallAnswered);
        } catch (UnsatisfiedLinkError e) {
//            Prefs.setSharedPreferenceBoolean(mContext, Prefs.PREFS_DIALER_SUCCESS, false);
            Log.d("DILER_Error_Callmanager", e.getMessage().toString());
            return false;
        } catch (DialerException e) {
//            Prefs.setSharedPreferenceBoolean(mContext, Prefs.PREFS_DIALER_SUCCESS, false);
            Log.d("DILER_Error_Callmanager", e.getMessage().toString());
            return false;
        } catch (Exception e) {
//            Prefs.setSharedPreferenceBoolean(mContext, Prefs.PREFS_DIALER_SUCCESS, false);
            Log.d("DILER_Error_Callmanager", e.getMessage().toString());
            return false;
        }
    }

    private static int getTransport(String sipTransport) {
        int transportID = 0;
        switch (sipTransport) {
            case "TCP":
                transportID = 1;
                return transportID;
            case "UDP":
                transportID = 1;
                return transportID;
            case "TLS":
                transportID = 2;
                return transportID;
        }
        return transportID;
    }

    public static void stopDialer() {
        try {
            Dialer.stop();
        } catch (Exception e) {
            e.printStackTrace();
        }
    }

    public static void registerDialer() {
        try {
            Dialer.register();
        } catch (DialerException e) {
//            Toast.makeText(KulfiApplication.getAppContext(), "Registration failed", Toast.LENGTH_SHORT).show();
            e.printStackTrace();
        }
    }

    public static void unRegisterDialer() {
        try {
            Dialer.unregister();
        } catch (DialerException e) {
            e.printStackTrace();
        }
    }

    public static Dialer.Configuration getDefaultConfig(Context mContext) {
        String[] codecs = new String[5];
        codecs[0] = "G729/8000/1";
        codecs[1] = "opus/48000/2";
        codecs[2] = "opus/24000/2";
        codecs[3] = "PCMU/8000/1";
        codecs[4] = "PCMA/8000/1";

        File[] sdCards = ContextCompat.getExternalFilesDirs(mContext, "");
        String filePath = sdCards[0].listFiles()[0].getAbsolutePath();
//        String deviceToken = Prefs.getSharedPreferenceString(mContext, Prefs.PREFS_DEVICE_TOKEN, "");

        Dialer.Configuration dialerConfig = new Dialer.Configuration();
        dialerConfig.sipServerHost = "209.15.246.144";
        dialerConfig.sipServerPort = 8993;
        dialerConfig.sipLocalPort = 8993;
        dialerConfig.sipTransport = 1;
        dialerConfig.sipUsername = "TCS48503643336";
        dialerConfig.sipPassword = "500500";
        dialerConfig.sipRealm = "*";
        dialerConfig.turnHost = "turntaiwan.mvoipctsi.com";
        dialerConfig.turnUsername = "comlinkxone";
        dialerConfig.turnPassword = "hgskSlGHgwSKfgsdUSDGhs";
        dialerConfig.turnRealm = "*";
        dialerConfig.stunHost = "turntaiwan.mvoipctsi.com";
        dialerConfig.enableICE = true;
        dialerConfig.enableSRTP = false;
        dialerConfig.answerTimeout = 10;
        dialerConfig.ringbackAudioFile = filePath;
        dialerConfig.desiredCodecs = codecs;
        dialerConfig.deviceId = "deviceToken";

        return dialerConfig;
    }
}
