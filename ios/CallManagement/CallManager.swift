//
// Kulfi
// Copyright 2019 Comlink Inc. All rights reserved.
//

import AVKit
import CallKit
import Foundation

///
/// CallKit based call management.
///
/// This is a work in progress.
///

class MyVariables {
    static let shared = MyVariables()
    var yourVariable = false
}

final class CallManager {
  // The one and only instance of CallManager
  static let shared = CallManager()

  /// Published "in-call" indicator
  var inCall = false

  /// Published "on-hold" indicator
  var onHold =  false

  /// Published "muted" indicator
  var isMuted = false

  // Published "connecting" indicator
  var isConnecting = false
  
  // Published "speaker-on" indicator
  var isSpeakerOn = false

  // Published "remote party name" value
  var remotePartyName = ""
  
  // Published "remote party calling line ID" value
  var remotePartyClid = ""

  // Published "call duration" value (expressed in seconds)
  var callDuration = 0
  
  var isFromAppLaunch = false
  
  private let _controller = CXCallController()
  private let _provider: CXProvider
  private let _dispatchQueue = DispatchQueue(label: "CallManagerDispatchQueue")
  private let _logger = Logger(componentName: "CallManager")

  private static let kNullUUID = UUID(uuid: UUID_NULL)
  
  // Current call info
  private var _currentCallUuid: UUID = CallManager.kNullUUID
  private var _incomingCallUuid: UUID = CallManager.kNullUUID
  private var answerAction : CXAnswerCallAction?
  
  // Current audio session
  private var _activeAudioSession: AVAudioSession?
  
  // Pending call info
  private var _inboundCallDescriptor: InboundCallDescriptor?

  // Current call timer
  private var _callTimer: Timer?

  private var _waitingForInboundCall = BlockingBarrier<Bool>(withInitalValue: false)
  private var _makeCallInProgress = BlockingBarrier<Bool>(withInitalValue: false)
  private var _audioSessionReady = BlockingBarrier<Bool>(withInitalValue: false)
  private var _addDelayinCallAnswer = BlockingBarrier<Bool>(withInitalValue: false)
  
  // When this field is set to true the call teardown sequence will not reset
  // the published properties (inCall, etc). This is, essentially, a kludge that provides
  // a way to suppress unwanted actions from being generated in response to changes in
  // published properties.
  private var _suppressPublishedPropertyReset = false

  typealias ActionCompletion = (Error?) -> Void
  private var _actionCompletion: SingleFireCallback<Error>?

  private init() {
    let localizedName = NSLocalizedString("Kulfi", comment: "Kulfi Dialer")
    let configuration = CXProviderConfiguration(localizedName: localizedName)

    configuration.supportsVideo = false
    configuration.maximumCallGroups = 1
    configuration.maximumCallsPerCallGroup = 1
    configuration.supportedHandleTypes = [.phoneNumber]
    configuration.ringtoneSound = "ring.wav"

    _provider = CXProvider(configuration: configuration)
    _provider.setDelegate(ProviderDelegateTrampoline.instance, queue: DispatchQueue.main)

    Dialer.shared.inboundCallHandler = onInboundCallArrived
    Dialer.shared.callEndedHandler = onRemoteCallTerminated
    Dialer.shared.callAnsweredHandler = onCallAnswered
  }
  
  // Invoked by the dialer whenever a call is terminated by the remote end.
  private func onRemoteCallTerminated(uuid: UUID) {
    // If a make-call action is currently in progress we'll terminate it here.
    // Whatever is waiting for this value to change will have to handle the dropped
    // call. Otherwise, the call is already in progress and we'll have to tear it down.
    if uuid == _currentCallUuid && _makeCallInProgress.isEqualTo(true) {
      _makeCallInProgress.setAndNotify(newValue: false)
      return
    }
    
    // Otherwise, attempt to tear down the call via CallKit.
    let action = CXEndCallAction(call: uuid)

    _controller.requestTransaction(with: action) { error in
      if let error = error {
        self._logger.writeError(error)
      }
    }
  }
  
  /// Invoked by the dialer whenever a call is answered.
  private func onCallAnswered(uuid: UUID) {
    _makeCallInProgress.setAndNotify(newValue: false)
    DispatchQueue.main.async {
      self.isConnecting = false
    }
  }

  /// Configuras the audio session. Invoked via the provider delegate trampoline.
  fileprivate func onAudioSessionActivated(_ audioSession: AVAudioSession) {
    configureAudioSession(audioSession)
    
    // This becomes our audio session. Let everyone know that it is available.
    _activeAudioSession = audioSession
    _audioSessionReady.setAndNotify(newValue: true)
    
    // FIXME: does this need to be here?
    isSpeakerOn = false
  }
  
  // Disassociates from the given audio session. Invoked via the provider delegate trampoline.
  fileprivate func onAudioSessionDeactivated(_ audioSession: AVAudioSession) {
    _logger.write("deactivating audio session", type: .debug)
    
    if (audioSession == _activeAudioSession) {
      _activeAudioSession = nil
      _audioSessionReady.setAndNotify(newValue: false)
    } else {
      _logger.write("unknown audio session", type: .error)
    }
  }
  
  // Audio session configuration.
  fileprivate func configureAudioSession(_ audioSession: AVAudioSession) {
  
    _logger.write("configuring audio session", type: .debug)
    
    do {
      try audioSession.setCategory(.playAndRecord)
      try audioSession.setMode(.voiceChat)
      try audioSession.setActive(true)
    } catch {

      _logger.writeError(error)
    }
  }
  
  // Redirects the current audio session to the speaker.
  func toggleSpeaker(completion: ActionCompletion = { _ in /* Empty */ }) {
    _logger.write("toggling speaker", type: .debug)
    
    var throwable: Error? = nil
    
    do {
      if isSpeakerOn {
        try _activeAudioSession?.overrideOutputAudioPort(.none)
        isSpeakerOn = false
      } else {
        try _activeAudioSession?.overrideOutputAudioPort(.speaker)
        isSpeakerOn = true
      }
    } catch {
      _logger.writeError(error)
      
      throwable = error
    }
    
    completion(throwable)
  }

  /// Sets the callback for the current action. The callback must be set exactly
  /// once for every action that requires one. The next callback cannot be set until
  /// the current callback has been called. Each callback may be invoked only once
  /// by invoking `completeCurrentAction()`.
  ///
  /// - Parameters:
  ///   - handler: Callback to install.
  private func doUserActionStartup(_ handler: @escaping ActionCompletion = { _ in /* Empty */}) {
    precondition(_actionCompletion == nil, "Another action already in progress")
    _actionCompletion = SingleFireCallback<Error>(callback: handler)
  }

  /// Completes the current action.
  ///
  /// - Parameters:
  ///   - error: Optional error to pass to the callback.
  private func doUserActionCleanup(error: Error? = nil) {
    if var completion = _actionCompletion {
      DispatchQueue.main.async {
        completion.fire(with: error)
      }
      
      _actionCompletion = nil
    }
  }

  /// Starts the call timer. This is performed every time a call is started.
  private func startCallTimer() {
    DispatchQueue.main.async {
      precondition(self._callTimer == nil)
      self._callTimer = Timer.scheduledTimer(withTimeInterval: 1, repeats: true) { _ in
        self.callDuration += 1
      }
    }
  }

  private func reset() {
    _logger.write("uuid=[%@], suppressPublishedPropertyReset=[%@]", type: .debug,
                  _currentCallUuid.uuidString, _suppressPublishedPropertyReset ? "true" : "false")
    
    _currentCallUuid = CallManager.kNullUUID
    _incomingCallUuid = CallManager.kNullUUID
    answerAction = nil

    _callTimer?.invalidate()
    _callTimer = nil
    
    // For more information see the comment attached to the definition of
    // _suppressPublishedPropertySheet.
    if !_suppressPublishedPropertyReset {
      DispatchQueue.main.async {
        self.inCall = false
        self.onHold = false
        self.isMuted = false
        self.isConnecting = false
        self.callDuration = 0
        self.remotePartyName = ""
        self.remotePartyClid = ""
        self.isFromAppLaunch = false
        UserDefaults.standard.setValue("false", forKey: "isVoipCall")
     //   UserDefaults.standard.setValue("false", forKey: "isAppLaunch")
        UserDefaults.standard.synchronize()
      }
    }
    ModuleWithEmitter.emitter.sendEvent(withName: "onSessionConnect", body: ["callStatus" : "TERMINATED"])
  }

  /// Starts the call manager.
  func start() {
    // Perform dialer initialization in its own thread. We do this because the dialer expects
    // a valid push token which may not yet be available. Getting the push token from PushManager
    // blocks until the token becomes available.
    _dispatchQueue.async {
      do {
        let pushToken = ""
        try Dialer.shared.start(with: pushToken)
        self._logger.write("started with pushToken=[%@]", type: .debug, pushToken)
      } catch {
        self._logger.write("Dialer startup failure", type: .fault)
      }
    }
  }
  
  func restart() {
    do {
      try Dialer.shared.stop()
      let pushToken = ""
      try Dialer.shared.start(with: pushToken)
      _logger.write("restarted with pushToken=[%@]", type: .debug, pushToken)
    } catch {
      _logger.write("Dialer restart failure", type: .fault)
    }
  }

  /// Sends a DTMF tone.
  ///
  /// - Parameters:
  ///   - digit: String containing the digit for which the corresponding DTMF
  ///            tone will be sent.
  func sendDtmf(digit: String, completion: @escaping ActionCompletion = { _ in /* Empty */ }) {
    _logger.write("digit=[%@]", digit)
    
    var throwable: Error?
    
    do {
      try Dialer.shared.sendDTMFTone(with: _currentCallUuid, tone: digit)
    } catch {
      throwable = error
    }
    
    completion(throwable)
  }

  /// Drops the current call.
  ///
  /// - Parameters:
  ///   - completion  Code to execute on action completion.
  func dropCurrentCall(completion: @escaping ActionCompletion = { _ in /* Empty */ }) {
    _logger.write("uuid=[%@]", type: .debug, _currentCallUuid.uuidString)

    // This is a no-op if we don't have a current call.
    // FIXME: should this be a precondition?
    if _currentCallUuid == CallManager.kNullUUID {
      return
    }

    // If there is a make call action in progress then we already have an action
    // callback in place. Therefore, we'll silently ignore the one provided by
    // the caller.
    if _makeCallInProgress.isEqualTo(false) {
      doUserActionStartup(completion)
    } else {
      // Unblock the task that is blocking on the make-call-in-progress flag.
      // It is up to the task to determine that the call did not get established.
      _makeCallInProgress.setAndNotify(newValue: false)
    }
  
    let action = CXEndCallAction(call: _currentCallUuid)

    _controller.requestTransaction(with: action) { error in
      if let error = error {
        self._logger.writeError(error)
      }
      self.doUserActionCleanup(error: error)
    }
  }

  /// Processes an end-call action. Invoked via the provider delegate trampoline.
  fileprivate func handleEndCallAction(_ action: CXEndCallAction) {
    _logger.write("uuid=[%@]", type: .debug, action.callUUID.uuidString)

    // If the call being dropped is the current call then we reset our current
    // call state and all of the published properties.
    _dispatchQueue.async {
      ModuleWithEmitter.emitter.sendEvent(withName: "onSessionConnect", body: ["callStatus" : "TERMINATED"])
    }
    
    _dispatchQueue.async {
      Dialer.shared.dropCall(uuid: action.callUUID)
      action.fulfill()
    }
    
    if _currentCallUuid == action.callUUID {
      reset()
    }
  
    
    
    doUserActionCleanup()
  }

  /// Initiates a new call. The call that we start here becomes the current call.
  /// Consequently, this function must not be invoked if there already is a current
  /// call. In those casees, the current call should be either placed on hold or
  /// dropped.
  ///
  /// - Parameters:
  ///   - outpulse:   String containing the number to dial.
  ///   - completion  Code to execute after the transaction is completed.
  func makeCall(outpulse: String, completion: @escaping ActionCompletion = { _ in /* Empty */ }) {
    precondition(_currentCallUuid == CallManager.kNullUUID, "Call already in progress")

    _currentCallUuid = UUID()
    
    _logger.write("outpulse=[%@], uuid=[%@]", type: .debug, outpulse, _currentCallUuid.uuidString)

    doUserActionStartup(completion)

    _makeCallInProgress.setAndNotify(newValue: true)

    let handle = CXHandle(type: .phoneNumber, value: outpulse)
    let action = CXStartCallAction(call: _currentCallUuid, handle: handle)
    action.isVideo = false
    action.contactIdentifier = outpulse

    _controller.requestTransaction(with: action) { error in
      if let error = error {
        self._logger.writeError(error)
        self._provider.reportCall(with: self._currentCallUuid, endedAt: nil, reason: .failed)
      }
      self.doUserActionCleanup(error: error)
    }

    inCall = true
    isConnecting = true
    remotePartyName = getRemotePartyName(phoneNumber: outpulse, defaultName: "Unknown")
    remotePartyClid = outpulse
  }

  fileprivate func _handleStartCallAsync(_ action: CXStartCallAction) {
    // Tell CallKit that we've started connecting.
    _provider.reportOutgoingCall(with: action.callUUID, startedConnectingAt: nil)
    
    do {
      // Wait for the audio session to become activated by CallKit before prceeding.
      // Otherwise, we end up with no audio. The underlying call handling code needs
      // the session to be active prior to call initiation.
      
    //  try _audioSessionReady.waitAndThrowOnTimeout(untilEqualTo: true, timeout: 20.0)

      // Initiate the make call action.
      try Dialer.shared.makeCall(outpulse: action.handle.value, uuid: action.callUUID)
      
      // Wait for the make call action to finish.
      try _makeCallInProgress.waitAndThrowOnTimeout(
        untilEqualTo: false, timeout: Configuration.shared.answerTimeout)
      
    } catch {
      action.fail()
      //_logger.writeError("error = \(error)" as! Error)
      reset()
      doUserActionCleanup(error: error)
      
      return;
    }
      
    let info = Dialer.shared.getCallInfo(uuid: action.callUUID)
    
    if info.isAnswered {
      // The call was answered. Report success to CallKit and perform post-setup tasks.
      action.fulfill()
      
      _provider.reportOutgoingCall(with: action.callUUID, connectedAt: nil)
      
      _logger.write("uuid=[%@]: answered", type: .debug, action.callUUID.uuidString)
      startCallTimer()
      doUserActionCleanup()
    } else {
      // We don't report any errors here. The call either failed because it was declined,
      // timed out or rejected in some other fashion. Simply report failure to CallKit
      // and clean up.
      action.fail()
      
      _provider.reportCall(with: action.callUUID, endedAt: nil, reason: .failed)
      
      _logger.write("uuid=[%@]: failed", type: .debug, action.callUUID.uuidString)
      reset()
      doUserActionCleanup()
    }
  }

  /// Handles the start-call action. Invoked via the provider delegate trampoline.
  fileprivate func handleStartCallAction(_ action: CXStartCallAction) {
    _logger.write("uuid=[%@]", action.callUUID.uuidString)

    _dispatchQueue.async {
      self._handleStartCallAsync(action)
    }
  }

  /// Places the current call on hold.
  ///
  /// - Parameters:
  ///   - completion: Code to execute upon task completion.
  func holdCall(completion: @escaping ActionCompletion = { _ in /* Empty */ }) {
    precondition(_currentCallUuid != CallManager.kNullUUID, "No current call")
    
    _logger.write("uuid=[%@]", type: .debug, _currentCallUuid.uuidString)

    doUserActionStartup(completion)

    let action = CXSetHeldCallAction(call: _currentCallUuid, onHold: true)

    _controller.requestTransaction(with: action) { error in
      if let error = error {
        self._logger.writeError(error)
      }
      self.doUserActionCleanup(error: error)
    }
  }

  /// Resumes a call that was previously placed on hold.
  ///
  /// - Parameters:
  ///   - uuid:       UUID fof the call.
  ///   - completion: Code to execute upon task completion.
  func resumeCall(uuid: UUID, completion: @escaping ActionCompletion = { _ in /* Empty */ }) {
    precondition(_currentCallUuid != CallManager.kNullUUID, "No current call")

    _logger.write("uuid=[%@]", type: .debug, _currentCallUuid.uuidString)
    
    doUserActionStartup(completion)

    let action = CXSetHeldCallAction(call: uuid, onHold: false)

    _controller.requestTransaction(with: action) { error in
      if let error = error {
        self._logger.writeError(error)
      }
      self.doUserActionCleanup(error: error)
    }
  }

  /// Processes hte set-held action. Invoked via the provider delegate trampoline.
  fileprivate func handleSetHeldCallAction(_ action: CXSetHeldCallAction) {
    _logger.write("uuid=[%@]", action.callUUID.uuidString)
    
    do {
      if action.isOnHold {
        try Dialer.shared.holdCall(uuid: action.callUUID)
        _currentCallUuid = CallManager.kNullUUID
        DispatchQueue.main.async {
          self.onHold = true
        }
      } else {
        try Dialer.shared.resumeCall(uuid: action.callUUID)
        _currentCallUuid = action.callUUID
        DispatchQueue.main.async {
          self.onHold = false
        }
      }
      action.fulfill()
      doUserActionCleanup()
    } catch {
      _logger.writeError(error)
      
      action.fail()
      
      doUserActionCleanup(error: error)
    }
  }

  /// Mutes or unmutes the microphone for the current call.
  ///
  /// - Parameters:
  ///   - completion Code to execute after the transaction is completed
  func muteOrUnmuteCall(completion: @escaping ActionCompletion = { _ in /* Empty */ }) {
    doUserActionStartup(completion)

    // Get the current state of the microphone and invert it. So if the we're currently muted
    // then the action is to unmute it and vice versa.
    let isMuted = Dialer.shared.isMicrophoneMuted(uuid: _currentCallUuid)
    let action = CXSetMutedCallAction(call: _currentCallUuid, muted: !isMuted)

    _controller.requestTransaction(with: action) { error in
      if let error = error {
        self._logger.writeError(error)
      }
      completion(error)
    }
  }

  /// Processes the set-mute action. Invoked via the provider delegate trampoline.
  fileprivate func handleSetMuteCallAction(_ action: CXSetMutedCallAction) {
    _logger.write("uuid=[%@], isMuted=[%@]",
                  action.callUUID.uuidString, action.isMuted ? "yes" : "no")
    
    // It appears that CallKit automatically generates an "unumte" event at the end of the call
    // if the call was dropped while it was muted. It is possible for CallKit to generete this
    // event *after* we've finished dropping the call. That is problematic since we cannot make
    // any calls into Dialer if the UUID no longer represents a valid call.
    //
    // FIXME: I believe there is still a race condition here! If so then this needs to be resolved
    // within Dialer, and that's something that I'd like to avoid.
    if !Dialer.shared.isValidCall(action.callUUID) {
      _logger.write("uuid=[%@], call no longer exists", type: .error, action.callUUID.uuidString)
      action.fulfill()
      doUserActionCleanup()
      return
    }
    
    do {
      if action.isMuted {
        try Dialer.shared.muteMicrophone(uuid: action.callUUID)
        DispatchQueue.main.async {
          self.isMuted = true
        }
      } else {
        try Dialer.shared.unmuteMicrophone(uuid: action.callUUID)
        DispatchQueue.main.async {
          self.isMuted = false
        }
      }
      
      action.fulfill()
      doUserActionCleanup()
      
    } catch {
      _logger.writeError(error)
      action.fail()
      doUserActionCleanup(error: error)
    }
  }

  /// Invoked by the push meanager whenever a voIP push notification is received.
  ///
  /// - Parameters:
  ///   - notification: Instance of `InboundCallOffer` describing the expected call.
  ///                   This information will also be used to set up the CallKit
  ///                   incoming call screen.
  func onPushArrived(descriptor: InboundCallDescriptor) {
    // Save this information for later
    _inboundCallDescriptor = descriptor
    
    // If we're currently in the middle of a call setup then we abort the call that is
    // currently being set up. The inbound call taks priority. Of course, if we have an
    // establieshed current call then we'll proceed and let the user interact with
    // CallKit and decide how to proceed.
    if _makeCallInProgress.isEqualTo(true) {
      dropCurrentCall()
    }

    // Suppress published property reset. See the comment attached to the definition
    // of this field above. This is necessary here because, in those cases when the user
    // is already on a call when a push arrives and they decide to drop the current
    // call and accept the inbound one, CallKit will issue EndCall, followed by an
    // AnswerCall. If EndCall clears the inCall property and one of its observers
    // causes a call drop it may and probably will end up dropping the call that gets
    // established via AnswerCall.
    _suppressPublishedPropertyReset = true
    
    let uuid = UUID()
    
    _logger.write("clid=[%@], uuid=[%@]", descriptor.clid, uuid.uuidString)
    
    let update = CXCallUpdate()
    update.localizedCallerName = descriptor.localizedDisplayName
    update.hasVideo = descriptor.hasVideo
    update.remoteHandle = CXHandle(type: .phoneNumber, value: descriptor.clid)
    update.supportsGrouping = false
    update.supportsUngrouping = false
    update.supportsHolding = false
  
    _provider.reportNewIncomingCall(with: uuid, update: update) { error in
      if let error = error {
        self._logger.writeError(error)
      } else {
        self._dispatchQueue.async {
          do {
            // Start waiting for a call here. Note that the following call doesn't block.
            // Once the call arrives, the underlying layers will invoke onInboundCallArrived
            // which will trip the blocking barrier.
            self._incomingCallUuid = uuid
            self._waitingForInboundCall.setAndNotify(newValue: true)
            try Dialer.shared.waitForCall(with: uuid)
          } catch {
            self._logger.writeError(error)
          }
        }
      }
    }
  }

  /// Invoked by the dialer whenever a new call arrives.
  fileprivate func onInboundCallArrived(uuid: UUID)  {
    _logger.write("uuid=[%@]", uuid.uuidString)
    
    // At this point we know more about the call. Tell CallKit about it so that it can
    // update the CallKit call screen if it is being shown.
    let info = Dialer.shared.getCallInfo(uuid: uuid)
    let remoteClid = info.remoteClid ?? "Unavailable"
    let remoteName = getRemotePartyName(phoneNumber: remoteClid, defaultName: "Unknown")
    
    let update = CXCallUpdate()
    update.localizedCallerName = remoteName.isEmpty ? remoteClid : remoteName
    _provider.reportCall(with: uuid, updated: update)
    
    // Update our published properties
    DispatchQueue.main.async {
      self.remotePartyName = remoteName
      self.remotePartyClid = remoteClid
    }

    _waitingForInboundCall.setAndNotify(newValue: false)
  }
  
  fileprivate func _handleAnswerCallActionAsync(_ action: CXAnswerCallAction) {
   
    // Enable published property reset
    _suppressPublishedPropertyReset = false

    // The call may not be available just yet. Therefore, we'll wait for it to
    // arrive before we try to answer it.
    if !_waitingForInboundCall.wait(untilEqualTo: false,
                                    timeout: Configuration.shared.answerTimeout) {
      _logger.write("uid=[%@]: call did not arrive in time", action.callUUID.uuidString)
      action.fail()
      return
    }
    
    // Kludge alert! This is possibly related to: http://www.openradar.appspot.com/28774388.
    // The problem is that CallKit does not activate the audio session and we time out
    // below. The solution seems to be to configure the audio session ourselvees.
    configureAudioSession(AVAudioSession.sharedInstance())
    
    // Fulfill this action now. This is when CallKit will start initializing
    // the audio session. Note that this happens despite our sassion already having been
    // configured in the above step. Consequently, we end up configuring the session
    // twice.
    action.fulfill()
    
    // Now wait for the session to finish initializing. If we proceed and CallKit has not
    // finished initializing the audio session and answer the call, the call will end up
    // without audio.
    //
    // FIXME: for now, in case of timeout, we'll simply not answer the call. If we try
    // to drop the call at this point we may crash. This needs to be investigated.
    
    
    /*if (!_audioSessionReady.wait(untilEqualTo: true, timeout: 20.0)) {
      NSLog("audio session not ready")
      _logger.write("uid=[%@]: audio session not ready", action.callUUID.uuidString)
      return
    }*/
  
    do {
      
      //self._addDelayinCallAnswer.wait(untilEqualTo: true)
      
      // At this point we know we have a call that we can answer.
      try Dialer.shared.answerCall(uuid: action.callUUID)
      
      DispatchQueue.main.async {
        // Let everyone know that we're no longer connecting (we're connected).
        self.isConnecting = false;
      }
      startCallTimer()
      
      ModuleWithEmitter.emitter.sendEvent(withName: "getInboundCall", body: ["phoneNumber" : self.remotePartyClid])
      
    } catch {
      _logger.writeError(error)
      dropCurrentCall()
    }
  }

  /// Handles the answer-call action. Invoked via the provider delegate trampoline.
  fileprivate func handleAnswerCallAction(_ action: CXAnswerCallAction) {
    precondition(_currentCallUuid == CallManager.kNullUUID)
    
    _logger.write("uuid=[%@]", action.callUUID.uuidString)
    
  /*  DispatchQueue.main.asyncAfter(deadline: .now() + 5.0) {
      self._addDelayinCallAnswer.setAndNotify(newValue: true)
    }*/
    
    self.inCall = true
    self.isConnecting = true
    self.callDuration = 0
    self._callTimer?.invalidate()
    
    // We no longer need this notification
    _inboundCallDescriptor = nil
    
    // This becomes our current call.
    _currentCallUuid = action.callUUID
    answerAction = action
   
    DispatchQueue.main.asyncAfter(deadline: .now() + 2.0) {
      self._dispatchQueue.async {
        self._handleAnswerCallActionAsync(action)
      }
    }

  }
 
  
  fileprivate func getRemotePartyName(phoneNumber: String, defaultName: String) -> String {
    let results = ContactManager.shared.search(phoneNumber: phoneNumber)
  
    // Very simple name formatting. This should be isolated into its own class so that we can
    // properly handle different name formatting standards/customs/...
    if !results.isEmpty {
      if !results[0].firstName.isEmpty {
        if !results[0].lastName.isEmpty {
          return results[0].lastName + ", " + results[0].firstName
        } else {
          return results[0].firstName
        }
      } else {
        if !results[0].lastName.isEmpty {
          return results[0].lastName
        }
      }
    }
  
    return defaultName
  }
}

///
/// CXProvider delegate implementation.
///
internal class ProviderDelegateTrampoline: NSObject, CXProviderDelegate {
  static let instance = ProviderDelegateTrampoline()

  private override init() {
    super.init()
  }

  func providerDidReset(_ provider: CXProvider) {
    CallManager.shared.dropCurrentCall { _ in /* Ignored */ }
  }

  func provider(_ provider: CXProvider, didActivate audioSession: AVAudioSession) {
    CallManager.shared.onAudioSessionActivated(audioSession)
  }
  
  func provider(_ provider: CXProvider, didDeactivate audioSession: AVAudioSession) {
    CallManager.shared.onAudioSessionDeactivated(audioSession)
  }

  func provider(_ provider: CXProvider, perform action: CXStartCallAction) {
    CallManager.shared.handleStartCallAction(action)
  }

  func provider(_ provider: CXProvider, perform action: CXAnswerCallAction) {
    CallManager.shared.handleAnswerCallAction(action)
  }

  func provider(_ provider: CXProvider, perform action: CXEndCallAction) {
    CallManager.shared.handleEndCallAction(action)
  }

  func provider(_ provider: CXProvider, perform action: CXSetHeldCallAction) {
    CallManager.shared.handleSetHeldCallAction(action)
  }

  func provider(_ provider: CXProvider, perform action: CXSetMutedCallAction) {
    CallManager.shared.handleSetMuteCallAction(action)
  }
}


