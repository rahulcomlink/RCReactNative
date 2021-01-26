import NotificationsIOS, { NotificationAction, NotificationCategory } from 'react-native-notifications';
import {Notifications} from 'react-native-notifications';
import messaging from '@react-native-firebase/messaging';
import { Alert } from 'react-native';

import reduxStore from '../../lib/createStore';
import I18n from '../../i18n';

const replyAction = new NotificationAction({
	activationMode: 'background',
	title: I18n.t('Reply'),
	textInput: {
		buttonTitle: I18n.t('Reply'),
		placeholder: I18n.t('Type_message')
	},
	identifier: 'REPLY_ACTION'
});

class PushNotification {
	constructor() {
		this.onRegister = null;
		this.onNotification = null;
		this.deviceToken = null;

		NotificationsIOS.addEventListener('remoteNotificationsRegistered', (deviceToken) => {
			this.deviceToken = deviceToken;
		});

		NotificationsIOS.addEventListener('notificationOpened', (notification, completion) => {
			console.debug("Notification Received - Foreground", notification.payload);
			 const { background } = reduxStore.getState().app;
			 if (background) {
				this.onNotification(notification);
			 }
			completion();
		});

		NotificationsIOS.addEventListener('notificationReceivedForeground', (notification, completion) => {
			console.debug('Notification received in foreground 1: ', notification);
			completion({ alert: true, sound: true, badge: true });
		});

		NotificationsIOS.addEventListener('notificationReceivedBackground', (notification, completion) => {
			console.debug('Notification received in foreground 1: ', notification);
			completion({ alert: true, sound: true, badge: true });
		});

		messaging().setBackgroundMessageHandler(async remoteMessage => {
			console.debug('Message handled in the background!', remoteMessage);
		  });

		 messaging().onMessage(async remoteMessage => {
			//Alert.alert('A new FCM message arrived!', JSON.stringify(remoteMessage));
			
			//completion({ alert: true, sound: true, badge: true });
		  });

		  messaging().onNotificationOpenedApp(remoteMessage => {
			console.debug(
			  'Notification caused app to open from background state from background',
			  remoteMessage,
			);
			this.onNotification(remoteMessage.data);
			//Alert.alert('A new FCM message arrived!', JSON.stringify(remoteMessage));
		   // navigation.navigate(remoteMessage.data.type);
		  });

		  messaging()
      .getInitialNotification()
      .then(remoteMessage => {
        if (remoteMessage) {
          console.log(
            'Notification caused app to open from quit state:',
            remoteMessage.notification,
		  );
		  this.onNotification(remoteMessage.data);1
		  //Alert.alert('A new FCM message arrived!', JSON.stringify(remoteMessage));
        }
      });

		const actions = [];
		actions.push(new NotificationCategory({
			identifier: 'MESSAGE',
			actions: [replyAction]
		}));
		NotificationsIOS.requestPermissions(actions);

		
	}

	getDeviceToken() {
		return this.deviceToken;
	}

	setBadgeCount = (count = 0) => {
		NotificationsIOS.setBadgesCount(count);
	}

	async configure(params) {
		this.onRegister = params.onRegister;
		this.onNotification = params.onNotification;

		const initial = await NotificationsIOS.getInitialNotification();
		// NotificationsIOS.consumeBackgroundQueue();
		return Promise.resolve(initial);
	}
}
export default new PushNotification();
