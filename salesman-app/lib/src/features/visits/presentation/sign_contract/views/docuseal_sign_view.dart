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
  final String? signerEmail;

  const DocuSealSignViewParams({
    required this.signingUrl,
    required this.templateName,
    required this.leadId,
    this.signerEmail,
  });

  @override
  List<Object?> get props => [signingUrl, templateName, leadId, signerEmail];
}

class DocuSealSignView extends StatefulWidget {
  final DocuSealSignViewParams params;
  const DocuSealSignView({super.key, required this.params});

  @override
  State<DocuSealSignView> createState() => _DocuSealSignViewState();
}

class _DocuSealSignViewState extends State<DocuSealSignView> {
  late final String _viewType;
  bool _isCompleted = false;

  @override
  void initState() {
    super.initState();
    _viewType = 'docuseal-form-${widget.params.leadId}-${DateTime.now().millisecondsSinceEpoch}';

    ui_web.platformViewRegistry.registerViewFactory(
      _viewType,
      (int viewId) {
        final div = html.DivElement()
          ..style.width = '100%'
          ..style.height = '100%';

        // Create the docuseal-form element
        final formElement = html.Element.tag('docuseal-form')
          ..setAttribute('data-src', widget.params.signingUrl)
          ..setAttribute('data-send-copy-email', 'false')
          ..style.width = '100%'
          ..style.height = '100%';

        if (widget.params.signerEmail != null) {
          formElement.setAttribute('data-email', widget.params.signerEmail!);
        }

        div.append(formElement);

        // Listen for completed event
        formElement.addEventListener('completed', (event) {
          if (mounted) {
            setState(() => _isCompleted = true);
          }
        });

        return div;
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
          if (_isCompleted)
            Container(
              padding: const EdgeInsets.all(16),
              color: Colors.green.shade50,
              child: Row(
                children: [
                  Icon(Icons.check_circle, color: Colors.green.shade700),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      'Signing completed successfully!',
                      style: TextStyle(
                        color: Colors.green.shade700,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ],
              ),
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
                    if (_isCompleted) {
                      context.pop(true);
                      return;
                    }
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
                  icon: Icon(_isCompleted ? Icons.check_circle : Icons.check_circle_outline),
                  label: Text(_isCompleted ? 'Done' : 'Finished Signing'),
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
