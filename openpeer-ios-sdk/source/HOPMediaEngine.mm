/*
 
 Copyright (c) 2012, SMB Phone Inc.
 All rights reserved.
 
 Redistribution and use in source and binary forms, with or without
 modification, are permitted provided that the following conditions are met:
 
 1. Redistributions of source code must retain the above copyright notice, this
 list of conditions and the following disclaimer.
 2. Redistributions in binary form must reproduce the above copyright notice,
 this list of conditions and the following disclaimer in the documentation
 and/or other materials provided with the distribution.
 
 THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS" AND
 ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE IMPLIED
 WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE
 DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT OWNER OR CONTRIBUTORS BE LIABLE FOR
 ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES
 (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES;
 LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND
 ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT
 (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF THIS
 SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
 
 The views and conclusions contained in the software and documentation are those
 of the authors and should not be interpreted as representing official policies,
 either expressed or implied, of the FreeBSD Project.
 
 */


#import "HOPMediaEngine_Internal.h"
#import "HOPMediaEngine.h"
#import <hookflash/core/IMediaEngine.h>

using namespace hookflash::core;

@interface HOPMediaEngine()

- (id) initSingleton;
@end
@implementation HOPMediaEngine

+ (NSString*) cameraTypeToString: (HOPMediaEngineCameraTypes) type
{
  return [NSString stringWithUTF8String: IMediaEngine::toString((IMediaEngine::CameraTypes) type)];
}


+ (NSString*) audioRouteToString: (HOPMediaEngineOutputAudioRoutes) route
{
  return [NSString stringWithUTF8String: IMediaEngine::toString((IMediaEngine::OutputAudioRoutes) route)];
}

+ (id)sharedInstance
{
    static dispatch_once_t pred = 0;
    __strong static id _sharedObject = nil;
    dispatch_once(&pred, ^{
        _sharedObject = [[self alloc] initSingleton]; // or some other init method
    });
    return _sharedObject;
}

- (id) initSingleton
{
    self = [super init];
    if (self)
    {
        mediaEnginePtr = IMediaEngine::singleton();
    }
    return self;
}
- (void) setVideoOrientation
{
    if(mediaEnginePtr)
    {
        mediaEnginePtr->setVideoOrientation();
    }
    else
    {
        [NSException raise:NSInvalidArgumentException format:@"Invalid Media engine pointer!"];
    }
}
- (void) setDefaultVideoOrientation: (HOPMediaEngineVideoOrientations) orientation
{
    if(mediaEnginePtr)
    {
        //mediaEnginePtr->setDefaultVideoOrientation((IMediaEngine::VideoOrientations)orientation);
    }
    else
    {
        [NSException raise:NSInvalidArgumentException format:@"Invalid Media engine pointer!"];
    }
}
- (void) setCaptureRenderView: (UIImageView*) renderView
{
    if(mediaEnginePtr)
    {
        mediaEnginePtr->setCaptureRenderView((void*) renderView);
    }
    else
    {
        [NSException raise:NSInvalidArgumentException format:@"Invalid Media engine pointer!"];
    }
}

- (void) setChannelRenderView: (UIImageView*) renderView
{
    if(mediaEnginePtr)
    {
        mediaEnginePtr->setChannelRenderView((void*) renderView);
    }
    else
    {
        [NSException raise:NSInvalidArgumentException format:@"Invalid Media engine pointer!"];
    }
}

- (void) setEcEnabled: (BOOL) enabled
{
    if(mediaEnginePtr)
    {
        mediaEnginePtr->setEcEnabled(enabled);
    }
    else
    {
        [NSException raise:NSInvalidArgumentException format:@"Invalid Media engine pointer!"];
    }
}

- (void) setAgcEnabled: (BOOL) enabled
{
    if(mediaEnginePtr)
    {
        mediaEnginePtr->setAgcEnabled(enabled);
    }
    else
    {
        [NSException raise:NSInvalidArgumentException format:@"Invalid Media engine pointer!"];
    }
}


- (void) setNsEnabled: (BOOL) enabled
{
    if(mediaEnginePtr)
    {
        mediaEnginePtr->setNsEnabled(enabled);
    }
    else
    {
        [NSException raise:NSInvalidArgumentException format:@"Invalid Media engine pointer!"];
    }
}


- (void) setRecordFile: (NSString*) fileName
{
    if(mediaEnginePtr)
    {
        mediaEnginePtr->setRecordFile([fileName UTF8String]);
    }
    else
    {
        [NSException raise:NSInvalidArgumentException format:@"Invalid Media engine pointer!"];
    }
}


- (NSString*) getRecordFile
{
    NSString* ret = nil;
    
    if(mediaEnginePtr)
    {
        ret = [NSString stringWithUTF8String: mediaEnginePtr->getRecordFile()];
    }
    else
    {
        [NSException raise:NSInvalidArgumentException format:@"Invalid Media engine pointer!"];
    }
    return ret;
}

- (void) setMuteEnabled: (BOOL) enabled
{
    if(mediaEnginePtr)
    {
        mediaEnginePtr->setMuteEnabled(enabled);
    }
    else
    {
        [NSException raise:NSInvalidArgumentException format:@"Invalid Media engine pointer!"];
    }
}


- (BOOL) getMuteEnabled
{
    BOOL ret = NO;
    
    if(mediaEnginePtr)
    {
        ret = mediaEnginePtr->getMuteEnabled();
    }
    else
    {
        [NSException raise:NSInvalidArgumentException format:@"Invalid Media engine pointer!"];
    }
    return ret;
}

- (void) setLoudspeakerEnabled: (BOOL) enabled
{
    if(mediaEnginePtr)
    {
        mediaEnginePtr->setLoudspeakerEnabled(enabled);
    }
    else
    {
        [NSException raise:NSInvalidArgumentException format:@"Invalid Media engine pointer!"];
    }
}

- (BOOL) getLoudspeakerEnabled
{
    BOOL ret = NO;
    if(mediaEnginePtr)
    {
        ret = mediaEnginePtr->getLoudspeakerEnabled();
    }
    else
    {
        [NSException raise:NSInvalidArgumentException format:@"Invalid Media engine pointer!"];
    }
    return ret;
}

- (HOPMediaEngineOutputAudioRoutes) getOutputAudioRoute
{
    HOPMediaEngineOutputAudioRoutes ret = HOPMediaEngineOutputAudioRouteHeadphone;
    
    if(mediaEnginePtr)
    {
        ret = (HOPMediaEngineOutputAudioRoutes) mediaEnginePtr->getOutputAudioRoute();
    }
    else
    {
        [NSException raise:NSInvalidArgumentException format:@"Invalid Media engine pointer!"];
    }
    return ret;
}

- (HOPMediaEngineCameraTypes) getCameraType
{
    HOPMediaEngineCameraTypes ret = HOPMediaEngineCameraTypeNone;
    
    if(mediaEnginePtr)
    {
        ret = (HOPMediaEngineCameraTypes) mediaEnginePtr->getCameraType();
    }
    else
    {
        [NSException raise:NSInvalidArgumentException format:@"Invalid Media engine pointer!"];
    }
    return ret;
}

- (void) setCameraType: (HOPMediaEngineCameraTypes) type
{
    if(mediaEnginePtr)
    {
        mediaEnginePtr->setCameraType((IMediaEngine::CameraTypes)type);
    }
    else
    {
        [NSException raise:NSInvalidArgumentException format:@"Invalid Media engine pointer!"];
    }
}

- (int) getVideoTransportStatistics: (HOPMediaEngineRtpRtcpStatistics*) stat
{
    IMediaEngine::RtpRtcpStatistics coreStat;
    int ret = 0;

    if(mediaEnginePtr)
    {
        ret = mediaEnginePtr->getVideoTransportStatistics(coreStat);
        stat.fractionLost = coreStat.fractionLost;
        stat.cumulativeLost = coreStat.cumulativeLost;
        stat.extendedMax = coreStat.extendedMax;
        stat.jitter = coreStat.jitter;
        stat.rttMs = coreStat.rttMs;
        stat.bytesSent = coreStat.bytesSent;
        stat.packetsSent = coreStat.packetsSent;
        stat.bytesReceived = coreStat.bytesReceived;
        stat.packetsReceived = coreStat.packetsReceived;
    }
    else
    {
        [NSException raise:NSInvalidArgumentException format:@"Invalid Media engine pointer!"];
    }
  
    return ret;
}

- (int) getVoiceTransportStatistics: (HOPMediaEngineRtpRtcpStatistics*) stat
{
    IMediaEngine::RtpRtcpStatistics coreStat;
    int ret = 0;

    if(mediaEnginePtr)
    {
        ret = mediaEnginePtr->getVoiceTransportStatistics(coreStat);
        stat.fractionLost = coreStat.fractionLost;
        stat.cumulativeLost = coreStat.cumulativeLost;
        stat.extendedMax = coreStat.extendedMax;
        stat.jitter = coreStat.jitter;
        stat.rttMs = coreStat.rttMs;
        stat.bytesSent = coreStat.bytesSent;
        stat.packetsSent = coreStat.packetsSent;
        stat.bytesReceived = coreStat.bytesReceived;
        stat.packetsReceived = coreStat.packetsReceived;
    }
    else
    {
        [NSException raise:NSInvalidArgumentException format:@"Invalid Media engine pointer!"];
    }

    return ret;
}

#pragma mark - Internal methods
- (IMediaEnginePtr) getMediaEnginePtr
{
    return mediaEnginePtr;
}
@end
