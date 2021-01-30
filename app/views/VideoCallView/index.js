import React, { Component } from "react";
import {
  Text,
  View,
  TouchableOpacity,
  StyleSheet,
  Image,
  Dimensions,
  Alert,
  ImageBackground,
  Button,
} from "react-native";
import styles from "./styles";
import I18n, { LANGUAGES, isRTL } from "../../i18n";
import callJitsi from '../../lib/methods/callJitsi';

//const { width } = Dimensions.get("window");

class VideoCallView extends React.Component {
  static navigationOptions = () => ({
    title: "Video Call",
  });

  static propTypes = {
		navigation: PropTypes.object,
		route: PropTypes.object
	}

  constructor(props) {
    super(props);
    console.debug('this.props', props);
    this.rid = props.route.params?.roomId;
    this.state = {};
    // this.state = {
    //   modalVisible: false,
    //   userSelected: [],
    // };
  }

  acceptCallPressed = () => {
    this.rid = this.props.route.params?.rid;
	  callJitsi(this.rid);
  };

  rejectCallPressed = () => {
    this.props.navigation.pop()
  };

  render() {
    return (
      <ImageBackground style={styles.background}>
        <View>
          <Image
            source={require("../../static/images/logo.png")}
            style={styles.logo}
          ></Image>
          <Text style={styles.text}>Incoming Video Call From Tushar</Text>
        </View>

        <View style={styles.container}>
          <View style={styles.buttonContainer}>
            <Button title="Reject" onPress={this.rejectCallPressed} />
          </View>
          <View style={styles.buttonContainer}>
            <Button title="Accept" onPress={this.acceptCallPressed} />
          </View>
        </View>
      </ImageBackground>
    );
  }
}

export default VideoCallView;
