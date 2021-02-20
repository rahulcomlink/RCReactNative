import { StyleSheet } from "react-native";

import sharedStyles from "../Styles";

export default StyleSheet.create({
  sectionSeparatorBorder: {
    ...sharedStyles.separatorVertical,
    height: 36,
  },
  listPadding: {
    paddingVertical: 0,
  },
  headerTitleText: {
    fontFamily: "Cochin",
    fontSize: 20,
    fontWeight: "bold",
    color: "#ff0000",
    padding: 3,
  },
  contactTitleText: {
    padding: 15,
    backgroundColor: "#fff",
  },
});
