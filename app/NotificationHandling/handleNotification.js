import React from 'react';
import { StyleSheet, View } from 'react-native';

const baseUrl = "https://pigeon.mvoipctsi.com";

class handleNotification{

sendDeviceToken(){
 fetch(baseUrl + '/api/v1/users.update', { method:'POST'})
      .then((response) => response.json())
      .then((json) => {
        console.log(json);
      })
      .catch((error) => console.error(error));
    }
    }