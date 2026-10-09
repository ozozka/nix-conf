import QtQuick
import Quickshell
import Quickshell.Services.Polkit
import ".."

Scope {
  PolkitAgent {
    id: agent
  }

  FloatingWindow {
    visible: agent.isActive
    title: "quickshell-polkit"
    color: "transparent"
    implicitWidth: 420
    implicitHeight: content.implicitHeight + T.dimS * 2

    onClosed: agent.flow?.cancelAuthenticationRequest()
    onVisibleChanged: {
      if (visible && agent.flow?.isResponseRequired)
        Qt.callLater(() => response.forceActiveFocus());
    }

    Rectangle {
      color: T.colO
      anchors.fill: parent

      Column {
        id: content
        anchors {
          top: parent.top
          left: parent.left
          right: parent.right
          margins: T.dimS
        }
        spacing: T.dimS

        Text {
          width: parent.width
          color: T.colF
          font {
            family: "monospace"
            pointSize: T.fontSizeL
            bold: true
          }
          wrapMode: Text.Wrap
          text: "Authentication required"
        }

        Text {
          width: parent.width
          color: T.colF
          font {
            family: "sans-serif"
            pointSize: T.fontSizeM
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
            family: "sans-serif"
            pointSize: T.fontSizeM
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
            family: "sans-serif"
            pointSize: T.fontSizeM
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
            family: "sans-serif"
            pointSize: T.fontSizeM
          }
          text: "Authentication failed"
        }

        Rectangle {
          width: parent.width
          height: T.dimM * 1.5
          color: T.colO

          TextInput {
            id: response
            anchors {
              fill: parent
              margins: T.dimS
            }
            enabled: agent.flow?.isResponseRequired ?? false
            color: T.colF
            selectionColor: T.colP
            selectedTextColor: T.colO
            font {
              family: "monospace"
              pointSize: T.fontSizeM
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
          spacing: T.dimS

          Rectangle {
            width: cancelText.implicitWidth + T.dimS * 2
            height: T.dimM
            color: T.colO

            Text {
              id: cancelText
              anchors.centerIn: parent
              color: T.colF
              font {
                family: "monospace"
                pointSize: T.fontSizeM
              }
              text: "Cancel"
            }

            TapHandler {
              onTapped: agent.flow?.cancelAuthenticationRequest()
            }
          }

          Rectangle {
            width: authenticateText.implicitWidth + T.dimS * 2
            height: T.dimM
            color: agent.flow?.isResponseRequired ? T.colP : T.colM

            Text {
              id: authenticateText
              anchors.centerIn: parent
              color: T.colO
              font {
                family: "monospace"
                pointSize: T.fontSizeM
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
