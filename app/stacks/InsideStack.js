import React from "react";
import { I18nManager } from "react-native";
import { createStackNavigator } from "@react-navigation/stack";
import { createDrawerNavigator } from "@react-navigation/drawer";

import { ThemeContext } from "../theme";
import {
  defaultHeader,
  themedHeader,
  ModalAnimation,
  StackAnimation,
} from "../utils/navigation";
import Sidebar from "../views/SidebarView";
import AsyncStorage from '@react-native-async-storage/async-storage';

// Chats Stack
import RoomView from "../views/RoomView";
import RoomsListView from "../views/RoomsListView";
import RoomActionsView from "../views/RoomActionsView";
import RoomInfoView from "../views/RoomInfoView";
import RoomInfoEditView from "../views/RoomInfoEditView";
import RoomMembersView from "../views/RoomMembersView";
import SearchMessagesView from "../views/SearchMessagesView";
import SelectedUsersView from "../views/SelectedUsersView";
import InviteUsersView from "../views/InviteUsersView";
import InviteUsersEditView from "../views/InviteUsersEditView";
import MessagesView from "../views/MessagesView";
import AutoTranslateView from "../views/AutoTranslateView";
import DirectoryView from "../views/DirectoryView";
import NotificationPrefView from "../views/NotificationPreferencesView";
import VisitorNavigationView from "../views/VisitorNavigationView";
import ForwardLivechatView from "../views/ForwardLivechatView";
import LivechatEditView from "../views/LivechatEditView";
import PickerView from "../views/PickerView";
import ThreadMessagesView from "../views/ThreadMessagesView";
import MarkdownTableView from "../views/MarkdownTableView";
import ReadReceiptsView from "../views/ReadReceiptView";

// Profile Stack
import ProfileView from "../views/ProfileView";
import UserPreferencesView from "../views/UserPreferencesView";
import UserNotificationPrefView from "../views/UserNotificationPreferencesView";

// Settings Stack
import SettingsView from "../views/SettingsView";
import SecurityPrivacyView from "../views/SecurityPrivacyView";
import E2EEncryptionSecurityView from "../views/E2EEncryptionSecurityView";
import LanguageView from "../views/LanguageView";
import ThemeView from "../views/ThemeView";
import DefaultBrowserView from "../views/DefaultBrowserView";
import ScreenLockConfigView from "../views/ScreenLockConfigView";

// Admin Stack
import AdminPanelView from "../views/AdminPanelView";

// NewMessage Stack
import NewMessageView from "../views/NewMessageView";
import CreateChannelView from "../views/CreateChannelView";

// E2ESaveYourPassword Stack
import E2ESaveYourPasswordView from "../views/E2ESaveYourPasswordView";
import E2EHowItWorksView from "../views/E2EHowItWorksView";

// E2EEnterYourPassword Stack
import E2EEnterYourPasswordView from "../views/E2EEnterYourPasswordView";

// InsideStackNavigator
import AttachmentView from "../views/AttachmentView";
import ModalBlockView from "../views/ModalBlockView";
import JitsiMeetView from "../views/JitsiMeetView";
import VideoCallView from "../views/VideoCallView";
import StatusView from "../views/StatusView";
import ShareView from "../views/ShareView";
import CreateDiscussionView from "../views/CreateDiscussionView";

import QueueListView from "../ee/omnichannel/views/QueueListView";

//Sip Setting Navigator
import CallScreen from "../views/SipSettingView/CallScreen";
import SIPSettings from "../views/SipSettingView/SIPSettings";
import Inputs from "../views/SipSettingView/UserDetails";
import qrScanner from "../views/SipSettingView/qrScanner";
import getSipSettingsFromAPI from "../views/SipSettingView/getSipSettingsFromAPI";
import PhonebookView from "../views/PhonebookView";

//Keypad
import KeypadView from "../views/KeypadView/keypadView";
import SelectCountryCode from "../views/KeypadView/SelectCountryCode";

//VoIP Call Screen
import VoIPIncomingCall from "../views/VoIPIncomingCall";

// ChatsStackNavigator
const ChatsStack = createStackNavigator();
const ChatsStackNavigator = () => {
  const { theme } = React.useContext(ThemeContext);
  return (
    <ChatsStack.Navigator
      screenOptions={{
        ...defaultHeader,
        ...themedHeader(theme),
        ...StackAnimation,
      }}
    >
      <ChatsStack.Screen name="RoomsListView" component={RoomsListView} />
      <ChatsStack.Screen name="RoomView" component={RoomView} />
      <ChatsStack.Screen
        name="RoomActionsView"
        component={RoomActionsView}
        options={RoomActionsView.navigationOptions}
      />
      <ChatsStack.Screen
        name="RoomInfoView"
        component={RoomInfoView}
        options={RoomInfoView.navigationOptions}
      />
      <ChatsStack.Screen
        name="RoomInfoEditView"
        component={RoomInfoEditView}
        options={RoomInfoEditView.navigationOptions}
      />
      <ChatsStack.Screen
        name="RoomMembersView"
        component={RoomMembersView}
        options={RoomMembersView.navigationOptions}
      />
      <ChatsStack.Screen
        name="SearchMessagesView"
        component={SearchMessagesView}
        options={SearchMessagesView.navigationOptions}
      />
      <ChatsStack.Screen
        name="SelectedUsersView"
        component={SelectedUsersView}
      />
      <ChatsStack.Screen
        name="InviteUsersView"
        component={InviteUsersView}
        options={InviteUsersView.navigationOptions}
      />
      <ChatsStack.Screen
        name="InviteUsersEditView"
        component={InviteUsersEditView}
        options={InviteUsersEditView.navigationOptions}
      />
      <ChatsStack.Screen name="MessagesView" component={MessagesView} />
      <ChatsStack.Screen
        name="AutoTranslateView"
        component={AutoTranslateView}
        options={AutoTranslateView.navigationOptions}
      />
      <ChatsStack.Screen
        name="DirectoryView"
        component={DirectoryView}
        options={DirectoryView.navigationOptions}
      />
      <ChatsStack.Screen
        name="NotificationPrefView"
        component={NotificationPrefView}
        options={NotificationPrefView.navigationOptions}
      />
      <ChatsStack.Screen
        name="VisitorNavigationView"
        component={VisitorNavigationView}
        options={VisitorNavigationView.navigationOptions}
      />
      <ChatsStack.Screen
        name="ForwardLivechatView"
        component={ForwardLivechatView}
        options={ForwardLivechatView.navigationOptions}
      />
      <ChatsStack.Screen
        name="LivechatEditView"
        component={LivechatEditView}
        options={LivechatEditView.navigationOptions}
      />
      <ChatsStack.Screen
        name="PickerView"
        component={PickerView}
        options={PickerView.navigationOptions}
      />
      <ChatsStack.Screen
        name="ThreadMessagesView"
        component={ThreadMessagesView}
        options={ThreadMessagesView.navigationOptions}
      />
      <ChatsStack.Screen
        name="MarkdownTableView"
        component={MarkdownTableView}
        options={MarkdownTableView.navigationOptions}
      />
      <ChatsStack.Screen
        name="ReadReceiptsView"
        component={ReadReceiptsView}
        options={ReadReceiptsView.navigationOptions}
      />
      <ChatsStack.Screen
        name="QueueListView"
        component={QueueListView}
        options={QueueListView.navigationOptions}
      />
      <ChatsStack.Screen
        name="Inputs"
        component={Inputs}
        options={Inputs.navigationOptions}
      />
      <ChatsStack.Screen
        name="qrScanner"
        component={qrScanner}
        options={qrScanner.navigationOptions}
      />
      <ChatsStack.Screen
        name="getSipSettingsFromAPI"
        component={getSipSettingsFromAPI}
        options={getSipSettingsFromAPI.navigationOptions}
      />
    </ChatsStack.Navigator>
  );
};

// ProfileStackNavigator
const ProfileStack = createStackNavigator();
const ProfileStackNavigator = () => {
  const { theme } = React.useContext(ThemeContext);
  return (
    <ProfileStack.Navigator
      screenOptions={{
        ...defaultHeader,
        ...themedHeader(theme),
        ...StackAnimation,
      }}
    >
      <ProfileStack.Screen
        name="ProfileView"
        component={ProfileView}
        options={ProfileView.navigationOptions}
      />
      <ProfileStack.Screen
        name="UserPreferencesView"
        component={UserPreferencesView}
        options={UserPreferencesView.navigationOptions}
      />
      <ProfileStack.Screen
        name="UserNotificationPrefView"
        component={UserNotificationPrefView}
        options={UserNotificationPrefView.navigationOptions}
      />
      <ProfileStack.Screen
        name="PickerView"
        component={PickerView}
        options={PickerView.navigationOptions}
      />
    </ProfileStack.Navigator>
  );
};

// SettingsStackNavigator
const SettingsStack = createStackNavigator();
const SettingsStackNavigator = () => {
  const { theme } = React.useContext(ThemeContext);

  return (
    <SettingsStack.Navigator
      screenOptions={{
        ...defaultHeader,
        ...themedHeader(theme),
        ...StackAnimation,
      }}
    >
      <SettingsStack.Screen
        name="SettingsView"
        component={SettingsView}
        options={SettingsView.navigationOptions}
      />
      <SettingsStack.Screen
        name="SecurityPrivacyView"
        component={SecurityPrivacyView}
        options={SecurityPrivacyView.navigationOptions}
      />
      <SettingsStack.Screen
        name="E2EEncryptionSecurityView"
        component={E2EEncryptionSecurityView}
        options={E2EEncryptionSecurityView.navigationOptions}
      />
      <SettingsStack.Screen
        name="LanguageView"
        component={LanguageView}
        options={LanguageView.navigationOptions}
      />
      <SettingsStack.Screen
        name="ThemeView"
        component={ThemeView}
        options={ThemeView.navigationOptions}
      />
      <SettingsStack.Screen
        name="DefaultBrowserView"
        component={DefaultBrowserView}
        options={DefaultBrowserView.navigationOptions}
      />
      <SettingsStack.Screen
        name="ScreenLockConfigView"
        component={ScreenLockConfigView}
        options={ScreenLockConfigView.navigationOptions}
      />
    </SettingsStack.Navigator>
  );
};

// SipSettingsStackNavigator
const SipSettingsStack = createStackNavigator();
const SipSettingsStackNavigator = () => {
  const { theme } = React.useContext(ThemeContext);

  return (
    <SipSettingsStack.Navigator
      screenOptions={{
        ...defaultHeader,
        ...themedHeader(theme),
        ...StackAnimation,
      }}
    >
      <SipSettingsStack.Screen
        name="SIPSettings"
        component={SIPSettings}
        options={SIPSettings.navigationOptions}
      />
      
    </SipSettingsStack.Navigator>
  );
};

//KeypadViewStackNavigator
const KeypadViewStack = createStackNavigator();
const KeypadViewStackNavigator = () => {
  const { theme } = React.useContext(ThemeContext);

  return (
    <KeypadViewStack.Navigator
      screenOptions={{
        ...defaultHeader,
        ...themedHeader(theme),
        ...StackAnimation,
      }}
    >
      <KeypadViewStack.Screen
        name="KeypadView"
        component={KeypadView}
        options={KeypadView.navigationOptions}
      />
      <CallScreenStack.Screen
        name="CallScreen"
        component={CallScreen}
        options={{
          headerShown: false,
        }}
      />
      <KeypadViewStack.Screen
        name="SelectCountryCode"
        component={SelectCountryCode}
        options={SelectCountryCode.navigationOptions}
      />
    </KeypadViewStack.Navigator>
  );
};

// NewMessageStackNavigator
const SipProvisioningStack = createStackNavigator();
const SipProvisioningStackNavigator = () => {
  const { theme } = React.useContext(ThemeContext);

  return (
    <SipProvisioningStack.Navigator
      screenOptions={{
        ...defaultHeader,
        ...themedHeader(theme),
        ...StackAnimation,
      }}
    >
      <SipProvisioningStack.Screen
        name="Inputs"
        component={Inputs}
        options={Inputs.navigationOptions}
      />
      <SipProvisioningStack.Screen
        name="qrScanner"
        component={qrScanner}
        options={qrScanner.navigationOptions}
      />
      <SipProvisioningStack.Screen
        name="getSipSettingsFromAPI"
        component={getSipSettingsFromAPI}
        options={getSipSettingsFromAPI.navigationOptions}
      />
	  <SipProvisioningStack.Screen
        name="PhonebookView"
        component={PhonebookView}
		options={PhonebookView.navigationOptions}
      />
	  <SipProvisioningStack.Screen
        name="KeypadView"
        component={KeypadView}
        options={KeypadView.navigationOptions}
      />
	  <SipProvisioningStack.Screen
        name="SelectCountryCode"
        component={SelectCountryCode}
        options={SelectCountryCode.navigationOptions}
      />
	   <SipProvisioningStack.Screen
        name="CallScreen"
        component={CallScreen}
        options={{
          headerShown: false,
        }}
        //options={CallScreen.navigationOptions}
      />
	  
    </SipProvisioningStack.Navigator>
  );
};

// CallScreenStackNavigator
const CallScreenStack = createStackNavigator();
const CallScreenStackNavigator = () => {
  const { theme } = React.useContext(ThemeContext);

  return (
    <CallScreenStack.Navigator
      screenOptions={{
        ...defaultHeader,
        ...themedHeader(theme),
        ...StackAnimation,
      }}
    >
      <CallScreenStack.Screen
        name="CallScreen"
        component={CallScreen}
        options={{
          headerShown: false,
        }}
        //options={CallScreen.navigationOptions}
      />
      
    </CallScreenStack.Navigator>
  );
};

// PhonebookStackNavigator
const PhonebookStack = createStackNavigator();
const PhonebookStackNavigator = () => {
  const { theme } = React.useContext(ThemeContext);

  return (
    <PhonebookStack.Navigator>
      
      <PhonebookStack.Screen
        name="PhonebookView"
        component={PhonebookView}
        options={PhonebookView.navigationOptions}
      />
	  <PhonebookStack.Screen
        name="KeypadView"
        component={KeypadView}
        options={KeypadView.navigationOptions}
      />
	  <PhonebookStack.Screen
        name="CallScreen"
        component={CallScreen}
        options={{
          headerShown: false,
        }}
      />
      <PhonebookStack.Screen
        name="SelectCountryCode"
        component={SelectCountryCode}
        options={SelectCountryCode.navigationOptions}
      />
      <PhonebookStack.Screen
        name="VoIPIncomingCall"
        component={VoIPIncomingCall}
        options={{
          headerShown: false,
        }}
      />
      
    </PhonebookStack.Navigator>
  );
};

// AdminPanelStackNavigator
const AdminPanelStack = createStackNavigator();
const AdminPanelStackNavigator = () => {
  const { theme } = React.useContext(ThemeContext);

  return (
    <AdminPanelStack.Navigator
      screenOptions={{
        ...defaultHeader,
        ...themedHeader(theme),
        ...StackAnimation,
      }}
    >
      <AdminPanelStack.Screen
        name="AdminPanelView"
        component={AdminPanelView}
        options={AdminPanelView.navigationOptions}
      />
    </AdminPanelStack.Navigator>
  );
};

// DrawerNavigator
const Drawer = createDrawerNavigator();
const DrawerNavigator = () => (
  <Drawer.Navigator
    drawerContent={({ navigation, state }) => (
      <Sidebar navigation={navigation} state={state} />
    )}
    drawerPosition={I18nManager.isRTL ? "right" : "left"}
    screenOptions={{ swipeEnabled: false }}
    drawerType="back"
  >
    <Drawer.Screen name="ChatsStackNavigator" component={ChatsStackNavigator} />
    <Drawer.Screen
      name="ProfileStackNavigator"
      component={ProfileStackNavigator}
    />
    <Drawer.Screen
      name="SettingsStackNavigator"
      component={SettingsStackNavigator}
    />
    <Drawer.Screen
      name="AdminPanelStackNavigator"
      component={AdminPanelStackNavigator}
    />
    <Drawer.Screen
      name="SipSettingsStackNavigator"
      component={SipSettingsStackNavigator}
    />
    {/* <Drawer.Screen
      name="CallScreenStackNavigator"
      component={CallScreenStackNavigator}
    /> */}
    {/* <Drawer.Screen
      name="KeypadViewStackNavigator"
      component={KeypadViewStackNavigator}
    /> */}
    {/* <Drawer.Screen
      name="PhonebookStackNavigator"
      component={PhonebookStackNavigator}
    /> */}
  </Drawer.Navigator>
);

// NewMessageStackNavigator
const NewMessageStack = createStackNavigator();
const NewMessageStackNavigator = () => {
  const { theme } = React.useContext(ThemeContext);

  return (
    <NewMessageStack.Navigator
      screenOptions={{
        ...defaultHeader,
        ...themedHeader(theme),
        ...StackAnimation,
      }}
    >
      <NewMessageStack.Screen
        name="NewMessageView"
        component={NewMessageView}
        options={NewMessageView.navigationOptions}
      />
      <NewMessageStack.Screen
        name="SelectedUsersViewCreateChannel"
        component={SelectedUsersView}
      />
      <NewMessageStack.Screen
        name="CreateChannelView"
        component={CreateChannelView}
        options={CreateChannelView.navigationOptions}
      />
      <NewMessageStack.Screen
        name="CreateDiscussionView"
        component={CreateDiscussionView}
      />
    </NewMessageStack.Navigator>
  );
};

// E2ESaveYourPasswordStackNavigator
const E2ESaveYourPasswordStack = createStackNavigator();
const E2ESaveYourPasswordStackNavigator = () => {
  const { theme } = React.useContext(ThemeContext);

  return (
    <E2ESaveYourPasswordStack.Navigator
      screenOptions={{
        ...defaultHeader,
        ...themedHeader(theme),
        ...StackAnimation,
      }}
    >
      <E2ESaveYourPasswordStack.Screen
        name="E2ESaveYourPasswordView"
        component={E2ESaveYourPasswordView}
        options={E2ESaveYourPasswordView.navigationOptions}
      />
      <E2ESaveYourPasswordStack.Screen
        name="E2EHowItWorksView"
        component={E2EHowItWorksView}
        options={E2EHowItWorksView.navigationOptions}
      />
    </E2ESaveYourPasswordStack.Navigator>
  );
};

// E2EEnterYourPasswordStackNavigator
const E2EEnterYourPasswordStack = createStackNavigator();
const E2EEnterYourPasswordStackNavigator = () => {
  const { theme } = React.useContext(ThemeContext);

  return (
    <E2EEnterYourPasswordStack.Navigator
      screenOptions={{
        ...defaultHeader,
        ...themedHeader(theme),
        ...StackAnimation,
      }}
    >
      <E2EEnterYourPasswordStack.Screen
        name="E2EEnterYourPasswordView"
        component={E2EEnterYourPasswordView}
        options={E2EEnterYourPasswordView.navigationOptions}
      />
    </E2EEnterYourPasswordStack.Navigator>
  );
};

// InsideStackNavigator
const InsideStack = createStackNavigator();
const InsideStackNavigator = () => {
  const { theme } = React.useContext(ThemeContext);

  return (
    <InsideStack.Navigator
      mode="modal"
      screenOptions={{
        ...defaultHeader,
        ...themedHeader(theme),
        ...ModalAnimation,
      }}
    >
      <InsideStack.Screen
        name="DrawerNavigator"
        component={DrawerNavigator}
        options={{ headerShown: false }}
      />
      <InsideStack.Screen
        name="NewMessageStackNavigator"
        component={NewMessageStackNavigator}
        options={{ headerShown: false }}
      />
      <InsideStack.Screen
        name="E2ESaveYourPasswordStackNavigator"
        component={E2ESaveYourPasswordStackNavigator}
        options={{ headerShown: false }}
      />
      <InsideStack.Screen
        name="E2EEnterYourPasswordStackNavigator"
        component={E2EEnterYourPasswordStackNavigator}
        options={{ headerShown: false }}
      />
      <InsideStack.Screen name="AttachmentView" component={AttachmentView} />
      <InsideStack.Screen name="StatusView" component={StatusView} />
      <InsideStack.Screen name="ShareView" component={ShareView} />
      <InsideStack.Screen
        name="ModalBlockView"
        component={ModalBlockView}
        options={ModalBlockView.navigationOptions}
      />
      <InsideStack.Screen
        name="VideoCallView"
        component={VideoCallView}
        options={{ headerShown: false }}
      />
      <InsideStack.Screen
        name="JitsiMeetView"
        component={JitsiMeetView}
        options={{ headerShown: false }}
      />
      <InsideStack.Screen
        name="SipProvisioningStackNavigator"
        component={SipProvisioningStackNavigator}
        options={{ headerShown: false }}
      />
	  <InsideStack.Screen
        name="PhonebookStackNavigator"
        component={PhonebookStackNavigator}
        options={{ headerShown: false }}
      />
      <InsideStack.Screen
        name="CallScreen"
        component={CallScreen}
        options={{ headerShown: false }}
      />
      <InsideStack.Screen
        name="CallScreenStackNavigator"
        component={CallScreenStackNavigator}
        options={{ headerShown: false }}
      />


    
    </InsideStack.Navigator>
  );
};

export default InsideStackNavigator;
