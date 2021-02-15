import React from 'react';
import { NativeModules } from 'react-native';
import AsyncStorage from '@react-native-async-storage/async-storage';

class commonSipSettingFunc extends React.Component{
    
    constructor(props) {
        super(props);
    }
    getSipSettingsAndStart = async () => {
       
        try {

            console.debug('getSipSettingsAndStart 1')

            NativeModules.SIPSDKBridge.sipStop();

            const sipServer = await AsyncStorage.getItem('sipServer') ;
            const sipPort = await AsyncStorage.getItem('sipPort') ;
            const sipTransport = await AsyncStorage.getItem('sipTransport') ;
            const sipUsername = await AsyncStorage.getItem('sipUsername') ;
            const sipPassword = await AsyncStorage.getItem('sipPassword') ;
            const iceEnabled = await AsyncStorage.getItem('iceEnabled') ;
            const turnServer = await AsyncStorage.getItem('turnServer') ;
            const turnPort = await AsyncStorage.getItem('turnPort') ;
            const turnUsername = await AsyncStorage.getItem('turnUsername') ;
            const turnPassword = await AsyncStorage.getItem('turnPassword') ;
            const stunServer = await AsyncStorage.getItem('stunServer') ;
            const stunPort = await AsyncStorage.getItem('stunPort') ;
            
             this.forceUpdate()

             console.debug('getSipSettingsAndStart 2')
        
             NativeModules.SIPSDKBridge.sipRegistration('*','*','*','*','*','*','*','*','*','*','*','*','*','*','*');
            // NativeModules.SIPSDKBridge.sipRegistration(sipUsername,sipPassword,sipServer,'*',stunServer,turnServer,turnUsername,turnPassword,'',iceEnabled,sipPort,sipPort,sipTransport,turnPort,stunPort);

             
          } catch (error) {
            // Error retrieving data
            console.debug('error.message', error.message);
          }
    }

    callFunc = async (phoneNumber) => {
        try {
            const sipServer = await AsyncStorage.getItem('sipServer') ;
            const sipPort = await AsyncStorage.getItem('sipPort') ;
            const sipTransport = await AsyncStorage.getItem('sipTransport') ;

             this.forceUpdate()
        
             NativeModules.SIPSDKBridge.makeCall(phoneNumber,sipServer,sipPort,sipTransport);
             
          } catch (error) {
            // Error retrieving data
            console.debug('error.message', error.message);
          }
    }
}

const obj  = new commonSipSettingFunc();
export default obj;
