import * as Contacts from "expo-contacts";
import PropTypes from 'prop-types';
import React from 'react';
import { Text, View } from "react-native";
import { connect } from 'react-redux';
import { appStart as appStartAction } from '../../actions/app';
import { toggleAnalyticsEvents as toggleAnalyticsEventsAction, toggleCrashReport as toggleCrashReportAction } from '../../actions/crashReport';
import { logout as logoutAction } from '../../actions/login';
import { selectServerRequest as selectServerRequestAction } from '../../actions/server';
import { themes } from '../../constants/colors';
import { CloseModalButton, DrawerButton } from '../../containers/HeaderButton';
import SafeAreaView from '../../containers/SafeAreaView';
import StatusBar from '../../containers/StatusBar';
import { withTheme } from '../../theme';


const SectionSeparator = React.memo(({ theme }) => (
	<View
		style={[
			styles.sectionSeparatorBorder,
			{
				borderColor: themes[theme].separatorColor,
				backgroundColor: themes[theme].auxiliaryBackground
			}
		]}
	/>
));
SectionSeparator.propTypes = {
	theme: PropTypes.string
};

class PhonebookView extends React.Component {
  constructor(props) {
    super(props);

    //name字段必须,其他可有可无
    let nameData = [];

    this.state = {
      dataArray: nameData,
		searchText: "",
	  searchArray:[]
    };
  }

	async componentDidMount() {
    const { status } = await Contacts.requestPermissionsAsync();
    if (status === "granted") {
      const { data } = await Contacts.getContactsAsync({
        fields: [Contacts.Fields.Name],
      });

      if (data.length > 0) {
        for (var i = 0; i < data.length; i++) {
          const contact = data[i];
          if (contact != null && contact.name != null) {
			  this.state.dataArray.push({ name: contact.name });
          }
        }
      }
    }
	}
	
	componentWillReceiveProps() {
		this.setState({searchArray:[]})
	}

	onChangeSearchText = (e) => {
		let data = []
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
                this.state.searchArray.push({ name: data });
              }
            });
          } else {
            this.setState({ searchArray: [] });
          }
        }
      );
		}
	}

  static navigationOptions = ({ navigation, isMasterDetail }) => ({
    headerLeft: () =>
      isMasterDetail ? (
        <CloseModalButton
          navigation={navigation}
          testID="settings-view-close"
        />
      ) : (
        <DrawerButton navigation={navigation} />
      ),
    title: "Phonebook",
  });

  static propTypes = {
    navigation: PropTypes.object,
    server: PropTypes.object,
    allowCrashReport: PropTypes.bool,
    allowAnalyticsEvents: PropTypes.bool,
    toggleCrashReport: PropTypes.func,
    toggleAnalyticsEvents: PropTypes.func,
    theme: PropTypes.string,
    isMasterDetail: PropTypes.bool,
    logout: PropTypes.func.isRequired,
    selectServerRequest: PropTypes.func,
    user: PropTypes.shape({
      roles: PropTypes.array,
      id: PropTypes.string,
    }),
    appStart: PropTypes.func,
  };

	render() {

		let resultArray=[]
		const { server, isMasterDetail, theme } = this.props;
		if (this.state.searchArray.length>0) {
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
                  Alert.alert("" + item.name);
                }}
                otherAlphabet="#"
              />
          </View>
        </ScrollView>
              
      </SafeAreaView>
    );
  }

  _renderHeader = (params) => {
    console.log("---custom-renderHeader--", params);
    return (
      <View>
        <Text style={styles.headerTitleText}>{params.key}</Text>
      </View>
    );
  };
}

const mapStateToProps = state => ({
	server: state.server,
	//user: getUserSelector(state),
	allowCrashReport: state.crashReport.allowCrashReport,
	allowAnalyticsEvents: state.crashReport.allowAnalyticsEvents,
	isMasterDetail: state.app.isMasterDetail
});

const mapDispatchToProps = dispatch => ({
	logout: () => dispatch(logoutAction()),
	selectServerRequest: params => dispatch(selectServerRequestAction(params)),
	toggleCrashReport: params => dispatch(toggleCrashReportAction(params)),
	toggleAnalyticsEvents: params => dispatch(toggleAnalyticsEventsAction(params)),
	appStart: params => dispatch(appStartAction(params))
});

export default connect(mapStateToProps, mapDispatchToProps)(withTheme(PhonebookView));
