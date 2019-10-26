import 'package:flutter/material.dart';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';
import 'package:theme_provider/theme_provider.dart';
import 'package:uwall/screens/settings_page.dart';
import 'package:uwall/unsplash_image/image_provider.dart' as prefix1;
import 'package:uwall/unsplash_image/image_tile.dart';
import 'package:uwall/unsplash_image/loading_indicator.dart';
import 'package:uwall/unsplash_image/model.dart';

/// Screen for showing a collection of trending [UnsplashImage].
class MainPage extends StatefulWidget {
  @override
  _MainPageState createState() => _MainPageState();
}

/// Provide a state for [MainPage].
class _MainPageState extends State<MainPage> {
  /// Stores the current page index for the api requests.
  int page = 0, totalPages = -1;

  /// Stores the currently loaded images.
  List<UnsplashImage> images = [];

  /// States whether there is currently a task running loading images.
  bool loadingImages = false;

  /// Stored the currently searched keyword.
  String keyword;

  @override
  initState() {
    super.initState();
    // initial image Request
    _loadImages();
  }

  /// Resets the state to the inital state.
  _resetImages() {
    // clear image list
    images = [];
    // reset page counter
    page = 0;
    totalPages = -1;
    // reset keyword
    keyword = null;
    // show regular images
    _loadImages();
  }

  /// Requests a list of [UnsplashImage] for a given [keyword].
  /// If the given [keyword] is null, trending images are loaded.
  _loadImages({String keyword}) async {
    // check if there is currently a loading task running
    if (loadingImages) {
      // there is currently a task running
      return;
    }
    // check if all pages are already loaded
    if (totalPages != -1 && page >= totalPages) {
      // all pages already loaded
      return;
    }
    // set loading state
    // delay setState, otherwise: Unhandled Exception: setState() or markNeedsBuild() called during build.
    await Future.delayed(Duration(microseconds: 1));
    setState(() {
      // set loading
      loadingImages = true;
      // check if new search
      if (this.keyword != keyword) {
        // clear images for new search
        this.images = [];
        // reset page counter
        this.page = 0;
      }
      // keyword null
      this.keyword = keyword;
    });

    // load images
    List<UnsplashImage> images;
    if (keyword == null) {
      // load images from the next page of trending images
      images = await prefix1.ImageProvider.loadImages(page: ++page);
    } else {
      // load images from the next page with a keyword
      List res = await prefix1.ImageProvider.loadImagesWithKeyword(keyword,
          page: ++page);
      // set totalPages
      totalPages = res[0];
      // set images
      images = res[1];
    }

    // update the state
    setState(() {
      // done loading
      loadingImages = false;
      // set new loaded images
      this.images.addAll(images);
    });
  }

  /// Asynchronously loads a [UnsplashImage] for a given [index].
  Future<UnsplashImage> _loadImage(int index) async {
    // check if new images need to be loaded
    if (index >= images.length - 2) {
      // Reached the end of the list. Try to load more images.
      _loadImages(keyword: keyword);
    }

    return index < images.length ? images[index] : null;
  }

  @override
  Widget build(BuildContext context) => WillPopScope(
        onWillPop: () async {
          if (keyword != null) {
            _resetImages();
            return false;
          }
          return true;
        },
        child: Scaffold(
            backgroundColor: Theme.of(context).primaryColor,
            body: OrientationBuilder(
                builder: (context, orientation) => CustomScrollView(
                        // put AppBar in NestedScrollView to have it sliver off on scrolling
                        slivers: <Widget>[
                      _buildSearchAppBar(),
                      _buildImageGrid(orientation: orientation),
                      // loading indicator at the bottom of the list
                      loadingImages
                          ? SliverToBoxAdapter(
                              child: LoadingIndicator(Colors.grey[400]),
                            )
                          : null,
                      // filter null views
                    ].where((w) => w != null).toList()))),
      );

  /// Returns the SearchAppBar.
  Widget _buildSearchAppBar() => SliverAppBar(
        title: keyword != null
            ?
            // either search-field or just the title
            
            TextField(
                keyboardType: TextInputType.text,
                decoration: InputDecoration(
                    hintText: 'Search...',
                    hintStyle: TextStyle(
                      color: Theme.of(context).textTheme.display1.color
                    ),
                    border: InputBorder.none
                ),
                onSubmitted: (String keyword) =>
                    // search and display images associated to the keyword
                    _loadImages(keyword: keyword),
                autofocus: true,
              )
            : Text('UWall',
            style: TextStyle(
              color: Theme.of(context).textTheme.display1.color,
              fontWeight: FontWeight.bold
            )
            ),
        actions: <Widget>[
          // either search oder clear button
          keyword != null
              ? IconButton(
                  icon: Icon(Icons.clear),
                  color: Theme.of(context).iconTheme.color,
                  onPressed: () {
                    // reset the state
                    _resetImages();
                  },
                )
              : Row(
                children: [
                  IconButton(
                    tooltip: 'Search Image',
                  icon: Icon(Icons.search),
                  color: Theme.of(context).iconTheme.color,
                  onPressed: () =>
                      // go into searching state
                      setState(() => keyword = ""),
                  ),
                  IconButton(
                    tooltip: 'Settings',
                    icon: Icon(Icons.settings),
                    color: Theme.of(context).iconTheme.color,
                    onPressed: () =>
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => ThemeConsumer(child: SettingsPage(),)
                        )
                        )
                    )
                ])
        ],
        backgroundColor: Theme.of(context).primaryColor,
      );

  /// Returns a StaggeredTile for a given [image].
  StaggeredTile _buildStaggeredTile(UnsplashImage image, int columnCount) {
    // calc image aspect ration
    double aspectRatio =
        image.getHeight().toDouble() / image.getWidth().toDouble();
    // calc columnWidth
    double columnWidth = MediaQuery.of(context).size.width / columnCount;
    // not using [StaggeredTile.fit(1)] because during loading StaggeredGrid is really jumpy.
    return StaggeredTile.extent(1, aspectRatio * columnWidth);
  }

  /// Returns the grid that displays images.
  /// [orientation] can be used to adjust the grid column count.
  Widget _buildImageGrid({orientation = Orientation.portrait}) {
    // calc columnCount based on orientation
    int columnCount = orientation == Orientation.portrait ? 2 : 3;
    // return staggered grid
    return SliverPadding(
      padding: const EdgeInsets.all(16.0),
      sliver: SliverStaggeredGrid.countBuilder(
        // set column count
        crossAxisCount: columnCount,
        itemCount: images.length,
        // set itemBuilder
        itemBuilder: (BuildContext context, int index) =>
            _buildImageItemBuilder(index),
        staggeredTileBuilder: (int index) =>
            _buildStaggeredTile(images[index], columnCount),
        mainAxisSpacing: 16.0,
        crossAxisSpacing: 16.0,
      ),
    );
  }

  /// Returns a FutureBuilder to load a [UnsplashImage] for a given [index].
  Widget _buildImageItemBuilder(int index) => FutureBuilder(
        // pass image loader
        future: _loadImage(index),
        builder: (context, snapshot) =>
            // image loaded return [_ImageTile]
            ImageTile(snapshot.data),
      );
}