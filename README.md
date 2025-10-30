## gallery_picker_plus

Modern, customizable gallery picker for Flutter with multi-select, recent media, hero transitions, and builder-based customization.

> Built on and inspired by the original `gallery_picker` package by FlutterWay. See: [gallery_picker on pub.dev](https://pub.dev/packages/gallery_picker).

### Features
- Multi-select images and videos
- Recent media start mode
- Custom hero and multi-media builders
- Bottom-sheet controls via `BottomSheetPanel`
- Stream listener for selected files
- Collect gallery metadata (albums, media) with filtering

### Screenshots and GIFs

<div style="text-align: center">
  <table>
    <tr>
      <td style="text-align: center">
        <img src="https://raw.githubusercontent.com/FlutterWay/files/main/gallery_picker_views/gallery_picker_light.gif" width="200"/>
      </td>
      <td style="text-align: center">
        <img src="https://raw.githubusercontent.com/FlutterWay/files/main/gallery_picker_views/gallery_picker_dark.gif" width="200"/>
      </td>
      <td style="text-align: center">
        <img src="https://raw.githubusercontent.com/FlutterWay/files/main/gallery_picker_views/gallery_picker_destination.gif" width="200"/>
      </td>
      <td style="text-align: center">
        <img src="https://raw.githubusercontent.com/FlutterWay/files/main/gallery_picker_views/camera_page.gif" width="200"/>
      </td>
    </tr>
  </table>
</div>

### Requirements
- Dart SDK: `^3.9.2`
- Flutter: `>=3.3.0`

### Installation

Add to your `pubspec.yaml`:

```yaml
dependencies:
  gallery_picker_plus: ^0.0.1
```

Then run:

```bash
flutter pub get
```

### Platform setup

#### iOS
Add the Photo Library usage descriptions to `ios/Runner/Info.plist`:

```xml
<key>NSPhotoLibraryUsageDescription</key>
<string>This app needs access to your photo library to select media.</string>
<key>NSPhotoLibraryAddUsageDescription</key>
<string>This app may save media to your photo library.</string>
```

Make sure your app uses a valid build name/number in `pubspec.yaml` (e.g., `version: 1.0.0+1`).

#### Android
Ensure the following permissions exist in `android/app/src/main/AndroidManifest.xml` (adjust per min/target SDK):

```xml
<uses-permission android:name="android.permission.READ_MEDIA_IMAGES"/>
<uses-permission android:name="android.permission.READ_MEDIA_VIDEO"/>
<!-- Pre-Android 13 permission: -->
<uses-permission android:name="android.permission.READ_EXTERNAL_STORAGE"/>
```

At runtime, request permissions using a package like `permission_handler` (example below).

Notes:
- For broad compatibility, consider `minSdkVersion` 25 in `android/app/build.gradle`.
- Update Kotlin/AGP if your project is older (e.g., Kotlin 1.6.0, AGP 7.0.4) per your setup.

### Quick start

```dart
import 'package:flutter/material.dart';
import 'package:gallery_picker_plus/gallery_picker.dart';

class Demo extends StatefulWidget {
  const Demo({super.key});
  @override
  State<Demo> createState() => _DemoState();
}

class _DemoState extends State<Demo> {
  List<MediaFile> selected = [];

  Future<void> pick() async {
    final media = await GalleryPicker.pickMedia(
      context: context,
      initSelectedMedia: selected,
      extraRecentMedia: selected,
      startWithRecent: true,
    );
    if (media != null) setState(() => selected = media);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Gallery Picker Plus')),
      floatingActionButton: FloatingActionButton(
        onPressed: pick,
        child: const Icon(Icons.add),
      ),
      body: ListView(
        children: [
          for (final m in selected)
            Padding(
              padding: const EdgeInsets.all(8),
              child: ThumbnailMedia(media: m),
            ),
        ],
      ),
    );
  }
}
```

### Advanced usage

#### Builder mode with custom UI and hero

```dart
await GalleryPicker.pickMediaWithBuilder(
  multipleMediaBuilder: (medias, context) {
    return YourCustomMediasView(medias);
  },
  heroBuilder: (tag, media, context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Preview')),
      body: Center(
        child: Hero(
          tag: tag,
          child: MediaProvider(
            media: media,
            width: MediaQuery.of(context).size.width - 50,
            height: 300,
          ),
        ),
      ),
    );
  },
  context: context,
  startWithRecent: true,
);
```

#### PickerScaffold (bottom sheet layout)

Use a scaffold that integrates the picker as a bottom sheet:

```dart
import 'package:gallery_picker_plus/gallery_picker.dart';

@override
Widget build(BuildContext context) {
  return PickerScaffold(
    backgroundColor: Colors.transparent,
    onSelect: (media) {},
    initSelectedMedia: const [],
    config: const Config(),
    body: Container(),
  );
}
```

#### Listen to selected files (stream)

```dart
final subscription = GalleryPicker.listenSelectedFiles.listen((files) {
  // Handle updated selected files
});

// When done:
GalleryPicker.disposeSelectedFilesListener();
subscription.cancel();
```

#### Control the bottom sheet state

```dart
await GalleryPicker.openSheet();
final isOpen = GalleryPicker.isSheetOpened; // also: isSheetExpanded, isSheetCollapsed
await GalleryPicker.closeSheet();
```

#### Collect gallery metadata (albums/media)

```dart
final media = await GalleryPicker.collectGallery();
```

#### GalleryPickerBuilder

Update UI based on in-picker selections:

```dart
GalleryPickerBuilder(
  builder: (selectedFiles, context) {
    return Text('Selected: \\${selectedFiles.length}');
  },
)
```

#### BottomSheetBuilder

Listen to bottom sheet status to toggle UI:

```dart
BottomSheetBuilder(
  builder: (status, context) {
    return FloatingActionButton(
      onPressed: () {
        if (status.isExpanded) {
          GalleryPicker.closeSheet();
        } else {
          GalleryPicker.openSheet();
        }
      },
      child: Icon(!status.isExpanded ? Icons.open_in_browser : Icons.close_fullscreen),
    );
  },
)
```

### Permissions example (recommended)

```dart
import 'package:permission_handler/permission_handler.dart';

Future<void> ensureMediaPermissions() async {
  final photos = await Permission.photos.request();
  final videos = await Permission.videos.request();
  if (photos.isGranted && videos.isGranted) return;
  await Permission.storage.request();
}
```

If the user denies permissions, you can present a dedicated page via `Config(permissionDeniedPage: ...)`.

<img src="https://raw.githubusercontent.com/FlutterWay/files/main/gallery_picker_views/permission_denied.gif" width="200" />

### API overview

- `Future<List<MediaFile>?> GalleryPicker.pickMedia({...})`
- `Future<void> GalleryPicker.pickMediaWithBuilder({...})`
- `Stream<List<MediaFile>> GalleryPicker.listenSelectedFiles`
- `void GalleryPicker.disposeSelectedFilesListener()`
- `void GalleryPicker.dispose()`
- `Future<GalleryMedia?> GalleryPicker.collectGallery({ locale, mediaType })`
- `Future<GalleryMedia?> GalleryPicker.initializeGallery({ locale })`
- Sheet helpers: `openSheet()`, `closeSheet()`, `isSheetOpened`, `isSheetExpanded`, `isSheetCollapsed`

Key models are exported: `MediaFile`, `GalleryMedia`, `Medium`, `GalleryAlbum`, `Config`, plus UI helpers like `MediaProvider`, `ThumbnailMedia`, etc.

### Ready-to-use widgets

Handy UI helpers:

```dart
// Thumbnails for media files
ThumbnailMedia(media: media);

// Thumbnails for albums
ThumbnailAlbum(album: album);

// Image provider
PhotoProvider(media: media);

// Video provider
VideoProvider(media: media);
```

### Album views

Render albums and their contents:

```dart
final all = await GalleryPicker.collectGallery();

AlbumMediaView(
  galleryAlbum: all!.albums.first,
);

AlbumCategoriesView(
  albums: all.albums,
);
```

### Troubleshooting
- iOS crash on permission request: ensure `NSPhotoLibraryUsageDescription` and `NSPhotoLibraryAddUsageDescription` exist in `Info.plist`.
- Nothing returns on Android 13+: ensure `READ_MEDIA_IMAGES`/`READ_MEDIA_VIDEO` permissions and grant them at runtime.
- Black thumbnails for videos: ensure `video_thumbnail` and `video_player` are working in your environment.

### Publishing to pub.dev
1. Update `pubspec.yaml` with a proper `version`, `description`, `homepage`/`repository`.
2. Verify the README renders well on pub.dev (no remote images requiring auth).
3. Run a dry run:
   ```bash
   dart pub publish --dry-run
   ```
4. Publish:
   ```bash
   dart pub publish -f
   ```

### License
MIT

### Credits

This plugin builds upon ideas from the original `gallery_picker` by FlutterWay. Reference: [gallery_picker on pub.dev](https://pub.dev/packages/gallery_picker).


