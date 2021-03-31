package com.comlinkinc.android.pigeon;

import android.content.Context;
import android.content.Intent;
import android.media.AudioManager;
import android.os.Bundle;
import android.util.Log;
import android.view.View;
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
    String phoneNumber = "";
    boolean isVoipCall = true;
    private Context mContext;

    @Override
    protected void onCreate(Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);
        setContentView(R.layout.activity_incoming_call);

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

        phoneNumber = "" + contact.getPhoneNumbers().get(0).replace(":", "");
        if (contact != null){
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
            finish();
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
            } else {
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