package com.comlinkinc.android.pigeon;

import android.annotation.SuppressLint;
import android.app.Activity;
import android.app.KeyguardManager;
import android.app.Notification;
import android.app.NotificationChannel;
import android.app.NotificationManager;
import android.app.PendingIntent;
import android.content.ContentResolver;
import android.content.Context;
import android.content.Intent;
import android.content.res.AssetFileDescriptor;
import android.graphics.Color;
import android.media.AudioAttributes;
import android.media.MediaPlayer;
import android.net.Uri;
import android.os.Build;
import android.os.Environment;
import android.os.Handler;
import android.os.Looper;
import android.os.PowerManager;
import android.provider.Settings;
import android.util.Log;

import androidx.annotation.StringRes;
import androidx.core.app.NotificationCompat;
import androidx.core.content.ContextCompat;

import com.comlinkinc.android.pigeon.fcm.NotificationActionReceiver;
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
import java.util.Map;
import java.util.function.Consumer;

import static android.app.Notification.EXTRA_NOTIFICATION_ID;
import static android.content.Context.POWER_SERVICE;
import static com.comlinkinc.android.pigeon.SdkModule.callAswered;
import static com.comlinkinc.android.pigeon.SdkModule.reactContext;
import static com.comlinkinc.android.pigeon.fcm.MyFirebaseMessagingService.dataPayload;
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
    private static final int REFRESH_RATE = 1000;
    static Handler mCallStatusHandler = null;

    public static boolean ringing = false;
    public static boolean answered = false;
    public static boolean terminated = false;
    public static boolean declined = false;


    // Notification
    static NotificationCompat.Builder mBuilder;
    NotificationManager mNotificationManager;
    private static final String CHANNEL_ID = "notification";
    private static final int NOTIFICATION_ID = 42069;
    public static final String ACTION_ANSWER = "ANSWER";
    public static final String ACTION_HANGUP = "HANGUP";
    public static Contact contactFromPayload = null;


    /********************************************************************************************
     * SDK Class: Dialer.class
     *******************************************************************************************
     * @param mContext*/
    public static String startDialer(Context mContext) {
        try {
            Dialer.start(getDefaultConfig(mContext));
            Prefs.setSharedPreferenceBoolean(mContext, Prefs.PREFS_DIALER_SUCCESS, true);

            mCallStatusHandler = new CallStatusHandler();

//
            Dialer.setInboundCallHandler(CallManager::onInboundCall);
            Dialer.setCallTerminatedHandler(CallManager::onCallTerminated);
            Dialer.setCallDeclinedHandler(CallManager::onCallDeclined);
            Dialer.setCallAnsweredHandler(CallManager::onCallAnswered);
            return "Success";
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
    public static void startDialerNew(Context mContext, String sipUsername,
                                        String sipPassword,
                                        String sipServer,
                                        String realm,
                                        String stunServer,
                                        String turnServer,
                                        String turnUsername,
                                        String turnPassword,
                                        String turnRealm,
                                        boolean iceEnabled,
                                        int sipLocalPort,
                                        int sipServerPort,
                                        String sipTransport,
                                        String turnPort,
                                        String stunPort) {
        Prefs.setSharedPreferenceString(mContext, Prefs.PREF_SIP_ACCOUNT_SIP_SERVER_HOST, sipServer);
        Prefs.setSharedPreferenceInt(mContext, Prefs.PREF_SIP_ACCOUNT_SIP_SERVER_PORT, sipServerPort);
        Prefs.setSharedPreferenceInt(mContext, Prefs.PREF_SIP_ACCOUNT_SIP_LOCAL_PORT, sipLocalPort);
        Prefs.setSharedPreferenceString(mContext, Prefs.PREF_SIP_ACCOUNT_SIP_TRANSPORT, sipTransport);
        Prefs.setSharedPreferenceString(mContext, Prefs.PREF_SIP_ACCOUNT_SIP_USERNAME, sipUsername);
        Prefs.setSharedPreferenceString(mContext, Prefs.PREF_SIP_ACCOUNT_SIP_PASSWORD, sipPassword);
        Prefs.setSharedPreferenceString(mContext, Prefs.PREF_SIP_ACCOUNT_SIP_REALM, realm);

        Prefs.setSharedPreferenceString(mContext, Prefs.PREF_SIP_ACCOUNT_SIP_TURN_SERVER, turnServer);
        Prefs.setSharedPreferenceString(mContext, Prefs.PREF_SIP_ACCOUNT_SIP_TURN_USERNAME, turnUsername);
        Prefs.setSharedPreferenceString(mContext, Prefs.PREF_SIP_ACCOUNT_SIP_TURN_PASSWORD, turnPassword);
        Prefs.setSharedPreferenceString(mContext, Prefs.PREF_SIP_ACCOUNT_SIP_TURN_REALM, turnRealm);

        Prefs.setSharedPreferenceString(mContext, Prefs.PREF_SIP_ACCOUNT_STUN_SERVER, stunServer);
        Prefs.setSharedPreferenceBoolean(mContext, Prefs.PREF_SIP_ACCOUNT_ICE_ENABLE, iceEnabled);

        Prefs.setSharedPreferenceBoolean(mContext, Prefs.PREF_SIP_ACCOUNT_SRTP_ENABLE, false);
        Prefs.setSharedPreferenceString(mContext, Prefs.PREF_SIP_ACCOUNT_MISC_ANS_TIMEIOUT, "60");

        startDialer(MainApplication.getAppContext());
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
        String deviceToken = Prefs.getSharedPreferenceString(mContext, Prefs.PREFS_DEVICE_TOKEN, "");

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
        dialerConfig.deviceId = deviceToken;

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
        String deviceToken = Prefs.getSharedPreferenceString(mContext, Prefs.PREFS_DEVICE_TOKEN, "");

//        Dialer.Configuration dialerConfig = new Dialer.Configuration();
//        dialerConfig.sipServerHost = Constants.getServerHost(mContext);
//        dialerConfig.sipServerPort = Constants.getServerPort(mContext);
//        dialerConfig.sipLocalPort = Constants.getLocalPort(mContext);
//        dialerConfig.sipTransport = getTransport(Constants.getSIPTransport(mContext));
//        dialerConfig.sipUsername = Constants.getSIPUsername(mContext);
//        dialerConfig.sipPassword = Constants.getSIPPassword(mContext);
//        dialerConfig.sipRealm = Constants.getSIPRealm(mContext).replace("-","");
//        dialerConfig.turnHost = Constants.getTURNHost(mContext).replace("-","");
//        dialerConfig.turnUsername = Constants.getTUTNUsername(mContext).replace("-","");
//        dialerConfig.turnPassword = Constants.getTURNPassword(mContext).replace("-","");
//        dialerConfig.turnRealm = Constants.getTURNRealm(mContext).replace("-","");
//        dialerConfig.stunHost = Constants.getSTUNHost(mContext).replaceAll(":","");
//        dialerConfig.enableICE = Constants.getIsICEEnabled(mContext);
//        dialerConfig.enableSRTP = Constants.getIsSRTPEnabled(mContext);
//        dialerConfig.answerTimeout = Long.parseLong(Constants.getMiscTimeout(mContext));
//        dialerConfig.ringbackAudioFile = filePath;
//        dialerConfig.desiredCodecs = codecs;
//        dialerConfig.deviceId = deviceToken;

        Dialer.Configuration dialerConfig = new Dialer.Configuration();
        dialerConfig.sipServerHost = "newxonesip.mvoipctsi.com";
        dialerConfig.sipServerPort = 8993;
        dialerConfig.sipLocalPort = 8993;
        dialerConfig.sipTransport = 1;
        dialerConfig.sipUsername = "919011355859";
        dialerConfig.sipPassword = "5ddcff69f37aab001cdb67ad";
        dialerConfig.sipRealm = "*";
        dialerConfig.turnHost = "turntaiwan.mvoipctsi.com";
        dialerConfig.turnUsername = "comlinkxone";
        dialerConfig.turnPassword = "hgskSlGHgwSKfgsdUSDGhs";
        dialerConfig.turnRealm = "";
        dialerConfig.stunHost = "turntaiwan.mvoipctsi.com";
        dialerConfig.enableICE = false;
        dialerConfig.enableSRTP = false;
        dialerConfig.answerTimeout = 60;
        dialerConfig.ringbackAudioFile = filePath;
        dialerConfig.desiredCodecs = codecs;
        dialerConfig.deviceId = deviceToken;

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
        Intent intent = new Intent(MainApplication.getAppContext(), IncomingCallActivity.class);//CallActivity
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
                if (!ringing){
                    ringing = true;
                    reactContext
                            .getJSModule(DeviceEventManagerModule.RCTDeviceEventEmitter.class)
                            .emit("onSessionConnect", getCurrentActivity().getResources().getString(statusTextRes));
                }
                break;
            case ANSWERED:
                statusTextRes = R.string.status_call_answered;
                if (!answered){
                    answered = true;
                    reactContext
                            .getJSModule(DeviceEventManagerModule.RCTDeviceEventEmitter.class)
                            .emit("onSessionConnect", getCurrentActivity().getResources().getString(statusTextRes));
                }
                break;
            case TERMINATED:
                statusTextRes = R.string.status_call_disconnected;
                if (!terminated){
                    terminated = true;
                    reactContext
                            .getJSModule(DeviceEventManagerModule.RCTDeviceEventEmitter.class)
                            .emit("onSessionConnect", getCurrentActivity().getResources().getString(statusTextRes));
                }
                break;
            case DECLINED:
                statusTextRes = R.string.status_call_busy;
                if (!declined){
                    declined = true;
                    reactContext
                            .getJSModule(DeviceEventManagerModule.RCTDeviceEventEmitter.class)
                            .emit("onSessionConnect", getCurrentActivity().getResources().getString(statusTextRes));
                }
                break;
            default:
                statusTextRes = R.string.status_call_active;
                break;
        }

//        txtCallStatus.setText(statusTextRes);
    }


    public static boolean onInboundCall(Call callx) {
        // Do something with the call and return either true or false to indicate whether
        // to continue processing the call or not.
        Log.d("onInboundCall", "onInboundCall "+ callx);
        new Handler(Looper.getMainLooper()).post(() -> {
            call = callx;
            playRingtone(MainApplication.getAppContext());
            boolean isAppInBackground = Prefs.getSharedPreferenceBoolean(MainApplication.getAppContext(), Prefs.PREFS_IS_APP_IN_BACKGRUND, false);

            String number = "Unknown";

            try {
                number = URLDecoder.decode(call.getRemoteParty().substring(4, call.getRemoteParty().indexOf("@")).toString(), "utf-8").replace("tel:", "");
                contactFromPayload = new Contact(number,number,null);
            } catch (Exception e) {
                contactFromPayload =  new Contact("Unknown", "", null);
            }


            if (Constants.getDeviceName().toString().toLowerCase().contains("vivo")) {
                KeyguardManager myKM = (KeyguardManager) MainApplication.getAppContext().getSystemService(Context.KEYGUARD_SERVICE);
                boolean isPhoneLocked = myKM.inKeyguardRestrictedInputMode();
                if (isPhoneLocked) {
                    createNotification(dataPayload);
                } else {
                    CallManager.showOngoingCallActivity(contactFromPayload);
                }
            } else {
                if (isAppInBackground) {
                    createNotification(dataPayload);
                } else {
                    CallManager.showOngoingCallActivity(contactFromPayload);
                }
            }
        });
        return true;
    }

    public static void onCallTerminated(Call call) {
        call = call;
//        callTerminateDecline();
        reactContext
                .getJSModule(DeviceEventManagerModule.RCTDeviceEventEmitter.class)
                .emit("onSessionConnect", getCurrentActivity().getResources().getString(R.string.status_call_disconnected));

        stopRingTone();
        CallManager.reject();
        Log.d("onCallTerminated", "onCallTerminated "+ call);
    }

    public static void onCallDeclined(Call call) {
        call = call;
//        callTerminateDecline();
        reactContext
                .getJSModule(DeviceEventManagerModule.RCTDeviceEventEmitter.class)
                .emit("onSessionConnect", getCurrentActivity().getResources().getString(R.string.status_call_disconnected));
        stopRingTone();
        CallManager.reject();
        Log.d("onCallDeclined", "onCallDeclined "+ call);
    }

    public static void onCallAnswered(Call call) {
        call = call;
        Log.d("onCallAnswered", "onCallAnswered "+ call);
        stopRingTone();
        callAswered();
    }


    // -- Notification -- //
    private static void createNotification(Map<String, String> data) {

        new Handler(Looper.getMainLooper()).post(() -> {
            // Logic to turn on the screen
            PowerManager powerManager = (PowerManager) MainApplication.getAppContext().getSystemService(POWER_SERVICE);

            if (!powerManager.isInteractive()) { // if screen is not already on, turn it on (get wake_lock for 10 seconds)
                PowerManager.WakeLock wl = powerManager.newWakeLock(PowerManager.FULL_WAKE_LOCK | PowerManager.ACQUIRE_CAUSES_WAKEUP | PowerManager.ON_AFTER_RELEASE, "app:WAKELOCK_INCALL");
                wl.acquire(10000);
                PowerManager.WakeLock wl_cpu = powerManager.newWakeLock(PowerManager.PARTIAL_WAKE_LOCK, "app:WAKELOCK_INCALL");
                wl_cpu.acquire(10000);
            }

            if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.O) {
                Contact callerContact = CallManager.getDisplayContact(MainApplication.getAppContext());
                String callerName = callerContact.getName().replace(":","");

                if (callerName.equalsIgnoreCase("Unknown")) {
                    if (data != null) {
                        String urlCaller = data.get("url");
                        callerName = urlCaller.substring(20, urlCaller.indexOf("?")).replaceAll(":","");//comple string  url=url://incomingcall/919834545791
                    }
                }

                Intent touchNotification = new Intent(MainApplication.getAppContext(), IncomingCallActivity.class);
//            touchNotification.setFlags(Intent.FLAG_ACTIVITY_BROUGHT_TO_FRONT);
                PendingIntent pendingIntent = PendingIntent.getActivity(MainApplication.getAppContext(), 0, touchNotification, PendingIntent.FLAG_UPDATE_CURRENT);

                // Answer Button Intent
                Intent answerIntent = new Intent(MainApplication.getAppContext(), NotificationActionReceiver.class);
                answerIntent.setAction(ACTION_ANSWER);
                answerIntent.putExtra("callerName", callerName);
                answerIntent.putExtra(EXTRA_NOTIFICATION_ID, 0);
                PendingIntent answerPendingIntent = PendingIntent.getBroadcast(MainApplication.getAppContext(), 0, answerIntent, PendingIntent.FLAG_CANCEL_CURRENT);

                // Hangup Button Intent
                Intent hangupIntent = new Intent(MainApplication.getAppContext(), NotificationActionReceiver.class);
                hangupIntent.setAction(ACTION_HANGUP);
                hangupIntent.putExtra(EXTRA_NOTIFICATION_ID, 0);
                PendingIntent hangupPendingIntent = PendingIntent.getBroadcast(MainApplication.getAppContext(), 1, hangupIntent, PendingIntent.FLAG_CANCEL_CURRENT);

                Uri soundUri = Uri.parse("android.resource://" + MainApplication.getAppContext().getPackageName() + "/" + R.raw.incoming_call);

                mBuilder = new NotificationCompat.Builder(MainApplication.getAppContext(), CHANNEL_ID)
                        .setSmallIcon(R.drawable.ic_notification)
                        .setContentTitle(callerName)
                        .setContentText("Incoming Call")
                        .setPriority(NotificationCompat.PRIORITY_HIGH)
                        .setContentIntent(pendingIntent)
                        .setOngoing(true)
                        .setStyle(new androidx.media.app.NotificationCompat.MediaStyle().setShowActionsInCompactView(0, 1))
                        .setLights(Color.RED, 1000, 300)
                        .setDefaults(Notification.DEFAULT_ALL)
                        .setCategory(NotificationCompat.CATEGORY_CALL)
                        .setSound(null)
                        .setOnlyAlertOnce(false)
                        .setVibrate(new long[]{100, 200, 300, 400, 500, 400, 300, 200, 400})
                        .setFullScreenIntent(pendingIntent, true)
                        .setChannelId("CALLS1")
                        .setAutoCancel(true);

                // Adding the action buttons
                mBuilder.addAction(R.drawable.ic_call_end_black_24dp, "Answer", answerPendingIntent);
                mBuilder.addAction(R.drawable.ic_call_black_24dp, "Reject", hangupPendingIntent);

                NotificationManager notificationManager = (NotificationManager) MainApplication.getAppContext().getSystemService(Context.NOTIFICATION_SERVICE);
                Notification note = mBuilder.build();
//            note.defaults = Notification.PRIORITY_HIGH;

                if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.O) {
                    NotificationChannel channel = new NotificationChannel("CALLS1", "CALLS", NotificationManager.IMPORTANCE_HIGH);

                    AudioAttributes attributes = new AudioAttributes.Builder()
                            .setUsage(AudioAttributes.USAGE_NOTIFICATION)
                            .build();

                    channel.setDescription("Notification");
                    channel.setShowBadge(true);
                    channel.setImportance(NotificationManager.IMPORTANCE_HIGH);
                    channel.enableLights(true);
                    channel.setLightColor(Color.RED);
                    channel.enableVibration(true);
                    channel.setVibrationPattern(new long[]{100, 200, 300, 400, 500, 400, 300, 200, 400});
                    channel.setSound(null, attributes);
                    channel.setLockscreenVisibility(Notification.VISIBILITY_PUBLIC);

                    assert (notificationManager != null);
                    notificationManager.createNotificationChannel(channel);
                }
                notificationManager.notify(NOTIFICATION_ID, note);

            }
        });


    }

}
