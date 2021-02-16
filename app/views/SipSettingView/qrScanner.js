'use strict';

import React, { Component } from 'react';
import { baseUrl as baseurl, methodActprovsub as methodactprovsub } from '../../../app.json';

import {
  AppRegistry,
  StyleSheet,
  Text,
  TouchableOpacity,
  Linking, 
  NavigatorIOS,
  Dimensions,
} from 'react-native';

import QRCodeScanner from 'react-native-qrcode-scanner';
import { RNCamera } from 'react-native-camera';
import { View } from 'react-native-ui-lib/typings';

const SCREEN_HEIGHT = Dimensions.get("window").height;

class qrScanner extends Component {

  static navigationOptions = () => ({
    title: "Scan QR Code",
  });

    state = {
        authToken: '',
        sipServer : '',
        sipPort : '',
        sipTransport : 0,
        sipUsername :'',
        sipPassword : '',
        iceEnabled : true,
        turnServer : '',
        turnPort : '',
        turnUsername : '',
        turnPassword : '',
        stunServer : '',
        stunPort : ''
    }

    
    
    onSuccess = e => {
      console.debug('this.props.route.params.responseAppID',this.props.route.params.responseAppID)
        this.setState({ authToken: e.data})
        //alert(e.data)
        var params = {
            auth_type : 'QRCODE',
            app_id : this.props.route.params.responseAppID,
            sub_auth_str : this.props.route.params.UserMobileNumber,
            sub_dev_model : this.props.route.params.deviceModel,
            sub_dev_os : this.props.route.params.OSType,
            sub_dev_token : this.props.route.params.deviceToken,
            sub_activation_token : e.data,
         };
        //alert(this.state.authToken)
        console.debug('params of qr code', params);
        this.provisionUser(params);
    };

    provisionUser = (params) => {

        var myHeaders = new Headers();
        myHeaders.append("Content-Type", "Application/JSON");
        // "Content-type" : "Application/JSON"
        // myHeaders.append("Content-Type", "text/plain");
        /*
        var params = {
           auth_type : 'QRCODE',
           app_id : this.props.route.params.responseAppID,
           sub_auth_str : this.props.route.params.UserMobileNumber,
           sub_dev_model : this.props.route.params.deviceModel,
           sub_dev_os : this.props.route.params.OSType,
           sub_dev_token : this.props.route.params.deviceToken,
           sub_activation_token : this.state.authToken,
        };
        */
  
        var jsonString = JSON.stringify(params);
       // alert(jsonString)
  
        var requestOptions = {
           method: 'POST',
           headers: myHeaders,
           body: jsonString,
          // redirect: 'follow'
        };
        var url =  baseurl+methodactprovsub
        console.debug('url of dt = ',url)
        fetch(baseurl+methodactprovsub, requestOptions)
        .then(response => response.json())
        .then(result => this.handleResponse(result))
        .catch(error => alert(error))

        // fetch(baseurl+methodactprovsub, requestOptions)
        // .then(response => console.debug('response of qr code',response))
        // .then(result => this.handleResponse(result))
        // .catch(error => alert(error))
    }
////self.handleResponse(result)



    handleResponse = (apiResponse) => {
        if(apiResponse.auth_success === true){
            //alert("User provisioning completed.")
            var stunServers = apiResponse.app_cfg_data.stun_svrs
            var turnServers = apiResponse.app_cfg_data.turn_svrs
            this.setState({sipServer : apiResponse.app_cfg_data.sip_svrs[0]});
            this.setState({sipPort : 8993});
            this.setState({sipTransport : 'TCP'});
            this.setState({sipUsername : apiResponse.app_cfg_data.sip_uid});
            this.setState({sipPassword : ''});
            this.setState({iceEnabled : turnServers.length > 0 ? true : false});
            this.setState({turnServer : turnServers.length > 0 ? turnServers[0] : ''});
            this.setState({turnPort : 8993});
            this.setState({turnUsername : ''});
            this.setState({turnPassword : ''});
            this.setState({stunServer : stunServers.length > 0 ? stunServers[0] : ''});
            this.setState({stunPort : 8993});
            this.GoToSettingPage()

            
        }else{
            alert("User provisioning fail, Please try again")
        }
    }

    GoToSettingPage = () => {
      this.props.navigation.navigate('getSipSettingsFromAPI', {
                            sipServer : this.state.sipServer, 
                            sipPort : this.state.sipPort,
                            sipTransport : this.state.sipTransport,
                            sipUsername : this.state.sipUsername,
                            sipPassword : this.state.sipPassword,
                            iceEnabled : this.state.iceEnabled,
                            turnServer : this.state.turnServer,
                            turnPort : this.state.turnPort,
                            turnUsername : this.state.turnUsername,
                            turnPassword : this.state.turnPassword,
                            stunServer : this.state.stunServer,
                            stunPort : this.state.stunPort
     });
    }

    
  render() {
    return (
      <QRCodeScanner
      onRead={this.onSuccess}
      flashMode={RNCamera.Constants.FlashMode.off}
      reactivate = {false}
      cameraStyle={{ height: SCREEN_HEIGHT }}
        // onRead={this.onSuccess}
        // flashMode={RNCamera.Constants.FlashMode.off}
        // reactivate = {false}
        // style= {{ flex: 1 }}
        // showFrame = {true}
        // scanBarcode={true}
        // hideControls={true}
        // scanBarcode={true}
        // laserColor={'white'}
        // frameColor={'white'}
        // colorForScannerFrame={'white'}
        // cameraStyle={{ height: SCREEN_HEIGHT }}
     
      /> 
    );
  }





}

const styles = StyleSheet.create({
  container  : {
    flex : 1,
    backgroundColor : 'white',
  },
  centerText: {
    flex: 1,
    fontSize: 18,
    padding: 32,
    color: '#777'
  },
  textBold: {
    fontWeight: '500',
    color: '#000'
  },
  buttonText: {
    fontSize: 21,
    color: 'rgb(0,122,255)'
  },
  buttonTouchable: {
    padding: 16
  },
  zeroContainer: {
    flex: 1,
    backgroundColor : 'white',
  },
  cameraContainer: {
    height: Dimensions.get('window').height,
  },
 
  textBold: {
    fontWeight: '500',
    color: '#000',
  },
 
});

export default qrScanner;

//AppRegistry.registerComponent('qrScanner', () => qrScanner);
