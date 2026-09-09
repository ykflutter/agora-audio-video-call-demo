import 'package:agora_rtc_engine/agora_rtc_engine.dart';
import 'package:flutter/material.dart';

import '../core/constants/app_constant.dart';
import '../core/service/agora_s.dart';

class AudioCallPage extends StatefulWidget {
  const AudioCallPage({super.key});

  @override
  State<AudioCallPage> createState() => _AudioCallPageState();
}

class _AudioCallPageState extends State<AudioCallPage> {
  final _agora = AgoraService();
  RtcEngine? _engine;
  RtcEngineEventHandler? _handler;

  bool _isMuted = false;
  bool _isSpeakerOn = true;
  bool _remoteJoined = false;
  String _status = 'Connecting...';

  @override
  void initState() {
    super.initState();
    _init();
  }

  Future<void> _init() async {
    final engine = await _agora.initialize();
    if (!mounted) return;
    _engine = engine;

    _handler = RtcEngineEventHandler(
      onJoinChannelSuccess: (connection, elapsed) {
        debugPrint('AGORA: joined ${connection.channelId}');
        if (mounted) setState(() => _status = 'Calling...');
      },
      onUserJoined: (connection, remoteUid, elapsed) {
        debugPrint('AGORA: remote joined $remoteUid');
        if (mounted) {
          setState(() {
            _remoteJoined = true;
            _status = 'Connected';
          });
        }
      },
      onUserOffline: (connection, remoteUid, reason) {
        if (mounted) {
          setState(() {
            _remoteJoined = false;
            _status = 'Call ended';
          });
        }
      },
      onError: (err, msg) {
        debugPrint('AGORA ERROR: $err - $msg');
        if (mounted) setState(() => _status = 'Error: $err');
      },
    );

    engine.registerEventHandler(_handler!);
    await _agora.joinChannel(isVideo: false);
  }

  Future<void> _toggleMute() async {
    final next = !_isMuted;
    await _engine?.muteLocalAudioStream(next);
    if (mounted) setState(() => _isMuted = next);
  }

  Future<void> _toggleSpeaker() async {
    final next = !_isSpeakerOn;
    await _engine?.setEnableSpeakerphone(next);
    if (mounted) setState(() => _isSpeakerOn = next);
  }

  Future<void> _endCall() async {
    await _agora.leaveChannel();
    if (mounted) Navigator.pop(context);
  }

  @override
  void dispose() {
    final h = _handler;
    if (h != null) _engine?.unregisterEventHandler(h);
    _agora.leaveChannel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: SafeArea(
        child: Column(
          children: [
            const Spacer(),
            const CircleAvatar(radius: 55, child: Icon(Icons.person, size: 60)),
            const SizedBox(height: 20),
            Text(
              _remoteJoined ? 'Connected' : _status,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 20,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 8),
            const Text(AppConstants.agoraTestChannel, style: TextStyle(color: Colors.white54)),
            const Spacer(),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                _CallButton(
                  icon: _isMuted ? Icons.mic_off : Icons.mic,
                  onPressed: _toggleMute,
                ),
                const SizedBox(width: 24),
                _CallButton(
                  icon: _isSpeakerOn ? Icons.volume_up : Icons.volume_off,
                  onPressed: _toggleSpeaker,
                ),
                const SizedBox(width: 24),
                _CallButton(
                  icon: Icons.call_end,
                  backgroundColor: Colors.red,
                  onPressed: _endCall,
                ),
              ],
            ),
            const SizedBox(height: 40),
          ],
        ),
      ),
    );
  }
}


// ---------------- SHARED BUTTON ----------------
class _CallButton extends StatelessWidget {
  final IconData icon;
  final VoidCallback onPressed;
  final Color? backgroundColor;

  const _CallButton({
    required this.icon,
    required this.onPressed,
    this.backgroundColor,
  });

  @override
  Widget build(BuildContext context) {
    return CircleAvatar(
      radius: 28,
      backgroundColor: backgroundColor ?? Colors.white24,
      child: IconButton(
        onPressed: onPressed,
        icon: Icon(icon, color: Colors.white),
      ),
    );
  }
}