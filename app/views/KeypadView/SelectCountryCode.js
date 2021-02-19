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
        this.setState({ selected: this.state.item})
        this.props.navigation.goBack();
        this.props.route.params.onSelect({ selected: item });
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


