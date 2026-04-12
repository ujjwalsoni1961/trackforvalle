import 'dart:html' as html;
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
  bool _signingOpened = false;
  bool _signingComplete = false;

  void _openSigningWindow() {
    final url = widget.params.signingUrl;
    html.window.open(url, 'DocuSealSigning');
    setState(() {
      _signingOpened = true;
    });
  }

  @override
  Widget build(BuildContext context) {
    return MyScaffold(
      title: 'Sign: ${widget.params.templateName}',
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: _signingComplete
              ? _buildCompleteState(context)
              : _signingOpened
                  ? _buildWaitingState(context)
                  : _buildInitialState(context),
        ),
      ),
    );
  }

  Widget _buildInitialState(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Icon(
          Icons.description_outlined,
          size: 80,
          color: Theme.of(context).colorScheme.primary,
        ),
        const SizedBox(height: 24),
        Text(
          widget.params.templateName,
          style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                fontWeight: FontWeight.bold,
              ),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 12),
        Text(
          'A signing window will open for the customer to sign the contract.',
          style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                color: Colors.grey[600],
              ),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 32),
        SizedBox(
          width: 280,
          height: 52,
          child: FilledButton.icon(
            onPressed: _openSigningWindow,
            icon: const Icon(Icons.open_in_new),
            label: const Text('Open Signing Form'),
            style: FilledButton.styleFrom(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildWaitingState(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Icon(
          Icons.hourglass_top_rounded,
          size: 80,
          color: Colors.orange[400],
        ),
        const SizedBox(height: 24),
        Text(
          'Signing in Progress',
          style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                fontWeight: FontWeight.bold,
              ),
        ),
        const SizedBox(height: 12),
        Text(
          'The customer is signing the contract in the other window.\n'
          'Once they complete signing, click "Done" below.',
          style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                color: Colors.grey[600],
              ),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 16),
        TextButton.icon(
          onPressed: _openSigningWindow,
          icon: const Icon(Icons.open_in_new),
          label: const Text('Reopen Signing Window'),
        ),
        const SizedBox(height: 24),
        SizedBox(
          width: 280,
          height: 52,
          child: FilledButton.icon(
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
                        setState(() {
                          _signingComplete = true;
                        });
                      },
                      child: const Text('Done'),
                    ),
                  ],
                ),
              );
            },
            icon: const Icon(Icons.check_circle),
            label: const Text('Finished Signing'),
            style: FilledButton.styleFrom(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildCompleteState(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Icon(
          Icons.check_circle_outline,
          size: 80,
          color: Colors.green[600],
        ),
        const SizedBox(height: 24),
        Text(
          'Signing Complete',
          style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                fontWeight: FontWeight.bold,
                color: Colors.green[700],
              ),
        ),
        const SizedBox(height: 12),
        Text(
          'The signed contract will be emailed to the admin and partner automatically.',
          style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                color: Colors.grey[600],
              ),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 32),
        SizedBox(
          width: 280,
          height: 52,
          child: FilledButton.icon(
            onPressed: () => context.pop(true),
            icon: const Icon(Icons.arrow_back),
            label: const Text('Back to Leads'),
            style: FilledButton.styleFrom(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
          ),
        ),
      ],
    );
  }
}
