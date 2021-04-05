package com.comlinkinc.android.pigeon.fcm;

import android.content.BroadcastReceiver;
import android.content.Context;
import android.content.Intent;

import com.comlinkinc.android.pigeon.CallManager;
import com.comlinkinc.android.pigeon.IncomingCallActivity;
import com.comlinkinc.android.pigeon.MainActivity;
import com.comlinkinc.android.pigeon.MainApplication;

import static com.comlinkinc.android.pigeon.IncomingCallActivity.phoneNumber;

public class NotificationActionReceiver extends BroadcastReceiver {

    @Override
    public void onReceive(Context context, Intent intent) {
        String action = intent.getAction();

        if (action.equals(IncomingCallActivity.ACTION_ANSWER)) {
            // If the user pressed "Answer" from the notification
            CallManager.answer();
//            if (reactContext == null) {
            Intent intentAct = new Intent(MainApplication.getAppContext(), MainActivity.class);
            intentAct.putExtra("incoming_call", true);
            intentAct.putExtra("phoneNumber", intent.getExtras().getString("callerName"));
            intentAct.addFlags(Intent.FLAG_ACTIVITY_CLEAR_TOP);
            intentAct.addFlags(Intent.FLAG_ACTIVITY_NEW_TASK);
            MainApplication.getAppContext().startActivity(intentAct);
//                finish();
//            } else {
//                reactContext
//                        .getJSModule(DeviceEventManagerModule.RCTDeviceEventEmitter.class)
//                        .emit("CallAnswered", phoneNumber);
////                finish();
//            }
            MyFirebaseMessagingService.cancelNotification();
        } else if (action.equals(IncomingCallActivity.ACTION_HANGUP)) {
            // If the user pressed "Hang up" from the notification
            CallManager.reject();
            MyFirebaseMessagingService.cancelNotification();
        }
    }

}
