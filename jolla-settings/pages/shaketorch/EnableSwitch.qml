import QtQuick 2.1
import Sailfish.Silica 1.0
import Nemo.DBus 2.0
import com.jolla.settings 1.0

SettingsToggle {
    id: toggleSwitch

    icon.source: "image://theme/icon-m-flashlight"

    active: checked
    checked: serviceActive
    available: serviceLoaded

    // bind to Service
    property bool serviceActive: (activeStr == "active")
    property bool serviceLoaded: (loadedStr == "loaded")
    property string activeStr
    property string loadedStr

    onVisibleChanged: if (visible) dbus.updateProperties()
    Component.onCompleted: dbus.updateProperties()

    /*
    //% "Shake: off"
    //: top menu button status text
    name: qsTrId("settings_shaketorch_status-off")
    //% "Shake: on"
    //: top menu button status text
    activeText: qsTrId("settings_shaketorch_status-on")
    */

    //this is just here to have IDs for translations used in entries.json
    //% "ShakeTorch"
    //: button name in the top menu
    readonly property string buttonName: qsTrId("settings_shaketorch_eventname")
    name: buttonName
    activeText: buttonName

    menu: ContextMenu {
        SettingsMenuItem { onClicked: toggleSwitch.goToSettings() }
    }

    onToggled: {
        if (!checked) {
            console.info("ShakeTorch: engaged.")
            dbus.startUnit()
        } else {
            console.info("ShakeTorch: dis-engaged.")
            dbus.stopUnit()
        }
        refreshtimer.restart()
    }

    Timer { id: refreshtimer
        interval: 1000
        onTriggered: dbus.updateProperties()
    }

    /*
     * Dbus interface to systemd unit
    */
    DBusInterface {
        id: dbus
        bus: DBus.SessionBus
        service: "org.freedesktop.systemd1"
        path: "/org/freedesktop/systemd1/unit/harbour_2dshaketorch_2eservice"
        iface: "org.freedesktop.systemd1.Unit"

        signalsEnabled: true

        onPropertiesChanged: updateProperties()
        function updateProperties() {
            toggleSwitch.activeStr  = dbus.getProperty("ActiveState");
            toggleSwitch.loadedStr = dbus.getProperty("LoadState");
        }

        function startUnit() { call("Start", "replace", undefined, undefined ) }
        function stopUnit()  { call("Stop",  "replace", undefined, undefined ) }
    }
}
