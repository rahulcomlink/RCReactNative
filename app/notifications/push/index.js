import EJSON from 'ejson';
import PushNotification from './push';
import store from '../../lib/createStore';
import { deepLinkingOpen } from '../../actions/deepLinking';
import { isFDroidBuild } from '../../constants/environment';
import messaging from '@react-native-firebase/messaging';
import { isIOS, isTablet } from '../../utils/deviceInfo';

export const onNotification = (notification) => {
	console.debug('onNotification methoid called :', notification)
	if (notification) {

		// const data = notification.getData();
		// console.debug('data on click on notification : ', data);
		// if (data) {
		// 	try {
				const {
					rid, name, sender, type, host, messageType
				} = EJSON.parse(notification.ejson);

				const types = {
					c: 'channel', d: 'direct', p: 'group', l: 'channels'
				};
				let roomName = type === 'd' ? sender.username : name;
				if (type === 'l') {
					roomName = sender.name;
				}

				const params = {
					host,
					rid,
					path: `${ types[type] }/${ roomName }`,
					isCall: messageType === 'jitsi_call_started'
				};
				store.dispatch(deepLinkingOpen(params));
			//} catch (e) {
			//	console.warn(e);
			//}
		//}
	}
};

export const getDeviceToken = () => PushNotification.getDeviceToken();
export const setBadgeCount = count => PushNotification.setBadgeCount(count);
export const initializePushNotifications = () => {
	if (!isFDroidBuild) {
		setBadgeCount();
		return PushNotification.configure({
			onNotification
		});
	}
};
