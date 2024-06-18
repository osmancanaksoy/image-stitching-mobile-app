import Felgo
import QtQuick
import QtQuick.Controls 2.15

App {
  Navigation {
    // enable both tabs and drawer for this demo
    // by default, tabs are shown on iOS and a drawer on Android
    navigationMode: navigationModeTabs

    NavigationItem {
      title: "Home"
      iconType: IconType.home

      NavigationStack {
        AppPage {
         title: "Main Page"
        }
      }
    }

    NavigationItem {
      title: "Camera"
      iconType: IconType.camera

      NavigationStack {
        AppPage {
         title: "Camera"

         AppImage {
           id: image
           anchors.fill: parent
           // important to automatically rotate the image taken from the camera
           autoTransform: true
           fillMode: Image.PreserveAspectFit
         }

         AppButton {
           anchors.bottom: parent.bottom
           anchors.horizontalCenter: parent.horizontalCenter
           text: "Display CameraPicker"
           onClicked: {
             NativeUtils.displayCameraPicker("test")
           }
         }

         Connections {
           target: NativeUtils
           onCameraPickerFinished: (accepted, path) => {
             if(accepted) {
                image.source = path
                }
           }
         }


        }
      }
    }

    NavigationItem {
      title: "Filters"
      iconType: IconType.eyedropper

      NavigationStack {
        AppPage {
         title: "Filters"

         AppImage {
             id: image_f
             anchors.fill: parent
             anchors.bottom: open_image.top
             autoTransform: true
             fillMode: Image.PreserveAspectFit
         }

         AppButton {
             id: gray_button
             anchors.bottom: parent.bottom
             anchors.left: parent.left
             //width: 200
             text: "Gray Scale"
             onClicked: {
                 process.to_gray(image_f.source)
             }
         }

         AppButton {
             anchors.bottom: parent.bottom
             anchors.right: parent.right
             text: "Black&White"
             onClicked: {
                 process.to_binary(image_f.source)
             }
         }

         AppButton {
             id: open_image
             anchors.bottom: gray_button.top
             anchors.horizontalCenter: parent.horizontalCenter
             //width: 2
             //height: 80
             text: "Open Image"
             onClicked: {
                 NativeUtils.displayImagePicker("test")
             }
         }

         Connections {
             target: NativeUtils
             onImagePickerFinished: (accept, path) => {
                                        if(accept) {
                                            image_f.source = path
                                        }

                                    }
         }

         Connections {
             target: process
             function onSendProcessedImage(url) {
                 image_f.source = url
             }
         }
        }
      }
    }

    NavigationItem {
      id: stitch
      //title: "Stitcher"
      iconType: IconType.magic

      NavigationStack {
        AppPage {
         id: page
         //title: "Stitcher"

         AppImage {
             id: image_s
             anchors.fill: parent
             autoTransform: true
             fillMode: Image.PreserveAspectFit
         }

         AppButton {
             id: select_image
             anchors.horizontalCenter: parent.horizontalCenter
             anchors.bottom: parent.bottom
             text: "Select Images"
             onClicked: {
                 page.visible = false
                 pick.visible = true
             }
         }
         Connections {
             target: process
             function onSendProcessedImage(url) {
                 image_s.source = url
             }
         }


        }
        AppPage {
            anchors.top: parent.top
            id:pick
            visible: false
            title: qsTr("Choose Photos")



            // image picker view for photo selection
            ImagePicker {
              id: imagePicker
              anchors.fill: parent
            }

            AppButton {
                enabled: imagePicker.selectedCount > 0
                id: process_button
                anchors.horizontalCenter: parent.horizontalCenter
                anchors.bottom: parent.bottom
                text: "Stitch"
                onClicked: {
                    pick.visible = false
                    page.visible = true

                    var urlList = []
                    for (var i = 0; i < imagePicker.count; ++i) {
                        urlList.push(imagePicker.selection[i])
                    }

                    process.get_images(urlList)
                    //process.to_gray(imagePicker.selection.toString())
                }
            }
        }
      }
    }



    NavigationItem {
      title: "About"
      iconType: IconType.info

      NavigationStack {
        AppPage {
         title: "About"
        }
      }
    }
  }
}
