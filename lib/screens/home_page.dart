import 'package:flutter/material.dart';
import 'package:youtube_api/youtube_api.dart';

import '../global.dart';

class HomePage extends StatefulWidget {
  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  static const String key = "";
  final YoutubeAPI youtube = YoutubeAPI(key);
  final List<YouTubeVideo> videoResult = [];
  final ScrollController _scrollController = ScrollController();

  bool isLoading = false;
  bool isRefreshing = false;

  @override
  void initState() {
    super.initState();
    callAPI();
    _scrollController.addListener(_onScroll);
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  Future<void> _refresh() async {
    setState(() {
      isRefreshing = true;
    });
    videoResult.clear();
    await callAPI();
    setState(() {
      isRefreshing = false;
    });
  }


  Future<void> callAPI({bool loadMore = false}) async {
    if (isLoading) return;

    setState(() {
      isLoading = true;
    });

    List<YouTubeVideo> results;
    if (loadMore) {
      results = await youtube.nextPage();
    } else {
      results = await youtube.search(
        "trending",
        order: 'relevance',
        videoDuration: 'any',
        type: 'video,channel,playlist',
      );
    }

    setState(() {
      videoResult.addAll(results);
      isLoading = false;
    });
  }

  void _onScroll() {
    if (_scrollController.position.pixels >=
        _scrollController.position.maxScrollExtent - 200 &&
        !isLoading) {
      callAPI(loadMore: true);
    }
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        backgroundColor: Colors.white,
        appBar: AppBar(
          elevation: 0,
          backgroundColor: Colors.white,
          title: Row(
            children: const [
              Icon(Icons.play_circle_filled, color: Colors.red, size: 30),
              SizedBox(width: 5),
              Text(
                "YouTube",
                style: TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                    color: Colors.black),
              ),
            ],
          ),
          actions: [
            const Icon(Icons.cast, color: Colors.black, size: 23),
            const SizedBox(width: 12),
            const Icon(Icons.notifications_none_outlined,
                color: Colors.black, size: 27),
            IconButton(
              onPressed: () {
                Navigator.of(context).pushNamed("search_page");
              },
              icon: const Icon(Icons.search, color: Colors.black),
            ),
            CircleAvatar(
              radius: 15,
              backgroundColor: Colors.grey.withOpacity(0.5),
              backgroundImage: const NetworkImage(
                "https://avatars.githubusercontent.com/u/111499361?v=4",
              ),
            ),
            const SizedBox(width: 10),
          ],
        ),
        body: RefreshIndicator(
          onRefresh: _refresh,
          child: ListView.builder(
            controller: _scrollController,
            itemCount: videoResult.length + (isLoading ? 1 : 0),
            itemBuilder: (context, index) {
              if (index < videoResult.length) {
                return listItem(videoResult[index]);
              } else {
                return const Padding(
                  padding: EdgeInsets.all(16.0),
                  child: Center(child: CircularProgressIndicator()),
                );
              }
            },
          ),
        ),
      ),
    );
  }

  Widget listItem(YouTubeVideo video) {
    return GestureDetector(
      onTap: () {
        Global.data = video;
        Global.id = video.id.toString();
        Navigator.of(context).pushNamed("player_page");
      },
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            height: MediaQuery.of(context).size.height * 0.25,
            decoration: BoxDecoration(
              color: Colors.grey.withOpacity(0.2),
              image: DecorationImage(
                image: NetworkImage("${video.thumbnail.high.url}"),
                fit: BoxFit.cover,
              ),
            ),
          ),
          Padding(
            padding:
            const EdgeInsets.only(right: 15, left: 15, top: 5, bottom: 20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  video.title,
                  style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w500,
                      color: Colors.black),
                ),
                Text(
                  video.channelTitle,
                  style: TextStyle(
                    fontSize: 15,
                    color: Colors.black.withOpacity(0.7),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
