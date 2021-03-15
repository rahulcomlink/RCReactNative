package com.comlinkinc.android.pigeon;

import android.annotation.SuppressLint;
import android.app.Activity;
import android.content.ContentResolver;
import android.content.Context;
import android.content.Intent;
import android.content.res.AssetFileDescriptor;
import android.media.MediaPlayer;
import android.net.Uri;
import android.os.Environment;
import android.os.Handler;
import android.provider.Settings;
import android.util.Log;

import androidx.annotation.StringRes;
import androidx.core.content.ContextCompat;

import com.comlinkinc.communicator.dialer.Call;
import com.comlinkinc.communicator.dialer.Dialer;
import com.comlinkinc.communicator.dialer.DialerException;
import com.facebook.react.modules.core.DeviceEventManagerModule;

import java.io.BufferedReader;
import java.io.File;
import java.io.FileInputStream;
import java.io.FileNotFoundException;
import java.io.FileOutputStream;
import java.io.IOException;
import java.io.InputStreamReader;
import java.io.OutputStreamWriter;
import java.net.URLDecoder;
import java.util.function.Consumer;

import static com.comlinkinc.communicator.dialer.Call.Status.DECLINED;
import static com.comlinkinc.communicator.dialer.Call.Status.RINGING;
import static com.comlinkinc.communicator.dialer.Call.Status.TERMINATED;
import static com.incomingcall.IncomingCallModule.reactContext;
import static com.wix.reactnativeuilib.keyboardinput.AppContextHolder.getCurrentActivity;

public class CallManager {

    // Variables
    public static Call call;
    public static MediaPlayer ringtone;
    // Call State
    private static com.comlinkinc.communicator.dialer.Call.Status mState;
    private static String mStateText;

    // Handler variables
    private static final int TIME_START = 1;
    private static final int TIME_STOP = 0;
    private static final int TIME_UPDATE = 2;
    private static final int REFRESH_RATE = 100;
    static Handler mCallStatusHandler = null;


    /********************************************************************************************
     * SDK Class: Dialer.class
     *******************************************************************************************
     * @param mContext*/
    public static String startDialer(Context mContext) {
        try {
            Dialer.start(getDefaultConfig(mContext));
            Prefs.setSharedPreferenceBoolean(mContext, Prefs.PREFS_DIALER_SUCCESS, true);

            mCallStatusHandler = new CallStatusHandler();
            return "Success";
//
//            Dialer.setInboundCallHandler(CallActivity::onInboundCall);
//            Dialer.setCallTerminatedHandler(CallActivity::onCallTerminated);
//            Dialer.setCallDeclinedHandler(CallActivity::onCallDeclined);
//            Dialer.setCallAnsweredHandler(CallActivity::onCallAnswered);
        } catch (UnsatisfiedLinkError e) {
            Prefs.setSharedPreferenceBoolean(mContext, Prefs.PREFS_DIALER_SUCCESS, false);
            Log.d("DILER_Error_Callmanager", e.getMessage().toString());
            return ""+e.getMessage();
        } catch (DialerException e) {
            Prefs.setSharedPreferenceBoolean(mContext, Prefs.PREFS_DIALER_SUCCESS, false);
            Log.d("DILER_Error_Callmanager", e.getMessage().toString());
            return "" + e.getMessage();
        } catch (Exception e) {
            Prefs.setSharedPreferenceBoolean(mContext, Prefs.PREFS_DIALER_SUCCESS, false);
            Log.d("DILER_Error_Callmanager", e.getMessage().toString());
            return "" + e.getMessage();
        }
    }


    /********************************************************************************************
     * SDK Class: Dialer.class
     *******************************************************************************************
     * @param mContext*/
    public static String startDialerNew(Context mContext, String sipUsername,
                                        String sipPassword,
                                        String sipServer,
                                        String realm,
                                        String stunServer,
                                        String turnServer,
                                        String turnUsername,
                                        String turnPassword,
                                        String turnRealm,
                                        String iceEnabled,
                                        int sipLocalPort,
                                        int sipServerPort,
                                        String sipTransport,
                                        String turnPort,
                                        String stunPort) {
        try {
            Dialer.start(getDefaultConfigNew(mContext, sipUsername,
                    sipPassword,
                    sipServer,
                    realm,
                    stunServer,
                    turnServer,
                    turnUsername,
                    turnPassword,
                    turnRealm,
                    iceEnabled,
                    sipLocalPort,
                    sipServerPort,
                    sipTransport,
                    turnPort,
                    stunPort));
            return "Success";
        } catch (UnsatisfiedLinkError e) {
//            Prefs.setSharedPreferenceBoolean(mContext, Prefs.PREFS_DIALER_SUCCESS, false);
            Log.d("DILER_Error_Callmanager", e.getMessage().toString());
            return "" + e.getMessage();
        } catch (DialerException e) {
//            Prefs.setSharedPreferenceBoolean(mContext, Prefs.PREFS_DIALER_SUCCESS, false);
            Log.d("DILER_Error_Callmanager", e.getMessage().toString());
            return "" + e.getMessage();
        } catch (Exception e) {
//            Prefs.setSharedPreferenceBoolean(mContext, Prefs.PREFS_DIALER_SUCCESS, false);
            Log.d("DILER_Error_Callmanager", e.getMessage().toString());
            return "" + e.getMessage();
        }
    }

    public static Dialer.Configuration getDefaultConfigNew(Context mContext, String sipUsername,
                                                           String sipPassword,
                                                           String sipServer,
                                                           String realm,
                                                           String stunServer,
                                                           String turnServer,
                                                           String turnUsername,
                                                           String turnPassword,
                                                           String turnRealm,
                                                           String iceEnabled,
                                                           int sipLocalPort,
                                                           int sipServerPort,
                                                           String sipTransport,
                                                           String turnPort,
                                                           String stunPort) {
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
        dialerConfig.sipServerHost = sipServer;
        dialerConfig.sipServerPort = sipServerPort;
        dialerConfig.sipLocalPort = sipLocalPort;
        dialerConfig.sipTransport = getTransport(sipTransport);
        dialerConfig.sipUsername = sipUsername;
        dialerConfig.sipPassword = sipPassword;
        dialerConfig.sipRealm = "*";
        dialerConfig.turnHost = turnServer;
        dialerConfig.turnUsername = turnUsername;
        dialerConfig.turnPassword = turnPassword;
        dialerConfig.turnRealm = "*";
        dialerConfig.stunHost = stunServer;
        dialerConfig.enableICE = true;
        dialerConfig.enableSRTP = false;
        dialerConfig.answerTimeout = 10;
        dialerConfig.ringbackAudioFile = filePath;
        dialerConfig.desiredCodecs = codecs;
        dialerConfig.deviceId = "deviceToken";

        return dialerConfig;
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
        dialerConfig.sipServerHost = "newxonesip.mvoipctsi.com";
        dialerConfig.sipServerPort = 8993;
        dialerConfig.sipLocalPort = 8993;
        dialerConfig.sipTransport = 1;
        dialerConfig.sipUsername = "919926054520";
        dialerConfig.sipPassword = "5d7d42db4c2f87001a71c413";
        dialerConfig.sipRealm = "*";
        dialerConfig.turnHost = "turntaiwan.mvoipctsi.com";
        dialerConfig.turnUsername = "comlinkxone";
        dialerConfig.turnPassword = "hgskSlGHgwSKfgsdUSDGhs";
        dialerConfig.turnRealm = "";
        dialerConfig.stunHost = "turntaiwan.mvoipctsi.com";
        dialerConfig.enableICE = true;
        dialerConfig.enableSRTP = false;
        dialerConfig.answerTimeout = 60;
        dialerConfig.ringbackAudioFile = filePath;
        dialerConfig.desiredCodecs = codecs;
        dialerConfig.deviceId = "deviceToken";

        return dialerConfig;
    }

    //Sip registration template (Android) -  "sip:" + username + "@" + host + ":" + port;
    //Make call template                  -  "sip:" + numberToDial + "@" + data.getHost()
    public static void makeCall(Activity mContext, String sipUri, Contact contact) {
        try {
//            writeLogCat();
            mContext.runOnUiThread(new Runnable() {
                @Override
                public void run() {
                    showOngoingCallActivity(contact);
                }
            });

            boolean isDialerAlreadyStart = Prefs.getSharedPreferenceBoolean(mContext, Prefs.PREFS_DIALER_SUCCESS, false);
            if (!isDialerAlreadyStart) {
//                stopDialer();
                startDialer(MainApplication.getAppContext());
            }

//            unRegisterDialer();
            registerDialer();
            call = Dialer.makeCall(sipUri);
        } catch (DialerException e) {
            Log.d("Make_Call_Fail", e.getMessage());
            e.printStackTrace();
        }
    }


    public static void hangup(Context mContext) {
        if (call != null) {
            try {
                call.hangup();
//                call.close();
                Dialer.unregister();
                call = null;
            } catch (DialerException e) {
                e.printStackTrace();
            } catch (Exception e) {
                e.printStackTrace();
            }
        }

        mCallStatusHandler.sendEmptyMessage(TIME_STOP);
    }

    private void getIncomingCall(){

    }

    private static Consumer<Call> inboundCall() {
        Log.d("CALL", "Inbound Call");
        return null;
    }


    // -- Call Actions -- //

    /**
     * Answers incoming call
     */
    public static void answer() {
        if (call != null) {
            try {
                call.answer();
            } catch (DialerException e) {
                e.printStackTrace();
            }
        }
    }

    /**
     * Ends call
     * If call ended from the other side, disconnects
     *
     * @return true whether there's no more calls awaiting
     */
    public static void reject() {
        if (call != null) {
            try {
//                if (call.getStatus() == com.comlinkinc.communicator.dialer.Call.Status.RINGING) {
//                    call.reject();
//                } else {
//                    call.hangup();
//                }
                call.hangup();
//                CallActivity.getInstance().finishOngoingCallActivity();
            } catch (DialerException e) {
//                CallActivity.getInstance().finishOngoingCallActivity();
                e.printStackTrace();
            }
        }

        stopRingTone();
        unRegisterDialer();
//        CallActivity.getInstance().finishOngoingCallActivity();

//        stopDialer();
    }

    /**
     * Put call on hold
     *
     * @param hold
     */
    public static void hold(boolean hold) {
        if (call != null) {
            if (hold) {
                try {
                    call.hold();
                } catch (DialerException e) {
                    e.printStackTrace();
                }
            } else {
                try {
                    call.releaseHold();
                } catch (DialerException e) {
                    e.printStackTrace();
                }
            }
        }
    }

    /**
     * Mute/Unmute call
     */
    public static void muteUnmuteCall(boolean hold) {
        if (call != null) {
            if (call.isMicrophoneMuted()) {
                try {
                    call.unmuteMicrophone();
                } catch (DialerException e) {
                    e.printStackTrace();
                }
            } else {
                try {
                    call.muteMicrophone();
                } catch (DialerException e) {
                    e.printStackTrace();
                }
            }
        }
    }

    /**
     * Open keypad
     *
     * @param c
     */
    public static void keypad(char c) {
        if (call != null) {
            try {
                call.sendDTMFTone(c);
            } catch (DialerException e) {
                e.printStackTrace();
            }
        }
    }


    /**
     * Gets the phone number of the contact from the end side of the current call
     * in the case of a voicemail number, returns "Voicemail"
     *
     * @return String - phone number, or voicemail. if not recognized, return null.
     */
    public static Contact getDisplayContact(Context context) {
        String number;
        // try getting the number of the other side of the call
        try {
            number = URLDecoder.decode(call.getRemoteParty().substring(4, call.getRemoteParty().indexOf("@")).toString(), "utf-8").replace("tel:", "");
        } catch (Exception e) {
            return Constants.UNKNOWN;
        }
        // check if number is a voice mail
        if (number.contains("voicemail")) return Constants.VOICEMAIL;
        // get the contact
        Contact contact = Constants.getContactByPhoneNumber(context, number); // get the contacts with the number
        if (contact == null) return new Contact(number, number, null); // return a number contact
        else return contact; // contact is valid, return it
    }

    /**
     * Returnes the current state of the call from the Call object (named call)
     *
     * @return Call.State
     */
    public static com.comlinkinc.communicator.dialer.Call.Status getState() {
        if (call == null) return call.getStatus().NONE; // if no call, return disconnected
        return call.getStatus();
    }

    public static void showOngoingCallActivity(Contact contact) {
        Intent intent = new Intent(MainApplication.getAppContext(), MainActivity.class);//CallActivity
        intent.addFlags(Intent.FLAG_ACTIVITY_CLEAR_TOP);
        intent.addFlags(Intent.FLAG_ACTIVITY_NEW_TASK);
        intent.putExtra("Contact", contact);
        MainApplication.getAppContext().startActivity(intent);

    }

    public static void playRingtone(Context mContext) {
        ringtone = MediaPlayer.create(mContext, Settings.System.DEFAULT_RINGTONE_URI);
        ringtone.start();
    }

    public static void stopRingTone() {
        if (ringtone != null) {
            ringtone.stop();
        }
    }

    public static void copyRingtoneToPhoneStorage(Context mContext) {
        boolean isRingAlreadySaved = Prefs.getSharedPreferenceBoolean(mContext, Prefs.PREFS_CP_RING_TO_PHONE, false);
        if (!isRingAlreadySaved) {
            String ringtoneuri = Environment.getExternalStorageDirectory().getAbsolutePath() + "/Android/data/com.comlinkinc.android.pigeon/files";
            File file1 = new File(ringtoneuri);
            file1.mkdirs();
            File newSoundFile = new File(ringtoneuri, "ring.wav");

            Uri mUri = Uri.parse("android.resource://com.comlinkinc.android.pigeon/" + R.raw.ring);


            ContentResolver mCr = mContext.getContentResolver();
            AssetFileDescriptor soundFile;
            try {
                soundFile = mCr.openAssetFileDescriptor(mUri, "r");
            } catch (FileNotFoundException e) {
                soundFile = null;
            }

            try {
                byte[] readData = new byte[1024];
                FileInputStream fis = soundFile.createInputStream();
                FileOutputStream fos = new FileOutputStream(newSoundFile);
                int i = fis.read(readData);

                while (i != -1) {
                    fos.write(readData, 0, i);
                    i = fis.read(readData);
                }

                fos.close();
            } catch (IOException io) {
            }


            String absPath = newSoundFile.getAbsolutePath();
            Prefs.setSharedPreferenceBoolean(mContext, Prefs.PREFS_CP_RING_TO_PHONE, true);
            startDialer(mContext);
        }
    }

    protected static void writeLogCat() {
        try {
            Process process = Runtime.getRuntime().exec("logcat -d");
            BufferedReader bufferedReader = new BufferedReader(new InputStreamReader(process.getInputStream()));
            StringBuilder log = new StringBuilder();
            String line;
            while ((line = bufferedReader.readLine()) != null) {
                log.append(line);
                log.append("\n");
            }

            //Convert log to string
            final String logString = new String(log.toString());

            //Create txt file in SD Card
            File sdCard = Environment.getExternalStorageDirectory();
            File dir = new File(sdCard.getAbsolutePath() + File.separator + "EnterpriseVoIP");

            if (!dir.exists()) {
                dir.mkdirs();
            }

            String timestamp = String.valueOf(System.currentTimeMillis());
            Prefs.setSharedPreferenceString(MainApplication.getAppContext(), "timestamp", timestamp);
            File file = new File(dir, "evoiplogcat" + timestamp + ".txt");

            //To write logcat in text file
            FileOutputStream fout = new FileOutputStream(file);
            OutputStreamWriter osw = new OutputStreamWriter(fout);

            //Writing the string to file
            osw.write(logString);
            osw.flush();
            osw.close();
        } catch (FileNotFoundException e) {
            e.printStackTrace();
        } catch (IOException e) {
            e.printStackTrace();
        }
    }


    @SuppressLint("HandlerLeak")
    public static class CallStatusHandler extends Handler {
        @Override
        public void handleMessage(android.os.Message msg) {
            super.handleMessage(msg);
            switch (msg.what) {
                case TIME_START:
                    mCallStatusHandler.sendEmptyMessage(TIME_UPDATE); // Starts the time ui updates
                    break;
                case TIME_STOP:
                    mCallStatusHandler.removeMessages(TIME_UPDATE); // No more updates
                    break;
                case TIME_UPDATE:
                    if (call != null) {
                        updateCallStatus(call.getStatus());
                    }
                    mCallStatusHandler.sendEmptyMessageDelayed(TIME_UPDATE, REFRESH_RATE); // Text view updates every milisecond (REFRESH RATE)
                    break;
                default:
                    break;
            }
        }
    }

    /**
     * Updates the ui given the call state
     *
     * @param state the current call state
     */
    private static void updateCallStatus(Call.Status state) {
        @StringRes int statusTextRes;
        switch (state) {
            case NONE:
                statusTextRes = R.string.status_call_none;
                break;
            case TRYING:
                statusTextRes = R.string.status_call_dialing;
                break;
            case RINGING:
                statusTextRes = R.string.status_call_ringing;
                break;
            case ANSWERED:
                statusTextRes = R.string.status_call_answered;
                break;
            case TERMINATED:
                statusTextRes = R.string.status_call_disconnected;
                break;
            case DECLINED:
                statusTextRes = R.string.status_call_busy;
                break;
            default:
                statusTextRes = R.string.status_call_active;
                break;
        }
        reactContext
                .getJSModule(DeviceEventManagerModule.RCTDeviceEventEmitter.class)
                .emit("onSessionConnect", getCurrentActivity().getResources().getString(statusTextRes));
//        txtCallStatus.setText(statusTextRes);
    }

}
