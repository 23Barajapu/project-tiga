import 'package:flutter/material.dart';
import '../../theme/app_theme.dart';
import 'package:flutter_mjpeg/flutter_mjpeg.dart';

class LiveFeedLayer extends StatelessWidget {
  final String streamUrl;
  final bool isRunning;
  final String aiStatus;
  final double confidenceScore;

  const LiveFeedLayer({
    super.key,
    required this.streamUrl,
    required this.isRunning,
    this.aiStatus = 'STATUS: RIPE',
    this.confidenceScore = 98.4,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 220,
      width: double.infinity,
      decoration: BoxDecoration(
        color: Colors.black,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppTheme.cardBackground, width: 2),
      ),
      child: Stack(
        children: [
          // MJPEG Stream Base Layer
          ClipRRect(
            borderRadius: BorderRadius.circular(18),
            child: SizedBox(
              width: double.infinity,
              height: double.infinity,
              child: Mjpeg(
                isLive: isRunning,
                stream: streamUrl,
                fit: BoxFit.cover,
                error: (context, error, stack) {
                  return const Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.videocam_off, color: Colors.white54, size: 40),
                        SizedBox(height: 8),
                        Text('Stream Disconnected', style: TextStyle(color: Colors.white54)),
                      ],
                    ),
                  );
                },
              ),
            ),
          ),
          
          // Status Badge overlay
          Positioned(
            top: 15, left: 15,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: AppTheme.accentNeonGreen,
                borderRadius: BorderRadius.circular(8),
                boxShadow: [
                  BoxShadow(
                    color: AppTheme.accentNeonGreen.withOpacity(0.3),
                    blurRadius: 8,
                    offset: const Offset(0, 2),
                  )
                ]
              ),
              child: Row(
                children: [
                  const Icon(Icons.check_circle, size: 14, color: Colors.black),
                  const SizedBox(width: 5),
                  Text(aiStatus, 
                      style: const TextStyle(color: Colors.black, fontWeight: FontWeight.bold, fontSize: 12)),
                ],
              ),
            ),
          ),
          
          // Bottom Bar (Confidence)
          Positioned(
            bottom: 0, left: 0, right: 0,
            child: Container(
              padding: const EdgeInsets.all(15),
              decoration: BoxDecoration(
                borderRadius: const BorderRadius.only(
                  bottomLeft: Radius.circular(18),
                  bottomRight: Radius.circular(18),
                ),
                gradient: LinearGradient(
                  begin: Alignment.bottomCenter,
                  end: Alignment.topCenter,
                  colors: [Colors.black.withOpacity(0.9), Colors.transparent],
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text('AI CONFIDENCE SCORE', style: TextStyle(fontSize: 10, color: Colors.white70, fontWeight: FontWeight.w600)),
                      Text('${confidenceScore.toStringAsFixed(1)}%', style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: AppTheme.accentNeonGreen)),
                    ],
                  ),
                  const SizedBox(height: 8),
                  // Progress bar representation
                  Container(
                    height: 4,
                    width: double.infinity,
                    decoration: BoxDecoration(
                      color: Colors.white24,
                      borderRadius: BorderRadius.circular(2),
                    ),
                    child: FractionallySizedBox(
                      alignment: Alignment.centerLeft,
                      widthFactor: confidenceScore / 100,
                      child: Container(
                        decoration: BoxDecoration(
                          color: AppTheme.accentNeonGreen,
                          borderRadius: BorderRadius.circular(2),
                          boxShadow: [
                            BoxShadow(
                              color: AppTheme.accentNeonGreen.withOpacity(0.5),
                              blurRadius: 4,
                            )
                          ]
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
