import React, { useState } from 'react';
import { View, FlatList, StyleSheet, Image } from "react-native";
import PropTypes from 'prop-types';

import TextInput from '../../../containers/TextInput';
import * as List from '../../../containers/List';
import { themes } from '../../../constants/colors';
import Item from './Item';

const styles = StyleSheet.create({
  container: {
    flex: 1,
    alignItems: "center",
  },
  backgroundContainer: {
    position: "absolute",
    top: 0,
    bottom: 0,
    left: 0,
    right: 0,
  },
  inputContainer: {
    marginTop: 0,
    marginBottom: 0,
  },
  serverHistory: {
    maxHeight: 180,
    width: "100%",
    top: "100%",
    zIndex: 1,
    position: "absolute",
    borderWidth: StyleSheet.hairlineWidth,
    borderRadius: 2,
    borderTopWidth: 0,
  },
  tinyLogo: {
    width: "100%",
    height: "100%",
    position: "relative",
  },
  overlay: {
    opacity: 0.9,
    backgroundColor: "#000000",
  },
  logo: {
    backgroundColor: "rgba(0,0,0,0)",
    width: 600,
    height: 800,
  },
  backdrop: {
    flex: 1,
    flexDirection: "column",
  },
  headline: {
    fontSize: 18,
    textAlign: "center",
    backgroundColor: "black",
    color: "white",
  },
});

const ServerInput = ({
	text,
	theme,
	serversHistory,
	onChangeText,
	onSubmit,
	onDelete,
	onPressServerHistory
}) => {
	const [focused, setFocused] = useState(false);
  return (
    <View style={styles.container}>
      <View style={styles.backgroundContainer}>
        {/* <Image
        style={styles.tinyLogo}
        source={require("/Users/tushar/ReactNative/Pigeon_Code_RN/Chat_Pigeon/Rocket.Chat.ReactNative/android/app/src/main/res/drawable/splash_screen.png")}
      /> */}
        <TextInput
          label="Enter server URL"
          placeholder="Ex. your-company name"
          containerStyle={styles.inputContainer}
          value={text}
          returnKeyType="send"
          onChangeText={onChangeText}
          testID="new-server-view-input"
          onSubmitEditing={onSubmit}
          clearButtonMode="while-editing"
          keyboardType="url"
          textContentType="URL"
          theme={theme}
          onFocus={() => setFocused(true)}
          onBlur={() => setFocused(false)}
        />
        {focused && serversHistory?.length ? (
          <View
            style={[
              styles.serverHistory,
              {
                backgroundColor: themes[theme].backgroundColor,
                borderColor: themes[theme].separatorColor,
              },
            ]}
          >
            <FlatList
              data={serversHistory}
              renderItem={({ item }) => (
                <Item
                  item={item}
                  theme={theme}
                  onPress={() => onPressServerHistory(item)}
                  onDelete={onDelete}
                />
              )}
              ItemSeparatorComponent={List.Separator}
              keyExtractor={(item) => item.id}
            />
          </View>
        ) : null}
      </View>
      <View style={styles.overlay}>
        <Image
          style={styles.logo}
          source={require("/Users/tushar/ReactNative/Pigeon_Code_RN/Chat_Pigeon/Rocket.Chat.ReactNative/android/app/src/main/res/drawable/splash_screen.png")}
        />
      </View>
    </View>
  );
};

ServerInput.propTypes = {
	text: PropTypes.string,
	theme: PropTypes.string,
	serversHistory: PropTypes.array,
	onChangeText: PropTypes.func,
	onSubmit: PropTypes.func,
	onDelete: PropTypes.func,
	onPressServerHistory: PropTypes.func
};

export default ServerInput;
