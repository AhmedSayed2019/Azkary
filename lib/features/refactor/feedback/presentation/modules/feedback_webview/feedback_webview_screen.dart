import 'package:azkark/features/home/loading_page.dart';
import 'package:azkark/features/refactor/feedback/domain/entity/feedback_form_type.dart';
import 'package:azkark/features/refactor/feedback/presentation/modules/feedback_webview/feedback_webview_view_model.dart';
import 'package:azkark/providers.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:webview_flutter/webview_flutter.dart';

/// Replaces the legacy `FeedbackTaker` — opens one of the app's Google
/// feedback forms (bug report / feature request / adhan report / dua-error
/// report) inside a webview.
///
/// The form URL is resolved asynchronously through [FeedbackWebviewViewModel]
/// (a factory VM resolved from GetIt, not a `ChangeNotifierProvider`); the
/// [WebViewController] itself is created lazily once that URL is known.
class FeedbackWebviewScreen extends StatefulWidget {
  const FeedbackWebviewScreen({
    super.key,
    required this.formType,
    this.title,
  });

  /// Which Google Form to open.
  final FeedbackFormType formType;

  /// Overrides the appbar title (and, for [FeedbackFormType.duaErrorReport],
  /// supplies the dua/azkar text embedded in the prefilled form URL). Falls
  /// back to a localized title per [formType] when omitted.
  final String? title;

  @override
  State<FeedbackWebviewScreen> createState() => _FeedbackWebviewScreenState();
}

class _FeedbackWebviewScreenState extends State<FeedbackWebviewScreen> {
  late final FeedbackWebviewViewModel _vm;
  WebViewController? _controller;
  bool _pageLoading = true;
  bool _pageError = false;

  @override
  void initState() {
    super.initState();
    _vm = getIt<FeedbackWebviewViewModel>();
    _vm.addListener(_ensureController);
    _vm.init(type: widget.formType, title: widget.title);
  }

  @override
  void dispose() {
    _vm.removeListener(_ensureController);
    _vm.dispose();
    super.dispose();
  }

  /// Creates the [WebViewController] the first time the VM resolves a URL.
  /// Kept out of [build] since a controller must only be constructed once.
  void _ensureController() {
    final url = _vm.url;
    if (url == null || _controller != null) return;

    _controller = WebViewController()
      ..setJavaScriptMode(JavaScriptMode.unrestricted)
      ..setBackgroundColor(Colors.transparent)
      ..setNavigationDelegate(
        NavigationDelegate(
          onPageStarted: (_) {
            if (!mounted) return;
            setState(() {
              _pageLoading = true;
              _pageError = false;
            });
          },
          onPageFinished: (_) {
            if (!mounted) return;
            setState(() => _pageLoading = false);
          },
          onWebResourceError: (_) {
            if (!mounted) return;
            setState(() {
              _pageError = true;
              _pageLoading = false;
            });
          },
        ),
      )
      ..loadRequest(Uri.parse(url));
  }

  String _appBarTitle() {
    final title = widget.title;
    if (title != null && title.trim().isNotEmpty) return title;
    switch (widget.formType) {
      case FeedbackFormType.bugReport:
        return tr('report_a_bug');
      case FeedbackFormType.featureRequest:
        return tr('request_a_feature');
      case FeedbackFormType.adhanReport:
      case FeedbackFormType.duaErrorReport:
        return tr('report_an_error');
    }
  }

  void _retryPage() {
    setState(() {
      _pageError = false;
      _pageLoading = true;
    });
    _controller?.reload();
  }

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: _vm,
      builder: (context, _) {
        final url = _vm.url;
        return Scaffold(
          appBar: AppBar(
            elevation: 0,
            title: Text(_appBarTitle()),
            actions: [
              if (url != null)
                IconButton(
                  onPressed: () => launchUrl(
                    Uri.parse(url),
                    mode: LaunchMode.externalApplication,
                  ),
                  icon: const Icon(Icons.open_in_new),
                ),
            ],
          ),
          body: _buildBody(),
        );
      },
    );
  }

  Widget _buildBody() {
    if (_vm.error != null) {
      return _FeedbackErrorView(
        message: _vm.error!,
        onRetry: _vm.retry,
      );
    }
    if (_pageError) {
      return _FeedbackErrorView(
        message: tr('error_occured'),
        onRetry: _retryPage,
      );
    }
    final controller = _controller;
    return Stack(
      children: [
        if (controller != null) WebViewWidget(controller: controller),
        if (_vm.isLoading || controller == null || _pageLoading) LoadingPage(),
      ],
    );
  }
}

class _FeedbackErrorView extends StatelessWidget {
  const _FeedbackErrorView({required this.message, required this.onRetry});

  final String message;
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(message, textAlign: TextAlign.center),
            const SizedBox(height: 12),
            ElevatedButton(
              onPressed: onRetry,
              child: Text(tr('tryAgain')),
            ),
          ],
        ),
      ),
    );
  }
}
