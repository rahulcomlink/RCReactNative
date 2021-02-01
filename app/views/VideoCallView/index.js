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
const Sound = require('react-native-sound')
import { Platform } from 'react-native';
//import Sound from 'react-native-sound';


//const { width } = Dimensions.get("window");

class VideoCallView extends React.Component {
  static navigationOptions = () => ({
    title: "Video Call",
  });

  static propTypes = {
		navigation: PropTypes.object,
		route: PropTypes.object
  }


  componentDidMount(){
    this.handlePress();
   
  }

  handlePress = async() => {
    this.hello.play((success) => {
      if (!success) {
        console.log('Sound did not play')
      }
    })
  }

  componentDidUpdate(){
    this.handlePress.bind(this)
  }

  componentWillUpdate(){
    this.handlePress.bind(this)
  }
  
  
  

  constructor(props) {
    super(props);
    console.debug('this.props', props);
    this.rid = props.route.params?.roomId;
    this.name =  props.route.params?.username;
    this.state = {
    };
   
  }

  acceptCallPressed = () => {
    this.rid = this.props.route.params?.roomId;
    this.props.navigation.pop()
	  callJitsi(this.rid);
  };

  rejectCallPressed = () => {
    this.props.navigation.pop()
  };

 
  render() {

    const mainBundle = Platform.OS === 'ios'
    ? encodeURIComponent(Sound.MAIN_BUNDLE)
    : Sound.MAIN_BUNDLE;
    this.hello = new Sound('tring_tring_tring.mp3', mainBundle, (error) => {
      if (error) {
        console.log('failed to load the sound', error);
        return;
      }
    });

    return (
      <View style={{ flex: 1 }}>
        <View style={styles.topBar}>
          <Text style={styles.title}>{this.props.route.params?.username}</Text>
          <Text style={styles.subText}>Incoming Video Call</Text>
        </View>

        <Image
          style={[styles.image]}
          source={require("../../static/images/logo.png")}
        />
        <View style={styles.bottomBar}>
          <TouchableOpacity
            style={[styles.btnActionEnd, styles.shadow]}
            onPress={() => this.rejectCallPressed()}
          >
            <Image
              style={styles.iconImg}
              source={require("../../static/images/call_end.png")}
            />
          </TouchableOpacity>

          <TouchableOpacity
            style={[styles.btnActionAccept, styles.shadow]}
            onPress={() => this.acceptCallPressed()}
          >
            <Image
              style={styles.iconImgAnswer}
              source={require("../../static/images/answer_call.png")}
            />
          </TouchableOpacity>

          {this.handlePress.bind(this)}

          <TouchableOpacity onPress={this.handlePress.bind(this)}>
                <View>
                      <Text>Start</Text>
                </View>
            </TouchableOpacity>
        </View>
      </View>
    );
  }
}

export default VideoCallView;