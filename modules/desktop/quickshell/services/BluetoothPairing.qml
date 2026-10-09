import QtQuick
import Quickshell
import Quickshell.Io

Scope {
  id: pairing
  property var device: null
  property string prompt: ""
  property string status: ""
  property bool confirmation: false
  readonly property bool busy: agent.running
  property bool requested: false
  property bool succeeded: false
  property int handledLength: 0

  function pair(target) {
    if (busy)
      return;
    device = target;
    prompt = "";
    status = `Pairing with ${target.name || target.address}…`;
    requested = false;
    succeeded = false;
    handledLength = 0;
    agent.running = true;
  }

  function respond(value) {
    if (!busy || !prompt)
      return;
    prompt = "";
    agent.write(`${String(value).replace(/[\r\n]/g, "")}\n`);
  }

  function cancel() {
    if (device?.pairing)
      device.cancelPair();
    agent.running = false;
    prompt = "";
    status = "Pairing cancelled.";
  }

  function consume(text) {
    if (!device)
      return;
    const chunk = text.slice(handledLength).replace(/\x1b\[[0-?]*[ -/]*[@-~]/g, "");
    handledLength = text.length;
    if (!requested && text.includes("Agent registered")) {
      requested = true;
      agent.write(`pair ${device.address}\n`);
    }
    const clean = text.replace(/\x1b\[[0-?]*[ -/]*[@-~]/g, "");
    if (chunk.includes("Pairing successful")) {
      succeeded = true;
      prompt = "";
      status = "Paired successfully.";
      device.connect();
      agent.write("quit\n");
    } else if (/Failed to pair|AuthenticationFailed|AuthenticationCanceled|AuthenticationRejected/.test(chunk)) {
      prompt = "";
      status = chunk.trim();
      agent.write("quit\n");
    } else {
      const display = chunk.match(/(?:Passkey|PIN code):\s*(\d+)/i);
      if (display)
        status = `Enter this code on your device: ${display[1]}`;
      const match = clean.match(
              /(?:Confirm passkey|Authorize service|Accept pairing|Enter PIN code|Enter passkey)[^\r\n]*[:?]\s*$/i);
      if (match) {
        prompt = match[0].trim();
        confirmation = /Confirm|Authorize|Accept/i.test(prompt);
      }
    }
  }

  Process {
    id: agent
    command: ["bluetoothctl", "--agent", "KeyboardDisplay"]
    stdinEnabled: true
    stdout: StdioCollector {
      waitForEnd: false
      onDataChanged: pairing.consume(text)
    }
    stderr: StdioCollector {
      onStreamFinished: {
        if (text.trim())
          pairing.status = text.trim();
      }
    }
    onExited: (exitCode, exitStatus) => {
      pairing.prompt = "";
      if (!pairing.succeeded && pairing.status.startsWith("Pairing with"))
        pairing.status = "Pairing failed or was cancelled. Check the device and try again.";
    }
  }

  Timer {
    interval: 60000
    running: pairing.busy
    onTriggered: pairing.cancel()
  }
}
