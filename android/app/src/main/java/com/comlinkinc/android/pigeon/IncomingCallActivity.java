package com.comlinkinc.android.pigeon;

import android.app.KeyguardManager;
import android.content.Context;
import android.content.Intent;
import android.content.pm.PackageManager;
import android.database.Cursor;
import android.media.AudioManager;
import android.net.Uri;
import android.os.Build;
import android.os.Bundle;
import android.provider.ContactsContract;
import android.util.Log;
import android.view.View;
import android.view.WindowManager;
import android.widget.ImageView;
import android.widget.TextView;

import androidx.appcompat.app.AppCompatActivity;

import com.facebook.react.modules.core.DeviceEventManagerModule;

import static com.comlinkinc.android.pigeon.SdkModule.reactContext;


public class IncomingCallActivity extends AppCompatActivity implements View.OnClickListener {

    public static final String ACTION_ANSWER = "ANSWER";
    public static final String ACTION_HANGUP = "HANGUP";

    private TextView txt_user_number;
    private TextView txt_user_name;
    private ImageView btn_end_call;
    private ImageView btn_accept_call;
    Contact contact;
    public static String phoneNumber = "";
    boolean isVoipCall = true;
    private Context mContext;

    @Override
    protected void onCreate(Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);

        setContentView(R.layout.activity_incoming_call);

        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.O_MR1) {
            setShowWhenLocked(true);
            setTurnScreenOn(true);
            KeyguardManager keyguardManager = (KeyguardManager) getSystemService(Context.KEYGUARD_SERVICE);
            keyguardManager.requestDismissKeyguard(this, null);
        } else {
            getWindow().addFlags(WindowManager.LayoutParams.FLAG_DISMISS_KEYGUARD|
                    WindowManager.LayoutParams.FLAG_SHOW_WHEN_LOCKED|
                    WindowManager.LayoutParams.FLAG_TURN_SCREEN_ON);

        }

        mContext = IncomingCallActivity.this;
        findViews();
    }

    private void findViews() {
        txt_user_number = (TextView) findViewById(R.id.txt_user_number);
        txt_user_name = (TextView) findViewById(R.id.txt_user_name);
        btn_end_call = (ImageView) findViewById(R.id.btn_end_call);
        btn_accept_call = (ImageView) findViewById(R.id.btn_accept_call);

        btn_end_call.setOnClickListener(this);
        btn_accept_call.setOnClickListener(this);

        if (getIntent() != null && getIntent().getExtras() != null) {
            contact = (Contact) getIntent().getSerializableExtra("Contact");
        }

        if (contact != null){
            phoneNumber = "" + contact.getPhoneNumbers().get(0).replace(":", "");
            txt_user_number.setText(phoneNumber);
//            txt_user_name.setText(""+contact.getName());
            txt_user_name.setText("Incoming Call...");

            runOnUiThread(new Runnable() {
                @Override
                public void run() {
                    String name = getContactNameFromNumber(phoneNumber, mContext);
                    txt_user_number.setText(name);
                }
            });
        }
    }

    @Override
    public void onClick(View v) {
        if (v == btn_end_call) {
            // Handle clicks for btn_end_call
            CallManager.reject();

            if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.LOLLIPOP) {
                super.finishAndRemoveTask();
            } else {
                super.finish();
            }
        } else if (v == btn_accept_call) {
            // Handle clicks for btn_accept_call
            CallManager.stopRingTone();
            CallManager.answer();
            Log.d("phoneNumber", phoneNumber + "");

            if (reactContext == null) {
                Intent intent = new Intent(MainApplication.getAppContext(), MainActivity.class);
                intent.putExtra("incoming_call", true);
                intent.putExtra("phoneNumber", phoneNumber);
                intent.addFlags(Intent.FLAG_ACTIVITY_CLEAR_TOP);
                intent.addFlags(Intent.FLAG_ACTIVITY_NEW_TASK);
                MainApplication.getAppContext().startActivity(intent);
                finish();
            } else {
                boolean isAppkilled = Prefs.getSharedPreferenceBoolean(MainApplication.getAppContext(), Prefs.PREFS_IS_APP_KILLED, false);
                if (isAppkilled) {
                    Intent intent = new Intent(MainApplication.getAppContext(), MainActivity.class);
                    intent.putExtra("incoming_call", true);
                    intent.putExtra("phoneNumber", phoneNumber);
                    intent.addFlags(Intent.FLAG_ACTIVITY_CLEAR_TOP);
                    intent.addFlags(Intent.FLAG_ACTIVITY_NEW_TASK);
                    MainApplication.getAppContext().startActivity(intent);
                    finish();
                }else{
                    reactContext
                            .getJSModule(DeviceEventManagerModule.RCTDeviceEventEmitter.class)
                            .emit("CallAnswered", phoneNumber);
                    finish();
                }
            }

            runOnUiThread(new Runnable() {
                @Override
                public void run() {
                    if (SdkModule.mAudioManager == null) {
                        SdkModule.mAudioManager = (AudioManager) getApplicationContext().getSystemService(AUDIO_SERVICE);
                    }

                    SdkModule.mAudioManager.setMicrophoneMute(false);
                    SdkModule.mAudioManager.setSpeakerphoneOn(false);
                    SdkModule.mAudioManager.setMode(AudioManager.MODE_IN_CALL);
                }
            });

        }
    }


    public String getContactNameFromNumber(final String phoneNumber, Context context) {

        String requiredPermission = android.Manifest.permission.READ_CONTACTS;
        int checkVal = checkCallingOrSelfPermission(requiredPermission);
        if (checkVal == PackageManager.PERMISSION_GRANTED) {
            Uri uri = Uri.withAppendedPath(ContactsContract.PhoneLookup.CONTENT_FILTER_URI, Uri.encode(phoneNumber));
            String[] projection = new String[]{ContactsContract.PhoneLookup.DISPLAY_NAME};
            String contactName = "";
            Cursor cursor = context.getContentResolver().query(uri, projection, null, null, null);

            if (cursor != null) {
                if (cursor.moveToFirst()) {
                    contactName = cursor.getString(0);
                }
                cursor.close();
            }
            return contactName;
        }

        return phoneNumber;
    }
}