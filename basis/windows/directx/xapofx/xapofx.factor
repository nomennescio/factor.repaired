USING: alien.c-types alien.syntax classes.struct windows.ole32
windows.types ;
IN: windows.directx.xapofx

LIBRARY: xapofx

CONSTANT: FXEQ_MIN_FRAMERATE 22000
CONSTANT: FXEQ_MAX_FRAMERATE 48000

CONSTANT: FXEQ_MIN_FREQUENCY_CENTER       20.0
CONSTANT: FXEQ_MAX_FREQUENCY_CENTER       20000.0
CONSTANT: FXEQ_DEFAULT_FREQUENCY_CENTER_0 100.0
CONSTANT: FXEQ_DEFAULT_FREQUENCY_CENTER_1 800.0
CONSTANT: FXEQ_DEFAULT_FREQUENCY_CENTER_2 2000.0
CONSTANT: FXEQ_DEFAULT_FREQUENCY_CENTER_3 10000.0

CONSTANT: FXEQ_MIN_GAIN     0.126
CONSTANT: FXEQ_MAX_GAIN     7.94
CONSTANT: FXEQ_DEFAULT_GAIN 1.0

CONSTANT: FXEQ_MIN_BANDWIDTH     0.1
CONSTANT: FXEQ_MAX_BANDWIDTH     2.0
CONSTANT: FXEQ_DEFAULT_BANDWIDTH 1.0

CONSTANT: FXMASTERINGLIMITER_MIN_RELEASE     1
CONSTANT: FXMASTERINGLIMITER_MAX_RELEASE     20
CONSTANT: FXMASTERINGLIMITER_DEFAULT_RELEASE 6

CONSTANT: FXMASTERINGLIMITER_MIN_LOUDNESS     1
CONSTANT: FXMASTERINGLIMITER_MAX_LOUDNESS     1800
CONSTANT: FXMASTERINGLIMITER_DEFAULT_LOUDNESS 1000

CONSTANT: FXREVERB_MIN_DIFFUSION     0.0
CONSTANT: FXREVERB_MAX_DIFFUSION     1.0
CONSTANT: FXREVERB_DEFAULT_DIFFUSION 0.9

CONSTANT: FXREVERB_MIN_ROOMSIZE     0.0001
CONSTANT: FXREVERB_MAX_ROOMSIZE     1.0
CONSTANT: FXREVERB_DEFAULT_ROOMSIZE 0.6

CONSTANT: FXECHO_MIN_WETDRYMIX     0.0
CONSTANT: FXECHO_MAX_WETDRYMIX     1.0
CONSTANT: FXECHO_DEFAULT_WETDRYMIX 0.5

CONSTANT: FXECHO_MIN_FEEDBACK     0.0
CONSTANT: FXECHO_MAX_FEEDBACK     1.0
CONSTANT: FXECHO_DEFAULT_FEEDBACK 0.5

CONSTANT: FXECHO_MIN_DELAY     1.0
CONSTANT: FXECHO_MAX_DELAY     2000.0
CONSTANT: FXECHO_DEFAULT_DELAY 500.0

STRUCT: FXEQ_PARAMETERS
    { FrequencyCenter0 float }
    { Gain0            float }
    { Bandwidth0       float }
    { FrequencyCenter1 float }
    { Gain1            float }
    { Bandwidth1       float }
    { FrequencyCenter2 float }
    { Gain2            float }
    { Bandwidth2       float }
    { FrequencyCenter3 float }
    { Gain3            float }
    { Bandwidth3       float } ;

STRUCT: FXMASTERINGLIMITER_PARAMETERS
    { Release  UINT32 }
    { Loudness UINT32 } ;

STRUCT: FXREVERB_PARAMETERS
    { Diffusion float }
    { RoomSize  float } ;

STRUCT: FXECHO_PARAMETERS
    { WetDryMix float }
    { Feedback  float }
    { Delay     float } ;

FUNCTION: HRESULT CreateFX ( REFCLSID clsid, IUnknown** pEffect ) ;
