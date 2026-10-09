import QtQuick
import Quickshell
import Quickshell.Widgets
import ".."

FocusScope {
  id: applications
  signal launched
  property alias query: search.text
  property int visibleResultLimit: 6
  readonly property real resultHeight: T.spaceL + T.spaceS
  implicitHeight: Math.max(1, Math.min(results.count, visibleResultLimit)) * resultHeight + T.spaceS + searchBox.height

  function focusSearch() {
    search.forceActiveFocus();
  }

  function resetAndFocus() {
    search.text = "";
    results.currentIndex = 0;
    focusSearch();
  }

  function moveSelection(delta) {
    if (!results.count) {
      results.currentIndex = -1;
      return;
    }
    results.currentIndex = (results.currentIndex + delta + results.count) % results.count;
    results.positionViewAtIndex(results.currentIndex, ListView.Contain);
  }

  function activate(entry) {
    if (!entry)
      return;
    Quickshell.execDetached(["systemd-run", "--user", "--collect", "--slice=app.slice", "--property=Type=exec",
                             "--property=ExitType=cgroup", "--property=PartOf=graphical-session.target",
                             "--property=After=graphical-session.target", `--property=WorkingDirectory=${Quickshell.env(
                               "HOME")}`, "--", "gtk-launch", `${entry.application.id}.desktop`]);
    launched();
  }

  ScriptModel {
    id: resultModel
    objectProp: "key"
    values: {
      const query = search.text.trim().toLowerCase();
      return DesktopEntries.applications.values.map(application => ({
        key: application.id,
        name: application.name,
        detail: application.genericName || application.comment,
        icon: application.icon,
        application: application
      })).filter(entry => !query || entry.name.toLowerCase().includes(query) || String(entry.detail || "").toLowerCase(
      ).includes(query)).slice(0, 50);
    }
    }

      ListView {
      id: results
      anchors {
      top: parent.top
      bottom: searchBox.top
      left: parent.left
      right: parent.right
      bottomMargin: T.spaceS
    }
      clip: true
      model: resultModel
      currentIndex: count ? 0 : -1
      onCountChanged: {
      if (!count)
      currentIndex = -1;
      else if (currentIndex < 0 || currentIndex >= count)
      currentIndex = 0;
    }
      delegate: Rectangle {
      id: resultItem
      required property var modelData
      readonly property bool current: ListView.isCurrentItem
      width: results.width
      height: applications.resultHeight
      color: resultHover.hovered || resultItem.current ? T.colB : T.colO
      HoverHandler {
      id: resultHover
    }
      IconImage {
      anchors {
      left: parent.left
      leftMargin: T.spaceS
      verticalCenter: parent.verticalCenter
    }
      width: T.spaceL
      height: T.spaceL
      source: Quickshell.iconPath(modelData.icon || "application-x-executable", "")
    }
      Text {
      anchors {
      left: parent.left
      right: parent.right
      verticalCenter: parent.verticalCenter
      leftMargin: T.spaceL + T.spaceM
      rightMargin: T.spaceS
    }
      text: modelData.name
      color: resultItem.current ? T.colF : T.colM
      font.bold: resultItem.current
      font.family: T.fontSans
      font.pointSize: T.fontSizeB
      elide: Text.ElideRight
    }
      TapHandler {
      onTapped: applications.activate(modelData)
    }
    }
    }

      Text {
      anchors.centerIn: results
      visible: results.count === 0
      text: "No matching applications"
      color: T.colM
      font.family: T.fontSans
      font.pointSize: T.fontSizeB
    }

      Rectangle {
      id: searchBox
      anchors {
      bottom: parent.bottom
      left: parent.left
      right: parent.right
    }
      height: T.spaceL + T.spaceS * 2
      color: T.colO
      TextInput {
      id: search
      activeFocusOnTab: true
      anchors {
      fill: parent
      margins: T.spaceS
    }
      color: T.colF
      selectionColor: T.colP
      selectedTextColor: T.colO
      font.family: T.fontSans
      font.pointSize: T.fontSizeB
      verticalAlignment: TextInput.AlignVCenter
      clip: true
      onTextChanged: results.currentIndex = resultModel.values.length ? 0 : -1
      onAccepted: applications.activate(results.currentItem?.modelData)
      Keys.onPressed: event => {
      if (event.key === Qt.Key_Down || event.key === Qt.Key_Up) {
      applications.moveSelection(event.key === Qt.Key_Down ? 1 : -1);
      event.accepted = true;
    }
    }
      Text {
      anchors.fill: parent
      visible: !search.text.length
      text: "Search applications…"
      color: T.colM
      font: search.font
      verticalAlignment: Text.AlignVCenter
    }
    }
    }
    }
