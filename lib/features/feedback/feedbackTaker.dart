import 'package:azkark/core/res/resources.dart';
import 'package:azkark/features/home/loading_page.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:webview_flutter/webview_flutter.dart';

class FeedbackTaker extends StatefulWidget {
  final String url;
  final String title;

  const FeedbackTaker(this.title, this.url, {super.key});

  @override
  State<FeedbackTaker> createState() => _FeedbackTakerState();
}

class _FeedbackTakerState extends State<FeedbackTaker> {
  late final WebViewController _controller;
  bool loading = true;
  bool error = false;

  @override
  void initState() {
    super.initState();

    _controller = WebViewController()
      ..setJavaScriptMode(JavaScriptMode.unrestricted)
      ..setBackgroundColor(Colors.transparent)
      ..setNavigationDelegate(
        NavigationDelegate(
          onPageStarted: (url) {
            setState(() {
              loading = true;
              error = false;
            });
          },
          onPageFinished: (url) {
            if (!mounted) return;
            setState(() => loading = false);
          },
          onWebResourceError: (err) {
            print('onWebResourceError ${err.errorType?.name}');
            if (!mounted) return;
            setState(() {
              error = true;
              loading = false;
            });
          },
        ),
      )
      ..loadRequest(Uri.parse(widget.url));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        elevation: 0,
        title: Text(widget.title),
        actions: [
          IconButton(
            onPressed: () => launchUrl(
              Uri.parse(widget.url),
              mode: LaunchMode.externalApplication,
            ),
            icon: const Icon(Icons.open_in_new),
          ),
        ],
      ),
      body: error ? Center(
        child: Text(tr('error_occured'), style: TextStyle().regularStyle().errorStyle()),
      )
          : Stack(
        children: [
          WebViewWidget(controller: _controller),
          if (loading)  LoadingPage(),
        ],
      ),
    );
  }
}
