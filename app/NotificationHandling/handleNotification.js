import React, { Component } from 'react';
import { StyleSheet, View } from 'react-native';
import RocketChat from '../lib/rocketchat';
import { pigeonBaseUrl as pigeonBaseUrl } from "../../app.json";


const baseUrl = pigeonBaseUrl;

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