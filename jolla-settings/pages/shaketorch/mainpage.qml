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

    onVisibleChanged: if (visible)
        dbus.updateProperties()
    onStatusChanged: if (status != PageStatus.Inactive)
        dbus.updateProperties()

    /*
     * DConf path, must be the same in AccWatcher
     */
    ConfigurationGroup {
        id: config
        path: "/apps/dev.scarpino/harbour-shaketorch"
        property bool turnOnOnShake: true
        property bool turnOffOnShake: true

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

        property string uname: "harbour-shaketorch.service"

        function enable() {
            typedCall('EnableUnitFiles', [
                {
                    "type": "as",
                    "value": [uname]
                },
                {
                    "type": "b",
                    "value": false
                },
                {
                    "type": "b",
                    "value": true
                },
            ], function (result) {
                console.debug("Enabled", result);
                dbus.updateProperties();
            }, function (result) {
                console.warn("Enable", result[1]);
            });
        }
        function disable() {
            typedCall('DisableUnitFiles', [
                {
                    "type": "as",
                    "value": [uname]
                },
                {
                    "type": "b",
                    "value": false
                },
            ], function (result) {
                console.debug("Disabled", result);
                dbus.updateProperties();
            }, function (result) {
                console.warn("Disable", result);
            });
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
            page.activeStr = dbus.getProperty("ActiveState");
            page.enabledStr = dbus.getProperty("UnitFileState");
        }
        function startUnit() {
            call("Start", "replace", undefined, undefined);
        }
        function stopUnit() {
            call("Stop", "replace", undefined, undefined);
        }
    }

    SilicaFlickable {
        id: flick
        anchors.fill: parent
        contentHeight: column.height

        Column {
            id: column
            width: page.width
            spacing: Theme.paddingMedium

            PageHeader {
                title: qsTrId("settings_shaketorch_entryname")
            }

            Timer {
                running: enableSwitch.busy || activeSwitch.busy
                interval: 4000
                onTriggered: {
                    dbus.updateProperties();
                    enableSwitch.busy = false;
                    activeSwitch.busy = false;
                }
            }
            Label{
                width: parent.width - Theme.horizontalPageMargin
                anchors.horizontalCenter: parent.horizontalCenter
                color: Theme.highlightColor
                //% "ShakeTorch can turn the flashlight on or off when the device is shaken."
                text: qsTrId("settings_shaketorch_label")
                font.pixelSize: Theme.fontSizeSmall
                wrapMode: Text.Wrap
            }

            SectionHeader {
                //% "Service"
                text: qsTrId("settings_shaketorch_he_service")
            }

            TextSwitch {
                id: activeSwitch

                width: parent.width - Theme.horizontalPageMargin
                anchors.horizontalCenter: parent.horizontalCenter

                automaticCheck: false
                checked: serviceActive
                //% "Activate flashlight control"
                //: description of the active switch
                text: qsTrId("settings_shaketorch_active_desc")
                onClicked: {
                    if (busy)
                        return;
                    busy = true;
                    if (!checked) {
                        console.info("ShakeTorch: engaged.");
                        dbus.startUnit();
                    } else {
                        console.info("ShakeTorch: dis-engaged.");
                        dbus.stopUnit();
                    }
                }
            }

            TextSwitch {
                id: enableSwitch

                width: parent.width - Theme.horizontalPageMargin
                anchors.horizontalCenter: parent.horizontalCenter

                automaticCheck: false
                checked: serviceEnabled
                //% "Start at Boot"
                //: description of the enable switch
                text: qsTrId("settings_shaketorch_enable_desc")
                onClicked: {
                    if (busy)
                        return;
                    busy = true;
                    if (!checked) {
                        console.info("ShakeTorch: enabling.");
                        manager.enable();
                    } else {
                        console.info("ShakeTorch: disabling.");
                        manager.disable();
                    }
                }
            }


            SectionHeader {
                //% "Options"
                text: qsTrId("settings_shaketorch_he_options")
            }

            Label{
                width: parent.width - Theme.horizontalPageMargin
                anchors.horizontalCenter: parent.horizontalCenter
                color: Theme.highlightColor
                //% "When shaking is detected:"
                text: qsTrId("settings_shaketorch_option_label")
                font.pixelSize: Theme.fontSizeSmall
                wrapMode: Text.Wrap
            }


            TextSwitch {
                id: onSwitch

                width: parent.width - Theme.horizontalPageMargin
                anchors.horizontalCenter: parent.horizontalCenter

                checked: config.turnOnOnShake
                //% "Turn the flashlight on"
                //: description of the start switch
                text: qsTrId("settings_shaketorch_start_desc")
                onClicked: config.turnOnOnShake = checked
            }

            TextSwitch {
                id: offSwitch

                width: parent.width - Theme.horizontalPageMargin
                anchors.horizontalCenter: parent.horizontalCenter

                checked: config.turnOffOnShake
                //% "Turn the flashlight off"
                //: description of the stop switch
                text: qsTrId("settings_shaketorch_stop_desc")
                onClicked: config.turnOffOnShake = checked
            }
        }
    }
}
