package com.comlinkinc.android.pigeon;

import android.app.Activity;
import android.app.AlertDialog;
import android.content.ContentUris;
import android.content.ContentValues;
import android.content.Context;
import android.content.DialogInterface;
import android.content.Intent;
import android.database.Cursor;
import android.net.Uri;
import android.os.Build;
import android.provider.ContactsContract;
import android.text.TextUtils;
import android.util.Log;
import android.view.View;
import android.view.Window;
import android.view.WindowManager;
import android.view.animation.Animation;
import android.view.animation.RotateAnimation;
import android.view.inputmethod.InputMethodManager;
import android.widget.ImageView;
import android.widget.Toast;

import androidx.annotation.NonNull;
import androidx.core.content.ContextCompat;

import timber.log.Timber;

import static android.Manifest.permission.READ_CONTACTS;
import static android.Manifest.permission.WRITE_CONTACTS;
import static android.content.Intent.FLAG_ACTIVITY_CLEAR_TOP;

/**********************************************************************
 * Created by   -  Tushar Patil
 ***********************************************************************/

public class Constants {
    public static boolean isLogout = false;
    public static boolean isfromSplash = false;


    public static String CMS_ID = "SWIPES01";
    public static String AUTH_TYPE_QR_CODE = "QRCODE";
    public static String DEVICE_OS_ANDROID = "ANDROID";
    public static int SUCCESS = 200;

    //Error code
    public static final int RESPONSE_CODE_200 = 200;
    public static final int RESPONSE_CODE_400 = 400;
    public static final int RESPONSE_CODE_401 = 401;

    public static final String OUTGOING_CALL = "OUTGOING_CALL";
    public static final String INCOMING_CALL = "INCOMING_CALL";
    public static final String MISSED_CALL = "MISSED_CALL";

    // Constants
    public static final Contact UNKNOWN = new Contact("Unknown", "", null);
    public static final Contact VOICEMAIL = new Contact("Voicemail", "", null);
    public static final Contact ERROR = new Contact("Error", "", null);

    public static void DialogAlet(Activity activity, String title, String message) {
        if (activity != null) {
            AlertDialog.Builder builder1 = new AlertDialog.Builder(activity);
            builder1.setMessage(message);
            builder1.setCancelable(true);
            builder1.setTitle(title);

            builder1.setPositiveButton(
                    "OK",
                    new DialogInterface.OnClickListener() {
                        public void onClick(DialogInterface dialog, int id) {
                            dialog.cancel();
                        }
                    });

            AlertDialog alert11 = builder1.create();
            alert11.show();
        }
    }

    public static void DisplayMessageDialog(Activity activity, String title, String message) {
        if (activity != null) {
            AlertDialog.Builder builder1 = new AlertDialog.Builder(activity);
            builder1.setMessage(message);
            builder1.setCancelable(true);
            builder1.setTitle(title);

            builder1.setPositiveButton(
                    "OK",
                    new DialogInterface.OnClickListener() {
                        public void onClick(DialogInterface dialog, int id) {
//                            ((MainActivity) activity).selectTab();
                            dialog.cancel();
                        }
                    });

            AlertDialog alert11 = builder1.create();
            alert11.show();
        }
    }

    public static void showProgressbar(Activity activity, boolean isVisible, ImageView imageView) {
        if (activity != null) {
            ImageView imageViewThumb;

            float ROTATE_FROM = 5.0f;
            float ROTATE_TO = 360.0f;
            RotateAnimation r;

            if (isVisible) {
                imageView.setVisibility(View.VISIBLE);

                r = new RotateAnimation(ROTATE_FROM, ROTATE_TO, Animation.RELATIVE_TO_SELF, 0.5f, Animation.RELATIVE_TO_SELF, 0.5f);
                r.setDuration(2000);
                r.setRepeatCount(20);
                imageView.startAnimation(r);
            } else {
                imageView.setVisibility(View.GONE);
                imageView.clearAnimation();
            }
        }
    }

    public static void changeStatusBarColor(Activity activity, int color) {
        try {
            Window window = activity.getWindow();

            // clear FLAG_TRANSLUCENT_STATUS flag:
            window.clearFlags(WindowManager.LayoutParams.FLAG_TRANSLUCENT_STATUS);

            // add FLAG_DRAWS_SYSTEM_BAR_BACKGROUNDS flag to the window
            window.addFlags(WindowManager.LayoutParams.FLAG_DRAWS_SYSTEM_BAR_BACKGROUNDS);

            // finally change the color
            window.setStatusBarColor(ContextCompat.getColor(activity, color));
        } catch (Exception e) {
            //Eat exception....Bad HABBIT.. :) !!!
            Log.d("Error", "fail");
        }
    }

    /**
     * Returns a contact by a given phone number
     *
     * @param context
     * @param phoneNumber
     * @return Contact
     */
    public static Contact getContactByPhoneNumber(@NonNull Context context, @NonNull String phoneNumber) {
        // if no number, return null
        if (phoneNumber.isEmpty()) return null;
        // check for permission to read contacts
        if (Utilities.checkPermissionGranted(context, READ_CONTACTS)) return null;
        // get contacts cursor
        Cursor cursor = new ContactsCursorLoader(context, phoneNumber, null).loadInBackground();
        // if cursor null, there is no contact, return only with number
        if (cursor == null) return new Contact(null, phoneNumber, null);
        // there is a match, return the first one
        cursor.moveToFirst();
        return new Contact(cursor);
    }

    /**
     * Returns a contact by a given name
     * (almost identical to the previous method (above) but filters the name instead of
     * the phone number)
     *
     * @param context
     * @param name
     * @return Contact
     */
    public static Contact getContactByName(@NonNull Context context, @NonNull String name) {
        // if no name return null
        if (name.isEmpty()) return null;
        // check for permission to read contacts
        if (Utilities.checkPermissionGranted(context, READ_CONTACTS)) return null;
        // get contacts cursor
        Cursor cursor = new ContactsCursorLoader(context, null, name).loadInBackground();
        // no results, return only with a name
        if (cursor == null) return new Contact(name, null);
        // there is a match, return the first one
        cursor.moveToFirst();
        return new Contact(cursor);
    }

    /**
     * Opens 'Add Contact' dialog from default os
     *
     * @param number
     */
    public static void addContactIntent(Activity activity, String number) {
        Intent addContactIntent = new Intent(Intent.ACTION_INSERT); // initiate intent
        addContactIntent.setType(ContactsContract.Contacts.CONTENT_TYPE); // add type
        addContactIntent.putExtra(ContactsContract.Intents.Insert.PHONE, number); // add number
        int PICK_CONTACT = 100; // Unique number to return when done with intent
        activity.startActivityForResult(addContactIntent, PICK_CONTACT); // start intent
    }

    /**
     * Opens a contact in the default contacts app by a given number
     *
     * @param activity
     * @param number
     */
    public static void openContactByNumber(Activity activity, String number) {
        Uri uri = Uri.withAppendedPath(ContactsContract.PhoneLookup.CONTENT_FILTER_URI, Uri.encode(number));
        String[] projection = new String[]{ContactsContract.PhoneLookup._ID};
        Cursor cursor = activity.getContentResolver().query(uri, projection, null, null, null);

        // if cursor isn't empty, take the first result
        if (cursor != null && cursor.moveToNext()) {
            Long id = cursor.getLong(0);
            openContactById(activity, id);
        }
        cursor.close(); // close the mf cursor
    }

    /**
     * Open contact in default contacts app by the contact's id
     *
     * @param activity
     * @param contactId
     */
    public static void openContactById(Activity activity, long contactId) {
        try {
            // new intent to view contact in contacts
            Intent intent = new Intent(Intent.ACTION_VIEW);
            Uri uri = Uri.withAppendedPath(ContactsContract.Contacts.CONTENT_URI, String.valueOf(contactId));
            intent.setData(uri);
            activity.startActivity(intent);
        } catch (Exception e) {
            Toast.makeText(activity, "Oops there was a problem trying to open the contact :(", Toast.LENGTH_SHORT).show();
            Timber.i("ERROR: " + e.getMessage());
        }
    }

    /**
     * Open contact edit page in default contacts app by contact's id
     *
     * @param activity
     * @param number
     */
    public static void openContactToEditByNumber(Activity activity, String number) {
        try {
            long contactId = Constants.getContactByPhoneNumber(activity, number).getContactId();
            Uri uri = ContentUris.withAppendedId(ContactsContract.CommonDataKinds.Phone.CONTENT_URI,
                    contactId);
            Intent intent = new Intent(Intent.ACTION_EDIT);
            intent.setDataAndType(uri, ContactsContract.Contacts.CONTENT_ITEM_TYPE);
            intent.putExtra("finishActivityOnSaveCompleted", true);
            //add the below line
            intent.addFlags(FLAG_ACTIVITY_CLEAR_TOP);
            activity.startActivityForResult(intent, 1);
        } catch (Exception e) {
            Toast.makeText(activity, "Oops there was a problem trying to open the contact :(", Toast.LENGTH_SHORT).show();
        }
    }

    /**
     * Open contact edit page in default contacts app by contact's id
     *
     * @param activity
     * @param contactId
     */
    public static void openContactToEditById(Activity activity, long contactId) {
        try {
            Intent intent = new Intent(Intent.ACTION_EDIT, ContactsContract.Contacts.CONTENT_URI);
            intent.setData(ContentUris.withAppendedId(ContactsContract.Contacts.CONTENT_URI, contactId));
            intent.putExtra("finishActivityOnSaveCompleted", true);
            //add the below line?
            intent.addFlags(FLAG_ACTIVITY_CLEAR_TOP);
            activity.startActivityForResult(intent, 1);
        } catch (Exception e) {
            Toast.makeText(activity, "Oops there was a problem trying to open the contact :(", Toast.LENGTH_SHORT).show();
        }
    }

    /**
     * Deletes contact by id
     *
     * @param activity
     * @param contactId
     */
    public static void deleteContactById(Activity activity, long contactId) {
        Uri uri = Uri.withAppendedPath(ContactsContract.Contacts.CONTENT_URI, Long.toString(contactId));
        activity.getContentResolver().delete(uri, null, null);
        Toast.makeText(activity, "Contact Deleted", Toast.LENGTH_LONG).show();
    }

    /**
     * Sets the contact's favorite status by a given boolean (yes/no)
     *
     * @param activity
     * @param contactId
     * @param isSetFavorite
     */
    public static void setContactIsFavorite(Activity activity, String contactId, boolean isSetFavorite) {
        int num = isSetFavorite ? 1 : 0; // convert boolean to num
        if (Utilities.checkPermissionGranted(activity, WRITE_CONTACTS)) {
            ContentValues v = new ContentValues();
            v.put(ContactsContract.Contacts.STARRED, num);
            activity.getContentResolver().update(ContactsContract.Contacts.CONTENT_URI, v, ContactsContract.Contacts._ID + "=?", new String[]{contactId + ""});
        }
    }

    public static String getServerHost(Context mContext) {
        return Prefs.getSharedPreferenceString(mContext, Prefs.PREF_SIP_ACCOUNT_SIP_SERVER_HOST, "");
    }

    public static int getServerPort(Context mContext) {
        return Prefs.getSharedPreferenceInt(mContext, Prefs.PREF_SIP_ACCOUNT_SIP_SERVER_PORT, 0);
    }

    public static int getLocalPort(Context mContext) {
        return Prefs.getSharedPreferenceInt(mContext, Prefs.PREF_SIP_ACCOUNT_SIP_LOCAL_PORT, 0);
    }

    public static String getSIPTransport(Context mContext) {
        return Prefs.getSharedPreferenceString(mContext, Prefs.PREF_SIP_ACCOUNT_SIP_TRANSPORT, "");
    }

    public static String getSIPUsername(Context mContext) {
        return Prefs.getSharedPreferenceString(mContext, Prefs.PREF_SIP_ACCOUNT_SIP_USERNAME, "");
    }

    public static String getSIPPassword(Context mContext) {
        return Prefs.getSharedPreferenceString(mContext, Prefs.PREF_SIP_ACCOUNT_SIP_PASSWORD, "");
    }

    public static String getSIPRealm(Context mContext) {
        return Prefs.getSharedPreferenceString(mContext, Prefs.PREF_SIP_ACCOUNT_SIP_REALM, "");
    }

    public static String getTURNHost(Context mContext) {
        return Prefs.getSharedPreferenceString(mContext, Prefs.PREF_SIP_ACCOUNT_SIP_TURN_SERVER, "");
    }

    public static String getTUTNUsername(Context mContext) {
        return Prefs.getSharedPreferenceString(mContext, Prefs.PREF_SIP_ACCOUNT_SIP_TURN_USERNAME, "");
    }

    public static String getTURNPassword(Context mContext) {
        return Prefs.getSharedPreferenceString(mContext, Prefs.PREF_SIP_ACCOUNT_SIP_TURN_PASSWORD, "");
    }

    public static String getTURNRealm(Context mContext) {
        return Prefs.getSharedPreferenceString(mContext, Prefs.PREF_SIP_ACCOUNT_SIP_TURN_REALM, "");
    }

    public static String getSTUNHost(Context mContext) {
        return Prefs.getSharedPreferenceString(mContext, Prefs.PREF_SIP_ACCOUNT_STUN_SERVER, "");
    }

    public static Boolean getIsICEEnabled(Context mContext) {
        return Prefs.getSharedPreferenceBoolean(mContext, Prefs.PREF_SIP_ACCOUNT_ICE_ENABLE, false);
    }

    public static Boolean getIsSRTPEnabled(Context mContext) {
        return Prefs.getSharedPreferenceBoolean(mContext, Prefs.PREF_SIP_ACCOUNT_SRTP_ENABLE, false);
    }

    public static String getMiscTimeout(Context mContext) {
        return Prefs.getSharedPreferenceString(mContext, Prefs.PREF_SIP_ACCOUNT_MISC_ANS_TIMEIOUT, "");
    }

    public static void hideKeyboard(Activity activity) {
        InputMethodManager imm = (InputMethodManager) activity.getSystemService(Activity.INPUT_METHOD_SERVICE);
        //Find the currently focused view, so we can grab the correct window token from it.
        View view = activity.getCurrentFocus();
        //If no view currently has focus, create a new one, just so we can grab a window token from it
        if (view == null) {
            view = new View(activity);
        }
        imm.hideSoftInputFromWindow(view.getWindowToken(), 0);
    }

    /** Returns the consumer friendly device name */
    public static String getDeviceName() {
        String manufacturer = Build.MANUFACTURER;
        String model = Build.MODEL;
        if (model.startsWith(manufacturer)) {
            return capitalize(model);
        }
        return capitalize(manufacturer) + " " + model;
    }

    private static String capitalize(String str) {
        if (TextUtils.isEmpty(str)) {
            return str;
        }
        char[] arr = str.toCharArray();
        boolean capitalizeNext = true;

        StringBuilder phrase = new StringBuilder();
        for (char c : arr) {
            if (capitalizeNext && Character.isLetter(c)) {
                phrase.append(Character.toUpperCase(c));
                capitalizeNext = false;
                continue;
            } else if (Character.isWhitespace(c)) {
                capitalizeNext = true;
            }
            phrase.append(c);
        }

        return phrase.toString();
    }

}
