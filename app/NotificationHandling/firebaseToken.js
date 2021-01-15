import React, { useEffect } from 'react';
import messaging from '@react-native-firebase/messaging';
import RocketChat from '../lib/rocketchat';

async function saveTokenToDatabase(token) {
    // Assume user is already signed in
    console.debug('device token of iphone = : ', token);
    const userId = auth().currentUser.uid;
  
    // Add the token to the users datastore
    await RocketChat.info
    await firestore()
      .collection('users')
      .doc(userId)
      .update({
        tokens: firestore.FieldValue.arrayUnion(token),
      });
  }

export default function firebaseToken() {
   // useEffect(() => {
      // Get the device token
      const permissionGranted = firebase.messaging().requestPermission();
      console.debug('permissionGranted :', permissionGranted);
      messaging()
        .getToken()
        .then(token => {
          console.debug('get device token 1 : ',token);
			  	console.debug(token);
          return saveTokenToDatabase(token);
        });
        
      // If using other push notification providers (ie Amazon SNS, etc)
      // you may need to get the APNs token instead for iOS:
      // if(Platform.OS == 'ios') { messaging().getAPNSToken().then(token => { return saveTokenToDatabase(token); }); }
  
      // Listen to whether the token changes
      return messaging().onTokenRefresh(token => {
        saveTokenToDatabase(token);
      });
   // }, []);
  }

  