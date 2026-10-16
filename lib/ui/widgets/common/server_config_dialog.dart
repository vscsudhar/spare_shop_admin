import 'package:flutter/material.dart';
import 'package:spare_shop_admin/core/services/api_endpoints.dart';
import 'package:spare_shop_admin/ui/common/admin_styles.dart';

class ServerConfigDialog extends StatefulWidget {
  final VoidCallback? onSaved;

  const ServerConfigDialog({Key? key, this.onSaved}) : super(key: key);

  static Future<void> show(BuildContext context, {VoidCallback? onSaved}) {
    return showDialog(
      context: context,
      barrierDismissible: true,
      builder: (_) => ServerConfigDialog(onSaved: onSaved),
    );
  }

  @override
  State<ServerConfigDialog> createState() => _ServerConfigDialogState();
}

class _ServerConfigDialogState extends State<ServerConfigDialog> {
  late final TextEditingController _hostController;
  late final TextEditingController _portController;
  late final TextEditingController _baseUrlController;

  bool _isTesting = false;
  Map<String, dynamic>? _testResult;

  @override
  void initState() {
    super.initState();
    _hostController = TextEditingController(text: ApiEndpoints.hostIp);
    _portController = TextEditingController(text: ApiEndpoints.port);
    _baseUrlController = TextEditingController(text: ApiEndpoints.baseUrl);

    _hostController.addListener(_syncFromHostPort);
    _portController.addListener(_syncFromHostPort);
  }

  void _syncFromHostPort() {
    final host = _hostController.text.trim();
    final port = _portController.text.trim();
    if (host.isNotEmpty) {
      final portPart = port.isNotEmpty ? ':$port' : '';
      _baseUrlController.text = 'http://$host$portPart/api/v1';
    }
  }

  void _applyPreset(String host, String port) {
    setState(() {
      _hostController.text = host;
      _portController.text = port;
      _baseUrlController.text = 'http://$host:$port/api/v1';
      _testResult = null;
    });
  }

  Future<void> _testConnection() async {
    final target = _baseUrlController.text.trim();
    if (target.isEmpty) return;

    setState(() {
      _isTesting = true;
      _testResult = null;
    });

    final result = await ApiEndpoints.testConnection(target);

    if (mounted) {
      setState(() {
        _isTesting = false;
        _testResult = result;
      });
    }
  }

  Future<void> _save() async {
    final target = _baseUrlController.text.trim();
    if (target.isEmpty) return;

    await ApiEndpoints.saveBaseUrl(target);

    if (mounted) {
      Navigator.of(context).pop();
      widget.onSaved?.call();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('✅ Base URL updated to: $target'),
          backgroundColor: AdminColors.primaryGreen,
          duration: const Duration(seconds: 3),
        ),
      );
    }
  }

  Future<void> _reset() async {
    await ApiEndpoints.resetToDefault();
    setState(() {
      _hostController.text = ApiEndpoints.hostIp;
      _portController.text = ApiEndpoints.port;
      _baseUrlController.text = ApiEndpoints.baseUrl;
      _testResult = null;
    });

    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('↺ Reset to default Base URL: ${ApiEndpoints.baseUrl}'),
          backgroundColor: AdminColors.textSecondary,
        ),
      );
    }
  }

  @override
  void dispose() {
    _hostController.dispose();
    _portController.dispose();
    _baseUrlController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isCustom = ApiEndpoints.isCustomConfigured;

    return Dialog(
      backgroundColor: AdminColors.panelBackground,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      elevation: 12,
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 480),
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: AdminColors.primaryGreen.withValues(alpha: 0.15),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Icon(
                      Icons.settings_ethernet_rounded,
                      color: AdminColors.primaryGreen,
                      size: 24,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Server IP & Base URL',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: AdminColors.textPrimary,
                          ),
                        ),
                        Text(
                          isCustom ? 'Custom Configuration' : 'Default Platform IP',
                          style: TextStyle(
                            fontSize: 12,
                            color: isCustom ? AdminColors.primaryGreen : AdminColors.textSecondary,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                  ),
                  IconButton(
                    icon: Icon(Icons.close_rounded, size: 20, color: AdminColors.textSecondary),
                    onPressed: () => Navigator.of(context).pop(),
                  ),
                ],
              ),
              const SizedBox(height: 20),
              Text(
                'Quick Presets',
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                  color: AdminColors.textSecondary,
                  letterSpacing: 0.5,
                ),
              ),
              const SizedBox(height: 8),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: [
                  _presetChip('📱 LAN IP (${ApiEndpoints.defaultLanIp})', () {
                    _applyPreset(ApiEndpoints.defaultLanIp, '5000');
                  }),
                  _presetChip('💻 Localhost (127.0.0.1)', () {
                    _applyPreset('127.0.0.1', '5000');
                  }),
                  _presetChip('🤖 Android Emulator (10.0.2.2)', () {
                    _applyPreset('10.0.2.2', '5000');
                  }),
                ],
              ),
              const SizedBox(height: 18),
              Row(
                children: [
                  Expanded(
                    flex: 7,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Host IP / Domain',
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                            color: AdminColors.textPrimary,
                          ),
                        ),
                        const SizedBox(height: 6),
                        TextField(
                          controller: _hostController,
                          style: TextStyle(color: AdminColors.textPrimary),
                          decoration: InputDecoration(
                            hintText: '192.168.0.174',
                            hintStyle: TextStyle(color: AdminColors.textLight),
                            isDense: true,
                            contentPadding: const EdgeInsets.symmetric(
                                horizontal: 12, vertical: 10),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(8),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    flex: 3,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Port',
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                            color: AdminColors.textPrimary,
                          ),
                        ),
                        const SizedBox(height: 6),
                        TextField(
                          controller: _portController,
                          keyboardType: TextInputType.number,
                          style: TextStyle(color: AdminColors.textPrimary),
                          decoration: InputDecoration(
                            hintText: '5000',
                            hintStyle: TextStyle(color: AdminColors.textLight),
                            isDense: true,
                            contentPadding: const EdgeInsets.symmetric(
                                horizontal: 12, vertical: 10),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(8),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 14),
              Text(
                'Full Base URL (Prefix: /api/v1)',
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  color: AdminColors.textPrimary,
                ),
              ),
              const SizedBox(height: 6),
              TextField(
                controller: _baseUrlController,
                style: TextStyle(color: AdminColors.textPrimary),
                decoration: InputDecoration(
                  hintText: 'http://192.168.0.174:5000/api/v1',
                  hintStyle: TextStyle(color: AdminColors.textLight),
                  isDense: true,
                  contentPadding:
                      const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
              ),
              const SizedBox(height: 16),
              if (_testResult != null) ...[
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: (_testResult!['success'] == true)
                        ? AdminColors.success.withValues(alpha: 0.12)
                        : AdminColors.cancelled.withValues(alpha: 0.12),
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(
                      color: (_testResult!['success'] == true)
                          ? AdminColors.success
                          : AdminColors.cancelled,
                    ),
                  ),
                  child: Row(
                    children: [
                      Icon(
                        (_testResult!['success'] == true)
                            ? Icons.check_circle_rounded
                            : Icons.error_outline_rounded,
                        color: (_testResult!['success'] == true)
                            ? AdminColors.success
                            : AdminColors.cancelled,
                        size: 20,
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Text(
                          _testResult!['message'] ?? '',
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                            color: (_testResult!['success'] == true)
                                ? AdminColors.success
                                : AdminColors.cancelled,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 14),
              ],
              Row(
                children: [
                  OutlinedButton.icon(
                    onPressed: _isTesting ? null : _testConnection,
                    icon: _isTesting
                        ? const SizedBox(
                            width: 14,
                            height: 14,
                            child: CircularProgressIndicator(strokeWidth: 2),
                          )
                        : const Icon(Icons.network_check_rounded, size: 16),
                    label: Text(_isTesting ? 'Testing...' : 'Test Ping'),
                    style: OutlinedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 12, vertical: 10),
                    ),
                  ),
                  const Spacer(),
                  TextButton(
                    onPressed: _reset,
                    child: Text('Reset Default', style: TextStyle(color: AdminColors.textSecondary)),
                  ),
                  const SizedBox(width: 8),
                  ElevatedButton(
                    onPressed: _save,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AdminColors.primaryGreen,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(
                          horizontal: 16, vertical: 10),
                    ),
                    child: const Text('Save & Apply'),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _presetChip(String label, VoidCallback onTap) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(20),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
        decoration: BoxDecoration(
          color: AdminColors.sidebarBackground,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: AdminColors.border),
        ),
        child: Text(
          label,
          style: TextStyle(
            fontSize: 11,
            fontWeight: FontWeight.w600,
            color: AdminColors.textPrimary,
          ),
        ),
      ),
    );
  }
}
