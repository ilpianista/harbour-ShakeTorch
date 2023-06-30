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
    property bool serviceActive: (dbus.activeState == "active")
    property bool serviceEnabled: (dbus.unitFileState == "enabled")

    function refresh() {
      onoffSwitch.checked = !onoffSwitch.checked
      onoffSwitch.busy = false
    }

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

        function jobRemoved( id, job, unit, result ) {
            if ( (unit === "harbour-shaketorch.service") && (result == "done") ) {
                page.refresh()
            }
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

        propertiesEnabled: true
        signalsEnabled: true

        property string activeState
        property string subState
        property string unitFileState

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

            TextSwitch {
                id: onoffSwitch

                width: parent.width - Theme.horizontalPageMargin
                anchors.horizontalCenter: parent.horizontalCenter

                automaticCheck: false
                checked: serviceActive
                text: checked
                    //% "Disable %1"
                    //: name of the start/stop switch
                    ? qsTrId("settings_shaketorch_stop").arg(qsTrId("settings_shaketorch_entryname"))
                    //% "Enable %1"
                    //: name of the start/stop switch
                    : qsTrId("settings_shaketorch_start").arg(qsTrId("settings_shaketorch_entryname"))
                //% "Turn on the flashlight when the device is shaken."
                //: description of the start/stop switch
                description: qsTrId("settings_shaketorch_startstop_desc")
                onClicked: {
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
        }
    }
}
