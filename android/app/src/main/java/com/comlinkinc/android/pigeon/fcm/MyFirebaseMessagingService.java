package com.comlinkinc.android.pigeon.fcm;

import android.app.Notification;
import android.app.NotificationChannel;
import android.app.NotificationManager;
import android.app.PendingIntent;
import android.content.Context;
import android.content.Intent;
import android.graphics.Color;
import android.media.AudioAttributes;
import android.media.RingtoneManager;
import android.net.Uri;
import android.os.Build;
import android.os.Handler;
import android.os.Looper;
import android.util.Log;

import androidx.annotation.RequiresApi;
import androidx.core.app.NotificationCompat;

import com.comlinkinc.android.pigeon.CallManager;
import com.comlinkinc.android.pigeon.Contact;
import com.comlinkinc.android.pigeon.MainActivity;
import com.comlinkinc.android.pigeon.MainApplication;
import com.comlinkinc.android.pigeon.R;
import com.google.firebase.messaging.FirebaseMessagingService;
import com.google.firebase.messaging.RemoteMessage;

import java.util.Map;

import static android.app.Notification.EXTRA_NOTIFICATION_ID;

@RequiresApi(api = Build.VERSION_CODES.N)
public class MyFirebaseMessagingService extends FirebaseMessagingService {

    // Notification
    NotificationCompat.Builder mBuilder;
    NotificationManager mNotificationManager;
    private static final long END_CALL_MILLIS = 1500;
    private static final String CHANNEL_ID = "notification";
    private static final int NOTIFICATION_ID = 42069;
    public static Map<String, String> dataPayload = null;

    @Override
    public void onMessageReceived(RemoteMessage remoteMessage) {
        RemoteMessage.Notification notification = remoteMessage.getNotification();
        Map<String, String> data = remoteMessage.getData();

        Log.d("TAG", "From: " + remoteMessage.getFrom());

        // Check if message contains a data payload.
        if (remoteMessage.getData().size() > 0) {
            Log.d("TAG", "Message data payload: " + remoteMessage.getData());
        }

        // Check if message contains a notification payload.
        if (remoteMessage.getNotification() != null) {
            Log.d("TAG", "Message Notification Body: " + remoteMessage.getNotification().getBody());
            sendNotification(notification.getTitle().toString(), notification.getBody().toString());
        }

        if (data != null) {
            dataPayload = data;
            sipIncomingCall(data);
        }
    }

    private void sipIncomingCall(Map<String, String> data) {
        try {
            CallManager.stopDialer();
            CallManager.startDialer(MainApplication.getAppContext());
//            CallManager.unRegisterDialer();

            new Handler(Looper.getMainLooper()).post(() -> {
//                CallManager.isIncoming = true;
                CallManager.registerDialer();
//                boolean isAppInBackground = Prefs.getSharedPreferenceBoolean(KulfiApplication.getAppContext(), Prefs.PREFS_IS_APP_IN_BACKGRUND, false);
//                if (isAppInBackground) {
////                createNotificationChannel();
//                    createNotification(data);
//                } else {
//                    CallManager.showOngoingCallActivity(true);
//                }
            });

        } catch (Exception e) {
            e.printStackTrace();
        }

//        Dialer.stop();
    }

    @Override
    public void onNewToken(String token) {
        super.onNewToken(token);
        Log.d("TAG", "Refreshed token: " + token);
        sendRegistrationToServer(token);
    }

    private void sendRegistrationToServer(String token) {

    }

    private void sendNotification(String title, String messageBody) {
        Intent intent = new Intent(this, MainActivity.class);
        intent.addFlags(Intent.FLAG_ACTIVITY_CLEAR_TOP);
        PendingIntent pendingIntent = PendingIntent.getActivity(this, 0 /* Request code */, intent,
                PendingIntent.FLAG_ONE_SHOT);
        String channelId = "this_is_channel";
        Uri defaultSoundUri = RingtoneManager.getDefaultUri(RingtoneManager.TYPE_NOTIFICATION);
        NotificationCompat.Builder notificationBuilder =
                new NotificationCompat.Builder(this, channelId)
                        .setSmallIcon(R.mipmap.ic_launcher)
                        .setContentTitle(title)
                        .setContentText(messageBody)
                        .setAutoCancel(true)
                        .setSound(defaultSoundUri)
                        .setContentIntent(pendingIntent);
        NotificationManager notificationManager =
                (NotificationManager) getSystemService(Context.NOTIFICATION_SERVICE);
        // Since android Oreo notification channel is needed.
        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.O) {
            // Channel human readable title
            NotificationChannel channel = new NotificationChannel(channelId,
                    "Cloud Messaging Service",
                    NotificationManager.IMPORTANCE_DEFAULT);
            notificationManager.createNotificationChannel(channel);
        }
        notificationManager.notify(0 /* ID of notification */, notificationBuilder.build());
    }

    /**
     * Creates the notification channel
     * Which allows and manages the displaying of the notification
     */
    private void createNotificationChannel() {
        // Create the NotificationChannel, but only on API 26+ because
        // the NotificationChannel class is new and not in the support library
        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.O) {
            CharSequence name = "call_channel";
            String description = "call_desc";
            int importance = NotificationManager.IMPORTANCE_DEFAULT;
            NotificationChannel channel = new NotificationChannel(CHANNEL_ID, name, importance);
            channel.setDescription(description);
            // Register the channel with the system; you can't change the importance
            // or other notification behaviors after this
            mNotificationManager = MainApplication.getAppContext().getSystemService(NotificationManager.class);
            mNotificationManager.createNotificationChannel(channel);
        }
    }

    /**
     * Removes the notification
     */
    public static void cancelNotification() {
        try {
            NotificationManager notificationManager = (NotificationManager) MainApplication.getAppContext().getSystemService(NOTIFICATION_SERVICE);
            notificationManager.cancel(NOTIFICATION_ID);
        } catch (Exception e) {
        }
    }

}