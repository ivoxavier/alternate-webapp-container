import QtQuick 2.9
import Morph.Web 0.1
import Ubuntu.Components 1.3
import QtQuick.Controls 2.2
import QtWebEngine 1.7 as QTWEBENGINE
import "UCSComponents"
import Ubuntu.Content 1.3
import "."
import "config.js" as Conf

MainView {
    objectName: "mainView"
    width: units.gu(45)
    height: units.gu(75)
    applicationName: "webappcontainer.ogra"

    //useDeprecatedToolbar: false
    //anchorToKeyboard: true
    automaticOrientation: true

    property string myUrl: Conf.webappUrl
    property string myPattern: Conf.webappUrlPattern

    property string myUA: Conf.webappUA ? Conf.webappUA : "Mozilla/5.0 (Linux, Mobile) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/91.0.4472.124 Safari/537.36"

    Page {
        id: page
        anchors {
            fill: parent
            bottom: parent.bottom
        }
        width: parent.width
        height: parent.height

        WebContext {
            id: webcontext
            userAgent: myUA
        }
        WebView {
            id: webview
            anchors {
                fill: parent
                bottom: parent.bottom
            } 
            width: parent.width
            height: parent.height

            context: webcontext
            url: myUrl
            //preferences.localStorageEnabled: true
            //preferences.allowFileAccessFromFileUrls: true
            //preferences.allowUniversalAccessFromFileUrls: true
            //preferences.appCacheEnabled: true
            //preferences.javascriptCanAccessClipboard: true
            //filePicker: filePickerLoader.item

            function navigationRequestedDelegate(request) {
                var url = request.url.toString();
                var pattern = myPattern.split(',');
                var isvalid = false;

                for (var i=0; i<pattern.length; i++) {
                    var tmpsearch = pattern[i].replace(/\*/g,'(.*)')
                    var search = tmpsearch.replace(/^https\?:\/\//g, '(http|https):\/\/');
                    if (url.match(search)) {
                       isvalid = true;
                       break
                    }
                } 
                if(isvalid == false) {
                    console.warn("Opening remote: " + url);
                    Qt.openUrlExternally(url)
                    request.action = QTWEBENGINE.NavigationRequest.ActionReject
                }
            }
            Component.onCompleted: {
                //preferences.localStorageEnabled = true
                if (Qt.application.arguments[1].toString().indexOf(myUrl) > -1) {
                    console.warn("got argument: " + Qt.application.arguments[1])
                    url = Qt.application.arguments[1]
                }
                console.warn("url is: " + url)
            }
            //onGeolocationPermissionRequested: { request.accept() }
            /*Loader {
                id: filePickerLoader
                source: "ContentPickerDialog.qml"
                asynchronous: true
            }*/
        }
        ThinProgressBar {
            webview: webview
            anchors {
                left: parent.left
                right: parent.right
                top: parent.top
            }
        }
        RadialBottomEdge {
            id: nav
            visible: true
            actions: [
                RadialAction {
                    id: reload
                    iconName: "reload"
                    onTriggered: {
                        webview.reload()
                    }
                    text: qsTr("Reload")
                },
                RadialAction {
                    id: forward
                    enabled: webview.canGoForward
                    iconName: "go-next"
                    onTriggered: {
                        webview.goForward()
                    }
                   text: qsTr("Forward")
                 },
                RadialAction {
                    id: back
                    enabled: webview.canGoBack
                    iconName: "go-previous"
                    onTriggered: {
                        webview.goBack()
                    }
                    text: qsTr("Back")
                }
            ]
        }
    }
    Connections {
        target: Qt.inputMethod
        onVisibleChanged: nav.visible = !nav.visible
    }
    Connections {
        target: webview
        onFullscreenChanged: nav.visible = !webview.fullscreen
    }
    Connections {
        target: UriHandler
        onOpened: {
            if (uris.length === 0 ) {
                return;
            }
            webview.url = uris[0]
            console.warn("uri-handler request")
        }
    }
}
