import 'dart:async';
import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

/// Pembaca stream MJPEG manual — lebih andal di Android daripada flutter_mjpeg.
class MjpegLiveView extends StatefulWidget {
  final String streamUrl;
  final BoxFit fit;
  final Widget? loading;
  final Widget Function(BuildContext context, Object error)? errorBuilder;

  const MjpegLiveView({
    super.key,
    required this.streamUrl,
    this.fit = BoxFit.cover,
    this.loading,
    this.errorBuilder,
  });

  @override
  State<MjpegLiveView> createState() => _MjpegLiveViewState();
}

class _MjpegLiveViewState extends State<MjpegLiveView> {
  static const _jpegStart = [0xFF, 0xD8];
  static const _jpegEnd = [0xFF, 0xD9];

  Uint8List? _frame;
  Object? _error;
  http.Client? _client;
  bool _disposed = false;

  @override
  void initState() {
    super.initState();
    unawaited(_connect());
  }

  @override
  void didUpdateWidget(covariant MjpegLiveView oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.streamUrl != widget.streamUrl) {
      _stop();
      _error = null;
      _frame = null;
      unawaited(_connect());
    }
  }

  @override
  void dispose() {
    _disposed = true;
    _stop();
    super.dispose();
  }

  void _stop() {
    _client?.close();
    _client = null;
  }

  Future<void> _connect() async {
    while (!_disposed) {
      try {
        _client = http.Client();
        final request = http.Request('GET', Uri.parse(widget.streamUrl));
        request.headers['Connection'] = 'keep-alive';
        request.headers['Accept'] = 'multipart/x-mixed-replace, */*';

        final response = await _client!
            .send(request)
            .timeout(const Duration(seconds: 20));

        if (response.statusCode != 200) {
          throw Exception('HTTP ${response.statusCode}');
        }

        if (mounted) {
          setState(() => _error = null);
        }

        final buffer = <int>[];
        await for (final chunk in response.stream) {
          if (_disposed) break;
          buffer.addAll(chunk);

          while (true) {
            final start = _indexOf2(buffer, 0xFF, 0xD8);
            if (start < 0) {
              if (buffer.length > 1) {
                buffer.removeRange(0, buffer.length - 1);
              }
              break;
            }

            final end = _indexOf2(buffer, 0xFF, 0xD9, start + 2);
            if (end < 0) break;

            final frame =
                Uint8List.fromList(buffer.sublist(start, end + 2));
            buffer.removeRange(0, end + 2);

            if (mounted) {
              setState(() => _frame = frame);
            }
          }
        }
      } catch (e) {
        if (_disposed) return;
        if (mounted) {
          setState(() {
            _error = e;
            _frame = null;
          });
        }
        _stop();
        await Future<void>.delayed(const Duration(seconds: 2));
      }
    }
  }

  int _indexOf2(List<int> data, int p0, int p1, [int from = 0]) {
    if (from >= data.length - 1) return -1;
    final limit = data.length - 1;
    for (var i = from; i < limit; i++) {
      if (data[i] == p0 && data[i + 1] == p1) {
        return i;
      }
    }
    return -1;
  }

  @override
  Widget build(BuildContext context) {
    if (_frame != null) {
      return Image.memory(
        _frame!,
        fit: widget.fit,
        gaplessPlayback: true,
        filterQuality: FilterQuality.medium,
        errorBuilder: (_, __, ___) => _buildPlaceholder(),
      );
    }

    if (_error != null && widget.errorBuilder != null) {
      return widget.errorBuilder!(context, _error!);
    }

    return widget.loading ??
        const Center(
          child: CircularProgressIndicator(strokeWidth: 2),
        );
  }

  Widget _buildPlaceholder() {
    return widget.loading ??
        const Center(child: Icon(Icons.broken_image_outlined));
  }
}
