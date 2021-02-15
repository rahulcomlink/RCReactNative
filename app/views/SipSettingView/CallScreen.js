import React from 'react';
import {
	Text, ScrollView, StyleSheet, View, TextInput, TouchableOpacity, NativeModules, Image, Button, NativeEventEmitter
} from 'react-native';
import InputContainer from './InputContainer.js';
import speakerOn from '../../static/images/speakerOn.png';
import speakerOff from '../../static/images/speakerOff.png';
import muteOn from '../../static/images/muteOn.png';
import muteOff from '../../static/images/muteOff.png';
import call_0 from '../../static/images/call_0.png';
import call_1 from '../../static/images/call_1.png';
import call_2 from '../../static/images/call_2.png';
import call_3 from '../../static/images/call_3.png';
import call_4 from '../../static/images/call_4.png';
import call_5 from '../../static/images/call_5.png';
import call_6 from '../../static/images/call_6.png';
import call_7 from '../../static/images/call_7.png';
import call_8 from '../../static/images/call_8.png';
import call_9 from '../../static/images/call_9.png';
import call_pound from '../../static/images/call_pound.png';
import call_star from '../../static/images/call_star.png';
import calling_dailpad from '../../static/images/calling_dailpad.png';
import CountUp from 'react-native-countup-component';
import { min } from 'lodash';
import commonSipSettingFunc from './commonSipSettingFunc';

/*
const onSessionConnect = (event) => {
    console.debug("onSessionConnect", event);
    console.debug("event call status", event.callStatus);
};
*/
 const eventEmitter = new NativeEventEmitter(NativeModules.ModuleWithEmitter);
 //eventEmitter.addListener('onSessionConnect', onSessionConnect);

class CallScreen extends React.Component {

    constructor(props) {
        super(props);

        this.state =  {
            phoneNumber : '13157244022',
            isSpeakerOn : false,
            isMuteOn : false,
            keyPressed : '',
            counter: 0,
            timer: null,
            callStatusText: 'calling'
        }

        eventEmitter.addListener('onSessionConnect', this.getCallStatus);
    }

    componentWillUnmount() {
        clearInterval(this.state.timer);
    }

     renderSpeakerImage = () => {
        var imgSource = this.state.isSpeakerOn? speakerOn : speakerOff;
        NativeModules.SIPSDKBridge.setSpeakerOn(this.state.isSpeakerOn)
        return (
          <Image
            style={styles.button1 }
            source={ imgSource }
          />
        );
    }

    renderMuteImage = () => {
        var imgSource = this.state.isMuteOn? muteOn : muteOff;
        NativeModules.SIPSDKBridge.setMuteOn(this.state.isMuteOn)
        return (
          <Image
            style={styles.button1 }
            source={ imgSource }
          />
        );
    }

    onTextChanged = (text) => {
        this.setState({phoneNumber : text})
    }

    onKeyPressed = (item) => {
        this.setState({ keyPressed: this.state.keyPressed + item })
        NativeModules.SIPSDKBridge.keyPressed(item)
    }

    makeCall = () => {
        commonSipSettingFunc.callFunc(this.state.phoneNumber);
       // NativeModules.SIPSDKBridge.makeCall(this.state.phoneNumber)
    }

    setSpeaker = () => {
        let value = this.state.isSpeakerOn ? false : true
        this.setState({ isSpeakerOn: value })
    }

    setMute = () => {
        let value = this.state.isMuteOn ? false : true
        this.setState({ isMuteOn: value })
    }

    endCall = () => {
		this.props.navigation.goBack()
        NativeModules.SIPSDKBridge.endCall()
    }

    getCallStatus = (event) => {
        if(event.callStatus == 'ANSWERED'){
             this.startTimer()
        }
        if(event.callStatus == 'RINGING'){
            this.setState({ callStatusText : 'Ringing' });
        }
        if(event.callStatus == 'TERMINATED'){
            //this.endCall()
            this.setState({ callStatusText : 'Call terminated'});
            this.startTimer()
        }
        if(event.callStatus == 'DECLINED'){
            this.setState({ callStatusText : 'Call declined'});
            this.endCall()
        }
     }

    //Timer
    startTimer = () => {
        let timer = setInterval(this.manageTimer.bind(this), 1000);
        this.setState({ timer });
    }

    manageTimer = () => {
        this.setState({
            counter: this.state.counter + 1
          });

          var hours = this.state.counter/3600;
          var minutes = (this.state.counter%3600)/60;
          var seconds = this.state.counter%60;
          this.setState({ callStatusText : Math.floor(hours) + ':' +  Math.floor(minutes) + ':'  + Math.floor(seconds) });
    }


    render(){
        return(
            <View style={{padding: 10}}>
                <InputContainer
                    placeholder = 'Dial Number'
                    title = 'Dial Number'
                    keyBoardType = 'number-pad'
                    textValue = {this.state.phoneNumber}
                    onTextChange = {this.onTextChanged}
                />

               <TouchableOpacity style = {styles.saveButton}
                    onPress = {
                        () => this.makeCall()
                }>  
                <Text style = {styles.saveButtonText}> Dial Call </Text>
               </TouchableOpacity>

               <View style={{ alignSelf : 'center'}}>
                    <Text style={{ textAlign: 'center' , fontSize : 18}}>{this.state.callStatusText}</Text>
               </View>

               <View style={{flexDirection: 'row', alignSelf: 'center'}}>
                <TouchableOpacity style={styles.button1} 
                    onPress = {
                        () =>  this.setMute()
                      }> 
                    {this.renderMuteImage()}
                </TouchableOpacity>

                <TouchableOpacity style={styles.button1} 
                    onPress = {
                        () =>  this.setSpeaker()
                      }>  
                    <Image style={styles.button1} source={ calling_dailpad } />
                </TouchableOpacity>

                <TouchableOpacity style={styles.button1} 
                    onPress = {
                        () =>  this.setSpeaker()
                      }> 
                {this.renderSpeakerImage()}
                </TouchableOpacity>
                </View>


               <TouchableOpacity style = {styles.saveButton}
                    onPress = {
                        () => this.endCall()
                }>  
                <Text style = {styles.saveButtonText}> End Call </Text>
               </TouchableOpacity>

               <Text style = {{textAlign : 'center', fontSize : 25}} > {this.state.keyPressed} </Text>

               <View style={{flexDirection: 'row', alignSelf: 'center'}}>

               <TouchableOpacity style={styles.button1} 
                        onPress= {()=> this.onKeyPressed('1')} >  
                        <Image style = {styles.button1} source = {call_1}/>   
                </TouchableOpacity>

               <TouchableOpacity style={styles.button1}  
                    onPress= {()=> this.onKeyPressed('2')}>  
                    <Image style = {styles.button1} source = {call_2}/>   
               </TouchableOpacity>

               <TouchableOpacity style={styles.button1}  
               onPress= {()=> this.onKeyPressed('3')}>
                    <Image style = {styles.button1} source = {call_3}/>  
                 </TouchableOpacity>
               </View>

               <View style={{flexDirection: 'row', alignSelf: 'center'}}>
               <TouchableOpacity style={styles.button1}  
                 onPress= {()=> this.onKeyPressed('4')}>
                    <Image style = {styles.button1} source = {call_4}/>   
                </TouchableOpacity>

               <TouchableOpacity style={styles.button1}  
                    onPress= {()=> this.onKeyPressed('5')}>
                        <Image style = {styles.button1} source = {call_5}/>  
                 </TouchableOpacity>


               <TouchableOpacity style={styles.button1} 
                    onPress= {()=> this.onKeyPressed('6')}>
                     <Image style = {styles.button1} source = {call_6}/>  
                 </TouchableOpacity>
               </View>

               <View style={{flexDirection: 'row', alignSelf: 'center'}}>
               <TouchableOpacity style={styles.button1}  
                    onPress= {()=> this.onKeyPressed('7')}>
                    <Image style = {styles.button1} source = {call_7}/>   
                </TouchableOpacity>

               <TouchableOpacity style={styles.button1}  
                    onPress= {()=> this.onKeyPressed('8')}>
                        <Image style = {styles.button1} source = {call_8}/>  
                 </TouchableOpacity>


               <TouchableOpacity style={styles.button1} 
                onPress= {()=> this.onKeyPressed('9')}>
                     <Image style = {styles.button1} source = {call_9}/>  
                 </TouchableOpacity>
               </View>

               <View style={{flexDirection: 'row', alignSelf: 'center'}}>
               <TouchableOpacity style={styles.button1}  
                 onPress= {()=> this.onKeyPressed('*')}>
                    <Image style = {styles.button1} source = {call_star}/>   
                </TouchableOpacity>

               <TouchableOpacity style={styles.button1}  
                    onPress= {()=> this.onKeyPressed('0')}>
                        <Image style = {styles.button1} source = {call_0}/>  
                 </TouchableOpacity>


               <TouchableOpacity style={styles.button1} 
                onPress= {()=> this.onKeyPressed('#')}>
                     <Image style = {styles.button1} source = {call_pound}/>  
                 </TouchableOpacity>
               </View>

            </View>
        );
    }

}

const styles = StyleSheet.create({
    container  : {
        backgroundColor : 'white',
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

      button1: {
        width : 70,
        height : 70,
        alignSelf : 'center',
        margin: 20,
        
      },

      imagestyle: {
        width : 30,
        height : 30, 
      }
});

export default CallScreen;