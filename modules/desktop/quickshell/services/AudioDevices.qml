import QtQuick
import Quickshell
import Quickshell.Io

Scope {
  id: metadata
  property bool active: false
  required property var nodes
  property var endpoints: ({})

  function availability(node) {
    return endpoints[node?.name]?.availability ?? "unreported";
  }

  function label(node) {
    return endpoints[node?.name]?.label || node?.description || node?.nickname || node?.name || "Unavailable";
  }

  function routeInfo(route, key) {
    const info = route?.info ?? [];
    for (let index = 1; index + 1 < info.length; index += 2) {
      if (info[index] === key)
        return info[index + 1];
    }
    return "";
  }

  function parse(objects) {
    const devices = {};
    for (const object of objects) {
      if (object.type === "PipeWire:Interface:Device")
        devices[String(object.id)] = object.info?.params ?? {};
    }
    const result = {};
    for (const object of objects) {
      if (object.type !== "PipeWire:Interface:Node")
        continue;
      const props = object.info?.props ?? {};
      // Virtual/other audio classes must not inherit a physical port's disconnected status.
      if (props["node.virtual"] === true || props["node.virtual"] === "true" || !["Audio/Sink", "Audio/Source"].includes(
            props["media.class"]))
        continue;
      const params = devices[String(props["device.id"])] ?? {};
      const profileDevice = props["card.profile.device"];
      const direction = props["media.class"] === "Audio/Sink" ? "Output" : "Input";
      const routes = profileDevice === undefined ? [] : (params.EnumRoute ?? []).filter(route => route.direction
                                                                                                 === direction && (
                                                                                                   route.devices
                                                                                                   ?? []).some(device
                                                                                                               => String(
                                                                                                                    device)
                                                                                                                  === String(
                                                                                                                    profileDevice)));
      if (!routes.length)
        continue;
      const current = (params.Route ?? []).find(route => route.direction === direction && String(route.device) === String(
                                                           profileDevice));
      const route = routes.find(candidate => candidate.index === current?.index && candidate.available !== "no")
            ?? routes.find(candidate => candidate.available === "yes") ?? routes.find(candidate => candidate.available
                                                                                                   !== "no")
            ?? routes[0];
      const availability = routes.every(candidate => candidate.available === "no") ? "no" : routes.some(candidate
                                                                                                        => candidate.available
                                                                                                           === "yes")
                                                                                     ? "yes" : "unknown";
      const product = routeInfo(route, "device.product.name");
      result[props["node.name"]] = {
        availability: availability,
        label: product ? `${product} · ${route.description}` : route.description || props["node.description"]
      };
    }
    endpoints = result;
  }

  function refresh() {
    if (active && !snapshot.running)
      snapshot.running = true;
  }

  onActiveChanged: {
    if (active)
      refresh();
    else
      snapshot.running = false;
  }
  onNodesChanged: refresh()
  Timer {
    interval: 5000
    running: metadata.active
    repeat: true
    onTriggered: metadata.refresh()
  }
  Process {
    id: snapshot
    // Quickshell exposes nodes, but not the device route availability used here.
    command: ["pw-dump"]
    stdout: StdioCollector {
      onStreamFinished: {
        try {
          metadata.parse(JSON.parse(text));
        } catch (error) {
          if (metadata.active)
            metadata.endpoints = {};
        }
      }
    }
    onExited: (code, status) => {
      if (metadata.active && (code !== 0 || status !== 0))
        metadata.endpoints = {};
    }
  }
}
