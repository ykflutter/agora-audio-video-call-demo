import 'package:agora_rtc_engine/agora_rtc_engine.dart';
import 'package:agorademo/core/service/agora_s.dart';
import 'package:flutter/material.dart';

import '../core/constants/app_constant.dart';

class VideoCallPage extends StatefulWidget {
  const VideoCallPage({super.key});

  @override
  State<VideoCallPage> createState() => _VideoCallPageState();
}

class _VideoCallPageState extends State<VideoCallPage> {
  final _agora = AgoraService();
  RtcEngine? _engine;
  RtcEngineEventHandler? _handler;

  int? _remoteUid;
  bool _localJoined = false;
  bool _isMuted = false;
  bool _isCameraOff = false;

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
        if (mounted) setState(() => _localJoined = true);
      },
      onUserJoined: (connection, remoteUid, elapsed) {
        debugPrint('AGORA: remote joined $remoteUid');
        if (mounted) setState(() => _remoteUid = remoteUid);
      },
      onUserOffline: (connection, remoteUid, reason) {
        if (mounted) setState(() => _remoteUid = null);
      },
      onError: (err, msg) {
        debugPrint('AGORA ERROR: $err - $msg');
      },
    );

    engine.registerEventHandler(_handler!);
    await _agora.joinChannel(isVideo: true);
  }

  Future<void> _toggleMute() async {
    final next = !_isMuted;
    await _engine?.muteLocalAudioStream(next);
    if (mounted) setState(() => _isMuted = next);
  }

  Future<void> _toggleCamera() async {
    final next = !_isCameraOff;
    await _engine?.enableLocalVideo(!next);
    if (mounted) setState(() => _isCameraOff = next);
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
    final engine = _engine;

    return Scaffold(
      backgroundColor: Colors.black,
      body: SafeArea(
        child: Stack(
          children: [
            Positioned.fill(
              child: _remoteUid != null && engine != null
                  ? AgoraVideoView(
                      controller: VideoViewController.remote(
                        rtcEngine: engine,
                        canvas: VideoCanvas(uid: _remoteUid),
                        connection: const RtcConnection(channelId: AppConstants.agoraTestChannel),
                      ),
                    )
                  : const Center(
                      child: Text(
                        'Waiting for the other user...',
                        style: TextStyle(color: Colors.white),
                      ),
                    ),
            ),
            Positioned(
              top: 16,
              right: 16,
              child: SizedBox(
                width: 110,
                height: 150,
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(16),
                  child: engine != null && _localJoined
                      ? AgoraVideoView(
                          controller: VideoViewController(
                            rtcEngine: engine,
                            canvas: const VideoCanvas(uid: 0),
                          ),
                        )
                      : const Center(child: CircularProgressIndicator()),
                ),
              ),
            ),
            Positioned(
              left: 0,
              right: 0,
              bottom: 30,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  _CallButton(
                    icon: _isMuted ? Icons.mic_off : Icons.mic,
                    onPressed: _toggleMute,
                  ),
                  const SizedBox(width: 16),
                  _CallButton(
                    icon: _isCameraOff ? Icons.videocam_off : Icons.videocam,
                    onPressed: _toggleCamera,
                  ),
                  const SizedBox(width: 16),
                  _CallButton(
                    icon: Icons.cameraswitch,
                    onPressed: () => _engine?.switchCamera(),
                  ),
                  const SizedBox(width: 16),
                  _CallButton(
                    icon: Icons.call_end,
                    backgroundColor: Colors.red,
                    onPressed: _endCall,
                  ),
                ],
              ),
            ),
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