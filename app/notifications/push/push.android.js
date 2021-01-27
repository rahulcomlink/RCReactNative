import {
  NotificationsAndroid,
  PendingNotifications,
} from "react-native-notifications";
import messaging from "@react-native-firebase/messaging";
import { DeviceEventEmitter } from "react-native";
import IncomingCall from "react-native-incoming-call";
import callJitsi from "../../lib/methods/callJitsi";

class PushNotification {
  constructor() {
    this.onRegister = null;
    this.onNotification = null;
    this.deviceToken = null;

    NotificationsAndroid.setRegistrationTokenUpdateListener((deviceToken) => {
      this.deviceToken = deviceToken;
    });

    NotificationsAndroid.setNotificationOpenedListener((notification) => {
      this.onNotification(notification);
    });

    messaging().setBackgroundMessageHandler(async (remoteMessage) => {
      console.debug("Message handled in the background!", remoteMessage);

      // Receive remote message
      if (remoteMessage?.notification?.body === "Incoming Call") {
        // Display incoming call activity.
        IncomingCall.display(
          "callUUIDv4", // Call UUID v4
          remoteMessage?.notification?.title, // Username
          "https://user-images.githubusercontent.com/13730671/105949904-7be50e00-6093-11eb-88cd-f1d8b2147af3.png", // Avatar URL
          "Incoming Video Call", // Info text
          20000 // Timeout for end call after 20s
        );
      }

      // Listen to headless action events
      DeviceEventEmitter.addListener("endCall", (payload) => {
        // End call action here
      });
      DeviceEventEmitter.addListener("answerCall", (payload) => {
        console.log("answerCall", payload);
        if (payload.isHeadless) {
          // Called from killed state
          console.debug("answerCall - Killed", "payload.uuid");
          IncomingCall.openAppFromHeadlessMode(payload.uuid);
        } else {
          // Called from background state
			console.debug("answerCall - backToForeground", "payload.uuid");
			callJitsi("HiMWGbaP3q9krjy6Svc87hz5pvYENi4erx");
          IncomingCall.backToForeground();
        }
      });
    });

    messaging().onMessage(async (remoteMessage) => {
      //   Alert.alert("A new FCM message arrived!", JSON.stringify(remoteMessage));
      //completion({ alert: true, sound: true, badge: true });
    });

    messaging().onNotificationOpenedApp((remoteMessage) => {
      console.debug(
        "Notification caused app to open from background state from background",
        remoteMessage.notification
      );
      console.debug("remoteMessage.data", remoteMessage.data);
      this.onNotification(remoteMessage.data);
      //   Alert.alert("A new FCM message arrived!", JSON.stringify(remoteMessage));
      // navigation.navigate(remoteMessage.data.type);
    });

    messaging()
      .getInitialNotification()
      .then((remoteMessage) => {
        if (remoteMessage) {
          console.log(
            "Notification caused app to open from quit state:",
            remoteMessage.notification
          );
          console.debug("remoteMessage.data", remoteMessage.data);
          this.onNotification(remoteMessage.data);

          //   Alert.alert(
          //     "A new FCM message arrived!",
          //     JSON.stringify(remoteMessage)
          //   );
        }
      });
  }

  getDeviceToken() {
    return this.deviceToken;
  }

  setBadgeCount = () => {};

  configure(params) {
    this.onRegister = params.onRegister;
    this.onNotification = params.onNotification;
    NotificationsAndroid.refreshToken();
    return PendingNotifications.getInitialNotification();
  }
}

export default new PushNotification();
