import React, { Component,useState } from 'react';
import { View, Text, TextInput, StyleSheet } from 'react-native';


const InputContainer = ({placeholder, title, onTextChange, keyBoardType,textValue}) => {
    
    text = () => {

    }

    const isSecureEntry = placeholder.toLowerCase()
    
    return(
        <View style = {styles.containerView}>    
            <Text style = {styles.titleLabel}>
                {title}
            </Text>

            <TextInput style = {styles.inputFields}
               underlineColorAndroid = "transparent"
               placeholder = {placeholder}
               placeholderTextColor = "black"
               keyboardType = {keyBoardType}
               autoCapitalize = "none"
               onChangeText = {onTextChange}
               value = {textValue}
               secureTextEntry = {isSecureEntry === 'password' ? true : false}
            />
            
        </View>
    )
}

const styles = StyleSheet.create({
    containerView : {
        marginHorizontal : 20,
        marginTop : 15,
    },

    titleLabel : {
        textAlign : 'left',
        fontSize : 17,
        fontWeight : 'bold',
        color : 'black',
        textAlignVertical: 'center',
    },

    inputFields : {
        fontSize : 16,
        marginTop : 2,
        backgroundColor : 'white',
        height : 40,
    }
});

export default InputContainer;