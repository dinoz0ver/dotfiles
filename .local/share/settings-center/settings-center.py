#!/usr/bin/env python3
import gi
import json
import subprocess
import sys
import os
import shutil

gi.require_version('Gtk', '4.0')
gi.require_version('Adw', '1')
gi.require_version('Gdk', '4.0')
import math
import re
from collections import deque
from gi.repository import Gtk, Adw, Gio, GLib, Gdk

def run_command(cmd):
    """Run a shell command and return output"""
    try:
        result = subprocess.run(cmd, shell=True, capture_output=True, text=True, timeout=2)
        return result.stdout.strip()
    except:
        return ""

class DisplayPanel(Gtk.Box):
    def __init__(self):
        super().__init__(orientation=Gtk.Orientation.VERTICAL, spacing=12)
        self.set_margin_top(24)
        self.set_margin_bottom(24)
        self.set_margin_start(24)
        self.set_margin_end(24)

        title = Gtk.Label()
        title.set_markup("<span size='large' weight='bold'>Display Settings</span>")
        title.set_halign(Gtk.Align.START)
        self.append(title)

        group = Adw.PreferencesGroup()
        group.set_title("Monitors")
        group.set_description("Configure display settings")

        button = Gtk.Button(label="Open Display Settings (wdisplays)")
        button.add_css_class("suggested-action")
        button.connect("clicked", lambda b: subprocess.Popen("wdisplays", shell=True))

        self.append(group)
        self.append(button)

class AppearancePanel(Gtk.Box):
    def __init__(self):
        super().__init__(orientation=Gtk.Orientation.VERTICAL, spacing=12)
        self.set_margin_top(24)
        self.set_margin_bottom(24)
        self.set_margin_start(24)
        self.set_margin_end(24)

        title = Gtk.Label()
        title.set_markup("<span size='large' weight='bold'>Appearance</span>")
        title.set_halign(Gtk.Align.START)
        self.append(title)

        # Profile Icon
        icon_group = Adw.PreferencesGroup()
        icon_group.set_title("Profile Icon")
        icon_group.set_description("Avatar shown in the QuickShell control center")

        self.icon_row = Adw.ActionRow()
        self.icon_row.set_title("Profile Icon")
        self._update_icon_subtitle()

        # Circular preview
        self.icon_preview = Adw.Avatar(size=48, show_initials=True, text="D")
        if os.path.exists(PROFILE_ICON_PATH):
            self.icon_preview.set_custom_image(Gdk.Texture.new_from_filename(PROFILE_ICON_PATH))
        self.icon_preview.set_valign(Gtk.Align.CENTER)
        self.icon_row.add_prefix(self.icon_preview)

        remove_button = Gtk.Button.new_from_icon_name("edit-delete-symbolic")
        remove_button.set_valign(Gtk.Align.CENTER)
        remove_button.set_tooltip_text("Remove")
        remove_button.connect("clicked", self.on_remove_icon)

        choose_button = Gtk.Button(label="Choose")
        choose_button.set_valign(Gtk.Align.CENTER)
        choose_button.connect("clicked", self.on_choose_icon)

        self.icon_row.add_suffix(remove_button)
        self.icon_row.add_suffix(choose_button)
        icon_group.add(self.icon_row)
        self.append(icon_group)

        # Dark mode
        scheme_group = Adw.PreferencesGroup()
        scheme_group.set_title("Color Scheme")

        scheme_row = Adw.ActionRow()
        scheme_row.set_title("Dark Mode")
        scheme_row.set_subtitle("Use dark color scheme")

        switch = Gtk.Switch()
        switch.set_valign(Gtk.Align.CENTER)
        try:
            current_scheme = run_command("gsettings get org.gnome.desktop.interface color-scheme 2>/dev/null")
            switch.set_active("dark" in current_scheme)
        except:
            pass
        switch.connect("notify::active", self.on_dark_mode_toggled)
        scheme_row.add_suffix(switch)
        scheme_group.add(scheme_row)

        self.append(scheme_group)

        # External tools
        button = Gtk.Button(label="GTK Theme Settings (nwg-look)")
        button.add_css_class("suggested-action")
        button.connect("clicked", lambda b: subprocess.Popen("nwg-look", shell=True))
        self.append(button)

    def _update_icon_subtitle(self):
        if os.path.exists(PROFILE_ICON_PATH):
            meta_path = PROFILE_ICON_PATH + ".name"
            if os.path.exists(meta_path):
                with open(meta_path, "r") as f:
                    name = f.read().strip()
            else:
                name = "profile-icon (custom)"
            self.icon_row.set_subtitle(name)
        else:
            self.icon_row.set_subtitle("No icon set")

    def on_choose_icon(self, button):
        dialog = Gtk.FileDialog()
        dialog.set_title("Select Profile Icon")

        img_filter = Gtk.FileFilter()
        img_filter.set_name("Image files")
        for pattern in ["*.png", "*.jpg", "*.jpeg", "*.svg", "*.webp"]:
            img_filter.add_pattern(pattern)

        filters = Gio.ListStore.new(Gtk.FileFilter)
        filters.append(img_filter)
        dialog.set_filters(filters)
        dialog.set_default_filter(img_filter)

        dialog.open(self.get_root(), None, self._on_icon_chosen)

    def _on_icon_chosen(self, dialog, result):
        try:
            file = dialog.open_finish(result)
        except GLib.Error:
            return
        if not file:
            return

        src_path = file.get_path()
        os.makedirs(os.path.dirname(PROFILE_ICON_PATH), exist_ok=True)
        shutil.copy2(src_path, PROFILE_ICON_PATH)

        with open(PROFILE_ICON_PATH + ".name", "w") as f:
            f.write(os.path.basename(src_path))

        self.icon_preview.set_custom_image(Gdk.Texture.new_from_filename(PROFILE_ICON_PATH))
        self._update_icon_subtitle()

    def on_remove_icon(self, button):
        for path in [PROFILE_ICON_PATH, PROFILE_ICON_PATH + ".name"]:
            if os.path.exists(path):
                os.remove(path)
        self.icon_preview.set_custom_image(None)
        self._update_icon_subtitle()

    def on_dark_mode_toggled(self, switch, param):
        if switch.get_active():
            subprocess.run("gsettings set org.gnome.desktop.interface color-scheme 'prefer-dark'", shell=True)
        else:
            subprocess.run("gsettings set org.gnome.desktop.interface color-scheme 'prefer-light'", shell=True)

NOTIF_SOUND_PATH = os.path.expanduser("~/.config/quickshell/sounds/notification-sound")
PROFILE_ICON_PATH = os.path.expanduser("~/.config/quickshell/home/profile-icon")

class SoundPanel(Gtk.Box):
    def __init__(self):
        super().__init__(orientation=Gtk.Orientation.VERTICAL, spacing=12)
        self.set_margin_top(24)
        self.set_margin_bottom(24)
        self.set_margin_start(24)
        self.set_margin_end(24)

        title = Gtk.Label()
        title.set_markup("<span size='large' weight='bold'>Sound Settings</span>")
        title.set_halign(Gtk.Align.START)
        self.append(title)

        # Volume
        volume_group = Adw.PreferencesGroup()
        volume_group.set_title("Volume")

        volume_row = Adw.ActionRow()
        volume_row.set_title("Master Volume")

        volume_scale = Gtk.Scale.new_with_range(Gtk.Orientation.HORIZONTAL, 0, 100, 1)
        try:
            volume_str = run_command("pactl get-sink-volume @DEFAULT_SINK@ 2>/dev/null | grep -oP '\\d+%' | head -1")
            volume = int(volume_str.strip('%')) if volume_str else 50
            volume_scale.set_value(volume)
        except:
            volume_scale.set_value(50)

        volume_scale.set_hexpand(True)
        volume_scale.set_draw_value(True)
        volume_scale.set_value_pos(Gtk.PositionType.RIGHT)
        volume_scale.connect("value-changed", self.on_volume_changed)

        box = Gtk.Box(orientation=Gtk.Orientation.HORIZONTAL)
        box.set_hexpand(True)
        box.append(volume_scale)
        volume_row.add_suffix(box)

        volume_group.add(volume_row)
        self.append(volume_group)

        # Notification Sound
        notif_group = Adw.PreferencesGroup()
        notif_group.set_title("Notification Sound")

        self.notif_row = Adw.ActionRow()
        self.notif_row.set_title("Sound File")
        self._update_notif_subtitle()

        choose_button = Gtk.Button(label="Choose")
        choose_button.set_valign(Gtk.Align.CENTER)
        choose_button.connect("clicked", self.on_choose_sound)

        preview_button = Gtk.Button.new_from_icon_name("media-playback-start-symbolic")
        preview_button.set_valign(Gtk.Align.CENTER)
        preview_button.set_tooltip_text("Preview")
        preview_button.connect("clicked", self.on_preview_sound)

        self.notif_row.add_suffix(preview_button)
        self.notif_row.add_suffix(choose_button)
        notif_group.add(self.notif_row)
        self.append(notif_group)

        # External
        button = Gtk.Button(label="Advanced Sound Settings (pavucontrol)")
        button.add_css_class("suggested-action")
        button.connect("clicked", lambda b: subprocess.Popen("pavucontrol", shell=True))
        self.append(button)

    def _update_notif_subtitle(self):
        if os.path.exists(NOTIF_SOUND_PATH):
            # Try to read the original name from the sidecar file
            meta_path = NOTIF_SOUND_PATH + ".name"
            if os.path.exists(meta_path):
                with open(meta_path, "r") as f:
                    name = f.read().strip()
            else:
                name = "notification-sound (custom)"
            self.notif_row.set_subtitle(name)
        else:
            self.notif_row.set_subtitle("No sound set")

    def on_volume_changed(self, scale):
        volume = int(scale.get_value())
        subprocess.Popen(f"pactl set-sink-volume @DEFAULT_SINK@ {volume}%", shell=True)

    def on_choose_sound(self, button):
        dialog = Gtk.FileDialog()
        dialog.set_title("Select Notification Sound")

        audio_filter = Gtk.FileFilter()
        audio_filter.set_name("Audio files")
        for pattern in ["*.ogg", "*.mp3", "*.wav", "*.flac", "*.oga", "*.opus", "*.ogg.mp3"]:
            audio_filter.add_pattern(pattern)

        filters = Gio.ListStore.new(Gtk.FileFilter)
        filters.append(audio_filter)
        dialog.set_filters(filters)
        dialog.set_default_filter(audio_filter)

        dialog.open(self.get_root(), None, self._on_file_chosen)

    def _on_file_chosen(self, dialog, result):
        try:
            file = dialog.open_finish(result)
        except GLib.Error:
            return
        if not file:
            return

        src_path = file.get_path()
        os.makedirs(os.path.dirname(NOTIF_SOUND_PATH), exist_ok=True)
        shutil.copy2(src_path, NOTIF_SOUND_PATH)

        # Save original filename for display
        with open(NOTIF_SOUND_PATH + ".name", "w") as f:
            f.write(os.path.basename(src_path))

        self._update_notif_subtitle()

    def on_preview_sound(self, button):
        if os.path.exists(NOTIF_SOUND_PATH):
            subprocess.Popen(["pw-play", NOTIF_SOUND_PATH])

class NetworkPanel(Gtk.Box):
    def __init__(self):
        super().__init__(orientation=Gtk.Orientation.VERTICAL, spacing=12)
        self.set_margin_top(24)
        self.set_margin_bottom(24)
        self.set_margin_start(24)
        self.set_margin_end(24)

        title = Gtk.Label()
        title.set_markup("<span size='large' weight='bold'>Network Settings</span>")
        title.set_halign(Gtk.Align.START)
        self.append(title)

        # WiFi toggle
        status_group = Adw.PreferencesGroup()
        status_group.set_title("WiFi")

        wifi_row = Adw.ActionRow()
        wifi_row.set_title("Enable WiFi")

        self.wifi_switch = Gtk.Switch()
        self.wifi_switch.set_valign(Gtk.Align.CENTER)

        # Check for WiFi adapter
        has_wifi = False
        try:
            devices = run_command("nmcli -t -f DEVICE,TYPE device 2>/dev/null")
            has_wifi = ":wifi" in devices
            if has_wifi:
                wifi_status = run_command("nmcli radio wifi 2>/dev/null")
                self.wifi_switch.set_active(wifi_status == "enabled")
            else:
                self.wifi_switch.set_active(False)
                self.wifi_switch.set_sensitive(False)
                wifi_row.set_subtitle("No WiFi adapter detected")
        except:
            pass

        self.wifi_switch.connect("notify::active", self.on_wifi_toggled)
        wifi_row.add_suffix(self.wifi_switch)

        status_group.add(wifi_row)
        self.append(status_group)

        button = Gtk.Button(label="Network Connections (nm-connection-editor)")
        button.add_css_class("suggested-action")
        button.connect("clicked", lambda b: subprocess.Popen("nm-connection-editor", shell=True))
        self.append(button)

    def on_wifi_toggled(self, switch, param):
        if switch.get_active():
            subprocess.Popen("nmcli radio wifi on", shell=True)
        else:
            subprocess.Popen("nmcli radio wifi off", shell=True)

class BluetoothPanel(Gtk.Box):
    def __init__(self):
        super().__init__(orientation=Gtk.Orientation.VERTICAL, spacing=12)
        self.set_margin_top(24)
        self.set_margin_bottom(24)
        self.set_margin_start(24)
        self.set_margin_end(24)

        title = Gtk.Label()
        title.set_markup("<span size='large' weight='bold'>Bluetooth</span>")
        title.set_halign(Gtk.Align.START)
        self.append(title)

        status_group = Adw.PreferencesGroup()
        status_group.set_title("Bluetooth")

        bt_row = Adw.ActionRow()
        bt_row.set_title("Enable Bluetooth")

        self.bt_switch = Gtk.Switch()
        self.bt_switch.set_valign(Gtk.Align.CENTER)

        # Check for Bluetooth adapter
        has_bt = False
        try:
            # Check if adapter exists using rfkill (more reliable than bluetoothctl list)
            rfkill_output = run_command("rfkill list bluetooth 2>/dev/null")
            if rfkill_output and "Bluetooth" in rfkill_output:  # Adapter exists
                has_bt = True
                # Now check if it's powered on
                bt_status = run_command("bluetoothctl show 2>/dev/null | grep 'Powered' | awk '{print $2}'")
                self.bt_switch.set_active(bt_status == "yes")
            else:
                self.bt_switch.set_active(False)
                self.bt_switch.set_sensitive(False)
                bt_row.set_subtitle("No Bluetooth adapter detected")
        except:
            self.bt_switch.set_active(False)
            self.bt_switch.set_sensitive(False)

        self.bt_switch.connect("notify::active", self.on_bt_toggled)
        bt_row.add_suffix(self.bt_switch)

        status_group.add(bt_row)
        self.append(status_group)

        button = Gtk.Button(label="Bluetooth Manager (blueman)")
        button.add_css_class("suggested-action")
        button.connect("clicked", lambda b: subprocess.Popen("blueman-manager", shell=True))
        self.append(button)

    def on_bt_toggled(self, switch, param):
        if switch.get_active():
            subprocess.Popen("bluetoothctl power on", shell=True)
        else:
            subprocess.Popen("bluetoothctl power off", shell=True)

class MousePanel(Gtk.Box):
    def __init__(self):
        super().__init__(orientation=Gtk.Orientation.VERTICAL, spacing=12)
        self.set_margin_top(24)
        self.set_margin_bottom(24)
        self.set_margin_start(24)
        self.set_margin_end(24)

        title = Gtk.Label()
        title.set_markup("<span size='large' weight='bold'>Mouse</span>")
        title.set_halign(Gtk.Align.START)
        self.append(title)

        mouse_group = Adw.PreferencesGroup()
        mouse_group.set_title("Pointer")

        sens_row = Adw.ActionRow()
        sens_row.set_title("Sensitivity")
        sens_row.set_subtitle("Mouse pointer sensitivity (-1.0 to 1.0)")

        self.sens_scale = Gtk.Scale.new_with_range(Gtk.Orientation.HORIZONTAL, -1.0, 1.0, 0.1)
        self.sens_scale.set_hexpand(True)
        self.sens_scale.set_draw_value(True)
        self.sens_scale.set_value_pos(Gtk.PositionType.RIGHT)
        self.sens_scale.set_size_request(250, -1)
        try:
            output = run_command("hyprctl getoption input:sensitivity -j 2>/dev/null")
            val = json.loads(output).get("float", 0.0)
            self.sens_scale.set_value(val)
        except:
            self.sens_scale.set_value(0.0)
        self.sens_scale.connect("value-changed", self.on_sensitivity_changed)

        box = Gtk.Box(orientation=Gtk.Orientation.HORIZONTAL)
        box.set_hexpand(True)
        box.append(self.sens_scale)
        sens_row.add_suffix(box)

        mouse_group.add(sens_row)
        self.append(mouse_group)

    def on_sensitivity_changed(self, scale):
        val = round(scale.get_value(), 1)
        subprocess.Popen(f"hyprctl keyword input:sensitivity {val}", shell=True)

class HyprlandPanel(Gtk.Box):
    def __init__(self):
        super().__init__(orientation=Gtk.Orientation.VERTICAL, spacing=12)
        self.set_margin_top(24)
        self.set_margin_bottom(24)
        self.set_margin_start(24)
        self.set_margin_end(24)

        title = Gtk.Label()
        title.set_markup("<span size='large' weight='bold'>Hyprland</span>")
        title.set_halign(Gtk.Align.START)
        self.append(title)

        config_group = Adw.PreferencesGroup()
        config_group.set_title("Configuration")

        config_row = Adw.ActionRow()
        config_row.set_title("Configuration File")
        config_row.set_subtitle("~/.config/hypr/hyprland.conf")

        edit_button = Gtk.Button(label="Edit")
        edit_button.set_valign(Gtk.Align.CENTER)
        edit_button.connect("clicked", lambda b: subprocess.Popen(f"kitty -e $EDITOR {os.path.expanduser('~/.config/hypr/hyprland.conf')}", shell=True))
        config_row.add_suffix(edit_button)

        config_group.add(config_row)

        reload_row = Adw.ActionRow()
        reload_row.set_title("Reload Configuration")

        reload_button = Gtk.Button(label="Reload")
        reload_button.set_valign(Gtk.Align.CENTER)
        reload_button.add_css_class("suggested-action")
        reload_button.connect("clicked", lambda b: subprocess.Popen("hyprctl reload", shell=True))
        reload_row.add_suffix(reload_button)

        config_group.add(reload_row)
        self.append(config_group)

class UsageGraph(Gtk.DrawingArea):
    """A single line graph for a usage metric (0-100%)."""

    def __init__(self, label, color_rgb, history_len=60):
        super().__init__()
        self.label = label
        self.color = color_rgb
        self.history = deque([0.0] * history_len, maxlen=history_len)
        self.current = 0.0
        self.set_content_width(400)
        self.set_content_height(160)
        self.set_draw_func(self._draw)

    def push(self, value):
        self.current = value
        self.history.append(value)
        self.queue_draw()

    def _draw(self, area, cr, width, height):
        # Background
        cr.set_source_rgba(0.15, 0.15, 0.15, 1)
        cr.rectangle(0, 0, width, height)
        cr.fill()

        pad_left, pad_right, pad_top, pad_bottom = 10, 10, 28, 20
        gw = width - pad_left - pad_right
        gh = height - pad_top - pad_bottom

        # Grid lines
        cr.set_source_rgba(0.3, 0.3, 0.3, 0.5)
        cr.set_line_width(0.5)
        for pct in (25, 50, 75):
            y = pad_top + gh * (1 - pct / 100)
            cr.move_to(pad_left, y)
            cr.line_to(pad_left + gw, y)
            cr.stroke()

        # Line graph
        r, g, b = self.color
        n = len(self.history)
        if n < 2:
            return

        # Filled area
        cr.set_source_rgba(r, g, b, 0.15)
        cr.move_to(pad_left, pad_top + gh)
        for i, val in enumerate(self.history):
            x = pad_left + (i / (n - 1)) * gw
            y = pad_top + gh * (1 - val / 100)
            cr.line_to(x, y)
        cr.line_to(pad_left + gw, pad_top + gh)
        cr.close_path()
        cr.fill()

        # Line
        cr.set_source_rgba(r, g, b, 1)
        cr.set_line_width(1.5)
        for i, val in enumerate(self.history):
            x = pad_left + (i / (n - 1)) * gw
            y = pad_top + gh * (1 - val / 100)
            if i == 0:
                cr.move_to(x, y)
            else:
                cr.line_to(x, y)
        cr.stroke()

        # Label + current value
        cr.set_source_rgba(1, 1, 1, 0.9)
        cr.select_font_face("monospace", 0, 0)
        cr.set_font_size(12)
        cr.move_to(pad_left, 16)
        cr.show_text(f"{self.label}  {self.current:.1f}%")


class SystemMonitorPanel(Gtk.Box):
    def __init__(self):
        super().__init__(orientation=Gtk.Orientation.VERTICAL, spacing=12)
        self.set_margin_top(24)
        self.set_margin_bottom(24)
        self.set_margin_start(24)
        self.set_margin_end(24)

        title = Gtk.Label()
        title.set_markup("<span size='large' weight='bold'>System Monitor</span>")
        title.set_halign(Gtk.Align.START)
        self.append(title)

        self.cpu_graph = UsageGraph("CPU", (0.2, 0.6, 1.0))
        self.mem_graph = UsageGraph("Memory", (0.3, 0.8, 0.3))
        self.gpu_graph = UsageGraph("GPU", (1.0, 0.4, 0.3))

        for label, graph in [("CPU", self.cpu_graph), ("Memory", self.mem_graph), ("GPU", self.gpu_graph)]:
            group = Adw.PreferencesGroup()
            group.set_title(label)
            frame = Gtk.Frame()
            frame.set_child(graph)
            group.add(frame)
            self.append(group)

        # CPU state for delta calculation
        self._last_cpu_total = 0
        self._last_cpu_idle = 0

        self._timer_id = GLib.timeout_add_seconds(1, self._poll)
        self._poll()

    def _poll(self):
        self._poll_cpu()
        self._poll_mem()
        self._poll_gpu()
        return True  # keep timer running

    def _poll_cpu(self):
        try:
            with open("/proc/stat") as f:
                line = f.readline()
            parts = line.split()
            values = [int(v) for v in parts[1:8]]
            total = sum(values)
            idle = values[3] + values[4]
            dt = total - self._last_cpu_total
            di = idle - self._last_cpu_idle
            usage = (1 - di / dt) * 100 if dt > 0 else 0
            self._last_cpu_total = total
            self._last_cpu_idle = idle
            self.cpu_graph.push(max(0, min(100, usage)))
        except:
            pass

    def _poll_mem(self):
        try:
            with open("/proc/meminfo") as f:
                text = f.read()
            total = int(re.search(r"MemTotal:\s+(\d+)", text).group(1))
            avail = int(re.search(r"MemAvailable:\s+(\d+)", text).group(1))
            usage = ((total - avail) / total) * 100 if total > 0 else 0
            self.mem_graph.push(usage)
        except:
            pass

    def _poll_gpu(self):
        try:
            result = subprocess.run(
                ["nvidia-smi", "--query-gpu=utilization.gpu", "--format=csv,noheader,nounits"],
                capture_output=True, text=True, timeout=2
            )
            usage = float(result.stdout.strip())
            self.gpu_graph.push(usage)
        except:
            self.gpu_graph.push(0)


class SettingsWindow(Adw.ApplicationWindow):
    def __init__(self, **kwargs):
        super().__init__(**kwargs)
        self.set_title("Settings")
        self.set_default_size(700, 700)

        # Main box
        main_box = Gtk.Box(orientation=Gtk.Orientation.VERTICAL)

        # Header
        header = Adw.HeaderBar()
        main_box.append(header)

        # Content
        content_box = Gtk.Box(orientation=Gtk.Orientation.HORIZONTAL, spacing=0)
        content_box.set_vexpand(True)

        # Sidebar
        sidebar = Gtk.ListBox()
        sidebar.set_size_request(200, -1)
        sidebar.add_css_class("navigation-sidebar")
        sidebar.connect("row-selected", self.on_sidebar_selected)

        categories = [
            ("Display", "video-display-symbolic"),
            ("Appearance", "preferences-desktop-theme-symbolic"),
            ("Sound", "audio-volume-high-symbolic"),
            ("Network", "network-wireless-symbolic"),
            ("Bluetooth", "bluetooth-symbolic"),
            ("Mouse", "input-mouse-symbolic"),
            ("Hyprland", "preferences-system-symbolic"),
            ("System Monitor", "utilities-system-monitor-symbolic"),
        ]

        self.category_names = []
        for name, icon in categories:
            row = Adw.ActionRow()
            row.set_title(name)
            row_icon = Gtk.Image.new_from_icon_name(icon)
            row.add_prefix(row_icon)
            sidebar.append(row)
            self.category_names.append(name)

        content_box.append(sidebar)

        # Separator
        sep = Gtk.Separator(orientation=Gtk.Orientation.VERTICAL)
        content_box.append(sep)

        # Stack
        self.stack = Gtk.Stack()
        self.stack.set_transition_type(Gtk.StackTransitionType.CROSSFADE)

        self.stack.add_named(DisplayPanel(), "Display")
        self.stack.add_named(AppearancePanel(), "Appearance")
        self.stack.add_named(SoundPanel(), "Sound")
        self.stack.add_named(NetworkPanel(), "Network")
        self.stack.add_named(BluetoothPanel(), "Bluetooth")
        self.stack.add_named(MousePanel(), "Mouse")
        self.stack.add_named(HyprlandPanel(), "Hyprland")
        self.stack.add_named(SystemMonitorPanel(), "System Monitor")

        scrolled = Gtk.ScrolledWindow()
        scrolled.set_policy(Gtk.PolicyType.NEVER, Gtk.PolicyType.AUTOMATIC)
        scrolled.set_child(self.stack)
        scrolled.set_hexpand(True)
        scrolled.set_vexpand(True)

        content_box.append(scrolled)
        main_box.append(content_box)

        self.set_content(main_box)

        # Select first and show its panel
        sidebar.select_row(sidebar.get_row_at_index(0))
        self.stack.set_visible_child_name("Display")

    def on_sidebar_selected(self, listbox, row):
        if row is not None:
            index = row.get_index()
            panel_name = self.category_names[index]
            self.stack.set_visible_child_name(panel_name)

class SettingsApp(Adw.Application):
    def __init__(self):
        super().__init__(application_id="com.dinozover.Settings",
                         flags=Gio.ApplicationFlags.FLAGS_NONE)
        self.connect('activate', self.on_activate)

    def on_activate(self, app):
        self.win = SettingsWindow(application=app)
        self.win.present()

if __name__ == '__main__':
    app = SettingsApp()
    app.run(sys.argv)
