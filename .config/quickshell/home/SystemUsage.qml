// SystemUsage.qml
pragma Singleton
import QtQuick
import Quickshell.Io
import Quickshell

Singleton {
  id: root

  property real cpuPerc
  property real lastCpuTotal
  property real lastCpuIdle

  property real memUsed
  property real memTotal
  property real memPerc

  property real storagePerc

  property real gpuIdlePerc
  property real gpuBusyPerc
  property real lastGpuIdle

  Timer {
    running: true
    interval: 1000
    repeat: true
    onTriggered: {
      cpuInfo.reload()
      memInfo.reload()
      storageInfo.running = true
      gpuInfo.running = true
    }
  }

  FileView {
    id: cpuInfo
    path: "/proc/stat"

    onLoaded: {
      // parse cpu int int ... line
      const data = text().match(/^cpu\s+(\d+)\s+(\d+)\s+(\d+)\s+(\d+)\s+(\d+)\s+(\d+)\s+(\d+)/m);
      if (!data) return;

      const stats = data.slice(1).map(n => parseInt(n, 10));
      const total = stats.reduce((a, b) => a + b, 0);
      const idle = stats[3] + (stats[4] ?? 0);

      const totalDiff = total - root.lastCpuTotal;
      const idleDiff  = idle  - root.lastCpuIdle;

      root.cpuPerc = totalDiff > 0 ? (1 - idleDiff / totalDiff) : 0;

      root.lastCpuTotal = total;
      root.lastCpuIdle  = idle;
    }
  }
  
  FileView {
    id: memInfo

    path: "/proc/meminfo"
    onLoaded: {
      const data = text();
      root.memTotal = parseInt(data.match(/MemTotal: *(\d+)/)[1], 10) || 1;
      root.memUsed = (root.memTotal - parseInt(data.match(/MemAvailable: *(\d+)/)[1], 10)) || 0;
      root.memPerc = root.memTotal > 0 ? memUsed/memTotal : 0
    }
  }
  
  Process {
    id: storageInfo
    command: ["sh", "-c", "df -P | awk '$1==\"/dev/nvme0n1p3\" && $NF==\"/\" {print $5}'"]
    stdout: StdioCollector {
      onStreamFinished: { root.storagePerc = Number(this.text.split("\n")[0].replace("%","")) }
    }
  }


  Process {
    id: gpuInfo
    command: ["nvidia-smi", "--query-gpu=utilization.gpu", "--format=csv,noheader,nounits"]
    stdout: StdioCollector {
      onStreamFinished: {
        const usage = Number(this.text.trim())
        if (!isNaN(usage)) {
          root.gpuBusyPerc = usage
          root.gpuIdlePerc = 100 - usage
        }
      }
    }
  }
}
