import 'package:bottom_sheet_scaffold/bottom_sheet_scaffold.dart';
import 'package:flutter/material.dart';
import '../../../controller/gallery_controller.dart';
import '../../../models/media_file.dart';
import '../thumbnail_media_file.dart';

class MediaView extends StatelessWidget {
  final MediaFile file;
  final PhoneGalleryController controller;
  final bool singleMedia;
  final bool isBottomSheet;
  const MediaView(this.file,
      {super.key,
      required this.controller,
      required this.singleMedia,
      required this.isBottomSheet});
  @override
  Widget build(BuildContext context) {
    return Stack(
      fit: StackFit.expand,
      children: [
        ThumbnailMediaFile(
            onLongPress: () async {
              if (singleMedia) {
                controller.selectedFiles.add(file);
                if (controller.heroBuilder != null) {
                  await Navigator.of(context).push(
                      MaterialPageRoute<void>(builder: (BuildContext context) {
                    return controller.heroBuilder!(file.id, file, context);
                  }));
                  controller.switchPickerMode(true);
                } else if (controller.multipleMediasBuilder != null) {
                  await Navigator.of(context).push(
                      MaterialPageRoute<void>(builder: (BuildContext context) {
                    return controller.multipleMediasBuilder!([file], context);
                  }));
                  controller.switchPickerMode(true);
                } else {
                  controller.onSelect(controller.selectedFiles);
                  if (isBottomSheet) {
                    BottomSheetPanel.close();
                    controller.switchPickerMode(true);
                    controller.updatePickerListener();
                  } else {
                    Navigator.pop(context);
                    controller.updatePickerListener();
                    controller.disposeController();
                  }
                }
              } else {
                controller.selectMedia(file);
              }
            },
            onTap: () async {
              if (controller.pickerMode) {
                if (controller.isSelectedMedia(file)) {
                  controller.unselectMedia(file);
                } else {
                  controller.selectMedia(file);
                }
              } else {
                controller.selectedFiles.clear(); // Important: clear previous selection
                controller.selectedFiles.add(file);
                if (controller.heroBuilder != null) {
                  await Navigator.of(context).push(
                      MaterialPageRoute<void>(builder: (BuildContext context) {
                    return controller.heroBuilder!(file.id, file, context);
                  }));
                  controller.switchPickerMode(true);
                } else if (controller.multipleMediasBuilder != null) {
                  await Navigator.of(context).push(
                      MaterialPageRoute<void>(builder: (BuildContext context) {
                    return controller.multipleMediasBuilder!([file], context);
                  }));
                  controller.switchPickerMode(true);
                } else {
                  controller.onSelect(controller.selectedFiles);
                  if (isBottomSheet) {
                    BottomSheetPanel.close();
                    controller.switchPickerMode(true);
                    controller.updatePickerListener();
                  } else {
                    controller.updatePickerListener();
                    controller.disposeController();
                    Navigator.of(context, rootNavigator: true).pop(); // --> full pop
                  }
                }
              }
            },
            file: file,
            failIconColor: controller.config.appbarIconColor,
            controller: controller),
      ],
    );
  }
}
