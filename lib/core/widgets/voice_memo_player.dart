import 'dart:math';

import 'package:flutter/material.dart';
import 'package:just_audio/just_audio.dart';

import '../../data/models/attachment_ref.dart';

class VoiceMemoPlayer extends StatefulWidget {
  const VoiceMemoPlayer({super.key, required this.memo});

  final AttachmentRef memo;

  @override
  State<VoiceMemoPlayer> createState() => _VoiceMemoPlayerState();
}

class _VoiceMemoPlayerState extends State<VoiceMemoPlayer> {
  late final AudioPlayer _player;
  late final List<double> _bars;
  bool _ready = false;
  bool _failed = false;

  @override
  void initState() {
    super.initState();
    _player = AudioPlayer();
    _bars = _generateBars(widget.memo.id);
    _load();
  }

  Future<void> _load() async {
    try {
      await _player.setFilePath(widget.memo.path);
      setState(() => _ready = true);
    } catch (_) {
      setState(() => _failed = true);
    }
  }

  @override
  void dispose() {
    _player.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: theme.colorScheme.surface.withValues(alpha: 0.7),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: theme.dividerColor),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              StreamBuilder<PlayerState>(
                stream: _player.playerStateStream,
                builder: (context, snapshot) {
                  final playing = snapshot.data?.playing ?? false;
                  final icon = playing ? Icons.pause_circle_filled : Icons.play_circle_fill;
                  return IconButton(
                    icon: Icon(icon, size: 32),
                    onPressed: _ready && !_failed ? _togglePlayback : null,
                  );
                },
              ),
              const SizedBox(width: 8),
              Expanded(
                child: StreamBuilder<Duration>(
                  stream: _player.positionStream,
                  builder: (context, positionSnap) {
                    final position = positionSnap.data ?? Duration.zero;
                    final total = _player.duration ?? Duration.zero;
                    final progress = total.inMilliseconds == 0
                        ? 0.0
                        : position.inMilliseconds / total.inMilliseconds;

                    return _Waveform(
                      bars: _bars,
                      progress: progress.clamp(0.0, 1.0),
                      activeColor: theme.colorScheme.secondary,
                      inactiveColor: theme.colorScheme.onSurface.withValues(alpha: 0.2),
                    );
                  },
                ),
              ),
            ],
          ),
          const SizedBox(height: 6),
          StreamBuilder<Duration>(
            stream: _player.positionStream,
            builder: (context, snapshot) {
              final position = snapshot.data ?? Duration.zero;
              final total = _player.duration ?? Duration.zero;
              return Text(
                '${_format(position)} · ${_format(total)}',
                style: theme.textTheme.labelSmall?.copyWith(
                  color: theme.colorScheme.onSurface.withValues(alpha: 0.6),
                ),
              );
            },
          ),
          if (_failed)
            Padding(
              padding: const EdgeInsets.only(top: 6),
              child: Text(
                'Audio file not found.',
                style: theme.textTheme.labelSmall?.copyWith(color: Colors.redAccent),
              ),
            ),
        ],
      ),
    );
  }

  void _togglePlayback() {
    if (_player.playing) {
      _player.pause();
    } else {
      _player.play();
    }
  }

  List<double> _generateBars(String seed) {
    final random = Random(seed.hashCode);
    return List<double>.generate(28, (_) => 0.25 + random.nextDouble() * 0.75);
  }

  String _format(Duration duration) {
    final minutes = duration.inMinutes.remainder(60).toString().padLeft(2, '0');
    final seconds = duration.inSeconds.remainder(60).toString().padLeft(2, '0');
    return '$minutes:$seconds';
  }
}

class _Waveform extends StatelessWidget {
  const _Waveform({
    required this.bars,
    required this.progress,
    required this.activeColor,
    required this.inactiveColor,
  });

  final List<double> bars;
  final double progress;
  final Color activeColor;
  final Color inactiveColor;

  @override
  Widget build(BuildContext context) {
    final activeBars = (bars.length * progress).clamp(0, bars.length).toInt();

    return SizedBox(
      height: 32,
      child: Row(
        children: List.generate(bars.length, (index) {
          final height = bars[index] * 28;
          final color = index <= activeBars ? activeColor : inactiveColor;
          return Expanded(
            child: Align(
              alignment: Alignment.bottomCenter,
              child: Container(
                margin: const EdgeInsets.symmetric(horizontal: 1),
                height: height,
                decoration: BoxDecoration(
                  color: color,
                  borderRadius: BorderRadius.circular(6),
                ),
              ),
            ),
          );
        }),
      ),
    );
  }
}
