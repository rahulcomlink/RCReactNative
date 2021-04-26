package com.comlinkinc.android.pigeon.fcm;

import android.content.BroadcastReceiver;
import android.content.Context;
import android.content.Intent;
import android.telecom.Call;
import android.util.Log;

import com.comlinkinc.android.pigeon.CallManager;
import com.comlinkinc.android.pigeon.Contact;
import com.comlinkinc.android.pigeon.IncomingCallActivity;
import com.comlinkinc.android.pigeon.MainActivity;
import com.comlinkinc.android.pigeon.MainApplication;
import com.facebook.react.modules.core.DeviceEventManagerModule;

import java.util.ArrayList;
import java.util.List;

import static com.comlinkinc.android.pigeon.CallManager.contactFromPayload;
import static com.comlinkinc.android.pigeon.IncomingCallActivity.phoneNumber;
import static com.comlinkinc.android.pigeon.SdkModule.reactContext;

public class NotificationActionReceiver extends BroadcastReceiver {

    @Override
    public void onReceive(Context context, Intent intent) {
        String action = intent.getAction();

        if (action.equals(IncomingCallActivity.ACTION_ANSWER)) {
            // If the user pressed "Answer" from the notification
//            CallManager.stopRingTone();
//            CallManager.answer();
            Log.d("phoneNumber", contactFromPayload.getName() + "");

            List<String> numbers = new ArrayList<>();
            numbers.add(phoneNumber);

            CallManager.showOngoingCallActivity(contactFromPayload);

//            if (reactContext == null) {
//                Intent intentAct = new Intent(MainApplication.getAppContext(), MainActivity.class);
//                intentAct.putExtra("incoming_call", true);
//                intentAct.putExtra("phoneNumber", intent.getExtras().getString("callerName"));
//                intentAct.addFlags(Intent.FLAG_ACTIVITY_CLEAR_TOP);
//                intentAct.addFlags(Intent.FLAG_ACTIVITY_NEW_TASK);
//                MainApplication.getAppContext().startActivity(intentAct);
//            } else {
//                reactContext
//                        .getJSModule(DeviceEventManagerModule.RCTDeviceEventEmitter.class)
//                        .emit("CallAnswered", phoneNumber);
////                MainApplication.getAppContext().finish();
//            }

            MyFirebaseMessagingService.cancelNotification();
        } else if (action.equals(IncomingCallActivity.ACTION_HANGUP)) {
            // If the user pressed "Hang up" from the notification
            CallManager.reject();
            MyFirebaseMessagingService.cancelNotification();
        }
    }

}
