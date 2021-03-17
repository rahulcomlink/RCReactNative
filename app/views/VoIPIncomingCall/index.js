import React, { Component } from 'react';
import {
	Text, ScrollView, StyleSheet, View, TextInput, TouchableOpacity, NativeModules, Image, Button, NativeEventEmitter
} from 'react-native';
import contact_avatar from '../../static/images/contact_avatar.png';
import calling_end from '../../static/images/calling_end.png';
import calling_start from '../../static/images/calling_start.png';

class VoIPIncomingCall extends React.Component {
    render(){
        return(
            <View style={{padding: 10, flex : 1, backgroundColor : 'white'}}>
                <Image style = {{width : 70, height : 70, alignSelf : 'center' , margin : 20, marginTop : 100, borderRadius : 70/2, borderWidth: 2, borderColor : 'lightgrey'}} source = {contact_avatar}/>
                <Text style = {{textAlign : 'center', fontSize : 28, marginBottom : 20, marginTop : 20}}> Callee name</Text> 
                <Text style = {{textAlign : 'center', fontSize : 20, marginBottom : 20}}> phone number</Text> 

                <View style = {styles.bottom}>
               <TouchableOpacity style={styles.button1} 
               onPress = {
                        () =>  console.debug('')
                      }>
               <Image style={styles.button1} source={ calling_start } />
              </TouchableOpacity>

              <TouchableOpacity style={styles.button1} 
                    onPress = {
                        () =>  console.debug('')
                      }> 
                      <Image style={styles.button1} source={ calling_end } />
             </TouchableOpacity>
                </View>

            </View> 
        );
    }
}

const styles = StyleSheet.create({
    
     button1: {
        width : 70,
        height : 70,
        alignSelf : 'center',
    },

      bottom: {
        width: '100%', 
        height: 70, 
        justifyContent: 'space-evenly', 
        alignItems: 'center',
        position: 'absolute',
        bottom: 80,
        flexDirection: 'row',
        alignSelf : 'center',
      }
});

export default VoIPIncomingCall;