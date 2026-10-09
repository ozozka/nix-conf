import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import Quickshell
import Quickshell.Io
import Quickshell.Networking
import Quickshell.Bluetooth
import Quickshell.Services.Pipewire
import "../services" as SV
import ".."

ColumnLayout {
  id: controls
  property bool active: false
  property string expanded: ""
  property var selectionAnchor: null
  property var pendingNetwork: null
  property var passwordNetwork: null
  property string passwordText: ""
  property string pairingText: ""
  property string networkError: ""
  readonly property bool scanning: scan.running || scanSettling.running
  readonly property var wifiDevices: Networking.devices.values.filter(device => device.type === DeviceType.Wifi)
  readonly property var wifiDevice: wifiDevices.find(device => device.connected) ?? wifiDevices[0] ?? null
  readonly property var connectedNetwork: wifiDevice?.networks.values.find(network => network.connected) ?? null
  readonly property var adapter: Bluetooth.defaultAdapter
  readonly property var audioCandidates: Pipewire.nodes.values.filter(node => !node.isStream && node.audio)
  readonly property var audioDevices: audioCandidates.filter(node => audioMetadata.availability(node) !== "no")
  signal detailsRequested
  signal passwordRequested
  spacing: T.spaceS

  function reset() {
    expanded = "";
    selectionAnchor = null;
    passwordNetwork = null;
    passwordText = "";
    pairingText = "";
    pendingNetwork = null;
    networkError = "";
    scan.running = false;
    scanSettling.stop();
    if (pairing.busy)
      pairing.cancel();
  }

  function toggleDetails(section, anchor = null) {
    const next = expanded === section ? "" : section;
    reset();
    selectionAnchor = anchor;
    expanded = next;
    detailsRequested();
  }

  function refreshWifi() {
    if (!wifiDevice || !Networking.wifiEnabled || !Networking.wifiHardwareEnabled || scanning)
      return;
    networkError = "";
    scan.command = ["nmcli", "--wait", "15", "device", "wifi", "rescan", "ifname", wifiDevice.name];
    scan.running = true;
  }

  function connectNetwork(network) {
    networkError = "";
    passwordNetwork = null;
    pendingNetwork = network;
    if (network.connected)
      network.disconnect();
    else
      network.connect();
  }

  function submitPassword() {
    if (!passwordNetwork || !passwordText.length)
      return;
    pendingNetwork = passwordNetwork;
    pendingNetwork.connectWithPsk(passwordText);
    passwordText = "";
    passwordNetwork = null;
  }

  Process {
    id: scan
    stdout: StdioCollector {
      id: scanOutput
    }
    stderr: StdioCollector {
      id: scanError
    }
    onExited: (code, status) => {
      if (!controls.active || controls.expanded !== "wifi")
        return;
      if (code === 0 && status === 0)
        scanSettling.restart();
      else
        controls.networkError = scanError.text.trim() || scanOutput.text.trim() || "Wi-Fi scan failed.";
    }
  }
  // nmcli acknowledges the request before NetworkManager publishes the results.
  Timer {
    id: scanSettling
    interval: 3000
  }

  Binding {
    target: controls.wifiDevice
    property: "scannerEnabled"
    value: true
    when: controls.active && controls.expanded === "wifi" && controls.wifiDevice !== null && Networking.wifiEnabled
    restoreMode: Binding.RestoreBindingOrValue
  }
  Binding {
    target: controls.adapter
    property: "discovering"
    value: true
    when: controls.active && controls.expanded === "bluetooth" && (controls.adapter?.enabled ?? false)
    restoreMode: Binding.RestoreBindingOrValue
  }
  Connections {
    target: controls.pendingNetwork
    function onConnectionFailed(reason) {
      if (reason === ConnectionFailReason.NoSecrets && [WifiSecurityType.WpaPsk, WifiSecurityType.Wpa2Psk,
                                                        WifiSecurityType.Sae].includes(
            controls.pendingNetwork.security)) {
        controls.passwordNetwork = controls.pendingNetwork;
        controls.networkError = "Enter the Wi-Fi password.";
        controls.passwordRequested();
      } else {
        controls.networkError = reason === ConnectionFailReason.NoSecrets
            ? "This network requires credentials in a NetworkManager connection profile." :
              ConnectionFailReason.toString(reason);
      }
    }
  }
  SV.BluetoothPairing {
    id: pairing
  }
  PwObjectTracker {
    objects: controls.audioCandidates
  }
  SV.AudioDevices {
    id: audioMetadata
    active: controls.active
    nodes: controls.audioCandidates
  }
  Connections {
    target: SV.PowerProfiles
    function onBackendPresentChanged() {
      if (!SV.PowerProfiles.backendPresent && controls.expanded === "profiles")
        controls.toggleDetails("profiles");
    }
  }

  component SectionText: Text {
    color: T.colF
    font.family: T.fontSans
    font.pointSize: T.fontSizeB
    wrapMode: Text.Wrap
  }

  component AudioSummary: MenuButton {
    id: summary
    required property bool input
    readonly property var node: input ? Pipewire.defaultAudioSource : Pipewire.defaultAudioSink
    readonly property bool available: !!node?.ready && !!node?.audio
    Layout.fillWidth: true
    Layout.minimumWidth: 0
    symbol: input ? "♩" : "♫"
    text: (input ? "Microphone · " : "Speaker · ") + audioMetadata.label(node)
    valueText: available ? `${Math.round(node.audio.volume * 100)}%` : "—"
    Accessible.description: (muted ? "Muted · " : "") + valueText
    muted: available && node.audio.muted
    enabled: controls.audioDevices.some(device => device.isSink !== input)
    selected: controls.expanded === (input ? "input" : "output")
    onClicked: controls.toggleDetails(input ? "input" : "output", summary)
  }

  MenuButton {
    id: wifiButton
    Layout.fillWidth: true
    symbol: "≋"
    text: {
      if (!controls.wifiDevice)
        return "Wi-Fi · unavailable";
      if (!Networking.wifiHardwareEnabled)
        return "Wi-Fi · blocked";
      if (!Networking.wifiEnabled)
        return "Wi-Fi · off";
      return "Wi-Fi · " + (controls.connectedNetwork?.name || "Not connected");
    }
    selected: controls.expanded === "wifi"
    enabled: controls.wifiDevice !== null
    onClicked: controls.toggleDetails("wifi", wifiButton)
  }
  MenuButton {
    id: bluetoothButton
    Layout.fillWidth: true
    symbol: "⋈"
    text: !controls.adapter ? "Bluetooth · unavailable" : !controls.adapter.enabled ? "Bluetooth · off" : "Bluetooth · "
                                                                                      + controls.adapter.devices.values.filter(
                                                                                        device => device.connected).length
                                                                                      + " connected"
    selected: controls.expanded === "bluetooth"
    enabled: controls.adapter !== null
    onClicked: controls.toggleDetails("bluetooth", bluetoothButton)
  }
  MenuButton {
    id: profilesButton
    visible: SV.PowerProfiles.backendPresent
    Layout.fillWidth: true
    symbol: "⚡︎"
    text: SV.PowerProfiles.available ? `Power · ${SV.PowerProfiles.activeProfile}` : "Power profile · unavailable"
    selected: controls.expanded === "profiles"
    enabled: SV.PowerProfiles.available
    onClicked: controls.toggleDetails("profiles", profilesButton)
  }
  AudioSummary {
    input: false
  }
  AudioSummary {
    input: true
  }

  component AudioOptions: ColumnLayout {
    id: audioControl
    required property bool input
    readonly property var node: input ? Pipewire.defaultAudioSource : Pipewire.defaultAudioSink
    readonly property bool available: !!node?.ready && !!node?.audio
    readonly property var devices: controls.audioDevices.filter(device => device.isSink !== input)
    spacing: T.spaceS
    SectionText {
      Layout.fillWidth: true
      text: audioMetadata.label(audioControl.node)
      color: audioControl.available && audioControl.node.audio.muted ? T.colM : T.colF
    }
    RowLayout {
      Layout.fillWidth: true
      Slider {
        id: volume
        Layout.fillWidth: true
        from: 0
        to: 1.5
        value: audioControl.available ? audioControl.node.audio.volume : 0
        enabled: audioControl.available
        onMoved: audioControl.node.audio.volume = value
        background: Rectangle {
          x: volume.leftPadding
          y: volume.topPadding + volume.availableHeight / 2 - height / 2
          width: volume.availableWidth
          height: 4
          color: T.colB
          Rectangle {
            width: volume.visualPosition * parent.width
            height: parent.height
            color: audioControl.available && audioControl.node.audio.muted ? T.colM : T.colP
          }
        }
        handle: Rectangle {
          x: volume.leftPadding + volume.visualPosition * (volume.availableWidth - width)
          y: volume.topPadding + volume.availableHeight / 2 - height / 2
          implicitWidth: 14
          implicitHeight: 20
          color: !volume.enabled || audioControl.node.audio.muted ? T.colM : volume.activeFocus ? T.colF : T.colP
        }
      }
      SectionText {
        Layout.preferredWidth: 52
        horizontalAlignment: Text.AlignRight
        font.family: T.fontMono
        text: audioControl.available ? `${Math.round(audioControl.node.audio.volume * 100)}%` : "—"
        color: audioControl.available && audioControl.node.audio.muted ? T.colM : T.colF
      }
    }
    MenuButton {
      text: audioControl.available && audioControl.node.audio.muted ? "Unmute" : "Mute"
      selected: audioControl.available && audioControl.node.audio.muted
      enabled: audioControl.available
      onClicked: audioControl.node.audio.muted = !audioControl.node.audio.muted
    }
    SectionText {
      text: "Devices"
      font.bold: true
    }
    Repeater {
      model: audioControl.devices
      MenuButton {
        required property var modelData
        Layout.fillWidth: true
        text: audioMetadata.label(modelData) + (audioMetadata.availability(modelData) === "unknown"
                                                ? " · Availability unknown" : "")
        selected: audioControl.node === modelData
        onClicked: {
          if (audioControl.input)
            Pipewire.preferredDefaultAudioSource = modelData;
          else
            Pipewire.preferredDefaultAudioSink = modelData;
        }
      }
    }
  }

  // Instantiated by the selection widget, not laid out inside the main menu.
  property Component details: Component {
    ColumnLayout {
      spacing: T.spaceS
      ColumnLayout {
        Layout.fillWidth: true
        visible: controls.expanded === "profiles"
        spacing: T.spaceS
        Repeater {
          model: SV.PowerProfiles.availableProfiles
          MenuButton {
            required property string modelData
            Layout.fillWidth: true
            text: modelData
            selected: SV.PowerProfiles.activeProfile === modelData
            enabled: SV.PowerProfiles.available && !SV.PowerProfiles.busy
            onClicked: SV.PowerProfiles.setProfile(modelData)
          }
        }
        SectionText {
          Layout.fillWidth: true
          visible: text.length > 0
          color: T.colS
          text: SV.PowerProfiles.error
        }
      }

      ColumnLayout {
        Layout.fillWidth: true
        visible: controls.expanded === "wifi"
        spacing: T.spaceS
        RowLayout {
          Layout.fillWidth: true
          MenuButton {
            symbol: "⏻"
            Accessible.name: Networking.wifiEnabled ? "Turn Wi-Fi off" : "Turn Wi-Fi on"
            muted: !Networking.wifiEnabled
            enabled: !!controls.wifiDevice && Networking.wifiHardwareEnabled
            onClicked: Networking.wifiEnabled = !Networking.wifiEnabled
          }
          Item {
            Layout.fillWidth: true
          }
          MenuButton {
            symbol: "↻"
            Accessible.name: controls.scanning ? "Refreshing Wi-Fi" : "Scan / Refresh Wi-Fi"
            selected: controls.scanning
            enabled: !!controls.wifiDevice && Networking.wifiEnabled && Networking.wifiHardwareEnabled &&
                     !controls.scanning

            onClicked: controls.refreshWifi()
          }
        }
        SectionText {
          Layout.fillWidth: true
          visible: !controls.wifiDevice || !Networking.wifiHardwareEnabled || !Networking.wifiEnabled || !(controls.wifiDevice
                                                                                                           ?.networks.values.length
                                                                                                           ?? 0)
          text: !controls.wifiDevice ? "Wi-Fi device unavailable." : !Networking.wifiHardwareEnabled
                                       ? "Wi-Fi is blocked by the hardware switch." : !Networking.wifiEnabled
                                         ? "Wi-Fi is off." : controls.scanning ? "Looking for networks…" :
                                                                                 "No networks found."
          color: T.colM
        }
        Repeater {
          model: controls.wifiDevice?.networks.values ?? []
          MenuButton {
            required property var modelData
            Layout.fillWidth: true
            text: modelData.name + (modelData.connected ? " · Disconnect" : modelData.stateChanging ? " · Working…" :
                                                                                                      "")
            valueText: `${Math.round(modelData.signalStrength * 100)}%`
            selected: modelData.connected
            enabled: Networking.wifiEnabled && !modelData.stateChanging
            onClicked: controls.connectNetwork(modelData)
          }
        }
        SectionText {
          Layout.fillWidth: true
          visible: text.length > 0
          text: controls.networkError
          color: controls.passwordNetwork ? T.colM : T.colS
        }
        TextField {
          id: password
          Layout.fillWidth: true
          visible: controls.passwordNetwork !== null
          text: controls.passwordText
          onTextEdited: controls.passwordText = text
          placeholderText: "Wi-Fi password"
          echoMode: TextInput.Password
          color: T.colF
          placeholderTextColor: T.colM
          selectionColor: T.colP
          selectedTextColor: T.colO
          font.family: T.fontSans
          font.pointSize: T.fontSizeB
          background: Rectangle {
            color: T.colB
          }
          onAccepted: controls.submitPassword()
          Connections {
            target: controls
            function onPasswordRequested() {
              Qt.callLater(() => password.forceActiveFocus());
            }
          }
        }
        MenuButton {
          visible: controls.passwordNetwork !== null
          text: "Connect"
          onClicked: controls.submitPassword()
        }
      }

      ColumnLayout {
        Layout.fillWidth: true
        visible: controls.expanded === "bluetooth"
        spacing: T.spaceS
        MenuButton {
          Layout.fillWidth: true
          text: controls.adapter?.enabled ? "Turn Bluetooth off" : "Turn Bluetooth on"
          enabled: controls.adapter !== null && !pairing.busy
          onClicked: controls.adapter.enabled = !controls.adapter.enabled
        }
        Repeater {
          model: controls.adapter?.devices.values ?? []
          MenuButton {
            required property var modelData
            Layout.fillWidth: true
            text: (modelData.name || modelData.address) + " · " + (modelData.pairing ? "Pairing…" : modelData.connected ? "Disconnect" :
                                                                                                                          modelData.paired
                                                                                                                          ? "Connect" :
                                                                                                                            "Pair")
            selected: modelData.connected
            enabled: !!controls.adapter?.enabled && !pairing.busy && !modelData.pairing &&
                     ![BluetoothDeviceState.Connecting, BluetoothDeviceState.Disconnecting].includes(modelData.state)
            onClicked: {
              if (modelData.paired)
                modelData.connected = !modelData.connected;
              else
                pairing.pair(modelData);
            }
          }
        }
        SectionText {
          Layout.fillWidth: true
          visible: text.length > 0
          text: pairing.status
          color: T.colM
        }
        SectionText {
          Layout.fillWidth: true
          visible: text.length > 0
          text: pairing.prompt
          font.bold: true
        }
        TextField {
          Layout.fillWidth: true
          visible: pairing.busy && pairing.prompt.length > 0 && !pairing.confirmation
          text: controls.pairingText
          onTextEdited: controls.pairingText = text
          placeholderText: "PIN / passkey"
          color: T.colF
          placeholderTextColor: T.colM
          font.family: T.fontMono
          background: Rectangle {
            color: T.colB
          }
          onAccepted: {
            pairing.respond(text);
            controls.pairingText = "";
          }
        }
        RowLayout {
          visible: pairing.busy && pairing.prompt.length > 0
          MenuButton {
            text: pairing.confirmation ? "Confirm" : "Send"
            onClicked: {
              pairing.respond(pairing.confirmation ? "yes" : controls.pairingText);
              controls.pairingText = "";
            }
          }
          MenuButton {
            text: "Cancel"
            onClicked: pairing.cancel()
          }
        }
        MenuButton {
          visible: pairing.busy && !pairing.prompt
          text: "Cancel pairing"
          onClicked: pairing.cancel()
        }
      }
      AudioOptions {
        Layout.fillWidth: true
        visible: controls.expanded === "output" || controls.expanded === "input"
        input: controls.expanded === "input"
      }
    }
  }
}
