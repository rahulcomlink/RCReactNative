import React from "react";
import { NativeModules, Alert } from "react-native";
import AsyncStorage from "@react-native-async-storage/async-storage";
import { isIOS, isTablet } from "../../utils/deviceInfo";
const os = isIOS ? "ios" : "android";

class commonSipSettingFunc extends React.Component {
  constructor(props) {
    super(props);
  }
  getSipSettingsAndStart = async () => {
    console.debug('getSipSettingsAndStart')
    try {
      if (os == "android") {
        NativeModules.Sdk.stopDialer();
      } else {
       // NativeModules.SIPSDKBridge.sipStop();
      }

      const sipServer = await AsyncStorage.getItem("sipServer");
      const sipPort = await AsyncStorage.getItem("sipPort");
      const sipTransport = await AsyncStorage.getItem("sipTransport");
      const sipUsername = await AsyncStorage.getItem("sipUsername");
      const sipPassword = await AsyncStorage.getItem("sipPassword");
      const iceEnabled = await AsyncStorage.getItem("iceEnabled");
      const turnServer = await AsyncStorage.getItem("turnServer");
      const turnPort = await AsyncStorage.getItem("turnPort");
      const turnUsername = await AsyncStorage.getItem("turnUsername");
      const turnPassword = await AsyncStorage.getItem("turnPassword");
      const stunServer = await AsyncStorage.getItem("stunServer");
      const stunPort = await AsyncStorage.getItem("stunPort");

      if (sipServer == null) {
      } else {
        if (os == "android") {
          NativeModules.Sdk.startDialer(
            sipUsername,
            sipPassword,
            sipServer,
            "*",
            stunServer,
            turnServer,
            turnUsername,
            turnPassword,
            "",
            iceEnabled,
            sipPort,
            sipPort,
            sipTransport,
            turnPort,
            stunPort
          );
        } else {
          NativeModules.SIPSDKBridge.sipRegistration(
            sipUsername,
            sipPassword,
            sipServer,
            "*",
            stunServer,
            turnServer,
            turnUsername,
            turnPassword,
            "",
            iceEnabled,
            sipPort,
            sipPort,
            sipTransport,
            '0',
            '0'
          );
        }
      }
    } catch (error) {
      // Error retrieving data
      console.debug("error.message", error.message);
    }
  };

  callFunc = async (phoneNumber) => {
    try {
      const sipServer = await AsyncStorage.getItem("sipServer");
      const sipPort = await AsyncStorage.getItem("sipPort");
      const sipTransport = await AsyncStorage.getItem("sipTransport");

      if (sipServer == null) {
        Alert("Please complete Sip Provisioning");
      } else {
        if (os == "android") {
          NativeModules.Sdk.makeCall(
            "sip:" +
              phoneNumber +
              "@" +
              sipServer +
              ":" +
              sipPort +
              ";transport=" +
              sipTransport
          );
        } else {
          NativeModules.SIPSDKBridge.makeCall(
            phoneNumber,
            sipServer,
            sipPort,
            sipTransport
          );
        }
      }
    } catch (error) {
      // Error retrieving data
      console.debug("error.message", error.message);
    }
  };
}

const obj = new commonSipSettingFunc();
export default obj;
