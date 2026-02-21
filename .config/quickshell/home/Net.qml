// Net.qml
pragma Singleton
import QtQuick
import Quickshell   // Process, StdioCollector
import Quickshell.Io   // Process, StdioCollector

Item {
  id: net

  // public state
  property bool online: false
  property bool hasAdapter: false
  property bool ethernetConnected: false
  property string activeSsid: ""
  property var networks: []   // [{ inUse: bool, ssid: string, signal: int }]

  // --- processes ---
  Process {
    id: procAdapter
    command: ["nmcli", "-t", "-f", "DEVICE,TYPE,STATE", "device"]
    stdout: StdioCollector {
      onStreamFinished: {
        net.hasAdapter = text.includes(":wifi:")
        var ethConnected = false
        var lines = text.trim().split("\n")
        for (var i = 0; i < lines.length; i++) {
          var parts = lines[i].split(":")
          if (parts[1] === "ethernet" && parts[2] === "connected") {
            ethConnected = true
            break
          }
        }
        net.ethernetConnected = ethConnected
      }
    }
  }

  Process {
    id: procState
    command: ["nmcli", "-t", "-f", "WIFI", "g"]
    stdout: StdioCollector {
      onStreamFinished: {
        //console.log(this.text)
        const txt = text.trim()
        net.online = txt === "enabled"
      }
    }
  }

  Process {
    id: procScan
    command: ["nmcli", "-t", "-f", "IN-USE,SSID,SIGNAL,SECURITY", "dev", "wifi"]
    stdout: StdioCollector {
      onStreamFinished: {
        //console.log(this.text)
        const rows = []
        for (let line of text.trim().split("\n")) {
          if (!line) continue
          const parts = line.split(":")
          rows.push({
            inUse: parts[0] === "*",
            ssid: parts[1] && parts[1].length ? parts[1] : "(hidden)",
            signal: parseInt(parts[2] || "0"),
            security: parts[3] || ""
          })
          if (parts[0] === "*") {net.activeSsid = parts[1] && parts[1].length ? parts[1] : "(hidden)"}
          //console.log(parts)
        }
        net.networks = rows
        //console.log("net.activeSsid = "+net.activeSsid, net.online)
      }
    }
  }

  Process {
    id: procAction
    command: []
    stdout: StdioCollector {
      onStreamFinished: {
        //console.log(this.text)
        // ignore actual text, just trigger refresh
        net.refresh()
      }
    }
  }

  // --- api ---
  function refresh() {
    console.log("Refreshing network...")
    procAdapter.running = true
    procState.running = true
    procScan.running = true
  }

  function connect(ssid, password) {
    let cmd = ["nmcli", "device", "wifi", "connect", ssid]
    if (password && password.length) cmd.push("password", password)
    procAction.command = cmd
    procAction.running = true
  }

  function disconnect() {
    if (!activeSsid) return
    procAction.command = ["nmcli", "connection", "down", activeSsid]
    procAction.running = true
    net.activeSsid = ""
  }

  function setWifiEnabled(on) {
    procAction.command = ["nmcli", "radio", "wifi", on ? "on" : "off"]
    procAction.running = true
    net.activeSsid = ""
    //console.log("setting wifi to", on)
  }

  Component.onCompleted: refresh()
}