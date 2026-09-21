import QtQuick
import Quickshell
import Quickshell.Services.Polkit
import "../components" as CM
import ".."

Scope {
  id: polkitModule

  PolkitAgent {
    id: agent
  }

  FloatingWindow {
    id: dialog

    visible: agent.isActive
    title: "quickshell-polkit"
    color: "transparent"
    implicitWidth: 420
    implicitHeight: content.implicitHeight + T.spaceM * 2

    onClosed: agent.flow?.cancelAuthenticationRequest()
    onVisibleChanged: {
      if (visible && agent.flow?.isResponseRequired)
        Qt.callLater(() => response.forceActiveFocus());
    }

    CM.Surface {
      anchors.fill: parent

      Column {
        id: content
        anchors {
          top: parent.top
          left: parent.left
          right: parent.right
          margins: T.spaceM
        }
        spacing: T.spaceM

        Text {
          width: parent.width
          color: T.colF
          font {
            family: T.fontMono
            pointSize: T.fontSizeH
            bold: true
          }
          wrapMode: Text.Wrap
          text: "Authentication required"
        }

        Text {
          width: parent.width
          color: T.colF
          font {
            family: T.fontSans
            pointSize: T.fontSizeB
          }
          wrapMode: Text.Wrap
          textFormat: Text.PlainText
          text: agent.flow?.message ?? ""
        }

        Text {
          width: parent.width
          visible: text.length > 0
          color: T.colM
          font {
            family: T.fontSans
            pointSize: T.fontSizeB
          }
          wrapMode: Text.Wrap
          textFormat: Text.PlainText
          text: agent.flow?.inputPrompt ?? ""
        }

        Text {
          width: parent.width
          visible: text.length > 0
          color: agent.flow?.supplementaryIsError ? T.colS : T.colM
          font {
            family: T.fontSans
            pointSize: T.fontSizeB
          }
          wrapMode: Text.Wrap
          textFormat: Text.PlainText
          text: agent.flow?.supplementaryMessage ?? ""
        }

        Text {
          width: parent.width
          visible: agent.flow?.failed ?? false
          color: T.colS
          font {
            family: T.fontSans
            pointSize: T.fontSizeB
          }
          text: "Authentication failed"
        }

        Rectangle {
          width: parent.width
          height: T.spaceL * 1.5
          radius: T.spaceS
          color: T.colO

          TextInput {
            id: response
            anchors {
              fill: parent
              margins: T.spaceS
            }
            enabled: agent.flow?.isResponseRequired ?? false
            color: T.colF
            selectionColor: T.colP
            selectedTextColor: T.colO
            font {
              family: T.fontMono
              pointSize: T.fontSizeB
            }
            echoMode: agent.flow?.responseVisible ? TextInput.Normal : TextInput.Password
            inputMethodHints: Qt.ImhSensitiveData | Qt.ImhNoPredictiveText
            verticalAlignment: TextInput.AlignVCenter

            function submit() {
              if (!agent.flow?.isResponseRequired)
                return;
              agent.flow.submit(text);
              text = "";
            }

            onAccepted: submit()
            Keys.onEscapePressed: agent.flow?.cancelAuthenticationRequest()
          }
        }

        Row {
          anchors.right: parent.right
          spacing: T.spaceS

          Rectangle {
            width: cancelText.implicitWidth + T.spaceM * 2
            height: T.spaceL
            radius: T.spaceS
            color: T.colO

            Text {
              id: cancelText
              anchors.centerIn: parent
              color: T.colF
              font {
                family: T.fontMono
                pointSize: T.fontSizeB
              }
              text: "Cancel"
            }

            TapHandler {
              onTapped: agent.flow?.cancelAuthenticationRequest()
            }
          }

          Rectangle {
            width: authenticateText.implicitWidth + T.spaceM * 2
            height: T.spaceL
            radius: T.spaceS
            color: T.colP
            opacity: agent.flow?.isResponseRequired ? 1 : 0.5

            Text {
              id: authenticateText
              anchors.centerIn: parent
              color: T.colO
              font {
                family: T.fontMono
                pointSize: T.fontSizeB
                bold: true
              }
              text: "Authenticate"
            }

            TapHandler {
              enabled: agent.flow?.isResponseRequired ?? false
              onTapped: response.submit()
            }
          }
        }
      }
    }

    Connections {
      target: agent

      function onFlowChanged() {
        response.text = "";
        if (agent.flow?.isResponseRequired)
          Qt.callLater(() => response.forceActiveFocus());
      }
    }

    Connections {
      target: agent.flow

      function onIsResponseRequiredChanged() {
        response.text = "";
        if (agent.flow?.isResponseRequired)
          Qt.callLater(() => response.forceActiveFocus());
      }

      function onAuthenticationSucceeded() {
        response.text = "";
      }
      function onAuthenticationRequestCancelled() {
        response.text = "";
      }
    }
  }
}
