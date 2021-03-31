package com.comlinkinc.android.pigeon;

import android.app.Service;
import android.content.Intent;
import android.os.IBinder;
import android.util.Log;

public class OnClearFromRecentService extends Service {

    @Override
    public IBinder onBind(Intent intent) {
        return null;
    }

    @Override
    public int onStartCommand(Intent intent, int flags, int startId) {
        Log.d("ClearFromRecentService", "Service Started");
        return START_NOT_STICKY;
    }

    @Override
    public void onDestroy() {
        super.onDestroy();
        Log.d("ClearFromRecentService", "Service Destroyed");
    }

    @Override
    public void onTaskRemoved(Intent rootIntent) {
        Log.e("ClearFromRecentService", "END");
        Prefs.setSharedPreferenceBoolean(MainApplication.getAppContext(), Prefs.PREFS_IS_APP_IN_BACKGRUND, true);
        CallManager.unRegisterDialer();
        CallManager.stopDialer();
        stopSelf();
    }
}
