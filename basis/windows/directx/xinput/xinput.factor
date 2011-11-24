USING: alien.c-types alien.syntax classes.struct windows.directx
windows.kernel32 windows.types ;
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

CONSTANT: XINPUT_GAMEPAD_DPAD_UP        0x0001
CONSTANT: XINPUT_GAMEPAD_DPAD_DOWN      0x0002
CONSTANT: XINPUT_GAMEPAD_DPAD_LEFT      0x0004
CONSTANT: XINPUT_GAMEPAD_DPAD_RIGHT     0x0008
CONSTANT: XINPUT_GAMEPAD_START          0x0010
CONSTANT: XINPUT_GAMEPAD_BACK           0x0020
CONSTANT: XINPUT_GAMEPAD_LEFT_THUMB     0x0040
CONSTANT: XINPUT_GAMEPAD_RIGHT_THUMB    0x0080
CONSTANT: XINPUT_GAMEPAD_LEFT_SHOULDER  0x0100
CONSTANT: XINPUT_GAMEPAD_RIGHT_SHOULDER 0x0200
CONSTANT: XINPUT_GAMEPAD_A              0x1000
CONSTANT: XINPUT_GAMEPAD_B              0x2000
CONSTANT: XINPUT_GAMEPAD_X              0x4000
CONSTANT: XINPUT_GAMEPAD_Y              0x8000

CONSTANT: XINPUT_GAMEPAD_LEFT_THUMB_DEADZONE  7849
CONSTANT: XINPUT_GAMEPAD_RIGHT_THUMB_DEADZONE 8689
CONSTANT: XINPUT_GAMEPAD_TRIGGER_THRESHOLD    30

CONSTANT: XINPUT_FLAG_GAMEPAD 1

CONSTANT: XUSER_MAX_COUNT                 4

CONSTANT: XUSER_INDEX_ANY                 0x000000FF

CONSTANT: VK_PAD_A                        0x5800
CONSTANT: VK_PAD_B                        0x5801
CONSTANT: VK_PAD_X                        0x5802
CONSTANT: VK_PAD_Y                        0x5803
CONSTANT: VK_PAD_RSHOULDER                0x5804
CONSTANT: VK_PAD_LSHOULDER                0x5805
CONSTANT: VK_PAD_LTRIGGER                 0x5806
CONSTANT: VK_PAD_RTRIGGER                 0x5807

CONSTANT: VK_PAD_DPAD_UP                  0x5810
CONSTANT: VK_PAD_DPAD_DOWN                0x5811
CONSTANT: VK_PAD_DPAD_LEFT                0x5812
CONSTANT: VK_PAD_DPAD_RIGHT               0x5813
CONSTANT: VK_PAD_START                    0x5814
CONSTANT: VK_PAD_BACK                     0x5815
CONSTANT: VK_PAD_LTHUMB_PRESS             0x5816
CONSTANT: VK_PAD_RTHUMB_PRESS             0x5817

CONSTANT: VK_PAD_LTHUMB_UP                0x5820
CONSTANT: VK_PAD_LTHUMB_DOWN              0x5821
CONSTANT: VK_PAD_LTHUMB_RIGHT             0x5822
CONSTANT: VK_PAD_LTHUMB_LEFT              0x5823
CONSTANT: VK_PAD_LTHUMB_UPLEFT            0x5824
CONSTANT: VK_PAD_LTHUMB_UPRIGHT           0x5825
CONSTANT: VK_PAD_LTHUMB_DOWNRIGHT         0x5826
CONSTANT: VK_PAD_LTHUMB_DOWNLEFT          0x5827

CONSTANT: VK_PAD_RTHUMB_UP                0x5830
CONSTANT: VK_PAD_RTHUMB_DOWN              0x5831
CONSTANT: VK_PAD_RTHUMB_RIGHT             0x5832
CONSTANT: VK_PAD_RTHUMB_LEFT              0x5833
CONSTANT: VK_PAD_RTHUMB_UPLEFT            0x5834
CONSTANT: VK_PAD_RTHUMB_UPRIGHT           0x5835
CONSTANT: VK_PAD_RTHUMB_DOWNRIGHT         0x5836
CONSTANT: VK_PAD_RTHUMB_DOWNLEFT          0x5837

CONSTANT: XINPUT_KEYSTROKE_KEYDOWN        0x0001
CONSTANT: XINPUT_KEYSTROKE_KEYUP          0x0002
CONSTANT: XINPUT_KEYSTROKE_REPEAT         0x0004

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
