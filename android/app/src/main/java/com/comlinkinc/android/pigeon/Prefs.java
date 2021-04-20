package com.comlinkinc.android.pigeon;

import android.content.Context;
import android.content.SharedPreferences;
import android.preference.PreferenceManager;

/*******************************************************************************************
 * Created by   - Tushar Patil
 *
 * Organization - Comlink Inc.
 *
 * Class        - Prefs.java
 *
 * Description  - We can easily maintain shared prefs (Save prefs, Retrieve Prefs)
 *                Prefs can be any type of (int, string, boolean)
 *
 *******************************************************************************************/

public class Prefs {
    private final static String PREF_FILE = "XonePrefs";

    public final static String PREF_SIP_ACCOUNT_SIP_SERVER_HOST = "prefs_sip_sip_server_host";
    public final static String PREF_SIP_ACCOUNT_SIP_SERVER_PORT = "prefs_sip_sip_sever_port";
    public final static String PREF_SIP_ACCOUNT_SIP_LOCAL_PORT = "prefs_sip_sip_local_port";
    public final static String PREF_SIP_ACCOUNT_SIP_TRANSPORT = "prefs_sip_transport";
    public final static String PREF_SIP_ACCOUNT_SIP_REALM = "prefs_sip_realm";
    public final static String PREF_SIP_ACCOUNT_SIP_USERNAME = "prefs_sip_username";
    public final static String PREF_SIP_ACCOUNT_SIP_PASSWORD = "prefs_sip_password";

    public final static String PREF_SIP_ACCOUNT_ICE_ENABLE = "prefs_sip_ice_enable";
    public final static String PREF_SIP_ACCOUNT_SRTP_ENABLE = "prefs_sip_srtp_enable";
    public final static String PREF_SIP_ACCOUNT_MISC_ANS_TIMEIOUT = "prefs_sip_misc_ans_timeout";

    public final static String PREF_SIP_ACCOUNT_STUN_ENABLE = "prefs_sip_stun_enable";
    public final static String PREF_SIP_ACCOUNT_STUN_SERVER = "prefs_sip_stun_server";
    public final static String PREF_SIP_ACCOUNT_STUN_PORT = "prefs_sip_stun_port";

    public final static String PREF_SIP_ACCOUNT_SIP_TURN_SERVER = "prefs_sip_turn_server";
    public final static String PREF_SIP_ACCOUNT_SIP_TURN_PORT = "prefs_sip_turn_port";
    public final static String PREF_SIP_ACCOUNT_SIP_TURN_USERNAME = "prefs_sip_turn_username";
    public final static String PREF_SIP_ACCOUNT_SIP_TURN_PASSWORD = "prefs_sip_turn_password";
    public final static String PREF_SIP_ACCOUNT_SIP_TURN_REALM = "prefs_sip_turn_realm";

    public final static String PREF_IS_FROM_OUTGOING_SCREEN = "prefs_is_from_outgoing";

    public final static String PREF_CALLEE_NAME = "prefs_callee_name";
    public final static String PREF_CALLEE_MOB_NO = "prefs_callee_mob_no";
    public final static String PREF_CALLEE_MOB_NO_TEMP = "prefs_callee_mob_no_temp";
    public final static String PREF_NEW_CALLEE_MOB_NO = "prefs_new_callee_mob_no";
    public final static String PREF_CONTACT_ID = "prefs_contact-id";

    public final static String PREF_SELECTED_TRANSPORT = "prefs_selected_transport";

    public final static String PREFS_AUTH_TOKEN = "prefs_auth_token";
    public final static String PREFS_USER_ID = "prefs_user_id";
    public static final String PREFS_READ_ONLY_GROUP = "ReadOnlyGroup";

    public static final String PREFS_PEER_USER = "PeerUser";

    public static final String PREFS_NOTIFICATION_TYPE = "NotificationType";

    public static final String NOTIFICAION_INTENT_VIDEO_URL = "NotificationIntent_Url";

    public static final String NOTIFICAION_TYPE_PEER_CHAT = "peer_chat";
    public static final String NOTIFICAION_TYPE_GROUP_CHAT = "group_chat";
    public static final String NOTIFICAION_TYPE_CHANNEL_CHAT = "channel_chat";

    public static final String PREFS_USER_NAME = "PeerUserName";
    public static final String PREFS_GROUP_NAME = "PeerUserGroupName";
    public static final String PREFS_ROOM_ID = "RoomId";
    public static final String PREFS_PEER_USER_NAME = "NotfPeerUserName";
    public static final String PREFS_ROOM_TYPE = "RoomType";
    public static final String PREFS_LIVE_CHAT_WITH_ROOM_ID = "LiveChatWithRoomId";

    public static final String PREFS_LOGIN_USER_NAME = "LoginUserName";

    //User square view color
    public static final String PREFS_USER_COLOR = "UserColor";

    public static final String PREFS_GROUP_OWNER_NAME = "PrefsGroupOwnerName";

    public static final String PREFS_RC_USERNAME = "prefs_rc_username";
    public static final String PREFS_RC_PASSWORD = "prefs_rc_password";

    public static final String PREFS_UNAME = "PrefsUname";
    public static final String PREFS_IS_BACK_CLICK = "is_back_click";

    public static final String PREFS_V_CARD_URL = "vcardurl";
    public static final String PREFS_V_CARD_TAG_LINE = "vcardtagline";
    public static final String PREFS_IS_SUBSCRIPTION_LOADED = "is_subsc_loaded";
    public static final String PREFS_CTSI_VC_URL = "ctsivcurl";
    public static final String PREFS_CTSI_VC_ID = "ctsivcid";

    public static final String PREFS_TOTAL_BALANCE = "total_xobey_balance";
    public static final String PREFS_CALL_RATE_BY_COUNTRY_CODE = "call_rate_by_c_code";

    public static final String PREFS_IS_RC_REGISTRATION_SUCCESS = "is_rc_reg_success";

    public static final String PREFS_CALL_START_TIME = "call_start_time";
    public static final String PREFS_CALL_END_TIME = "call_end_time";

    public static final String PREFS_IS_ONGOING_VIDEO_CALL = "is_ongoing_video_call";
    public static final String PREFS_DEDUCTED_AMOUNT = "deducted_amount";

    public static final String PREFS_DRAWING_URI = "prefs_drawing_uri";
    public static final String PREFS_DEVICE_TOKEN = "prefs_device_token";
    public static final String PREFS_OS_TYPE = "prefs_os_type";

    public final static String PREF_TOTAL_CONTACTS_NATIVE = "prefs_total_contact_native_phonebook";
    public final static String PREF_CREATE_GROUP = "prefs_create_group";
    public final static String PREF_MSG_REFRESH = "prefs_msg_refresh";
    public final static String PREF_OPEN_SEARCH = "prefs_opensearch";
    public final static String PREF_FROM_SCREEN = "prefs_fromscreen";
    public final static String PREF_MISSED_TAB_CLICK_TIME = "prefs_missed_tab_click_time";
    public final static String PREF_TAB_HISTORY_MISSED_CLICK = "prefs_tab_history_missed_click";
    public final static String PREF_CALL_FRG_SELECTED_TAB = "prefs_call_frg_selected_tab";

    public final static String PREF_ADD_MEMBER_IN_GROUP = "prefs_add_member_in_group";
    public final static String PREF_BACK_PRESSED = "prefs_back_pressed";
    public final static String PREF_ALL_MEMBERS_IN_GROUP = "prefs_all_members_in_group";
    public final static String PREF_IS_IM_LOGOUT = "prefs_is_im_logout";

    public final static String PREF_CONTACT_SYNT_TIME = "prefs_contact_sync_time";
    public final static String PREF_CHAT_NOTIFICATION_COUNTER = "prefs_chat_notification_counter";

    public final static String PREF_IM_FRIEND_SYNC_FIRST_TIME = "prefs_im_friend_sync_first_time";
    public final static String PREF_IS_BUSY = "prefs_isBusy";
    public static final String PREFS_INCOMING_ACTIVITY_VISIBLE = "prefs_incoming_screen_visible";
    public final static String PREF_CONTACT_EDIT = "prefs_contact_edit";
    public final static String PREF_ACTIVITY_IN_BG_ONPAUSE = "prefs_activity_in_bg_onpause";
    public final static String PREF_ACTIVITY_IN_BG_ONRESUME = "prefs_activity_in_bg_onresume";
    public final static String PREF_ADD_MISSED_CALL_ENTRY = "Prefs_AddMissedEntry";
    public final static String PREF_DELETE_HISTORY = "Prefs_delete_history";
    public final static String PREF_CALL_ID_CALL_ANSWER_REWARD = "Prefs_call_id_call_answer_reward";
    public final static String PREF_CURRENT_CALL_RATE_PER_MINUTE = "prefs_current_call_rate_per_minute";
    public static final String PREFS_CALL_END_SHOW_EARN_PAGE = "PrefsCallEndaShowearnPage";
    public static final String PREFS_CALL_DISCONNECTED = "PrefsIsCallDisconnected";
    public static final String PREFS_IS_LEFT_GROUP = "PrefsIsLeftGroup";

    public static final String PREFS_IS_IM_LOGIN_IN_PROGRESS = "prefs_is_im_login_in_progress";
    public static final String PREFS_IS_IMAGES = "prefs_is_images";
    public static final String PREFS_USE_REALNAME = "prefs_use_realname";

    public static final String PREFS_PROGRESS_STATUS = "prefs_progress_status";

    public final static String IN_PROGRESS = "InProgress";
    public final static String SUCCESS = "Success";
    public final static String FAILED = "Failed";
    public final static String NEW_REGISTRATION = "New_Registration";

    public final static String IS_GRID = "is_grid";

    public final static String Prefs_Temp_Name = "temp_name";
    public final static String Prefs_Temp_Number = "temp_number";
    public final static String Prefs_Import_Clicked = "import_clicked";

    public final static String PREFS_DIALER_SUCCESS = "prefs_dialer_success";

    public final static String PREFS_TIMER_VALUE = "timer_value";
    public final static String PREFS_CALEE_NAME = "calee_name";
    public final static String PREFS_CALEE_NUMBER = "calee_number";


    public final static String PREFS_CP_RING_TO_PHONE = "copr_ring_to_phone_storage";
    public final static String PREFS_APP_ID = "prefs_app_id";
    public final static String PREFS_SUB_AUTH_STR = "prefs_sub_auth_str";
    public final static String PREFS_ACCOUNT_ACTIVATED = "prefs_acount_activated";

    public final static String IS_CALL_IN_PROGRESS = "Is_call_in_progress";


    public final static String PREFS_IS_APP_IN_BACKGRUND = "prefs_app_in_bg";


    /**
     * Set a string shared preference
     *
     * @param key   - Key to set shared preference
     * @param value - Value for the key
     */
    public static void setSharedPreferenceString(Context context, String key, String value) {
        SharedPreferences settings = context.getSharedPreferences(PREF_FILE, 0);
        SharedPreferences.Editor editor = settings.edit();
        editor.putString(key, value);
        editor.apply();
    }

    /**
     * Set a integer shared preference
     *
     * @param key   - Key to set shared preference
     * @param value - Value for the key
     */
    public static void setSharedPreferenceInt(Context context, String key, int value) {
        SharedPreferences settings = context.getSharedPreferences(PREF_FILE, 0);
        SharedPreferences.Editor editor = settings.edit();
        editor.putInt(key, value);
        editor.apply();
    }

    /**
     * Set a Boolean shared preference
     *
     * @param key   - Key to set shared preference
     * @param value - Value for the key
     */
    public static void setSharedPreferenceBoolean(Context context, String key, boolean value) {
        SharedPreferences settings = context.getSharedPreferences(PREF_FILE, 0);
        SharedPreferences.Editor editor = settings.edit();
        editor.putBoolean(key, value);
        editor.apply();
    }

    /**
     * Get a string shared preference
     *
     * @param key      - Key to look up in shared preferences.
     * @param defValue - Default value to be returned if shared preference isn't found.
     * @return value - String containing value of the shared preference if found.
     */
    public static String getSharedPreferenceString(Context context, String key, String defValue) {
        SharedPreferences settings = context.getSharedPreferences(PREF_FILE, 0);
        return settings.getString(key, defValue);
    }

    /**
     * Get a integer shared preference
     *
     * @param key      - Key to look up in shared preferences.
     * @param defValue - Default value to be returned if shared preference isn't found.
     * @return value - String containing value of the shared preference if found.
     */
    public static int getSharedPreferenceInt(Context context, String key, int defValue) {
        SharedPreferences settings = context.getSharedPreferences(PREF_FILE, 0);
        return settings.getInt(key, defValue);
    }

    public static void removeFromPrefs(Context context, String key) {
        SharedPreferences prefs = PreferenceManager.getDefaultSharedPreferences(context);
        final SharedPreferences.Editor editor = prefs.edit();
        editor.remove(key);
        editor.commit();
    }

    /**
     * Get a boolean shared preference
     *
     * @param key      - Key to look up in shared preferences.
     * @param defValue - Default value to be returned if shared preference isn't found.
     * @return value - String containing value of the shared preference if found.
     */
    public static boolean getSharedPreferenceBoolean(Context context, String key, boolean defValue) {
        SharedPreferences settings = context.getSharedPreferences(PREF_FILE, 0);
        return settings.getBoolean(key, defValue);
    }
}
