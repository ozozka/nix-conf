import QtQuick
import Quickshell
import Quickshell.Io
import Quickshell.Services.Pam
import Quickshell.Wayland
import "../components" as CM
import ".."

Scope {
  id: lockModule

  property string pendingResponse: ""
  property bool authenticating: false
  property bool authenticationFailed: false
  property bool awaitingUserResponse: false
  property bool suspendPending: false

  function engage() {
    if (pam.active)
      pam.abort();
    pendingResponse = "";
    authenticating = false;
    authenticationFailed = false;
    awaitingUserResponse = false;
    sessionLock.locked = true;
  }

  function submit(response) {
    if (!sessionLock.locked || response.length === 0)
      return;
    authenticationFailed = false;

    if (pam.active) {
      if (awaitingUserResponse && pam.responseRequired) {
        awaitingUserResponse = false;
        pam.respond(response);
      }
      return;
    }

    pendingResponse = response;
    awaitingUserResponse = false;
    authenticating = pam.start();
    if (!authenticating) {
      pendingResponse = "";
      authenticationFailed = true;
    }
  }

  function suspendWhenSecure() {
    suspendPending = true;
    engage();
    if (sessionLock.secure)
      suspend();
    else
      suspendTimeout.restart();
  }

  function suspend() {
    if (!suspendPending || !sessionLock.secure)
      return;
    suspendPending = false;
    suspendTimeout.stop();
    Quickshell.execDetached(["systemctl", "suspend-then-hibernate"]);
  }

  IpcHandler {
    target: "lock"
    function lock(): void {
    lockModule.engage();
  }
    function suspend(): void {
                          lockModule.suspendWhenSecure();
                        }
  }

  PamContext {
    id: pam
    config: "quickshell"

    onPamMessage: {
      if (responseRequired && lockModule.pendingResponse.length > 0) {
        const response = lockModule.pendingResponse;
        lockModule.pendingResponse = "";
        lockModule.awaitingUserResponse = false;
        respond(response);
      } else {
        lockModule.awaitingUserResponse = responseRequired;
      }
    }

    onCompleted: result => {
      lockModule.pendingResponse = "";
      lockModule.authenticating = false;
      lockModule.awaitingUserResponse = false;

      if (result === PamResult.Success) {
        lockModule.authenticationFailed = false;
        sessionLock.locked = false;
      } else {
        lockModule.authenticationFailed = true;
      }
    }

    onError: error => console.error("Lock PAM error:", PamError.toString(error))
  }

  WlSessionLock {
    id: sessionLock
    locked: false

    onSecureChanged: {
      if (secure)
        lockModule.suspend();
    }

    WlSessionLockSurface {
      color: T.colO

      CM.Surface {
        anchors.centerIn: parent
        width: 360
        height: lockContent.implicitHeight + T.spaceM * 2

        Column {
          id: lockContent
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
            horizontalAlignment: Text.AlignHCenter
            font {
              family: T.fontMono
              pointSize: T.fontSizeT
              bold: true
            }
            text: "Locked"
          }

          Rectangle {
            width: parent.width
            height: T.spaceL * 1.5
            radius: T.spaceS
            color: T.colO

            TextInput {
              id: password
              anchors {
                fill: parent
                margins: T.spaceS
              }
              focus: true
              enabled: !pam.active || lockModule.awaitingUserResponse
              color: T.colF
              selectionColor: T.colP
              selectedTextColor: T.colO
              font {
                family: T.fontMono
                pointSize: T.fontSizeB
              }
              echoMode: pam.responseRequired && pam.responseVisible ? TextInput.Normal : TextInput.Password
              inputMethodHints: Qt.ImhSensitiveData | Qt.ImhNoPredictiveText
              verticalAlignment: TextInput.AlignVCenter

              onTextChanged: lockModule.authenticationFailed = false
              onAccepted: {
                lockModule.submit(text);
                text = "";
              }
            }
          }

          Text {
            width: parent.width
            visible: lockModule.authenticationFailed
            color: T.colS
            horizontalAlignment: Text.AlignHCenter
            font {
              family: T.fontSans
              pointSize: T.fontSizeB
            }
            text: "Authentication failed"
          }

          Text {
            width: parent.width
            visible: lockModule.authenticating
            color: T.colM
            horizontalAlignment: Text.AlignHCenter
            font {
              family: T.fontSans
              pointSize: T.fontSizeB
            }
            text: lockModule.awaitingUserResponse ? pam.message : "Authenticating"
          }
        }
      }

      Connections {
        target: lockModule

        function onAuthenticatingChanged() {
          if (!lockModule.authenticating) {
            password.text = "";
            password.forceActiveFocus();
          }
        }
      }
    }
  }

  Timer {
    id: suspendTimeout
    interval: 5000
    onTriggered: {
      if (lockModule.suspendPending)
        console.error("Session lock was not secured; refusing to suspend");
      lockModule.suspendPending = false;
    }
  }
}
