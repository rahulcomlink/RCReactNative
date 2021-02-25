package com.comlinkinc.android.pigeon;

import android.annotation.SuppressLint;
import android.app.Activity;
import android.app.Dialog;
import android.content.Context;
import android.content.Intent;
import android.content.pm.PackageManager;
import android.content.res.Resources;
import android.database.Cursor;
import android.graphics.Color;
import android.graphics.Rect;
import android.graphics.drawable.ColorDrawable;
import android.net.ConnectivityManager;
import android.net.NetworkInfo;
import android.net.Uri;
import android.os.Build;
import android.os.Looper;
import android.os.VibrationEffect;
import android.os.Vibrator;
import android.provider.CallLog;
import android.provider.ContactsContract;
import android.telecom.TelecomManager;
import android.telephony.SmsManager;
import android.util.DisplayMetrics;
import android.view.View;
import android.view.WindowManager;
import android.view.inputmethod.InputMethodManager;
import android.widget.Button;
import android.widget.TextView;
import android.widget.Toast;

import androidx.annotation.NonNull;
import androidx.core.app.ActivityCompat;
import androidx.core.content.ContextCompat;
import androidx.fragment.app.FragmentActivity;

import org.jetbrains.annotations.NotNull;

import java.util.ArrayList;
import java.util.Date;
import java.util.List;
import java.util.Locale;

import timber.log.Timber;

import static android.Manifest.permission.ANSWER_PHONE_CALLS;
import static android.Manifest.permission.CALL_PHONE;
import static android.Manifest.permission.CAMERA;
import static android.Manifest.permission.FOREGROUND_SERVICE;
import static android.Manifest.permission.READ_CALL_LOG;
import static android.Manifest.permission.READ_CONTACTS;
import static android.Manifest.permission.READ_EXTERNAL_STORAGE;
import static android.Manifest.permission.READ_PHONE_STATE;
import static android.Manifest.permission.RECORD_AUDIO;
import static android.Manifest.permission.SEND_SMS;

public class Utilities {

    public static final int DEFAULT_DIALER_RC = 11;
    public static final int PERMISSION_RC = 10;
    public static final String[] MUST_HAVE_PERMISSIONS = {CALL_PHONE, READ_EXTERNAL_STORAGE, RECORD_AUDIO, CAMERA, READ_CONTACTS, ANSWER_PHONE_CALLS, READ_PHONE_STATE, FOREGROUND_SERVICE};
    public static final String[] OPTIONAL_PERMISSIONS = {SEND_SMS, READ_CONTACTS, READ_CALL_LOG};
    public static final long LONG_VIBRATE_LENGTH = 500;
    public static final long SHORT_VIBRATE_LENGTH = 20;
    public static final long DEFAULT_VIBRATE_LENGTH = 100;
    public static Locale sLocale;

    public static void setUpLocale(@NonNull Context context) {
        sLocale = Locale.US;
    }

    /**
     * Check if app is set as the default dialer app
     *
     * @param activity
     * @return boolean
     */
    public static boolean checkDefaultDialer(FragmentActivity activity) {
        String packageName = activity.getApplication().getPackageName();
        try {
            if (!activity.getSystemService(TelecomManager.class).getDefaultDialerPackage().equals(packageName)) {
                // Prompt the user with a dialog to select this app to be the default phone app
                Intent intent = new Intent(TelecomManager.ACTION_CHANGE_DEFAULT_DIALER)
                        .putExtra(TelecomManager.EXTRA_CHANGE_DEFAULT_DIALER_PACKAGE_NAME, packageName);
                activity.startActivityForResult(intent, DEFAULT_DIALER_RC);
                return false;
            }
            return true;
        } catch (Exception e) {
            return false;
        }
    }

    /**
     * Checks for granted permission but by a single string (single permission)
     *
     * @param context    from what context is being called
     * @param permission permission to check if granted
     * @return is permission granted / not
     */
    public static boolean checkPermissionGranted(Context context, String permission) {
        return ContextCompat.checkSelfPermission(context, permission) == PackageManager.PERMISSION_GRANTED;
    }

    /**
     * Check for permissions by a given list
     * Return true *only* if all of the given permissions are granted
     *
     * @param context     from where the function is being called
     * @param permissions permission to check if granted
     * @return boolean is permissions granted / not
     */
    public static boolean checkPermissionsGranted(Context context, String[] permissions) {
        for (String permission : permissions) {
            if (!checkPermissionGranted(context, permission)) return false;
        }
        return true;
    }

    /**
     * Check is premissions granted by grant results list
     * Return true only if all permissions were granted
     *
     * @param grantResults permissions grant results
     * @return boolean is all granted / not
     */
    public static boolean checkPermissionsGranted(int[] grantResults) {
        for (int result : grantResults) {
            if (result == PackageManager.PERMISSION_DENIED) return false;
        }
        return true;
    }

    /**
     * Ask user for a specific permission
     *
     * @param activity   the activity that is calling the function
     * @param permission permission to ask the user for
     */
    public static void askForPermission(FragmentActivity activity, String permission) {
        askForPermissions(activity, new String[]{permission});
    }

    /**
     * Asks user for permissions by a given list
     *
     * @param activity    the activity that is calling the function
     * @param permissions permissions to ask the user for
     */
    public static void askForPermissions(FragmentActivity activity, String[] permissions) {
        ActivityCompat.requestPermissions(activity, permissions, PERMISSION_RC);
    }


    /**
     * Vibrate the phone for {@code DEFAULT_VIBRATE_LENGTH} milliseconds
     */
    public static void vibrate(@NotNull Context context) {
//        vibrate(context, DEFAULT_VIBRATE_LENGTH);
    }

    /**
     * Get the dpi for this phone
     *
     * @return the dpi
     */
    public static float dpi(Context context) {
        DisplayMetrics displayMetrics = new DisplayMetrics();
        WindowManager windowManager = (WindowManager) context.getSystemService(Context.WINDOW_SERVICE);
        windowManager.getDefaultDisplay().getMetrics(displayMetrics);
        return displayMetrics.densityDpi;
    }

    /**
     * This method converts dp unit to equivalent pixels, depending on device density.
     *
     * @param context Context to get resources and device specific display metrics
     * @param dp      A value in dp (density independent pixels) unit. Which we need to convert into pixels
     * @return A float value to represent px equivalent to dp depending on device density
     */
    public static float convertDpToPixel(Context context, float dp) {
        return dp * (dpi(context) / DisplayMetrics.DENSITY_DEFAULT);
    }
}