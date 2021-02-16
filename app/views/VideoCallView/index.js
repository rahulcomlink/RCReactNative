import React from "react";
 import PropTypes from "prop-types";		
import {
   StyleSheet,		
   Text,		
   View,		  		
   TouchableOpacity,		 	
   Image,
   Dimensions,
   Alert,		  
   ImageBackground,
   Button,
 } from "react-native";
import styles from "./styles";
import I18n, { LANGUAGES, isRTL } from "../../i18n";
import callJitsi from '../../lib/methods/callJitsi';
import { Platform } from 'react-native';
import Sound from 'react-native-sound';


//const { width } = Dimensions.get("window");

const mainBundle = Platform.OS === 'ios'
    ? encodeURIComponent(Sound.MAIN_BUNDLE)
    : Sound.MAIN_BUNDLE;
    Sound.setCategory('Playback', true)
    const sound = new Sound(
      'tring_tring_tring.mp3',
      mainBundle,
      error => {
        if (error) {
          //alert(error)
          console.debug("sound", error);
          return;
        }else{
         // alert('Play Sound')
          //sound.play(() => sound.release());
        }
      }
    );

class VideoCallView extends React.Component {
  static navigationOptions = () => ({
    headerShown: false,
  });

  static propTypes = {
		navigation: PropTypes.object,
		route: PropTypes.object
  }

  
  
  
  componentDidMount(){
    console.debug('componentDidMount()');
    this.playSound()

    // setTimeout(function(){
    //   this.handlePress()
    // },5000);   
  }

  handlePress = async() => {
    this.hello.play((success) => {
      if (!success) {
        console.log('Sound did not play')
      }
    })
  }

  playSound = () => {
    // const mainBundle = Platform.OS === 'ios'
    // ? encodeURIComponent(Sound.MAIN_BUNDLE)
    // : Sound.MAIN_BUNDLE;
    // Sound.setCategory('Playback', true)
    // const sound = new Sound(
    //   'tring_tring_tring.mp3',
    //   mainBundle,
    //   error => {
    //     if (error) {
    //       //alert(error)
    //       console.debug("sound", error);
    //       return;
    //     }else{
    //      // alert('Play Sound')
    //       sound.play(() => sound.release());
    //     }
    //   }
    // );
     // The play dispatcher
    sound.play();
  }

  componentDidUpdate(){
    //this.handlePress.bind(this)
  }

  componentWillUpdate(){
    //this.handlePress.bind(this)
  }

  componentWillUnmount(){
    sound.stop()
    //sound.stop(() => sound.release());
  }
  constructor(props) {
    super(props);
    console.debug('this.props', props);
    this.rid = props.route.params?.roomId;
    console.debug('getting rid from video view', this.rid);
    this.name =  props.route.params?.username;
    this.state = {
    };
   
  }

  acceptCallPressed = () => {
    this.rid = this.props.route.params?.roomId;
    callJitsi(this.rid);
    this.props.navigation.pop()
  };

  rejectCallPressed = () => {
    this.props.navigation.pop()
  };

  render() {

    return (
      <View style={{ flex: 1 }}>
        <View style={styles.topBar}>
          <Text style={styles.title}>{this.props.route.params?.username}</Text>
          <Text style={styles.subText}>Incoming Call</Text>
        </View>

        <Image
          style={[styles.image]}
          source={require("../../static/images/logo.png")}
        />

        <View style={styles.bottomBar}>
          <TouchableOpacity
            style={[styles.btnActionEnd]}
            onPress={() => this.rejectCallPressed()}
          >
            <Image
              style={styles.iconImg}
              source={require("../../static/images/call_end.png")}
            />
          </TouchableOpacity>

          <TouchableOpacity
            style={[styles.btnActionAccept]}
            onPress={() => this.acceptCallPressed()}
          >
            <Image
              style={styles.iconImgAnswer}
              source={require("../../static/images/answer_call.png")}
            />
          </TouchableOpacity>
        </View>
      </View>
    );
  }
}

export default VideoCallView;