package com.comlinkinc.android.pigeon;

import android.app.KeyguardManager;
import android.content.Context;
import android.content.Intent;
import android.media.AudioManager;
import android.os.Build;
import android.os.Bundle;
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
        }
    }

    @Override
    public void onClick(View v) {
        if (v == btn_end_call) {
            // Handle clicks for btn_end_call
            CallManager.reject();

            if(Build.VERSION.SDK_INT >= Build.VERSION_CODES.LOLLIPOP) {
                super.finishAndRemoveTask();
            }
            else {
                super.finish();
            }
        } else if (v == btn_accept_call) {
            // Handle clicks for btn_accept_call
            CallManager.stopRingTone();
            CallManager.answer();
            Log.d("phoneNumber", phoneNumber + "");

            if (reactContext == null) {
                Intent intent = new Intent(mContext, MainActivity.class);
                intent.putExtra("incoming_call", true);
                intent.putExtra("phoneNumber", phoneNumber);
                startActivity(intent);
                finish();
//
//                if(!reactApplicationContext.hasActiveCatalystInstance()) {
//                    return;
//                }


//                ReactInstanceManager reactInstanceManager = getReactInstanceManager();
//                reactInstanceManager.addReactInstanceEventListener(new ReactInstanceManager.ReactInstanceEventListener() {
//                    @Override
//                    public void onReactContextInitialized(ReactContext context) {
//                        context.getJSModule(DeviceEventManagerModule.RCTDeviceEventEmitter.class)
//                                .emit("CallAnswered", phoneNumber);
//                        reactInstanceManager.removeReactInstanceEventListener(this);
//                    }
//                });


//                reactApplicationContext
//                        .getJSModule(DeviceEventManagerModule.RCTDeviceEventEmitter.class)
//                        .emit("CallAnswered", phoneNumber);
//                finish();
            } else {
//                if (reactApplicationContext.hasActiveCatalystInstance()) {
                reactContext
                            .getJSModule(DeviceEventManagerModule.RCTDeviceEventEmitter.class)
                            .emit("CallAnswered", phoneNumber);
                    finish();
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
}