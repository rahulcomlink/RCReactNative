import React, { useState } from 'react';
import { CountrySelection } from 'react-native-country-list';
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
  import AsyncStorage from "@react-native-async-storage/async-storage";


class SelectCountryCode extends React.Component {

    constructor(props){ 
        super(props);
        this.state = {
            selected : ''
        };
    }

    static navigationOptions = () => ({
      
    });

    onCountrySelection = (item) => {
      this.setState({ selected: this.state.item })
            // this.saveCC();
      AsyncStorage.setItem("lastSelectedCountryCode", item.callingCode);
        this.props.navigation.goBack();
      this.props.route.params.onSelect({ selected: item });
    }
  
  saveCC = async () => {
    console.debug("CODE_COUNTRY_POPUP", item.callingCode);
    await AsyncStorage.setItem("lastSelectedCountryCode", item.callingCode);
  }

    render(){
       return (
          <View style={styles.container}>
           <CountrySelection action={(item) => this.onCountrySelection(item)}/>
          </View>
        );
      }
}

export default SelectCountryCode;

const styles = StyleSheet.create({
    container: {
      flex: 1,
      padding: 10,
      backgroundColor : 'white'
      
    }
});


