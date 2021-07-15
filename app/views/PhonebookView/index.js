import React from "react";
import PropTypes from "prop-types";
import {
  View,
  ScrollView,
  Keyboard,
  Text,
  Alert,
  TouchableOpacity,
  Image,
  StyleSheet,
  ActivityIndicator,
  NativeModules,
} from "react-native";
import { connect } from "react-redux";
import prompt from "react-native-prompt-android";
import SHA256 from "js-sha256";
import ImagePicker from "react-native-image-crop-picker";
import RNPickerSelect from "react-native-picker-select";
import { isEqual, omit } from "lodash";

import Touch from "../../utils/touch";
import KeyboardView from "../../presentation/KeyboardView";
import sharedStyles from "../Styles";
import styles from "./styles";
import scrollPersistTaps from "../../utils/scrollPersistTaps";
import { showErrorAlert, showConfirmationAlert } from "../../utils/info";
import { LISTENER } from "../../containers/Toast";
import EventEmitter from "../../utils/events";
import RocketChat from "../../lib/rocketchat";
import RCTextInput from "../../containers/TextInput";
import log, { logEvent, events } from "../../utils/log";
import I18n from "../../i18n";
import Button from "../../containers/Button";
import Avatar from "../../containers/Avatar";
import { setUser as setUserAction } from "../../actions/login";
import { CustomIcon } from "../../lib/Icons";
import * as HeaderButton from "../../containers/HeaderButton";
import StatusBar from "../../containers/StatusBar";
import { themes } from "../../constants/colors";
import { withTheme } from "../../theme";
import { getUserSelector } from "../../selectors/login";
import SafeAreaView from "../../containers/SafeAreaView";
import * as Contacts from "expo-contacts";
import SectionListContacts from "react-native-sectionlist-contacts";
import SearchBox from "../../containers/SearchBox";
import call_1_3x from '../../static/images/dial.png';
import btn_back from '../../static/images/btn_back.png';
import left_arrow from '../../static/images/left-arrow.png';
import { StackActions, NavigationActions } from 'react-navigation';
import AsyncStorage from '@react-native-async-storage/async-storage';
import { BackHandler } from 'react-native';
import { isIOS, isTablet } from "../../utils/deviceInfo";
const os = isIOS ? "ios" : "android";
import commonSipSettingFunc from "../SipSettingView/commonSipSettingFunc";

class PhonebookView extends React.Component {
 
  static navigationOptions = ({ navigation }) => {
    const options = {
      title: "Phonebook",
    };

    options.headerLeft = () => (
      <TouchableOpacity
        style={{ width: 40, height: 20, marginLeft: 10 }}
        onPress={() => {
          navigation.navigate("RoomsListView");
        }}
      >
        <Image
          style={{ width: 40, height: 20, resizeMode: "contain" }}
          source={left_arrow}
        />
      </TouchableOpacity>
    );

    options.headerRight = () => (
      <TouchableOpacity
        style={phonebookstyle.button2}
        onPress={() => navigation.navigate("KeypadView")}
      >
        <Image style={phonebookstyle.button2} source={call_1_3x} />
      </TouchableOpacity>
    );

    return options;
  };

  static propTypes = {
    baseUrl: PropTypes.string,
    user: PropTypes.object,
  };

  constructor(props) {
    super(props);

    let nameData = [];
    this.state = {
      dataArray: nameData,
      searchText: "",
      searchArray: [],
    };
  }

  async componentDidMount() {
    const resetAction = StackActions.reset({
      index: 0,
      actions: [NavigationActions.navigate({ routeName: "PhonebookView" })],
    });
    this.props.navigation.dispatch(resetAction);

    this.fetchContactsAsync();
  }

  fetchContactsAsync = async () => {
    let dataArray = [];
    const { status } = await Contacts.requestPermissionsAsync();
    if (status === "granted") {
      const { data } = await Contacts.getContactsAsync({
        fields: [Contacts.Fields.Name],
        fields: [Contacts.Fields.PhoneNumbers],
      });

      if (data.length > 0) {
        data.map((item) => {
          if (item != null && item.name != null) {
            if (item.phoneNumbers != null && item.phoneNumbers[0] != null) 
              dataArray.push({
                name: item.name,
                number: item.phoneNumbers[0].number,
              });
          }
          return;
        });
        this.setState({ dataArray: dataArray });
      }
      this.forceUpdate();
    }

    if (os == "android") {
      NativeModules.Sdk.askStorageAndMicPermission();
    }


  };

  componentWillReceiveProps() {
    this.setState({ searchArray: [] });
  }

  onChangeSearchText = (e) => {
    let text = e.toLowerCase();
    let trucks = this.state.dataArray;
    let filteredName = trucks.filter((item) => {
      return item.name.toLowerCase().match(text);
    });
    if (!text || text === "") {
      this.setState({
        searchArray: [],
      });
    } else if (!Array.isArray(filteredName) && !filteredName.length) {
      // set no data flag to true so as to render flatlist conditionally
      this.setState({
        searchArray: [],
      });
    } else if (Array.isArray(filteredName)) {
      this.setState({
        searchArray: filteredName,
      });
    }
  };

  render() {
    let resultArray = [];
    const { server, isMasterDetail, theme } = this.props;
    if (this.state.searchArray.length > 0) {
      resultArray = this.state.searchArray;
    } else {
      resultArray = this.state.dataArray;
    }
    return (
      <SafeAreaView testID="settings-view" theme={theme}>
        <StatusBar theme={theme} />
        <ScrollView
          {...scrollPersistTaps}
          contentContainerStyle={styles.listPadding}
          showsVerticalScrollIndicator={false}
          testID="settings-view-list"
        >
          <View style={styles.contactTitleText}>
            <SearchBox
              onChangeText={(e) => this.onChangeSearchText(e)}
              hasCancel={false}
            />
            <SectionListContacts
              ref={(s) => (this.sectionList = s)}
              sectionListData={resultArray}
              sectionHeight={50}
              showsVerticalScrollIndicator={false}
              renderHeader={this._renderHeader}
              SectionListClickCallback={(item, index) => {
    
    
                var no = item.number;
                no = no.replace("*", "");
                no = no.replace("#", "");
                no = no.replace(" ", "");
                no = no.replace("+", "");
                no = no.replace("(", "");
                no = no.replace(")", "");

                if (no.indexOf("*") >= 0) {
                  no = no.replace("*", "");
                }
                if (no.indexOf("#") >= 0) {
                  no = no.replace("#", "");
                }
                if (no.indexOf(" ") >= 0) {
                  no = no.replace(" ", "");
                }
                if (no.indexOf("+") >= 0) {
                  no = no.replace("+", "");
                }
                if (no.indexOf("(") >= 0) {
                  no = no.replace("(", "");
                }
                if (no.indexOf(")") >= 0) {
                  no = no.replace(")", "");
                }
                if (no.indexOf("-") >= 0) {
                  no = no.replace("-", "");
                }

                this.props.navigation.navigate("CallScreen", {
                  phoneNumber: no,
                  name: item.name,
                  popParam: "1",
                });
              }}
              otherAlphabet="#"
            />
            <ActivityIndicator size="large" color="#000000" />
          </View>
        </ScrollView>
      </SafeAreaView>
    );
  }
}

_renderHeader = (params) => {
  console.log("---custom-renderHeader--", params);
  return (
    <View>
      <Text style={styles.headerTitleText}>{params.key}</Text>
    </View>
  );
};

const mapStateToProps = (state) => ({
  user: getUserSelector(state),
});

const mapDispatchToProps = (dispatch) => ({
  setUser: (params) => dispatch(setUserAction(params)),
});

export default connect(
  mapStateToProps,
  mapDispatchToProps
)(withTheme(PhonebookView));



const phonebookstyle = StyleSheet.create({
  container: {
    flex: 1,
    justifyContent: "center",
    alignItems: "center",
  },

  button2: {
    width: 30,
    height: 30,
    resizeMode: "contain",
    marginRight: 20,
  },
});