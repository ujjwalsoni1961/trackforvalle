import 'dart:html' as html;
import 'dart:ui_web' as ui_web;
import 'package:equatable/equatable.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:track/src/core/ui/widgets/my_scaffold.dart';

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
  late final String _viewType;

  @override
  void initState() {
    super.initState();
    _viewType = 'docuseal-signing-${widget.params.leadId}-${DateTime.now().millisecondsSinceEpoch}';

    // Register the iframe as an HTML element view
    ui_web.platformViewRegistry.registerViewFactory(
      _viewType,
      (int viewId) {
        final iframe = html.IFrameElement()
          ..src = widget.params.signingUrl
          ..style.border = 'none'
          ..style.width = '100%'
          ..style.height = '100%'
          ..allow = 'camera;microphone'
          ..setAttribute('allowfullscreen', 'true');
        return iframe;
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return MyScaffold(
      title: 'Sign: ${widget.params.templateName}',
      body: Column(
        children: [
          Expanded(
            child: HtmlElementView(viewType: _viewType),
          ),
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.surface,
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.1),
                  blurRadius: 4,
                  offset: const Offset(0, -2),
                ),
              ],
            ),
            child: SafeArea(
              child: SizedBox(
                width: double.infinity,
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
            ),
          ),
        ],
      ),
    );
  }
}
