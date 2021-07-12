import React, { Component } from 'react';
import PropTypes from "prop-types";
import { View, Text, Image, ScrollView, Switch ,TouchableOpacity, TextInput, StyleSheet, KeyboardAvoidingView , Alert} from 'react-native';
import InputContainer from './InputContainer.js';
import SegmentedControl from '@react-native-community/segmented-control';
import { block } from 'react-native-reanimated';
import AsyncStorage from '@react-native-async-storage/async-storage';
const SIPUserInfo = 'SIPUserData';
import * as HeaderButton from '../../containers/HeaderButton';
import { isNil } from 'lodash';
import commonSipSettingFunc from './commonSipSettingFunc';
import { KeyboardAwareScrollView } from 'react-native-keyboard-aware-scroll-view';

class getSipSettingsFromAPI extends React.Component {

    static navigationOptions = () => ({
        title: "Sip Settings",
    });

   
    //   static navigationOptions = ({ navigation, isMasterDetail }) => ({
	// 	headerLeft: () => (isMasterDetail ? (
	// 		<HeaderButton.CloseModal navigation={navigation} testID='sip-settings-view-close' />
	// 	) : (
	// 		<HeaderButton.Drawer navigation={navigation} testID='sip-settings-view-drawer' />
	// 	)),
	// 	 title: 'Sip Settings'
	// });

    static propTypes = {
		navigation: PropTypes.object,
		route: PropTypes.object
     }


    constructor(props) {
        super(props);
    
        
        this.state =  {
            sipServer : props.route.params?.sipServer,
            sipPort : props.route.params?.sipPort,
            sipTransport : props.route.params?.sipTransport,
            sipUsername :props.route.params?.sipUsername,
            sipPassword : props.route.params?.sipPassword,
            iceEnabled : props.route.params?.iceEnabled,
            turnServer : props.route.params?.turnServer,
            turnPort : props.route.params?.turnPort,
            turnUsername : props.route.params?.turnUsername,
            turnPassword : props.route.params?.turnPassword,
            stunServer : props.route.params?.stunServer,
            stunPort : props.route.params?.stunPort
        }
        
        

        /*
        this.state =  {
            sipServer : 'newxonesip.mvoipctsi.com',
            sipPort : '8993',
            sipTransport : 'TCP',
            sipUsername :'919420429240',
            sipPassword : '5d7d424b4c2f87001a71c411',
            iceEnabled : true,
            turnServer : 'turntaiwan.mvoipctsi.com',
            turnPort : '0',
            turnUsername : 'comlinkxone',
            turnPassword : 'hgskSlGHgwSKfgsdUSDGhs',
            stunServer : 'turntaiwan.mvoipctsi.com',
            stunPort : '0',
            fromQRPage : this.props.route.params?.fromQRPage
        }
        */
        

            // console.debug('sipServer===',this.state.sipServer);
            // console.debug('sipPort=',this.state.sipPort);
            // console.debug('sipTransport=',this.state.sipTransport);
            // console.debug('sipUsername=',this.state.sipUsername);
            // console.debug('sipPassword=',this.state.sipPassword);
            // console.debug('iceEnabled=',this.state.iceEnabled);
            // console.debug('turnServer=',this.state.turnServer);
            // console.debug('turnPort=',this.state.turnPort);
            // console.debug('turnUsername=',this.state.turnUsername);
            // console.debug('turnPassword=',this.state.turnPassword);
            // console.debug('stunServer==',this.state.stunServer);
            // console.debug('stunPort=',this.state.stunPort);

        this.state.selectedIndex = 0;
        if(this.state.sipTransport == 'TCP'){
            this.state.selectedIndex = 0;
        }else if(this.state.sipTransport == 'UDP'){
            this.state.selectedIndex = 1;
        }else {
            this.state.selectedIndex = 2;
        }

        // if(this.state.fromQRPage == true){
        //     props.navigation.setOptions({ title: "Sip Settings" });
        //  }
      }

    setValues = () => {

        this.setState({sipServer : this.props.route.params?.sipServer})
        this.setState({sipPort : this.props.route.params?.sipPort})
        this.setState({sipTransport : this.props.route.params?.sipTransport})
        this.setState({sipUsername : this.props.route.params?.sipUsername})
        this.setState({sipPassword : this.props.route.params?.sipPassword})
        this.setState({iceEnabled : this.props.route.params?.iceEnabled})
        this.setState({turnServer : this.props.route.params?.turnServer})
        this.setState({turnPort : this.props.route.params?.turnPort})
        this.setState({turnUsername : this.props.route.params?.turnUsername})
        this.setState({turnPassword : this.props.route.params?.turnPassword})
        this.setState({stunServer : this.props.route.params?.stunServer})
        this.setState({stunPort : this.props.route.params?.stunPort})

        this.state.selectedIndex = 0;
        if(this.state.sipTransport == 'TCP'){
            this.state.selectedIndex = 0;
        }else if(this.state.sipTransport == 'UDP'){
            this.state.selectedIndex = 1;
        }else {
            this.state.selectedIndex = 2;
        }
    }

    onSipServerTextChange = (text) => {
        this.setState({sipServer : text});
    }

    onSipPortChanged = (text) => {
        this.setState({sipPort : text})
    }

    onPasswordChange = (text) => {
        this.setState({sipPassword : text})
    }

    onUsernameChanged = (text) => {
        this.setState({sipUsername : text})
    }

    onTURNHostChanged = (text) => {
        this.setState({ turnServer: text });
    }

    onTURNPortChanged = (text) => {
        this.setState({turnPort : text})
    }

    onTURNUsernameChanged = (text) => {
        this.setState({ turnUsername: textAlign });
    }

    onTURNPasswordChanged = (text) => {
        this.setState({ turnPassword: text });
    }

    onStunServerChanged = (text) => {
        this.setState({stunServer : text})
    }

    onStunPortChanged = (text) => {
        this.setState({stunPort : text})
    }

    toggleSwitch = (value) => {
        this.setState({iceEnabled : value})
        if(value == true){
            // Open TURN server container 
        }else{
            // Hide TURN server configurations
        }
    }

    setSegmentedControl = () => {
        this.state.selectedIndex = 0;
        if(this.state.sipTransport == 'TCP'){
            this.state.selectedIndex = 0;
        }else if(this.state.sipTransport == 'UDP'){
            this.state.selectedIndex = 1;
        }else {
            this.state.selectedIndex = 2;
        }
    }

    saveSIPInfo = () => {
       // alert(JSON.stringify(this.state))
       this.storeData()
    }

    storeData = async () => {
       
        try {

            console.debug('sipServer===',this.state.sipServer);
            console.debug('sipPort=',this.state.sipPort);
            console.debug('sipTransport=',this.state.sipTransport);
            console.debug('sipUsername=',this.state.sipUsername);
            console.debug('sipPassword=',this.state.sipPassword);
            console.debug('iceEnabled=',this.state.iceEnabled);
            console.debug('turnServer=',this.state.turnServer);
            console.debug('turnPort=',this.state.turnPort);
            console.debug('turnUsername=',this.state.turnUsername);
            console.debug('turnPassword=',this.state.turnPassword);
            console.debug('stunServer==',this.state.stunServer);
            console.debug('stunPort=',this.state.stunPort);

           /* if(this.state.sipServer == null) {
                this.state.sipServer = 'sandbox.mvoipctsi.com';
                this.setState({sipServer: 'sandbox.mvoipctsi.com'});
            }*/

            await AsyncStorage.setItem('sipServer', this.state.sipServer);
            await AsyncStorage.setItem('sipPort', this.state.sipPort + '');
            await AsyncStorage.setItem('sipTransport', this.state.sipTransport);
            await AsyncStorage.setItem('sipUsername', this.state.sipUsername);
            await AsyncStorage.setItem('sipPassword', this.state.sipPassword);
            await AsyncStorage.setItem('iceEnabled', this.state.iceEnabled == true ? 'true' : 'false');
            await AsyncStorage.setItem('turnServer', this.state.turnServer == "" ? " " : this.state.turnServer);
            await AsyncStorage.setItem('turnPort', "0");
            await AsyncStorage.setItem('turnUsername', this.state.turnUsername == "" ? " " : this.state.turnUsername);
            await AsyncStorage.setItem('turnPassword', this.state.turnPassword == "" ? " " : this.state.turnPassword);
            await AsyncStorage.setItem('stunServer', this.state.stunServer == "" ? " " : this.state.stunServer);
            await AsyncStorage.setItem('stunPort', "0");

            alert('Sip Settings saved successfully.');
            commonSipSettingFunc.getSipSettingsAndStart();
            this.props.navigation.push('PhonebookView');
          } catch (error) {
            // Error retrieving data
            console.debug('error.message', error.message);
          }
      }

      getSIPUserData = async () =>{
    
      
        try {
            const sipServer = await AsyncStorage.getItem('sipServer') ;
            this.state.sipServer = sipServer;

            const sipPort = await AsyncStorage.getItem('sipPort') ;
            this.state.sipPort = sipPort;

            const sipTransport = await AsyncStorage.getItem('sipTransport') ;
            this.state.sipTransport = sipTransport;
            this.setSegmentedControl()

            const sipUsername = await AsyncStorage.getItem('sipUsername') ;
            this.state.sipUsername = sipUsername;

            const sipPassword = await AsyncStorage.getItem('sipPassword') ;
            this.state.sipPassword = sipPassword;

            const iceEnabled = await AsyncStorage.getItem('iceEnabled') ;
            this.state.iceEnabled = iceEnabled == 'true' ? true : false;

            const turnServer = await AsyncStorage.getItem('turnServer');
            // if (turnServer == "-") {
            //   turnServer = "";
            // }
            this.state.turnServer = turnServer;

            const turnPort = await AsyncStorage.getItem('turnPort');
            // if (turnPort == "-") {
            //   turnPort = "";
            // }
            this.state.turnPort = turnPort;

            const turnUsername = await AsyncStorage.getItem('turnUsername');
            // if (turnUsername == "-") {
            //   turnUsername = "";
            // }
            this.state.turnUsername = turnUsername;

            const turnPassword = await AsyncStorage.getItem('turnPassword');
            // if (turnPassword == "-") {
            //   turnPassword = "";
            // }
            this.state.turnPassword = turnPassword;

            const stunServer = await AsyncStorage.getItem('stunServer');
            // if (stunServer == "-") {
            //   stunServer = "";
            // }
            this.state.stunServer = stunServer;

            const stunPort = await AsyncStorage.getItem('stunPort');
            // if (stunPort == "-") {
            //   stunPort = "";
            // }
            this.state.stunPort = stunPort;

           this.forceUpdate()

           commonSipSettingFunc.getSipSettingsAndStart();

          } catch (error) {
            // Error retrieving data
            console.debug('error.message', error.message);
          }

      }

    componentDidMount(){
       // this.getSIPUserData();
       /*if(this.state.sipServer == null || this.state.sipServer != "") {
        this.state.sipServer = 'sandbox.mvoipctsi.com';
        this.setState({sipServer: 'sandbox.mvoipctsi.com'});
    }*/
    }

    render(){
     
        
        return (
          <KeyboardAwareScrollView style={styles.container}>
            <InputContainer
              placeholder="Sip Server"
              title="SIP Server Host"
              keyBoardType="email-address"
              textValue={this.state.sipServer}
              onTextChange={this.onSipServerTextChange}
            />

            <InputContainer
              placeholder="Sip Port"
              title="Port"
              keyBoardType="number-pad"
              textValue={this.state.sipPort + ""}
              onTextChange={this.onSipPortChanged}
            />

            <SegmentedControl
              style={styles.segmentControl}
              values={["TCP", "UDP", "TLS"]}
              selectedIndex={this.state.selectedIndex}
              onChange={(event) => {
                if (event.nativeEvent.selectedSegmentIndex == 0) {
                  this.setState({ sipTransport: "TCP" });
                  this.setState({
                    selectedIndex: event.nativeEvent.selectedSegmentIndex,
                  });
                } else if (event.nativeEvent.selectedSegmentIndex == 1) {
                  this.setState({ sipTransport: "UDP" });
                  this.setState({
                    selectedIndex: event.nativeEvent.selectedSegmentIndex,
                  });
                } else {
                  this.setState({ sipTransport: "TLS" });
                  this.setState({
                    selectedIndex: event.nativeEvent.selectedSegmentIndex,
                  });
                }
                // this.setState({sipTransport: event.nativeEvent.selectedSegmentIndex == 0 ? 'TCP' : });
              }}
            />

            <InputContainer
              placeholder="username"
              title="SIP Username"
              keyBoardType="email-address"
              textValue={this.state.sipUsername}
              onTextChange={this.onUsernameChanged}
            />

            <InputContainer
              placeholder=" password"
              title="SIP Password"
              keyBoardType="email-address"
              textValue={this.state.sipPassword}
              onTextChange={this.onPasswordChange}
            />

            <View style={styles.switch_Container}>
              <Text style={styles.switchText}>Enable ICE </Text>
              <Switch
                trackColor={{ false: "#767577", true: "green" }}
                thumbColor={"white"}
                ios_backgroundColor="#3e3e3e"
                onValueChange={this.toggleSwitch}
                value={this.state.iceEnabled}
              />
            </View>

            {/* TURN container setup. Hide and show based on */}
            {this.state.iceEnabled ? (
              <View>
                <InputContainer
                  placeholder="TURN Host"
                  title="TURN Server"
                  keyBoardType="email-address"
                  textValue={this.state.turnServer}
                  onTextChange={this.onTURNHostChanged}
                />

                {/* <InputContainer
                            placeholder = 'Port'
                            title = 'TURN Port'
                            keyBoardType = 'number-pad'
                            textValue = {this.state.turnPort + ''}
                            onTextChange = {this.onTURNPortChanged}
                        /> */}

                <InputContainer
                  placeholder="Username"
                  title="TURN Username"
                  keyBoardType="email-address"
                  textValue={this.state.turnUsername}
                  onTextChange={this.onTURNUsernameChanged}
                />

                <InputContainer
                  placeholder=" Password"
                  title="TURN Password"
                  keyBoardType="email-address"
                  textValue={this.state.turnPassword}
                  onTextChange={this.onTURNPasswordChanged}
                />
              </View>
            ) : null}

            <InputContainer
              placeholder="url"
              title="STUN Server"
              keyBoardType="email-address"
              textValue={this.state.stunServer}
              onTextChange={this.onStunServerChanged}
            />

            {/* <InputContainer
                    placeholder = 'Port'
                    title = 'STUN Port'
                    keyBoardType = 'number-pad'
                    textValue = {this.state.stunPort + ''}
                    onTextChange = {this.onStunPortChanged}
                /> */}

            <TouchableOpacity
              style={styles.saveButton}
              onPress={() => this.saveSIPInfo()}
            >
              <Text style={styles.saveButtonText}> Save </Text>
            </TouchableOpacity>
          </KeyboardAwareScrollView>
        );
    }
}

const styles = StyleSheet.create({
    container  : {
        backgroundColor : 'lightgrey',
    },

    containerScrollView  : {
        backgroundColor : '#D3D3D3',
    },

    segmentControl : {
        marginTop : 20,
        marginHorizontal : 10
    },

    switch_Container : {
        flexDirection : 'row',
        marginTop : 15,
        alignItems: 'center'
    },

    switchText : {
        marginLeft : 15,
        marginRight : 25,
        fontWeight : 'bold',
        fontSize : 17,
    },

    saveButton : {
        alignSelf : 'center',
        marginVertical : 30,
        backgroundColor : 'blue',
        width : 100,
        height : 30,
    },

    saveButtonText:{
        color: 'white',
        textAlign : 'center',
        fontWeight : 'bold',
        fontSize : 20,
     },

     button: {
        alignItems: "center",
        backgroundColor: "#DDDDDD",
        padding: 10
      },

      imagestyle: {
        width : 30,
        height : 30, 
      }
});

export default getSipSettingsFromAPI;