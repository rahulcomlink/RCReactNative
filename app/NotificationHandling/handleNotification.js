import React, { Component } from 'react';
import { StyleSheet, View } from 'react-native';
import RocketChat from '../lib/rocketchat';
import { IMBaseUrl as IMBaseUrl } from "../../app.json";


const baseUrl = IMBaseUrl;

class handleNotification extends Component{ 

sendDeviceToken(){
 fetch(baseUrl + '/api/v1/users.update', { method:'POST'})
      .then((response) => response.json())
      .then((json) => {
        console.log(json);
      })
      .catch((error) => console.error(error));
    }

    sendDeviceTokenToServer() {
      const customFields = {}
      RocketChat.saveUserProfile()
    }
  
 }