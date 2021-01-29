import React from "react";
import PropTypes from "prop-types";
import {
  StyleSheet,
  Text,
  View,
  ImageBackground,
  Image,
  TouchableOpacity,
  Button,
  Alert,
} from "react-native";
import styles from "./styles";
import I18n, { LANGUAGES, isRTL } from "../../i18n";

class VideoCallView extends React.Component {
  static navigationOptions = () => ({
    title: "Video Call",
  });

  constructor(props) {
    super(props);
    this.state = {};
  }

  acceptCallPressed = () => {
	  Alert.alert("Call Accepted");
	  callJitsi("Paas room_Id here");
  };

  rejectCallPressed = () => {
    Alert.alert("Call Rejected");
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
