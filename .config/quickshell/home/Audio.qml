// Audio.qml
pragma Singleton
import QtQuick
import Quickshell
import Quickshell.Services.Pipewire

Singleton {
    id: root

    readonly property PwNode sink: Pipewire.defaultAudioSink
    readonly property PwNode source: Pipewire.defaultAudioSource

    readonly property bool isReady: Pipewire.ready

    PwObjectTracker {
        //objects: [sink, source]
        objects: [Pipewire.defaultAudioSink, Pipewire.defaultAudioSource]
    }

    function setVolume(newVolume: int, isSink: bool): void {
        console.log(Pipewire.ready, sink.description, sink.ready, sink.audio?.volume, newVolume, sink, Pipewire.defaultAudioSink)
        if (isSink) {
            if (root.isReady && sink.ready) {
                sink.audio.muted = false;
                sink.audio.volume = Math.max(0, Math.min(1, newVolume/100));
            }
            console.log("new volume: ", sink.audio?.volume)
        }
        else {
            if (root.isReady && source.ready) {
                source.audio.muted = false;
                source.audio.volume = Math.max(0, Math.min(1, newVolume/100));
            }
            //console.log("new source volume: ", source.audio.volume)
        }
    }

    function toggleMute(isSink: bool) {
        if (isSink)
            sink.audio.muted = !sink.audio.muted
        else
            source.audio.muted = !source.audio.muted

    }
}