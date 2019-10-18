! (c)2010 Joe Groff bsd license
USING: alien audio byte-arrays destructors help.markup
help.syntax kernel math strings ;
IN: audio.engine

HELP: <audio-engine>
{ $values
    { "device-name" { $maybe string } } { "voice-count" integer }
    { "engine" audio-engine }
}
{ $description "Constructs an " { $link audio-engine } " instance capable of playing " { $snippet "voice-count" } " simultaneous clips. The OpenAL device named " { $snippet "device-name" } " will be used, or the default device if " { $snippet "device-name" } " is " { $link f } ". An error will be thrown if the engine cannot be initialized. The engine is returned in the stopped state; to start audio processing, use " { $link start-audio } " or " { $link start-audio* } "." } ;

HELP: <audio-orientation-state>
{ $values
    { "forward" "a sequence of 3 floats" } { "up" "a sequence of 3 floats" }
    { "audio-orientation-state" audio-orientation-state }
}
{ $description "Constructs an " { $link audio-orientation-state } " tuple." } ;

HELP: <standard-audio-engine>
{ $values
    
    { "engine" audio-engine }
}
{ $description "Constructs an " { $link audio-engine } " instance by calling " { $link <audio-engine> } " with the default values of " { $link f } " for the " { $snippet "device-name" } " and 16 for the " { $snippet "voice-count" } ". The engine is returned in the stopped state; to start audio processing, use " { $link start-audio } " or " { $link start-audio* } "." } ;

HELP: <static-audio-clip>
{ $values
    { "audio-engine" audio-engine } { "source" "an object implementing the " { $link "audio.engine-sources" } } { "audio" audio } { "loop?" boolean }
    { "audio-clip/f" { $maybe audio-clip } }
}
{ $description "Constructs a " { $link static-audio-clip } " tied to " { $snippet "source" } " and playing audio generated by " { $snippet "generator" } ". The clip won't be played until " { $link play-clip } " or " { $link play-clips } " is called on it. If " { $snippet "loop?" } " is true, the clip will repeat indefinitely when played until stopped with " { $link stop-clip } ". Otherwise, the clip will automatically be " { $link dispose } "d by the " { $link audio-engine } " after it finishes playing. If the engine has no available voices, no clip will be constructed, and " { $link f } " will be returned." } ;

HELP: <streaming-audio-clip>
{ $values
    { "audio-engine" audio-engine } { "source" "an object implementing the " { $link "audio.engine-sources" } } { "generator" "an object implementing the " { $link "audio.engine-generators" } } { "buffer-count" integer }
    { "audio-clip/f" { $maybe audio-clip } }
}
{ $description "Constructs a " { $link streaming-audio-clip } " tied to " { $snippet "source" } " and playing audio generated by " { $snippet "generator" } ". " { $snippet "buffer-count" } " buffers will be allocated for the clip. The clip won't be played until " { $link play-clip } " or " { $link play-clips } " is called on it. The clip will automatically be " { $link dispose } "d by the " { $link audio-engine } " when the generator stops supplying data and all the buffered data has played. The clip will in turn dispose its generator when it is disposed. If the engine has no available voices, no clip will be constructed, the generator will be disposed, and " { $link f } " will be returned." } ;

HELP: audio-clip
{ $class-description "Opaque type of clips being played by an " { $link audio-engine } ". There are two subclasses provided:"
{ $list
    { { $link static-audio-clip } ", constructed by " { $link <static-audio-clip> } " or " { $link play-static-audio-clip } }
    { { $link streaming-audio-clip } ", constructed by " { $link <streaming-audio-clip> } " or " { $link play-streaming-audio-clip } }
}
"Clip objects are transient. They get " { $link dispose } "d and invalidated by the controlling " { $link audio-engine } " when their playback finishes or is stopped. The " { $link play-clip } ", " { $link pause-clip } ", and " { $link stop-clip } " words control playback of individual clips. " { $link play-clips } ", " { $link pause-clips } ", and " { $link stop-clips } " synchronize the playing, pausing, or stopping of multiple clips." } ;

HELP: audio-context-not-available
{ $values
    { "device-name" { $maybe string } }
}
{ $description "Errors of this type are thrown by " { $link <audio-engine> } " when an OpenAL context cannot be created for the device named " { $snippet "device-name" } "." } ;

HELP: audio-device-not-found
{ $values
    { "device-name" { $maybe string } }
}
{ $description "Errors of this type are thrown by " { $link <audio-engine> } " when it is unable to open the OpenAL device named " { $snippet "device-name" } "." } ;

HELP: audio-distance
{ $values
    { "source" "an object implementing the " { $link "audio.engine-sources" } }
    { "distance" float }
}
{ $description "Returns the reference distance (that is, the distance from the listener below which the clip plays at full volume) for a playing audio clip. Larger reference distances make the clip play louder at further distances from the listener." } ;

HELP: audio-engine
{ $class-description "Objects of this class encapsulate the state for an active audio engine. Audio processing on an engine can be started and stopped with " { $link start-audio } ", " { $link start-audio* } ", and " { $link stop-audio } ". While running, " { $link update-audio } " must be called on an engine regularly to update source and listener attributes and refill buffers for streaming clips."
$nl
"An engine object should be treated as opaque, except for the " { $snippet "listener" } " slot. This slot may be filled with any object implementing the " { $link "audio.engine-listener" } " protocol, which will then be used to control the position, velocity, volume, and other attributes of the lisetener. By default, this slot contains an " { $link audio-listener } " tuple with all the slots set to their initial values." } ;

HELP: audio-gain
{ $values
    { "source/listener" "an object implementing the " { $link "audio.engine-sources" } " or " { $link "audio.engine-listener" } }
    { "gain" "a " { $link float } " between 0.0 and 1.0" }
}
{ $description "Returns the base gain for an individual audio clip, or for the listener. A clip source's gain will be attenuated by its distance from the listener. The listener's gain will be multiplied on top of each source's gain." } ;

HELP: audio-listener
{ $class-description "A tuple class that trivially implements the " { $link "audio.engine-listener" } " with accessors on its tuple slots."
{ $list
    { { $snippet "position" } " provides the " { $link audio-position } "." } 
    { { $snippet "gain" } " provides the " { $link audio-gain } "." }
    { { $snippet "velocity" } " provides the " { $link audio-velocity } "." }
    { { $snippet "orientation" } " provides the " { $link audio-orientation } "." }
} } ;

HELP: audio-orientation
{ $values
    { "listener" "an object implementing the " { $link "audio.engine-listener" } }
    { "orientation" audio-orientation }
}
{ $description "Returns the orientation of the listener. The orientation must be returned in an " { $snippet "audio-orientation" } " tuple with the following slots:" 
{ $list
    { { $snippet "forward" } " is a 3-component vector indicating the direction the listener is facing." }
    { { $snippet "up" } " is a 3-component vector indicating the \"up\" direction for the listener. This vector does not need to be normal to the " { $snippet "forward" } " vector." }
} "The vectors do not need to be normalized." } ;

HELP: audio-position
{ $values
    { "source/listener" "an object implementing the " { $link "audio.engine-sources" } " or " { $link "audio.engine-listener" } }
    { "position" "a 3-component float vector" }
}
{ $description "Returns the position of an audio clip or of the listener. These positions determine the distance between clips and the listener, which in turn control the attenuation of the clips." } ;

HELP: audio-relative?
{ $values
    { "source" "an object implementing the " { $link "audio.engine-sources" } }
    { "relative?" boolean }
}
{ $description "If true, the " { $link audio-position } " and " { $link audio-velocity } " of the clip will be taken as being relative to the listener instead of in world space." } ;

HELP: audio-rolloff
{ $values
    { "source" "an object implementing the " { $link "audio.engine-sources" } }
    { "rolloff" float }
}
{ $description "Returns the rolloff factor for an audio clip. Rolloff factors greater than one will result in greater distance-based attenuation, and factors less than one will result in lesser attenuation." } ;

HELP: audio-source
{ $class-description "A tuple class that trivially implements the " { $link "audio.engine-sources" } " with accessors on its tuple slots."
{ $list
    { { $snippet "position" } " provides the " { $link audio-position } "." } 
    { { $snippet "gain" } " provides the " { $link audio-gain } "." }
    { { $snippet "velocity" } " provides the " { $link audio-velocity } "." }
    { { $snippet "relative?" } " provides the " { $link audio-relative? } " value." }
    { { $snippet "distance" } " provides the " { $link audio-distance } "." }
    { { $snippet "rolloff" } " provides the " { $link audio-rolloff } "." }
} } ;

HELP: audio-velocity
{ $values
    { "source/listener" "an object implementing the " { $link "audio.engine-sources" } " or " { $link "audio.engine-listener" } }
    { "velocity" "a 3-component float vector" }
}
{ $description "Returns the velocity of an audio clip or of the listener. The relative velocity of each source to the listener is used to calculate a Doppler effect on its associated clips." } ;

HELP: generate-audio
{ $values
    { "generator" "an object implementing the " { $link "audio.engine-generators" } }
    { "c-ptr" { $maybe c-ptr } } { "size" { $maybe integer } }
}
{ $description "Tells " { $snippet "generator" } " to generate another block of PCM data. " { $snippet "c-ptr" } " can be a " { $link byte-array } " or " { $link alien } " pointer. " { $snippet "size" } " indicates the size in bytes of the returned buffer. The generator is allowed to reuse the buffer; the engine will copy the data to its own internal buffer before its next call to " { $snippet "generate-audio" } ". The method can provide " { $link f } " for both outputs or a " { $snippet "size" } " of 0 to indicate that its stream is exhausted." } ;

HELP: generator-audio-format
{ $values
    { "generator" "an object implementing the " { $link "audio.engine-generators" } }
    { "channels" integer } { "sample-bits" integer } { "sample-rate" integer }
}
{ $description "Returns the number of channels (1 for mono, 2 for stereo), number of bits per sample, and sample rate in hertz of the PCM data generated by " { $snippet "generator" } "." } ;

HELP: pause-clip
{ $values
    { "audio-clip" audio-clip }
}
{ $description "Pauses the " { $link audio-clip } "." }
{ $notes "Use " { $link pause-clips } " to synchronize the pausing of multiple clips." } ;

HELP: pause-clips
{ $values
    { "audio-clips" "a sequence of " { $link audio-clip } "s" }
}
{ $description "Pauses all of the " { $link audio-clip } "s at the exact same time." } ;

HELP: play-clip
{ $values
    { "audio-clip" audio-clip }
}
{ $description "Starts or resumes playing the " { $link audio-clip } "." }
{ $notes "Use " { $link play-clips } " to synchronize the playing of multiple clips." } ;

HELP: play-clips
{ $values
    { "audio-clips" "a sequence of " { $link audio-clip } "s" }
}
{ $description "Plays all of the " { $link audio-clip } "s at the exact same time." } ;

HELP: play-static-audio-clip
{ $values
    { "audio-engine" audio-engine } { "source" "an object implementing the " { $link "audio.engine-sources" } } { "audio" audio } { "loop?" boolean }
    { "audio-clip/f" { $maybe audio-clip } }
}
{ $description "Constructs and immediately starts playing a " { $link static-audio-clip } " tied to " { $snippet "source" } " and playing audio generated by " { $snippet "generator" } ". If " { $snippet "loop?" } " is true, the clip will repeat indefinitely until stopped with " { $link stop-clip } ". Otherwise, the clip will automatically be " { $link dispose } "d by the " { $link audio-engine } " when it finishes playing. If the engine has no available voices, no clip will be constructed, and " { $link f } " will be returned." }
{ $notes "Use " { $link play-clips } " with " { $link <static-audio-clip> } " and " { $link <streaming-audio-clip> } " to synchronize the playing of multiple clips." } ;

HELP: play-streaming-audio-clip
{ $values
    { "audio-engine" audio-engine } { "source" "an object implementing the " { $link "audio.engine-sources" } } { "generator" "an object implementing the " { $link "audio.engine-generators" } } { "buffer-count" integer }
    { "audio-clip/f" { $maybe audio-clip } }
}
{ $description "Constructs and immediately starts playing a " { $link streaming-audio-clip } " tied to " { $snippet "source" } " and playing audio generated by " { $snippet "generator" } ". " { $snippet "buffer-count" } " buffers will be allocated for the clip. The clip will automatically be " { $link dispose } "d by the " { $link audio-engine } " when the generator stops supplying data and all the buffered data has played. The clip will in turn dispose its generator when it is disposed. If the engine has no available voices, no clip will be constructed, the generator will be disposed, and " { $link f } " will be returned." }
{ $notes "Use " { $link play-clips } " with " { $link <static-audio-clip> } " and " { $link <streaming-audio-clip> } " to synchronize the playing of multiple clips." } ;

HELP: start-audio
{ $values
    { "audio-engine" audio-engine }
}
{ $description "Starts processing of the " { $link audio-engine } ", and starts a thread that will call " { $link update-audio } " 50 times per second. If you will be integrating your own timer mechanism, " { $link start-audio* } " will start processing without providing the update thread." } ;

HELP: start-audio*
{ $values
    { "audio-engine" audio-engine }
}
{ $description "Starts processing of the " { $link audio-engine } ". Unlike " { $link start-audio } ", this does not start a thread to call " { $link update-audio } " for you. This is useful if you will be integrating your own timer mechanism (such as a " { $vocab-link "game.loop" } ") to keep the audio engine updated." } ;

HELP: static-audio-clip
{ $class-description "An " { $link audio-clip } " that plays back static, prerendered, fixed-size PCM data from an " { $link audio } " object. Use " { $link <static-audio-clip> } " or " { $link play-static-audio-clip } " to construct static audio clips." } ;

HELP: stop-audio
{ $values
    { "audio-engine" audio-engine }
}
{ $description "Stops processing of the " { $link audio-engine } " and invalidates any currently playing " { $link audio-clip } "s. The engine can be restarted using " { $link start-audio } " or " { $link start-audio* } "; however, any clips that were playing will remain invalidated." } ;

HELP: stop-clip
{ $values
    { "audio-clip" audio-clip }
}
{ $description "Stops and disposes an audio clip." }
{ $notes "Use " { $link pause-clip } " if playback will need to be continued. Use " { $link stop-clips } " to synchronize the stopping of multiple clips." } ;

HELP: stop-clips
{ $values
    { "audio-clips" "a sequence of " { $link audio-clip } "s" }
}
{ $description "Stops all of the " { $link audio-clip } "s at the exact same time. All of the clips will be " { $link dispose } "d and rendered invalid." }
{ $notes "Use " { $link pause-clips } " if playback will need to be continued." } ;

HELP: streaming-audio-clip
{ $class-description "An " { $link audio-clip } " that plays back PCM data streamed by a generator object implementing the " { $link "audio.engine-generators" } ". Use " { $link <streaming-audio-clip> } " or " { $link play-streaming-audio-clip } " to construct streaming audio clips." } ;

HELP: update-audio
{ $values
    { "audio-engine" audio-engine }
}
{ $description "Updates the " { $link audio-engine } " state, refilling processed audio buffers for playing " { $link streaming-audio-clip } "s as well as updating the listener and source attributes of every audio clip. " { $link start-audio } " will start up a timer that will call " { $snippet "update-audio" } " regularly for you. If you start the audio engine using " { $link start-audio* } ", you will need to arrange for " { $snippet "update-audio" } " to be regularly invoked yourself." } ;

ARTICLE: "audio.engine-generators" "Audio generator protocol"
{ $link streaming-audio-clip } "s require a " { $snippet "generator" } " object to supply PCM data to the audio engine as it is needed. To function as a generator, an object must provide methods for the following generic words:"
{ $subsections
    generate-audio
    generator-audio-format
}
"A generator object must also be " { $link disposable } "." ;

ARTICLE: "audio.engine-listener" "Audio listener protocol"
"The " { $link audio-engine } " has a " { $snippet "listener" } " slot. The engine uses the object in this slot to determine the position, velocity, volume, and other attributes of the frame of reference for audio playback. These attributes are dynamic; every time " { $link update-audio } " runs, the listener attributes are queried and updated. The listener object must provide methods for the following generic words:"
{ $subsections
    audio-position
    audio-gain
    audio-velocity
    audio-orientation
}
"Some of these methods are shared with the " { $link "audio.engine-sources" } "."
$nl
"For simple applications, a tuple class is provided with a trivial implementation of these methods:"
{ $subsections
    audio-listener
} ;

ARTICLE: "audio.engine-sources" "Audio source protocol"
"Every audio clip has an associated " { $snippet "source" } " object. The " { $link audio-engine } " uses this object to determine the position, velocity, volume, and other attributes of the clip. These attributes are dynamic; every time " { $link update-audio } " runs, these attributes are queried and updated for every currently playing clip. The source object must provide methods for the following generic words:"
{ $subsections
    audio-position
    audio-gain
    audio-velocity
    audio-relative?
    audio-distance
    audio-rolloff
}
"Some of these methods are shared with the " { $link "audio.engine-listener" } "."
$nl
"For simple applications, a tuple class is provided with a trivial implementation of these methods:"
{ $subsections
    audio-source
} ;

ARTICLE: "audio.engine" "Audio playback engine"
"The " { $vocab-link "audio.engine" } " manages playback of prerendered and streaming audio clips. It uses OpenAL as the underlying interface to audio hardware. As clips play, their 3D location, volume, and other attributes can be updated on the fly."
$nl
"An " { $link audio-engine } " object manages the connection to the OpenAL implementation and any playing clips:"
{ $subsections
    audio-engine
    <audio-engine>
    <standard-audio-engine>
}
"The audio engine can be started and stopped. While it is running, it must be regularly updated to keep audio buffers full and clip attributes up to date."
{ $subsections
    start-audio
    start-audio*
    stop-audio
    update-audio
}
"Audio clips are represented by " { $link audio-clip } " objects while they are playing. Words are provided to control the playback of clips:"
{ $subsections
    audio-clip
    play-clip
    pause-clip
    stop-clip
    play-clips
    pause-clips
    stop-clips
}
"Two types of audio clip objects can be played by the engine. A " { $link static-audio-clip } " plays back a static, prerendered, fixed-size block of PCM data from an " { $link audio } " object."
{ $subsections
    static-audio-clip
    <static-audio-clip>
    play-static-audio-clip
}
"A " { $link streaming-audio-clip } " generates PCM data on the fly from a generator object."
{ $subsections
    "audio.engine-generators"
    streaming-audio-clip
    <streaming-audio-clip>
    play-streaming-audio-clip
}
"Every audio clip has an associated " { $snippet "source" } " object that determines the clip's 3D position, velocity, volume, and other attributes. The engine itself has a " { $snippet "listener" } " that describes the position, orientation, velocity, and volume that make up the frame of reference for audio playback."
{ $subsections
    "audio.engine-sources"
    "audio.engine-listener"
} ;

ABOUT: "audio.engine"
