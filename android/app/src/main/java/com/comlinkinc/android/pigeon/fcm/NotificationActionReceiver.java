package com.comlinkinc.android.pigeon.fcm;

import android.content.BroadcastReceiver;
import android.content.Context;
import android.content.Intent;

import com.comlinkinc.android.pigeon.CallManager;
import com.comlinkinc.android.pigeon.IncomingCallActivity;

public class NotificationActionReceiver extends BroadcastReceiver {

    @Override
    public void onReceive(Context context, Intent intent) {
        String action = intent.getAction();

        if (action.equals(IncomingCallActivity.ACTION_ANSWER)) {
            // If the user pressed "Answer" from the notification
            CallManager.answer();
            MyFirebaseMessagingService.cancelNotification();
        } else if (action.equals(IncomingCallActivity.ACTION_HANGUP)) {
            // If the user pressed "Hang up" from the notification
            CallManager.reject();
            MyFirebaseMessagingService.cancelNotification();
        }
    }

}
