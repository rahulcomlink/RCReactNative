import React, { useState } from 'react';
import DeviceInfo from 'react-native-device-info';
import  {
    AppRegistry,
    Component,
    StyleSheet,
    Text,
    View,
    StatusBarIOS,
    PixelRatio,
    TouchableOpacity,
    Image
  } from 'react-native';
import * as HeaderButton from '../../containers/HeaderButton';
import call_0_3x from '../../static/images/call_0_1.png';
import call_1_3x from '../../static/images/call_1_1.png';
import call_2_3x from '../../static/images/call_2_1.png';
import call_3_3x from '../../static/images/call_3_1.png';
import call_4_3x from '../../static/images/call_4_1.png';
import call_5_3x from '../../static/images/call_5_1.png';
import call_6_3x from '../../static/images/call_6_1.png';
import call_7_3x from '../../static/images/call_7_1.png';
import call_8_3x from '../../static/images/call_8_1.png';
import call_9_3x from '../../static/images/call_9_1.png';
import call_pound_3x from '../../static/images/call_pound_d_1.png';
import call_star_3x from '../../static/images/call_star_d_1.png';
import calling_start from '../../static/images/calling_start.png';
import call_back from '../../static/images/call_back.png';

import { CountrySelection } from 'react-native-country-list';

class KeypadView extends React.Component {

  
  static navigationOptions = ({ navigation, isMasterDetail }) => ({
		headerLeft: () => (isMasterDetail ? (
			<HeaderButton.CloseModal navigation={navigation} testID='keypad-view-close' />
		) : (
			<HeaderButton.Drawer navigation={navigation} testID='keypad-view-drawer' />
		)),
		 title: ''
  });
 
    constructor(props){ 
        super(props);
       
        this.state = {
          keyPressed : '',
          selectedCC : '+1'
        };
    }

    onKeyPressed = (item) => {
      this.setState({ keyPressed: this.state.keyPressed + item })
  }
  

    call = () => {
      if(this.state.keyPressed == null){

      }else {
        var cc =  this.state.selectedCC.replace('+','')
        var key =  this.state.keyPressed
        key  = key.replace('*','')
        key  = key.replace('#','')
        this.props.navigation.push('CallScreen', {
          phoneNumber : cc + key,
       });
      }
    }

    removeChar = () => {
      if(this.state.keyPressed != null){
        this.setState({ keyPressed: this.state.keyPressed.slice(0,-1)})
      }
    }

    goToNextScreen = () => {
      this.props.navigation.push("SelectCountryCode", { onSelect: this.getCountryCode });
    }

    getCountryCode = (cc) => {
      console.debug('cc = ',cc.selected.callingCode);
      this.setState({ selectedCC: '+' + cc.selected.callingCode})
    }


    render() {
        return (
         <View style={{padding: 10, flex : 1, backgroundColor : 'white'}}>
           
          
           <View style={{backgroundColor : 'white'}}>
               <View style={{flexDirection: 'row', height:50 , marginTop : 30, marginBottom : 30, marginRight : 20}}>
               <TouchableOpacity style={{ marginLeft : 10, marginRight : 10, height :  50}} 
                        onPress= {()=> this.goToNextScreen()} >  
                        <Text style = {{textAlign : 'center', fontSize : 36, height : 50}}>{this.state.selectedCC} </Text>
                </TouchableOpacity>
                <Text style = {{textAlign : 'center', fontSize : 36, height : 50,  marginRight : 20 }}> {this.state.keyPressed} </Text>
               </View>

               <View style={{flexDirection: 'row', alignSelf: 'center'}}>

               <TouchableOpacity style={styles.button2} 
                        onPress= {()=> this.onKeyPressed('1')} >  
                        <Image style = {styles.button2} source = {call_1_3x}/>   
                </TouchableOpacity>

               <TouchableOpacity style={styles.button2}  
                    onPress= {()=> this.onKeyPressed('2')}>  
                    <Image style = {styles.button2} source = {call_2_3x}/>   
               </TouchableOpacity>

               <TouchableOpacity style={styles.button2}  
               onPress= {()=> this.onKeyPressed('3')}>
                    <Image style = {styles.button2} source = {call_3_3x}/>  
                 </TouchableOpacity>
               </View>

               <View style={{flexDirection: 'row', alignSelf: 'center'}}>
               <TouchableOpacity style={styles.button2}  
                 onPress= {()=> this.onKeyPressed('4')}>
                    <Image style = {styles.button2} source = {call_4_3x}/>   
                </TouchableOpacity>

               <TouchableOpacity style={styles.button2}  
                    onPress= {()=> this.onKeyPressed('5')}>
                        <Image style = {styles.button2} source = {call_5_3x}/>  
                 </TouchableOpacity>


               <TouchableOpacity style={styles.button2} 
                    onPress= {()=> this.onKeyPressed('6')}>
                     <Image style = {styles.button2} source = {call_6_3x}/>  
                 </TouchableOpacity>
               </View>

               <View style={{flexDirection: 'row', alignSelf: 'center'}}>
               <TouchableOpacity style={styles.button2}  
                    onPress= {()=> this.onKeyPressed('7')}>
                    <Image style = {styles.button2} source = {call_7_3x}/>   
                </TouchableOpacity>

               <TouchableOpacity style={styles.button2}  
                    onPress= {()=> this.onKeyPressed('8')}>
                        <Image style = {styles.button2} source = {call_8_3x}/>  
                 </TouchableOpacity>


               <TouchableOpacity style={styles.button2} 
                onPress= {()=> this.onKeyPressed('9')}>
                     <Image style = {styles.button2} source = {call_9_3x}/>  
                 </TouchableOpacity>
               </View>

               <View style={{flexDirection: 'row', alignSelf: 'center'}}>
               <TouchableOpacity style={styles.button2}  
                 onPress= {()=> this.onKeyPressed('*')}>
                    <Image style = {styles.button2} source = {call_star_3x}/>   
                </TouchableOpacity>

               <TouchableOpacity style={styles.button2}  
                    onPress= {()=> this.onKeyPressed('0')}>
                        <Image style = {styles.button2} source = {call_0_3x}/>  
                 </TouchableOpacity>


               <TouchableOpacity style={styles.button2} 
                onPress= {()=> this.onKeyPressed('#')}>
                     <Image style = {styles.button2} source = {call_pound_3x}/>  
                 </TouchableOpacity>
               </View>
               </View>

               <View style = {styles.bottom}>
               <TouchableOpacity style={styles.button1} 
                    onPress = {
                        () => console.debug('')
                      }>  
                </TouchableOpacity>
               <TouchableOpacity style={styles.button1} 
                    onPress = {
                        () => this.call()
                      }>  
                    <Image style={styles.button1} source={ calling_start } />
                </TouchableOpacity>
                <TouchableOpacity style={styles.button1} 
                    onPress = {
                        () => this.removeChar()
                      }>  
                    <Image style={styles.button1}  source={ call_back }  />
                </TouchableOpacity>
               </View>
               
         </View>
        );
      }
}
export default KeypadView;


const styles = StyleSheet.create({
    container: {
      flex: 1,
      justifyContent: 'center',
      alignItems: 'center'
    },
    welcome: {
      fontSize: 20,
      textAlign: 'center',
      margin: 10,
    },
    instructions: {
      fontSize: 12,
      textAlign: 'center',
      color: '#888',
      marginBottom: 5,
    },
    data: {
      padding: 15,
      marginTop: 10,
      backgroundColor: '#ddd',
      borderColor: '#888',
      borderWidth: 1 / PixelRatio.get(),
      color: '#777'
    },
    button2: {
      width : 55,
      height : 55,
      alignSelf : 'center',
      margin: 30,
      resizeMode : 'center'
   },
   button1: {
    width : 80,
    height : 80,
    alignSelf : 'center',
    margin: 20,
    resizeMode : 'center'
 },
 bottom: {
  width: '100%', 
  height: 80, 
  justifyContent: 'center', 
  alignItems: 'center',
  position: 'absolute',
  bottom: 80,
  flexDirection: 'row',
  alignSelf : 'center',
  backgroundColor : 'white'
}

  });