import 'package:equatable/equatable.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:track/src/core/ui/widgets/my_scaffold.dart';
import 'package:webview_flutter/webview_flutter.dart';

class DocuSealSignViewParams extends Equatable {
  final String signingUrl;
  final String templateName;
  final int leadId;

  const DocuSealSignViewParams({
    required this.signingUrl,
    required this.templateName,
    required this.leadId,
  });

  @override
  List<Object?> get props => [signingUrl, templateName, leadId];
}

class DocuSealSignView extends StatefulWidget {
  final DocuSealSignViewParams params;
  const DocuSealSignView({super.key, required this.params});

  @override
  State<DocuSealSignView> createState() => _DocuSealSignViewState();
}

class _DocuSealSignViewState extends State<DocuSealSignView> {
  late final WebViewController _controller;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _controller = WebViewController()
      ..setJavaScriptMode(JavaScriptMode.unrestricted)
      ..setNavigationDelegate(
        NavigationDelegate(
          onPageStarted: (String url) {
            setState(() => _isLoading = true);
          },
          onPageFinished: (String url) {
            setState(() => _isLoading = false);
          },
          onWebResourceError: (WebResourceError error) {
            debugPrint('WebView error: ${error.description}');
          },
        ),
      )
      ..loadRequest(Uri.parse(widget.params.signingUrl));
  }

  @override
  Widget build(BuildContext context) {
    return MyScaffold(
      title: 'Sign: ${widget.params.templateName}',
      body: Stack(
        children: [
          WebViewWidget(controller: _controller),
          if (_isLoading)
            const Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  CircularProgressIndicator(),
                  SizedBox(height: 16),
                  Text('Loading signing form...'),
                ],
              ),
            ),
          Positioned(
            bottom: 16,
            left: 16,
            right: 16,
            child: ElevatedButton.icon(
              onPressed: () {
                showDialog(
                  context: context,
                  builder: (ctx) => AlertDialog(
                    title: const Text('Done Signing?'),
                    content: const Text(
                      'If the customer has completed signing, you can go back. '
                      'The signed contract will be processed automatically.',
                    ),
                    actions: [
                      TextButton(
                        onPressed: () => Navigator.of(ctx).pop(),
                        child: const Text('Continue Signing'),
                      ),
                      FilledButton(
                        onPressed: () {
                          Navigator.of(ctx).pop();
                          context.pop(true);
                        },
                        child: const Text('Done'),
                      ),
                    ],
                  ),
                );
              },
              icon: const Icon(Icons.check_circle),
              label: const Text('Finished Signing'),
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 14),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
