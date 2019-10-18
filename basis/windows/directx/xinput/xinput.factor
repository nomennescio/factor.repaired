USING: alien.c-types alien.syntax classes.struct windows.kernel32 windows.types ;
IN: windows.directx.xinput

LIBRARY: xinput

CONSTANT: XINPUT_DEVTYPE_GAMEPAD         1
CONSTANT: XINPUT_DEVSUBTYPE_GAMEPAD      1
CONSTANT: XINPUT_DEVSUBTYPE_WHEEL        2
CONSTANT: XINPUT_DEVSUBTYPE_ARCADE_STICK 3
CONSTANT: XINPUT_DEVSUBTYPE_FLIGHT_SICK  4
CONSTANT: XINPUT_DEVSUBTYPE_DANCE_PAD    5
CONSTANT: XINPUT_DEVSUBTYPE_GUITAR       6
CONSTANT: XINPUT_DEVSUBTYPE_DRUM_KIT     8

CONSTANT: XINPUT_CAPS_VOICE_SUPPORTED 4

CONSTANT: XINPUT_GAMEPAD_DPAD_UP        HEX: 0001
CONSTANT: XINPUT_GAMEPAD_DPAD_DOWN      HEX: 0002
CONSTANT: XINPUT_GAMEPAD_DPAD_LEFT      HEX: 0004
CONSTANT: XINPUT_GAMEPAD_DPAD_RIGHT     HEX: 0008
CONSTANT: XINPUT_GAMEPAD_START          HEX: 0010
CONSTANT: XINPUT_GAMEPAD_BACK           HEX: 0020
CONSTANT: XINPUT_GAMEPAD_LEFT_THUMB     HEX: 0040
CONSTANT: XINPUT_GAMEPAD_RIGHT_THUMB    HEX: 0080
CONSTANT: XINPUT_GAMEPAD_LEFT_SHOULDER  HEX: 0100
CONSTANT: XINPUT_GAMEPAD_RIGHT_SHOULDER HEX: 0200
CONSTANT: XINPUT_GAMEPAD_A              HEX: 1000
CONSTANT: XINPUT_GAMEPAD_B              HEX: 2000
CONSTANT: XINPUT_GAMEPAD_X              HEX: 4000
CONSTANT: XINPUT_GAMEPAD_Y              HEX: 8000

CONSTANT: XINPUT_GAMEPAD_LEFT_THUMB_DEADZONE  7849
CONSTANT: XINPUT_GAMEPAD_RIGHT_THUMB_DEADZONE 8689
CONSTANT: XINPUT_GAMEPAD_TRIGGER_THRESHOLD    30

CONSTANT: XINPUT_FLAG_GAMEPAD 1

CONSTANT: XUSER_MAX_COUNT                 4

CONSTANT: XUSER_INDEX_ANY                 HEX: 000000FF

CONSTANT: VK_PAD_A                        HEX: 5800
CONSTANT: VK_PAD_B                        HEX: 5801
CONSTANT: VK_PAD_X                        HEX: 5802
CONSTANT: VK_PAD_Y                        HEX: 5803
CONSTANT: VK_PAD_RSHOULDER                HEX: 5804
CONSTANT: VK_PAD_LSHOULDER                HEX: 5805
CONSTANT: VK_PAD_LTRIGGER                 HEX: 5806
CONSTANT: VK_PAD_RTRIGGER                 HEX: 5807

CONSTANT: VK_PAD_DPAD_UP                  HEX: 5810
CONSTANT: VK_PAD_DPAD_DOWN                HEX: 5811
CONSTANT: VK_PAD_DPAD_LEFT                HEX: 5812
CONSTANT: VK_PAD_DPAD_RIGHT               HEX: 5813
CONSTANT: VK_PAD_START                    HEX: 5814
CONSTANT: VK_PAD_BACK                     HEX: 5815
CONSTANT: VK_PAD_LTHUMB_PRESS             HEX: 5816
CONSTANT: VK_PAD_RTHUMB_PRESS             HEX: 5817

CONSTANT: VK_PAD_LTHUMB_UP                HEX: 5820
CONSTANT: VK_PAD_LTHUMB_DOWN              HEX: 5821
CONSTANT: VK_PAD_LTHUMB_RIGHT             HEX: 5822
CONSTANT: VK_PAD_LTHUMB_LEFT              HEX: 5823
CONSTANT: VK_PAD_LTHUMB_UPLEFT            HEX: 5824
CONSTANT: VK_PAD_LTHUMB_UPRIGHT           HEX: 5825
CONSTANT: VK_PAD_LTHUMB_DOWNRIGHT         HEX: 5826
CONSTANT: VK_PAD_LTHUMB_DOWNLEFT          HEX: 5827

CONSTANT: VK_PAD_RTHUMB_UP                HEX: 5830
CONSTANT: VK_PAD_RTHUMB_DOWN              HEX: 5831
CONSTANT: VK_PAD_RTHUMB_RIGHT             HEX: 5832
CONSTANT: VK_PAD_RTHUMB_LEFT              HEX: 5833
CONSTANT: VK_PAD_RTHUMB_UPLEFT            HEX: 5834
CONSTANT: VK_PAD_RTHUMB_UPRIGHT           HEX: 5835
CONSTANT: VK_PAD_RTHUMB_DOWNRIGHT         HEX: 5836
CONSTANT: VK_PAD_RTHUMB_DOWNLEFT          HEX: 5837

CONSTANT: XINPUT_KEYSTROKE_KEYDOWN        HEX: 0001
CONSTANT: XINPUT_KEYSTROKE_KEYUP          HEX: 0002
CONSTANT: XINPUT_KEYSTROKE_REPEAT         HEX: 0004

STRUCT: XINPUT_GAMEPAD
    { wButtons WORD }
    { bLeftTrigger BYTE }
    { bRightTrigger BYTE }
    { sThumbLX SHORT }
    { sThumbLY SHORT }
    { sThumbRX SHORT }
    { sThumbRY SHORT } ;
TYPEDEF: XINPUT_GAMEPAD* PXINPUT_GAMEPAD

STRUCT: XINPUT_VIBRATION
    { wLeftMotorSpeed WORD }
    { wRightMotorSpeed WORD } ;
TYPEDEF: XINPUT_VIBRATION* PXINPUT_VIBRATION

STRUCT: XINPUT_CAPABILITIES
    { Type BYTE }
    { SubType BYTE }
    { Flags WORD }
    { Gamepad XINPUT_GAMEPAD }
    { Vibration XINPUT_VIBRATION } ;
TYPEDEF: XINPUT_CAPABILITIES* PXINPUT_CAPABILITIES

STRUCT: XINPUT_KEYSTROKE
    { VirtualKey WORD }
    { Unicode WCHAR }
    { Flags WORD }
    { UserIndex BYTE }
    { HidCode BYTE } ;
TYPEDEF: XINPUT_KEYSTROKE* PXINPUT_KEYSTROKE

STRUCT: XINPUT_STATE
    { dwPacketNumber DWORD }
    { Gamepad XINPUT_GAMEPAD } ;
TYPEDEF: XINPUT_STATE* PXINPUT_STATE

FUNCTION: DWORD XInputGetCapabilities ( DWORD dwUserIndex, DWORD dwFlags, XINPUT_CAPABILITIES* pCapabilities ) ;
FUNCTION: DWORD XInputGetKeystroke ( DWORD dwUserIndex, DWORD dwReserved, PXINPUT_KEYSTROKE pKeystroke ) ;
FUNCTION: DWORD XInputGetState ( DWORD dwUserIndex, XINPUT_STATE* pState ) ;
FUNCTION: DWORD XInputSetState ( DWORD dwUserIndex, XINPUT_VIBRATION* pVibration ) ;
FUNCTION: DWORD XInputGetDSoundAudioDeviceGuids ( DWORD dwUserIndex, GUID* pDSoundRenderGuid, GUID* pDSoundCaptureGuid ) ;
FUNCTION: void XInputEnable ( BOOL enable ) ;
