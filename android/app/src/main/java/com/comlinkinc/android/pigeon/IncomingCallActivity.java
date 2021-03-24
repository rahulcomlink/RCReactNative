package com.comlinkinc.android.pigeon;

import android.os.Bundle;
import android.view.View;
import android.widget.Button;
import android.widget.ImageView;
import android.widget.TextView;

import androidx.appcompat.app.AppCompatActivity;

public class IncomingCallActivity extends AppCompatActivity implements View.OnClickListener {

    public static final String ACTION_ANSWER = "ANSWER";
    public static final String ACTION_HANGUP = "HANGUP";

    private TextView txt_user_number;
    private TextView txt_user_name;
    private ImageView btn_end_call;
    private ImageView btn_accept_call;
    Contact contact;

    @Override
    protected void onCreate(Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);
        setContentView(R.layout.activity_incoming_call);

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
            txt_user_number.setText(""+contact.getPhoneNumbers().get(0));
            txt_user_name.setText(""+contact.getName());
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
        }
    }
}