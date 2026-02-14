// Player.qml
pragma Singleton
import Quickshell
import QtQuick
import Quickshell.Services.Mpris


Singleton {
  id: root
  readonly property list<MprisPlayer> list: Mpris.players.values
  readonly property MprisPlayer player: list[0] ? list[0] : null
  //onListChanged: {console.log(Mpris.players.values[0].identity)}
}
