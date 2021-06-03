import NotificationsIOS, { NotificationAction, NotificationCategory } from 'react-native-notifications';
import {Notifications} from 'react-native-notifications';
import messaging from '@react-native-firebase/messaging';
import { Alert , NativeEventEmitter, NativeModules} from 'react-native';
import EJSON from 'ejson';
import reduxStore from '../../lib/createStore';
import I18n from '../../i18n';
import Navigation from '../../lib/Navigation';
import CallScreen from '../../views/SipSettingView/CallScreen';
import AsyncStorage from '@react-native-async-storage/async-storage';
import VoipPushNotification from 'react-native-voip-push-notification';

const replyAction = new NotificationAction({
	activationMode: 'background',
	title: I18n.t('Reply'),
	textInput: {
		buttonTitle: I18n.t('Reply'),
		placeholder: I18n.t('Type_message')
	},
	identifier: 'REPLY_ACTION'
});

const eventEmitter = new NativeEventEmitter(NativeModules.ModuleWithEmitter);

class PushNotification {
	constructor() {
		this.onRegister = null;
		this.onNotification = null;
		this.deviceToken = null;
	
		eventEmitter.addListener('VoipCall', this.getVoIPCall);

		NotificationsIOS.addEventListener('remoteNotificationsRegistered', (deviceToken) => {
			this.deviceToken = deviceToken;
		});

		VoipPushNotification.addEventListener('register', (token) => {
			// --- send token to your apn provider server
			this.saveVoIPToken(token);
        });

		NotificationsIOS.addEventListener('notificationOpened', (notification, completion) => {
			 const { background } = reduxStore.getState().app;
			 if (background) {
				this.onNotification(notification);
			 }
			completion();
		});
		
		NotificationsIOS.addEventListener('notificationReceivedForeground', (notification, completion) => {
			completion({ alert: true, sound: true, badge: true });
		});

		

		NotificationsIOS.addEventListener('notificationReceivedBackground', (notification, completion) => {
			completion({ alert: true, sound: true, badge: true });
		});

		

		messaging().setBackgroundMessageHandler(async remoteMessage => {
		  });

		 messaging().onMessage(async remoteMessage => {
			 
			 const {
				rid, name, sender, type, host, messageType
			} = EJSON.parse(remoteMessage.data.ejson);
	
			if(messageType == 'jitsi_call_started'){
				this.onNotification(remoteMessage.data);
			}
		  });

		  messaging().onNotificationOpenedApp(remoteMessage => {
			this.onNotification(remoteMessage.data);

		  });

		  messaging()
      .getInitialNotification()
      .then(remoteMessage => {
        if (remoteMessage) {
		  this.onNotification(remoteMessage.data);
        }
      });

		const actions = [];
		actions.push(new NotificationCategory({
			identifier: 'MESSAGE',
			actions: [replyAction]
		}));
		NotificationsIOS.requestPermissions(actions);

		// --- NOTE: You still need to subscribe / handle the rest events as usuall.
        // --- This is just a helper whcih cache and propagate early fired events if and only if for
        // --- "the native events which DID fire BEFORE js bridge is initialed",
        // --- it does NOT mean this will have events each time when the app reopened.

		VoipPushNotification.registerVoipToken();

		
	}

	getDeviceToken() {
		return this.deviceToken;
	}

	setBadgeCount = (count = 0) => {
		NotificationsIOS.setBadgesCount(count);
	}

	getVoIPCall = (event) => {
		Navigation.navigate('CallScreen', { phoneNumber : event.phoneNumber, isVoIPCall : true});
	}

	saveVoIPToken = async(token) => {
		try {
			await AsyncStorage.setItem('VoIPToken', token);
		}catch (error) {
			// Error retrieving data
			console.debug('error.message', error.message);
		  }
	}

	async configure(params) {
		this.onRegister = params.onRegister;
		this.onNotification = params.onNotification;

		const initial = await NotificationsIOS.getInitialNotification();
		return Promise.resolve(initial);
	}
}
export default new PushNotification();
