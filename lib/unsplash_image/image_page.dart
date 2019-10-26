import 'package:flutter/material.dart';
import 'package:image_downloader/image_downloader.dart';
import 'package:photo_view/photo_view.dart';
import 'package:uwall/unsplash_image/image_provider.dart' as prefix0;
import 'package:uwall/unsplash_image/info_sheet.dart';
import 'package:url_launcher/url_launcher.dart';
import './model.dart';

/// Screen for showing an individual [UnsplashImage].
class ImagePage extends StatefulWidget {
  final String imageId, imageUrl;

  ImagePage(this.imageId, this.imageUrl, {Key key}) : super(key: key);

  @override
  _ImagePageState createState() => _ImagePageState();
}

/// Provide a state for [ImagePage].
class _ImagePageState extends State<ImagePage> {
  /// create global key to show info bottom sheet
  final GlobalKey<ScaffoldState> _scaffoldKey = new GlobalKey<ScaffoldState>();

  /// Bottomsheet controller
  PersistentBottomSheetController bottomSheetController;

  ///Check whether Bottom Sheet is open or not.
  bool _bottomSheetStatus = false;

  /// Displayed image.
  UnsplashImage image;

  @override
  void initState() {
    super.initState();
    // load image
    _loadImage();
  }

  /// Reloads the image from unsplash to get extra data, like: exif, location, ...
  _loadImage() async {
    UnsplashImage image = await prefix0.ImageProvider.loadImage(widget.imageId);
    setState(() {
      this.image = image;
      // reload bottom sheet if open
      if (bottomSheetController != null) {
        _showInfoBottomSheet();
      }
    });
  }

  ///Download Image
  _downloadImage() async {
    String message;
    try {
      var imageId = ImageDownloader.downloadImage(widget.imageUrl,
          destination: AndroidDestinationType.custom(directory: 'UWall'));
      if (imageId == null) {
        message = 'Download failed.';
      } else {
        message = 'Image downloaded in UWall folder.';
      }
    } catch (error) {
      message = 'Unable to download image.';
    }
    final snackBar = SnackBar(content: Text(message));
    setState(() {
      ImageDownloader.callback(
          onProgressUpdate: (String imageId, int progress) {
        setState(() {
          if (progress == 100 || progress == null) {
            _scaffoldKey.currentState.showSnackBar(snackBar);
          }
        });
      });
    });
  }

  /// Returns AppBar.
  Widget _buildAppBar() => AppBar(
        elevation: 0.0,
        backgroundColor: Colors.transparent,
        actions: <Widget>[
          // show image info
          IconButton(
              icon: Icon(
                Icons.info_outline,
                color: Colors.white,
              ),
              tooltip: 'Image Info',
              onPressed: () {
                if (_bottomSheetStatus == false) {
                  bottomSheetController = _showInfoBottomSheet();
                  _bottomSheetStatus = true;
                }
                else{
                  _bottomSheetStatus = false;
                  Navigator.of(context).pop();
                }
              }),
          // open in browser icon button
          IconButton(
              icon: Icon(
                Icons.open_in_browser,
                color: Colors.white,
              ),
              tooltip: 'Open in Browser',
              onPressed: () => launch(image?.getHtmlLink())),
          IconButton(
            icon: Icon(
              Icons.file_download,
              color: Colors.white,
            ),
            tooltip: 'Download Image',
            onPressed: _downloadImage,
          ),
        ],
      );

  /// Returns PhotoView around given [imageId] & [imageUrl].
  Widget _buildPhotoView(String imageId, String imageUrl) => PhotoView(
        imageProvider: NetworkImage(imageUrl),
        initialScale: PhotoViewComputedScale.covered,
        minScale: PhotoViewComputedScale.covered,
        heroAttributes: PhotoViewHeroAttributes(tag: '$imageId'),
        maxScale: PhotoViewComputedScale.covered,
        loadingChild: const Center(
            child: CircularProgressIndicator(
          valueColor: AlwaysStoppedAnimation<Color>(Colors.white70),
        )),
      );

  @override
  Widget build(BuildContext context) {
    return Scaffold(
          // set the global key
          key: _scaffoldKey,
          backgroundColor: Colors.black,
          body: Stack(
            children: <Widget>[
              _buildPhotoView(widget.imageId, widget.imageUrl),
              // wrap in Positioned to not use entire screen
              Positioned(
                  top: 0.0, left: 0.0, right: 0.0, child: _buildAppBar()),
            ],
          ),
        );
  }

  /// Shows a BottomSheet containing image info.
  PersistentBottomSheetController _showInfoBottomSheet() {
    return _scaffoldKey.currentState.showBottomSheet(
      (context) => InfoSheet(image),
    );
  }
}
