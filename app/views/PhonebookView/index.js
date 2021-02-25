import React from "react";
import PropTypes from "prop-types";
import { View, ScrollView, Keyboard, Text, Alert, TouchableOpacity, Image, StyleSheet } from "react-native";
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
import { StackActions, NavigationActions } from 'react-navigation';
import AsyncStorage from '@react-native-async-storage/async-storage';
import { BackHandler } from 'react-native';

class PhonebookView extends React.Component {
  // static navigationOptions = ({ navigation, isMasterDetail }) => {
  //   const options = {
  //     title: I18n.t("Phonebook"),
  //   };
  //   if (!isMasterDetail) {
  //     options.headerLeft = () => (
  //       <HeaderButton.Drawer navigation={navigation} />
  //     );
  //   }
  //   return options;
  // };

   static navigationOptions = ({ navigation }) => {
    const options = {
      title: "Phonebook",
    };

    options.headerLeft = () => (
      <TouchableOpacity style= {{width : 40, height : 20, marginLeft : 20}}
      onPress= {()=> 
        { navigation.navigate('RoomsListView'); }
      } >  
      <Image style= {{width : 10, height : 20 , resizeMode : 'center', }}  source = {btn_back}/>     
      </TouchableOpacity>
    );
    
      options.headerRight = () => (
        <TouchableOpacity style={phonebookstyle.button2} 
        onPress= {()=> navigation.navigate('KeypadView')} >  
        <Image style={phonebookstyle.button2}  source = {call_1_3x}/>   
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

    //name字段必须,其他可有可无
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
      actions: [NavigationActions.navigate({ routeName: 'PhonebookView' })],
    });
    this.props.navigation.dispatch(resetAction)

    const { status } = await Contacts.requestPermissionsAsync();
    if (status === "granted") {
      const { data } = await Contacts.getContactsAsync({
        fields: [Contacts.Fields.Name],
        fields: [Contacts.Fields.PhoneNumbers],
      });

      if (data.length > 0) {
        for (var i = 0; i < data.length; i++) {
          const contact = data[i];
          if (contact != null && contact.name != null) {
            if (contact.phoneNumbers != null && contact.phoneNumbers[0] != null) { 
            this.state.dataArray.push({
              name: contact.name,
              number: contact.phoneNumbers[0].number,
            });
          }
          }
        }
      }
      this.forceUpdate()
    }
  }

 
  componentWillReceiveProps() {
    this.setState({ searchArray: [] });
  }

  /*
  onChangeSearchText = (e) => {
    let data = [];
    if (e.length === 0) {
      this.setState({ searchArray: [] });
    }
    if (e.length > 3) {
      this.setState(
        {
          searchText: e,
        },
        () => {
          if (this.state.searchText.length > 3) {
            this.state.dataArray.map((item) => {
              data.push(item.name);
            });
            data.filter((data) => {
              if (
                data.toLowerCase().includes(this.state.searchText.toLowerCase())
              ) {
                if(this.state.searchArray.indexOf('data') > 0){

                }else {
                  this.state.searchArray.push({ name: data });
                }
              }
            });
          } else {
            this.setState({ searchArray: [] });
          }
        }
      );
    }
  };
  */

 onChangeSearchText = (e) => {
    let text = e.toLowerCase()
    let trucks = this.state.dataArray
    let filteredName = trucks.filter((item) => {
      return item.name.toLowerCase().match(text)
    })
    if (!text || text === '') {
      this.setState({
        searchArray: initial
      })
    } else if (!Array.isArray(filteredName) && !filteredName.length) {
      // set no data flag to true so as to render flatlist conditionally
      this.setState({
        searchArray: []
      })
    } else if (Array.isArray(filteredName)) {
      this.setState({
        searchArray: filteredName
      })
    }
  }

  render() {
    let resultArray = [];
    const { server, isMasterDetail, theme } = this.props;
    if (this.state.searchArray.length > 0) {
      resultArray = this.state.searchArray;
      //this.setState({searchArray:[]})
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
              initialNumToRender={resultArray.length}
              showsVerticalScrollIndicator={false}
              renderHeader={this._renderHeader}
              SectionListClickCallback={(item, index) => {
                console.log("---SectionListClickCallback--:", item, index);
                //Alert.alert("" + item.name +"\n"+item.number);
                var no = item.number
                no  = no.replace('*','')
                no  = no.replace('#','')
                no  = no.replace(' ','')
                no  = no.replace('+','')
                no  = no.replace('(','')
                no  = no.replace(')','')

              if( no.indexOf('*') >= 0){
                no  = no.replace('*','')
              }
              if( no.indexOf('#') >= 0){
                no  = no.replace('#','')
              }
              if( no.indexOf(' ') >= 0){
                no  = no.replace(' ','')
              }
              if( no.indexOf('+') >= 0){
                no  = no.replace('+','')
              }
              if( no.indexOf('(') >= 0){
                no  = no.replace('(','')
              }
              if( no.indexOf(')') >= 0){
                no  = no.replace(')','')
              }
              if( no.indexOf('-') >= 0){
                no  = no.replace('-','')
              }

                console.debug('item.name = ', no)
                
                NativeModules.Sdk.startDialerMethod((err, name) => {
                  console.log(err, name);
                  console.debug(err, name);
                });

                this.props.navigation.push('CallScreen', {
                  phoneNumber : no,
                  name : item.name,
               });
              }}
              otherAlphabet="#"
            />
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
    justifyContent: 'center',
    alignItems: 'center'
  },
  
  button2: {
    width : 30,
    height : 30,
   // alignSelf : 'center',
   // overflow: 'hidden',
    resizeMode : 'center',
  //  backgroundColor : '#70E3E3',
  //  borderRadius : 30/2,
    marginRight : 20
 },
 
});