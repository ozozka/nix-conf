import QtQuick
import Quickshell.Services.Pipewire
import ".."

Text {
  id: audio

  readonly property var sink: Pipewire.defaultAudioSink
  readonly property bool available: !!sink?.ready && !!sink?.audio

  color: T.colF
  font {
    family: T.fontMono
    pointSize: T.fontSizeB
  }
  text: !available ? "" : sink.audio.muted ? "% -" : `%${Math.round(sink.audio.volume * 100)}`

  PwObjectTracker {
    objects: audio.sink ? [audio.sink] : []
  }

  WheelHandler {
    onWheel: event => {
      if (!audio.available)
        return;
      audio.sink.audio.volume = Math.max(0, Math.min(1.5, audio.sink.audio.volume + Math.sign(event.angleDelta.y)
                                                     * 0.01));
    }
  }

  TapHandler {
    onTapped: {
      if (audio.available)
        audio.sink.audio.muted = !audio.sink.audio.muted;
    }
  }
}
