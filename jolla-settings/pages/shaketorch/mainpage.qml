import QtQuick 2.1
import Sailfish.Silica 1.0
import Nemo.DBus 2.0
import Nemo.Configuration 1.0

Page {
    id: page

    //% "ShakeTorch"
    //: name in the Settings Page
    property string entryname: qsTrId("settings_shaketorch_entryname")

    // bind to Service
    property bool serviceActive: (activeStr == "active")
    property bool serviceEnabled: (enabledStr == "enabled")
    property string activeStr
    property string enabledStr

    onVisibleChanged: if (visible) dbus.updateProperties()
    onStatusChanged: if (status != PageStatus.Inactive) dbus.updateProperties()

    /*
     * Dbus interface to systemd manager
     */
    DBusInterface {
        id: manager
        bus: DBus.SessionBus
        service: 'org.freedesktop.systemd1'
        path: "/org/freedesktop/systemd1"
        iface: 'org.freedesktop.systemd1.Manager'

        signalsEnabled: true

        property string uname: "harbour-shaketorch.service"

        function enable() {
            typedCall('EnableUnitFiles', [
                { "type": "as", "value": [uname] },
                { "type": "b", "value": false },
                { "type": "b", "value": true },
            ],
            function(result) { console.debug("Enabled", result); dbus.updateProperties()  },
            function(result) { console.warn("Enable", result[1]) }
            );
        }
        function disable() {
            typedCall('DisableUnitFiles', [
                { "type": "as", "value": [uname] },
                { "type": "b", "value": false },
            ],
            function(result) { console.debug("Disabled", result); dbus.updateProperties() },
            function(result) { console.warn("Disable", result) }
            );
        }
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
            page.activeStr  = dbus.getProperty("ActiveState");
            page.enabledStr = dbus.getProperty("UnitFileState");
        }
        function startUnit() { call("Start", "replace", undefined, undefined ) }
        function stopUnit()  { call("Stop",  "replace", undefined, undefined ) }
    }

    SilicaFlickable { id: flick
        anchors.fill: parent
        contentHeight: column.height

        Column { id: column
            width: page.width
            spacing: Theme.paddingMedium

            PageHeader { title: qsTrId("settings_shaketorch_entryname") }

            Timer {
                running: onoffSwitch.busy || enableSwitch.busy
                interval: 4000
                onTriggered: {
                    dbus.updateProperties()
                    onoffSwitch.busy = false
                    enableSwitch.busy = false
                }
            }
            TextSwitch {
                id: onoffSwitch

                width: parent.width - Theme.horizontalPageMargin
                anchors.horizontalCenter: parent.horizontalCenter

                automaticCheck: false
                checked: serviceActive
                //% "Turn on the flashlight when the device is shaken."
                //: description of the start/stop switch
                text: qsTrId("settings_shaketorch_startstop_desc")
                onClicked: {
                    if (busy) return
                    busy = true
                    if (!checked) {
                        console.info("ShakeTorch: engaged.")
                        dbus.startUnit()
                    } else {
                        console.info("ShakeTorch: dis-engaged.")
                        dbus.stopUnit()
                    }
                }
            }
            TextSwitch {
                id: enableSwitch

                width: parent.width - Theme.horizontalPageMargin
                anchors.horizontalCenter: parent.horizontalCenter

                automaticCheck: false
                checked: serviceEnabled
                //% "Enable and start at Boot"
                //: description of the enable switch
                text: qsTrId("settings_shaketorch_enable_desc")
                onClicked: {
                    if (busy) return
                    busy = true
                    if (!checked) {
                        console.info("ShakeTorch: enabling.")
                        manager.enable()
                    } else {
                        console.info("ShakeTorch: disabling.")
                        manager.disable()
                    }
                }
            }
        }
    }
}
