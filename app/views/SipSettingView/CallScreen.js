import React from "react";
import {
  Text,
  ScrollView,
  StyleSheet,
  View,
  TextInput,
  TouchableOpacity,
  NativeModules,
  Image,
  Button,
  NativeEventEmitter,
  DeviceEventEmitter,
} from "react-native";
import InputContainer from "./InputContainer.js";
import speakerOn from "../../static/images/speakerOn.png";
import speakerOff from "../../static/images/speakerOff.png";
import muteOn from "../../static/images/muteOn.png";
import muteOff from "../../static/images/muteOff.png";
import call_0 from "../../static/images/call_0.png";
import call_1 from "../../static/images/call_1.png";
import call_2 from "../../static/images/call_2.png";
import call_3 from "../../static/images/call_3.png";
import call_4 from "../../static/images/call_4.png";
import call_5 from "../../static/images/call_5.png";
import call_6 from "../../static/images/call_6.png";
import call_7 from "../../static/images/call_7.png";
import call_8 from "../../static/images/call_8.png";
import call_9 from "../../static/images/call_9.png";
import call_pound from "../../static/images/call_pound.png";
import call_star from "../../static/images/call_star.png";
import calling_dailpad from "../../static/images/calling_dailpad.png";
import calling_end from "../../static/images/calling_end.png";
import dialling_close from "../../static/images/dialling_close.png";
import contact_avatar from "../../static/images/contact_avatar.png";
import CountUp from "react-native-countup-component";
import { min } from "lodash";
import commonSipSettingFunc from "./commonSipSettingFunc";
import call_0_3x from "../../static/images/call_0_1.png";
import call_1_3x from "../../static/images/call_1_1.png";
import call_2_3x from "../../static/images/call_2_1.png";
import call_3_3x from "../../static/images/call_3_1.png";
import call_4_3x from "../../static/images/call_4_1.png";
import call_5_3x from "../../static/images/call_5_1.png";
import call_6_3x from "../../static/images/call_6_1.png";
import call_7_3x from "../../static/images/call_7_1.png";
import call_8_3x from "../../static/images/call_8_1.png";
import call_9_3x from "../../static/images/call_9_1.png";
import call_pound_3x from "../../static/images/call_pound_d_1.png";
import call_star_3x from "../../static/images/call_star_d_1.png";
import { isIOS, isTablet } from "../../utils/deviceInfo";
const os = isIOS ? "ios" : "android";


/*
const onSessionConnect = (event) => {
    console.debug("onSessionConnect", event);
    console.debug("event call status", event.callStatus);
};
*/
const eventEmitter = new NativeEventEmitter(NativeModules.ModuleWithEmitter);
//eventEmitter.addListener('onSessionConnect', onSessionConnect);

class CallScreen extends React.Component {
  static navigationOptions = () => ({});

  constructor(props) {
    super(props);

    //13157244022
    this.state = {
      phoneNumber: props.route.params?.phoneNumber,
      isSpeakerOn: false,
      isMuteOn: false,
      keyPressed: "",
      counter: 0,
      timer: null,
      callStatusText: "calling",
      showKeypad: false,
      name: props.route.params?.name,
    };

    if (os == "android") {
      DeviceEventEmitter.addListener("onSessionConnect", this.getCallStatusAndroid);
    } else {
      eventEmitter.addListener("onSessionConnect", this.getCallStatus);
    }
  }

  componentWillUnmount() {
    clearInterval(this.state.timer);
  }

  componentDidMount() {
    if (this.state.phoneNumber != null) {
      this.makeCall();
    }
  }

  renderSpeakerImage = () => {
    var imgSource = this.state.isSpeakerOn ? speakerOn : speakerOff;
    if (os == "android") {
      NativeModules.Sdk.setOnSpeker(this.state.isSpeakerOn);
    } else {
      NativeModules.SIPSDKBridge.setSpeakerOn(this.state.isSpeakerOn);
    }
    return <Image style={styles.button1} source={imgSource} />;
  };

  renderMuteImage = () => {
    var imgSource = this.state.isMuteOn ? muteOn : muteOff;
    if (os == "android") {
      NativeModules.Sdk.muteUnmuteCall(this.state.isMuteOn);
    } else {
      NativeModules.SIPSDKBridge.setMuteOn(this.state.isMuteOn);
    }
    return <Image style={styles.button1} source={imgSource} />;
  };

  onTextChanged = (text) => {
    this.setState({ phoneNumber: text });
  };

  onKeyPressed = (item) => {
    this.setState({ keyPressed: this.state.keyPressed + item });
    if (os == "android") {
      NativeModules.Sdk.keyPressed(item);
    } else {
      NativeModules.SIPSDKBridge.keyPressed(item);
    }
  };

  makeCall = () => {
    commonSipSettingFunc.callFunc(this.state.phoneNumber);
  };

  setSpeaker = () => {
    let value = this.state.isSpeakerOn ? false : true;
    this.setState({ isSpeakerOn: value });
  };

  setMute = () => {
    let value = this.state.isMuteOn ? false : true;
    this.setState({ isMuteOn: value });
  };

  endCall = () => {
    this.props.navigation.pop();
    if (os == "android") {
      NativeModules.Sdk.endCall();
    } else {
      NativeModules.SIPSDKBridge.endCall();
    }
  };

  getCallStatusAndroid = (event) => {
    if (event == "ANSWERED") {
      this.startTimer();
    }
    if (event == "RINGING") {
      this.setState({ callStatusText: "Ringing" });
    }
    if (event == "TERMINATED") {
      this.setState({ callStatusText: "Call terminated" });
      this.endCall();
    }
    if (event == "DECLINED") {
      this.setState({ callStatusText: "Call declined" });
      this.endCall();
    }
  };

  getCallStatus = (event) => {
    if (event.callStatus == "ANSWERED") {
      this.startTimer();
    }
    if (event.callStatus == "RINGING") {
      this.setState({ callStatusText: "Ringing" });
    }
    if (event.callStatus == "TERMINATED") {
      this.setState({ callStatusText: "Call terminated" });
      this.endCall();
    }
    if (event.callStatus == "DECLINED") {
      this.setState({ callStatusText: "Call declined" });
      this.endCall();
    }
  };

  //Timer
  startTimer = () => {
    let timer = setInterval(this.manageTimer.bind(this), 1000);
    this.setState({ timer });
  };

  manageTimer = () => {
    this.setState({
      counter: this.state.counter + 1,
    });

    var hours = this.state.counter / 3600;
    var minutes = (this.state.counter % 3600) / 60;
    var seconds = this.state.counter % 60;

    hours = Math.floor(hours);
    hours = hours > 9 ? hours : "0" + hours;

    minutes = Math.floor(minutes);
    minutes = minutes > 9 ? minutes : "0" + minutes;

    seconds = Math.floor(seconds);
    seconds = seconds > 9 ? seconds : "0" + seconds;

    this.setState({ callStatusText: hours + ":" + minutes + ":" + seconds });
  };

  render() {
    return (
      <View style={{ padding: 10, flex: 1, backgroundColor: "white" }}>
        {/*
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
               
               */}

        <Image
          style={{
            width: 70,
            height: 70,
            alignSelf: "center",
            margin: 20,
            marginTop: 50,
            borderRadius: 70 / 2,
            borderWidth: 2,
            borderColor: "lightgrey",
          }}
          source={contact_avatar}
        />

        <Text style={{ textAlign: "center", fontSize: 28, marginBottom: 20 }}>
          {" "}
          {this.state.name == null ? this.state.phoneNumber : this.state.name}
        </Text>

        <View style={{ alignSelf: "center" }}>
          <Text style={{ textAlign: "center", fontSize: 16 }}>
            {this.state.callStatusText}
          </Text>
        </View>

        {this.state.showKeypad ? (
          <View>
            <Text style={{ textAlign: "center", fontSize: 18, marginTop: 30 }}>
              {" "}
              {this.state.keyPressed}{" "}
            </Text>

            <View style={{ flexDirection: "row", alignSelf: "center" }}>
              <TouchableOpacity
                style={styles.button2}
                onPress={() => this.onKeyPressed("1")}
              >
                <Image style={styles.button2} source={call_1_3x} />
              </TouchableOpacity>

              <TouchableOpacity
                style={styles.button2}
                onPress={() => this.onKeyPressed("2")}
              >
                <Image style={styles.button2} source={call_2_3x} />
              </TouchableOpacity>

              <TouchableOpacity
                style={styles.button2}
                onPress={() => this.onKeyPressed("3")}
              >
                <Image style={styles.button2} source={call_3_3x} />
              </TouchableOpacity>
            </View>

            <View style={{ flexDirection: "row", alignSelf: "center" }}>
              <TouchableOpacity
                style={styles.button2}
                onPress={() => this.onKeyPressed("4")}
              >
                <Image style={styles.button2} source={call_4_3x} />
              </TouchableOpacity>

              <TouchableOpacity
                style={styles.button2}
                onPress={() => this.onKeyPressed("5")}
              >
                <Image style={styles.button2} source={call_5_3x} />
              </TouchableOpacity>

              <TouchableOpacity
                style={styles.button2}
                onPress={() => this.onKeyPressed("6")}
              >
                <Image style={styles.button2} source={call_6_3x} />
              </TouchableOpacity>
            </View>

            <View style={{ flexDirection: "row", alignSelf: "center" }}>
              <TouchableOpacity
                style={styles.button2}
                onPress={() => this.onKeyPressed("7")}
              >
                <Image style={styles.button2} source={call_7_3x} />
              </TouchableOpacity>

              <TouchableOpacity
                style={styles.button2}
                onPress={() => this.onKeyPressed("8")}
              >
                <Image style={styles.button2} source={call_8_3x} />
              </TouchableOpacity>

              <TouchableOpacity
                style={styles.button2}
                onPress={() => this.onKeyPressed("9")}
              >
                <Image style={styles.button2} source={call_9_3x} />
              </TouchableOpacity>
            </View>

            <View style={{ flexDirection: "row", alignSelf: "center" }}>
              <TouchableOpacity
                style={styles.button2}
                onPress={() => this.onKeyPressed("*")}
              >
                <Image style={styles.button2} source={call_star_3x} />
              </TouchableOpacity>

              <TouchableOpacity
                style={styles.button2}
                onPress={() => this.onKeyPressed("0")}
              >
                <Image style={styles.button2} source={call_0_3x} />
              </TouchableOpacity>

              <TouchableOpacity
                style={styles.button2}
                onPress={() => this.onKeyPressed("#")}
              >
                <Image style={styles.button2} source={call_pound_3x} />
              </TouchableOpacity>
            </View>
          </View>
        ) : (
          <View style={{ flexDirection: "row", alignSelf: "center" }}>
            <TouchableOpacity
              style={styles.button1}
              onPress={() => this.setMute()}
            >
              {this.renderMuteImage()}
            </TouchableOpacity>

            <TouchableOpacity
              style={styles.button1}
              onPress={() => this.setState({ showKeypad: true })}
            >
              <Image style={styles.button1} source={calling_dailpad} />
            </TouchableOpacity>

            <TouchableOpacity
              style={styles.button1}
              onPress={() => this.setSpeaker()}
            >
              {this.renderSpeakerImage()}
            </TouchableOpacity>
          </View>
        )}

        <View style={styles.bottom}>
          <TouchableOpacity
            style={styles.button1}
            onPress={() => {
              this.state.showKeypad
                ? this.setState({ showKeypad: false })
                : null;
            }}
          >
            {this.state.showKeypad ? (
              <Image style={styles.button1} source={dialling_close} />
            ) : null}
          </TouchableOpacity>

          <TouchableOpacity
            style={styles.button1}
            onPress={() => this.endCall()}
          >
            <Image style={styles.button1} source={calling_end} />
          </TouchableOpacity>

          <TouchableOpacity
            style={styles.button1}
            onPress={() => console.debug("")}
          ></TouchableOpacity>
        </View>
      </View>
    );
  }
}

const styles = StyleSheet.create({
  container: {
    backgroundColor: "white",
  },

  containerScrollView: {
    backgroundColor: "#D3D3D3",
  },

  segmentControl: {
    marginTop: 20,
    marginHorizontal: 10,
  },

  switch_Container: {
    flexDirection: "row",
    marginTop: 15,
    alignItems: "center",
  },

  switchText: {
    marginLeft: 15,
    marginRight: 25,
    fontWeight: "bold",
    fontSize: 17,
  },

  saveButton: {
    alignSelf: "center",
    marginVertical: 30,
    backgroundColor: "blue",
    width: 100,
    height: 30,
  },

  saveButtonText: {
    color: "white",
    textAlign: "center",
    fontWeight: "bold",
    fontSize: 20,
  },

  button: {
    alignItems: "center",
    backgroundColor: "#DDDDDD",
    padding: 10,
  },

  button1: {
    width: 70,
    height: 70,
    alignSelf: "center",
    margin: 20,
  },

  button2: {
    width: 40,
    height: 40,
    alignSelf: "center",
    margin: 30,
  },

  call_end: {
    width: 70,
    height: 70,
    alignSelf: "center",
    margin: 20,
    bottom: 20,
  },

  imagestyle: {
    width: 30,
    height: 30,
  },

  bottom: {
    width: "100%",
    height: 70,
    justifyContent: "center",
    alignItems: "center",
    position: "absolute",
    bottom: 80,
    flexDirection: "row",
    alignSelf: "center",
  },
});

export default CallScreen;
