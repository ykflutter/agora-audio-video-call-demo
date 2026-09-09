import 'package:agora_rtc_engine/agora_rtc_engine.dart';
import 'package:permission_handler/permission_handler.dart';

import '../constants/app_constant.dart';



class AgoraService {
  static final AgoraService _instance = AgoraService._internal();
  factory AgoraService() => _instance;
  AgoraService._internal();

  RtcEngine? _engine;
  bool _initialized = false;
  bool _inChannel = false;

  RtcEngine? get engine => _engine;

  Future<RtcEngine> initialize() async {
    if (_initialized && _engine != null) return _engine!;

    await [Permission.microphone, Permission.camera].request();

    final engine = createAgoraRtcEngine();
    await engine.initialize(
      const RtcEngineContext(
        appId: AppConstants.agoraAppId,
        channelProfile: ChannelProfileType.channelProfileLiveBroadcasting,
      ),
    );

    _engine = engine;
    _initialized = true;
    return engine;
  }

  Future<void> joinChannel({required bool isVideo}) async {
    final engine = _engine;
    if (engine == null) return;

    await engine.setClientRole(role: ClientRoleType.clientRoleBroadcaster);
    await engine.enableAudio();

    if (isVideo) {
      await engine.enableVideo();
      await engine.startPreview();
    } else {
      await engine.disableVideo();
      await engine.setDefaultAudioRouteToSpeakerphone(true);
    }

    await engine.joinChannel(
      token: AppConstants.agoraTempToken,
      channelId: AppConstants.agoraTestChannel,
      uid: 0,
      options: ChannelMediaOptions(
        clientRoleType: ClientRoleType.clientRoleBroadcaster,
        channelProfile: ChannelProfileType.channelProfileLiveBroadcasting,
        publishMicrophoneTrack: true,
        publishCameraTrack: isVideo,
        autoSubscribeAudio: true,
        autoSubscribeVideo: isVideo,
      ),
    );

    _inChannel = true;
  }

  Future<void> leaveChannel() async {
    if (!_inChannel) return;
    try {
      await _engine?.stopPreview();
    } catch (_) {}
    await _engine?.leaveChannel();
    _inChannel = false;
  }
}