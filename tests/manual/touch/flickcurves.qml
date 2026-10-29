import QtQuick
import QtQuick.Controls.Basic
import QtQuick.Layouts

Rectangle {
    id: root
    width: 1200
    height: 780
    color: "#f2f4f5"

    property int viewKind: 1
    readonly property bool compact: width < 800
    property int selectedCurve: 3
    property int expandedCurve: -1
    readonly property bool expanded: expandedCurve >= 0
    property real launchVelocity: 1800
    property real deceleration: 900
    property real velocityLimit: 5000
    property real bezierX1: 0.16
    property real bezierY1: 1
    property real bezierX2: 0.3
    property real bezierY2: 1
    readonly property var customBezier: [bezierX1, bezierY1, bezierX2, bezierY2, 1, 1]
    readonly property bool editorVisible: curveEditor.visible
    readonly property var curves: [
        { name: "Constant (Old)", detail: "OutQuad", type: Easing.OutQuad, color: "#287b60" },
        { name: "Exponential", detail: "OutExpo", type: Easing.OutExpo, color: "#b44b39" },
        { name: "Custom Bezier", detail: "(0.16, 1), (0.3, 1)", type: Easing.BezierSpline, color: "#346eb1" },
        { name: "Platform default", detail: Qt.platform.os, platformDefault: true, color: "#47606a" }
    ]
    readonly property var photos: ["lemonade.jpg", "fruit-salad.jpg", "hamburger.jpg",
                                   "vegetable-soup.jpg", "pancakes.jpg"]
    readonly property var rowAdjectives: ["Quiet", "Hidden", "Golden", "Distant", "Bright",
                                         "Winding", "Open", "Sleepy", "Wild", "Silver", "Misty", "Secret"]
    readonly property var rowSubjects: ["harbour walks", "mountain trails", "city gardens", "summer evenings",
                                       "forest paths", "weekend journeys", "island shores", "market streets",
                                       "river crossings", "morning stories", "coastal roads"]

    function rowText(rowIndex) {
        return rowAdjectives[(rowIndex * 7 + 3) % rowAdjectives.length] + " "
                + rowSubjects[(rowIndex * 13 + 5) % rowSubjects.length];
    }

    function toggleExpanded(curveIndex) {
        if (expanded) {
            expandedCurve = -1;
        } else {
            selectedCurve = curveIndex;
            expandedCurve = curveIndex;
        }
    }

    Flickable {
        id: platformDefaults
        objectName: "platformDefaults"
        visible: false
    }

    function resetPhysics() {
        launchVelocity = platformDefaults.maximumFlickVelocity;
        velocityLimit = platformDefaults.maximumFlickVelocity;
        deceleration = platformDefaults.flickDeceleration;
    }

    function setBezierCoordinate(coordinate, value) {
        const bounded = Math.max(0, Math.min(1, value));
        if (coordinate === 0) bezierX1 = bounded;
        else if (coordinate === 1) bezierY1 = bounded;
        else if (coordinate === 2) bezierX2 = bounded;
        else bezierY2 = bounded;
    }

    function resetBezier() {
        bezierX1 = 0.16;
        bezierY1 = 1;
        bezierX2 = 0.3;
        bezierY2 = 1;
    }

    onCustomBezierChanged: curvePlot.requestPaint()

    function replay() {
        for (let index = 0; index < lanes.count; ++index) {
            const view = lanes.itemAt(index).view;
            if (view) {
                view.cancelFlick();
                view.contentY = 1000;
            }
        }
        Qt.callLater(function() {
            for (let index = 0; index < lanes.count; ++index) {
                const view = lanes.itemAt(index).view;
                if (view)
                    view.flick(0, -root.launchVelocity);
            }
        });
    }

    ColumnLayout {
        anchors.fill: parent
        readonly property real outerMargin: root.expanded ? 0 : (root.compact ? 16 : 24)
        anchors.topMargin: outerMargin + root.SafeArea.margins.top
        anchors.bottomMargin: outerMargin + root.SafeArea.margins.bottom
        anchors.leftMargin: outerMargin + root.SafeArea.margins.left
        anchors.rightMargin: outerMargin + root.SafeArea.margins.right
        spacing: root.expanded ? 0 : 18

        RowLayout {
            Layout.fillWidth: true
            visible: !root.expanded
            Label {
                text: "Flick Curves"
                font.family: "Avenir Next"
                font.pixelSize: 28
                font.bold: true
                color: "#20272b"
            }
            Item { Layout.fillWidth: true }
            Button {
                objectName: "replayButton"
                text: "Replay All"
                onClicked: root.replay()
            }
        }

        RowLayout {
            Layout.fillWidth: true
            visible: !root.expanded
            ComboBox {
                id: viewSelector
                objectName: "viewSelector"
                Layout.fillWidth: root.compact
                model: ["Flickable", "ListView", "GridView (Pictures)"]
                currentIndex: root.viewKind
                onActivated: root.viewKind = currentIndex
            }
            ComboBox {
                objectName: "curveSelector"
                Layout.fillWidth: true
                visible: root.compact
                model: root.curves
                textRole: "name"
                currentIndex: root.selectedCurve
                onActivated: root.selectedCurve = currentIndex
            }
            Item { Layout.fillWidth: true; visible: !root.compact }
        }

        GridLayout {
            Layout.fillWidth: true
            visible: !root.expanded
            columns: root.compact ? 3 : 6
            rowSpacing: 12
            columnSpacing: 12
            Label { text: "Velocity"; color: "#36434a" }
            Slider {
                objectName: "velocitySlider"
                Layout.fillWidth: true
                from: 400
                to: Math.max(3000, platformDefaults.maximumFlickVelocity)
                stepSize: 100
                value: root.launchVelocity
                onMoved: root.launchVelocity = value
            }
            Label {
                Layout.preferredWidth: 85
                text: root.launchVelocity.toFixed(0) + " px/s"
                color: "#36434a"
            }
            Label { text: "Deceleration"; color: "#36434a" }
            Slider {
                objectName: "decelerationSlider"
                Layout.fillWidth: true
                from: 300
                to: Math.max(2400, platformDefaults.flickDeceleration)
                stepSize: 100
                value: root.deceleration
                onMoved: root.deceleration = value
            }
            Label {
                Layout.preferredWidth: 100
                text: root.deceleration.toFixed(0) + " px/s^2"
                color: "#36434a"
            }
            Button {
                objectName: "resetPhysicsButton"
                Layout.columnSpan: parent.columns
                Layout.alignment: Qt.AlignRight
                text: "Platform defaults"
                onClicked: root.resetPhysics()
            }
        }

        RowLayout {
            Layout.fillWidth: true
            Layout.fillHeight: true
            spacing: 16

            Repeater {
                id: lanes
                model: root.curves
                delegate: ColumnLayout {
                    id: lane
                    required property var modelData
                    required property int index
                    readonly property Flickable view: viewport.item
                    visible: root.expanded ? index === root.expandedCurve
                                          : !root.compact || index === root.selectedCurve
                    Layout.fillWidth: true
                    Layout.fillHeight: true
                    Layout.preferredWidth: 260
                    spacing: 8

                    Label {
                        Layout.fillWidth: true
                        visible: !root.expanded
                        text: lane.modelData.name
                        font.family: "Avenir Next"
                        font.pixelSize: 18
                        font.bold: true
                        color: lane.modelData.color
                        elide: Text.ElideRight
                    }
                    Label {
                        Layout.fillWidth: true
                        visible: !root.expanded
                                                text: lane.index === 2
                                                            ? "(" + root.bezierX1.toFixed(2) + ", " + root.bezierY1.toFixed(2)
                                                                + "), (" + root.bezierX2.toFixed(2) + ", " + root.bezierY2.toFixed(2) + ")"
                                                            : lane.modelData.detail
                        color: "#56616a"
                        elide: Text.ElideRight
                    }
                    Button {
                        objectName: lane.index === 2 ? "editBezierButton" : ""
                        visible: lane.index === 2 && !root.expanded
                        text: "Edit curve"
                        onClicked: curveEditor.open()
                    }
                    Loader {
                        id: viewport
                        Layout.fillWidth: true
                        Layout.fillHeight: true
                        sourceComponent: root.viewKind === 0 ? flickableView
                                         : root.viewKind === 1 ? listView : gridView
                        onLoaded: {
                            if (!lane.modelData.platformDefault) {
                                item.flickEasing.type = lane.modelData.type;
                                if (lane.modelData.type === Easing.BezierSpline)
                                    item.flickEasing.bezierCurve = Qt.binding(function() {
                                        return root.customBezier;
                                    });
                            }
                            item.contentY = 1000;
                        }
                    }
                    Label {
                        Layout.fillWidth: true
                        visible: !root.expanded
                        text: lane.view ? "y " + lane.view.contentY.toFixed(0)
                              + "   |   " + Math.abs(lane.view.verticalVelocity).toFixed(0)
                              + " px/s" : ""
                        font.family: "Menlo"
                        font.pixelSize: 12
                        color: "#36434a"
                    }

                    Component {
                        id: rowDelegate
                        Rectangle {
                            required property int index
                            width: viewport.width
                            height: 50
                            color: index % 2 ? "#ffffff" : "#e8edef"
                            Rectangle {
                                width: 4
                                height: parent.height
                                color: lane.modelData.color
                            }
                            Text {
                                anchors.left: parent.left
                                anchors.leftMargin: 16
                                anchors.right: parent.right
                                anchors.rightMargin: 12
                                anchors.verticalCenter: parent.verticalCenter
                                text: root.rowText(index)
                                font.family: "Avenir Next"
                                font.pixelSize: 15
                                color: "#36434a"
                                elide: Text.ElideRight
                            }
                        }
                    }

                    Component {
                        id: flickableView
                        Flickable {
                            objectName: "curveView" + lane.index
                            clip: true
                            contentWidth: width
                            contentHeight: rows.height
                            boundsBehavior: Flickable.StopAtBounds
                            maximumFlickVelocity: root.velocityLimit
                            flickDeceleration: root.deceleration
                            TapHandler {
                                gesturePolicy: TapHandler.DragThreshold
                                onDoubleTapped: root.toggleExpanded(lane.index)
                            }
                            Column {
                                id: rows
                                Repeater { model: 200; delegate: rowDelegate }
                            }
                        }
                    }
                    Component {
                        id: listView
                        ListView {
                            objectName: "curveView" + lane.index
                            clip: true
                            model: 200
                            delegate: rowDelegate
                            boundsBehavior: Flickable.StopAtBounds
                            maximumFlickVelocity: root.velocityLimit
                            flickDeceleration: root.deceleration
                            TapHandler {
                                gesturePolicy: TapHandler.DragThreshold
                                onDoubleTapped: root.toggleExpanded(lane.index)
                            }
                        }
                    }
                    Component {
                        id: gridView
                        GridView {
                            objectName: "curveView" + lane.index
                            clip: true
                            model: 400
                            cellWidth: width / 2
                            cellHeight: cellWidth
                            boundsBehavior: Flickable.StopAtBounds
                            maximumFlickVelocity: root.velocityLimit
                            flickDeceleration: root.deceleration
                            TapHandler {
                                gesturePolicy: TapHandler.DragThreshold
                                onDoubleTapped: root.toggleExpanded(lane.index)
                            }
                            delegate: Rectangle {
                                required property int index
                                width: viewport.width / 2 - 2
                                height: width
                                color: "#e8edef"
                                Image {
                                    objectName: "gridPicture"
                                    anchors.fill: parent
                                    source: Qt.resolvedUrl("../../../examples/quick/views/listview/content/pics/"
                                                           + root.photos[index % root.photos.length])
                                    sourceSize.width: 360
                                    sourceSize.height: 360
                                    fillMode: Image.PreserveAspectCrop
                                    asynchronous: true
                                }
                            }
                        }
                    }
                }
            }
        }
    }

    Popup {
        id: curveEditor
        parent: Overlay.overlay
        anchors.centerIn: parent
        width: Math.min(root.width - 32, 480)
        padding: 16
        modal: true
        focus: true
        closePolicy: Popup.CloseOnEscape | Popup.CloseOnPressOutside

        contentItem: ColumnLayout {
            spacing: 12
            Label {
                text: "Custom Bezier"
                font.pixelSize: 20
                font.bold: true
            }
            Rectangle {
                Layout.fillWidth: true
                Layout.preferredHeight: 200
                color: "#ffffff"
                border.color: "#aebac0"

                Item {
                    id: plot
                    anchors.fill: parent
                    anchors.margins: 24

                    Canvas {
                        id: curvePlot
                        anchors.fill: parent
                        onPaint: {
                            const context = getContext("2d");
                            context.clearRect(0, 0, width, height);
                            context.lineWidth = 1;
                            context.strokeStyle = "#e0e6e9";
                            context.beginPath();
                            for (let step = 0; step <= 4; ++step) {
                                const fraction = step / 4;
                                context.moveTo(fraction * width, 0);
                                context.lineTo(fraction * width, height);
                                context.moveTo(0, fraction * height);
                                context.lineTo(width, fraction * height);
                            }
                            context.stroke();
                            context.strokeStyle = "#89969d";
                            context.beginPath();
                            context.moveTo(0, height);
                            context.lineTo(root.bezierX1 * width, (1 - root.bezierY1) * height);
                            context.moveTo(width, 0);
                            context.lineTo(root.bezierX2 * width, (1 - root.bezierY2) * height);
                            context.stroke();
                            context.strokeStyle = "#346eb1";
                            context.lineWidth = 3;
                            context.beginPath();
                            context.moveTo(0, height);
                            context.bezierCurveTo(root.bezierX1 * width, (1 - root.bezierY1) * height,
                                                 root.bezierX2 * width, (1 - root.bezierY2) * height,
                                                 width, 0);
                            context.stroke();
                        }
                        onWidthChanged: requestPaint()
                        onHeightChanged: requestPaint()
                    }

                    Repeater {
                        model: 2
                        delegate: Item {
                            required property int index
                            objectName: "bezierHandle" + index
                            width: 44
                            height: 44
                            x: (index === 0 ? root.bezierX1 : root.bezierX2) * plot.width - width / 2
                            y: (1 - (index === 0 ? root.bezierY1 : root.bezierY2)) * plot.height - height / 2
                            Rectangle {
                                anchors.centerIn: parent
                                width: 18
                                height: 18
                                radius: 9
                                color: index === 0 ? "#346eb1" : "#b44b39"
                                border.color: "#ffffff"
                                border.width: 2
                            }
                            MouseArea {
                                anchors.fill: parent
                                preventStealing: true
                                property point grabOffset
                                onPressed: function(mouse) {
                                    grabOffset = Qt.point(mouse.x - width / 2, mouse.y - height / 2);
                                }
                                onPositionChanged: function(mouse) {
                                    if (!pressed)
                                        return;
                                    const position = mapToItem(plot, mouse.x - grabOffset.x,
                                                               mouse.y - grabOffset.y);
                                    root.setBezierCoordinate(index * 2, position.x / plot.width);
                                    root.setBezierCoordinate(index * 2 + 1, 1 - position.y / plot.height);
                                }
                            }
                        }
                    }
                }
            }
            GridLayout {
                Layout.fillWidth: true
                columns: 2
                columnSpacing: 12
                Repeater {
                    model: ["x1", "y1", "x2", "y2"]
                    delegate: RowLayout {
                        required property int index
                        required property string modelData
                        Layout.fillWidth: true
                        Label { text: modelData }
                        SpinBox {
                            Layout.fillWidth: true
                            Layout.minimumWidth: 0
                            from: 0
                            to: 100
                            editable: true
                            value: Math.round(root.customBezier[index] * 100)
                            validator: DoubleValidator { bottom: 0; top: 1; decimals: 2 }
                            textFromValue: function(value, locale) {
                                return Number(value / 100).toLocaleString(locale, "f", 2);
                            }
                            valueFromText: function(text, locale) {
                                return Math.round(Number.fromLocaleString(locale, text) * 100);
                            }
                            onValueModified: root.setBezierCoordinate(index, value / 100)
                        }
                    }
                }
            }
            RowLayout {
                Layout.fillWidth: true
                Button { text: "Reset"; onClicked: root.resetBezier() }
                Item { Layout.fillWidth: true }
                Button { text: "Done"; onClicked: curveEditor.close() }
            }
        }
    }
}