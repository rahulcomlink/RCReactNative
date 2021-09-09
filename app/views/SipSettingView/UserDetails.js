import React, { Component } from 'react'
import {
  View,
  Text,
  Image,
  TouchableOpacity,
  TextInput,
  StyleSheet,
  KeyboardAvoidingView,
  Alert,
  NativeModules,
} from "react-native";
import { Platform } from 'react-native';
import DeviceInfo from 'react-native-device-info';
import { baseUrl as baseurl, methodActAuthSub as methodactauthsub } from '../../../app.json';
import qrScanner from "./qrScanner";
import messaging from '@react-native-firebase/messaging';
import { isIOS, isTablet } from "../../utils/deviceInfo";
const os = isIOS ? "ios" : "android";
var vt = ''

class Inputs extends Component<{navigation: any}> {

   static navigationOptions = () => ({
      title: "Sip Provision",
    });

   state = {
      mobilenumber: '',
      email: '',
      deviceOS : '',
      deviceModel : '',
      responseAppID : '',
      deviceToken : '',
   }

   handlephoneNumber = (text) => {
      this.setState({ mobilenumber: text })
   }
   handleEmail = (text) => {
      this.setState({ email: text })
   }

  


   handleQRTape = () => {
     // this.props.navigation.navigate('SIPSettings');
      this.props.navigation.push('qrScanner', {
         deviceModel : this.state.deviceModel,
         OSType : this.state.deviceOS,
         UserMobileNumber : this.state.mobilenumber,
         responseAppID : this.state.responseAppID,
         deviceToken : this.state.deviceToken,
         onSelect: this.getCountryCode
      });
   }

   getCountryCode = (item) => {
    this.props.navigation.goBack();
   }


   validateEmail = (text) => {
      console.log(text);
      let reg = /^\w+([\.-]?\w+)*@\w+([\.-]?\w+)*(\.\w{2,3})+$/;
      if (reg.test(text) === false) {
         console.log(text)
         console.log("Email is Not Correct");
         return false;
      }else{     
        console.log("Email is Correct");
        return true
      }
    }

   login = async(mobilenumber, email) => {

      if(!this.state.mobilenumber.length){
         alert('Mobile number can not be blank')
      }else if (this.validateEmail(this.state.email)){
         var myHeaders = new Headers();
         myHeaders.append("Content-Type", "text/plain");

         // Keep the device and OS related info in stae for further usage
         this.setState({ deviceModel: DeviceInfo.getModel() })
         this.setState({ deviceOS: Platform.OS.toUpperCase() })

         this.state.deviceModel =  DeviceInfo.getModel()
         this.state.deviceOS =  Platform.OS.toUpperCase()

         if (os == "android") {
            vt = this.state.deviceToken
         }

         var params = {
            auth_type : 'QRCODE',
            cmsid : 'CTSIPIGEON',
            sub_auth_str : this.state.mobilenumber,
            sub_dev_model : DeviceInfo.getModel() ,
            sub_dev_os : Platform.OS.toUpperCase(),
            sub_dev_token : vt,
            sub_email : this.state.email
         };
   
         var jsonString = JSON.stringify(params);
   
         var requestOptions = {
            method: 'POST',
            headers: myHeaders,
            body: jsonString,
            redirect: 'follow'
         };
        
         fetch(baseurl+methodactauthsub, requestOptions)
         .then(response => response.json())
         .then(result => this.setAppID(result))
         .catch(error => alert(error)
         );
     
      }else{
         alert('Please enter a valid Email address')
      }
   }

   setAppID = (jsonObject) => {

      const AppID = jsonObject.app_id;
      alert('Please scan QR code')
      this.setState({responseAppID : AppID});
   }

   componentDidMount(){
      if (os == "android") {
      messaging().getToken().then(token => {
         this.setState({deviceToken : token});
      })
   }
   else {
      NativeModules.SIPSDKBridge.callbackMethod((err,voipToken) => {
         vt = voipToken.voiptoken
         this.setState({deviceToken : voipToken.voiptoken});
         this.state.deviceToken =  voipToken.voiptoken

      });
   }
      

      if (os == "android") {
        NativeModules.Sdk.askStorageAndMicPermission();
      }
   }

   

   render() {
      return (
         <View style = {styles.container}>

            <Image style = {styles.logo}
                source = {require('../../static/images/logo_user_provision.png')} 
            />

            <TextInput style = {styles.input}
               underlineColorAndroid = "transparent"
               placeholder = "Phone number"
               placeholderTextColor = "black"
               keyboardType = "numbers-and-punctuation"
               autoCapitalize = "none"
               onChangeText = {this.handlephoneNumber}/>
            
            <TextInput style = {styles.input}
               underlineColorAndroid = "transparent"
               placeholder = "Email"
               placeholderTextColor = "black"
               autoCapitalize = "none"
               keyboardType = "email-address"
               onChangeText = {this.handleEmail}/>

            <TouchableOpacity 
               //disabled = {!this.state.mobilenumber.length}
               style = {styles.submitButton}
               onPress = {
                  () => this.login(this.state.mobilenumber, this.state.email)
               }>
               <Text style = {styles.submitButtonText}> Submit </Text>
            </TouchableOpacity>

            <Text style = {styles.orLabel}> Or </Text>

            <TouchableOpacity
                onPress = {
                    () => this.handleQRTape()
                }>  
                <Image style = {styles.scannerLogo}
                    source = {require('../../static/images/qrScanner.png')} 
                />
            </TouchableOpacity>
            
            <Text style = {styles.orLabel}> Scan QR </Text>

         </View> 
      )
   }
}

const styles = StyleSheet.create({
   container: {
      flex : 1,
      backgroundColor: 'white'
      //paddingTop: 150
   },
   input: {
      margin: 7,
      height: 40,
      borderColor: 'gray',
      borderWidth: 0.5,
      marginHorizontal : 60,
      fontSize : 17,
   },
   submitButton: {
      backgroundColor: '#7a42f4',
      padding: 10,
      marginTop : 10,
      marginHorizontal: 60,
      height: 40,
   },
   submitButtonText:{
      color: 'white',
      textAlign : 'center',
      fontWeight : 'bold',
   },

   logo : {
       alignSelf : 'center',
       marginTop : 50
   },

   scannerLogo : {
       height : 130,
       width : 130,
       alignSelf : 'center',

   },

   orLabel : {
       fontSize : 15,
       alignSelf : 'center',
       fontWeight : 'bold',
       marginVertical : 10,
   }

});
export default Inputs;
