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

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
#import "HOPMediaEngineRtpRtcpStatistics.h"
#import "HOPTypes.h"

using namespace hookflash;


@interface HOPMediaEngine : NSObject

/**
 Retrieves string representation of camera type.
 @param type HOPMediaEngineCameraTypes Camera type enum
 @returns String representation of camera type
 */
+ (NSString*) cameraTypeToString: (HOPMediaEngineCameraTypes) type;

/**
 Retrieves string representation of the audio route.
 @param route HOPMediaEngineOutputAudioRoutes Audio route enum
 @returns String representation of audio route
 */
+ (NSString*) audioRouteToString: (HOPMediaEngineOutputAudioRoutes) route;

/**
 Returns singleton object of this class.
 */
+ (id)sharedInstance;

/**
 Sets window for rendering local capture video.
 @param renderView UIImageView Window where local capture video will be rendered
 */
- (void) setCaptureRenderView: (UIImageView*) renderView;

/**
 Sets window for rendering video received from channel.
 @param renderView UIView Window where video received from channel will be rendered
 */
- (void) setChannelRenderView: (UIImageView*) renderView;

/**
 Turns echo cancelation ON/OFF.
 @param enabled BOOL Enabled flag
 */
- (void) setEcEnabled: (BOOL) enabled;

/**
 Turns automatic gain control ON/OFF.
 @param enabled BOOL Enabled flag
 */
- (void) setAgcEnabled: (BOOL) enabled;

/**
 Turns noise suppression ON/OFF.
 @param enabled BOOL Enabled flag
 */
- (void) setNsEnabled: (BOOL) enabled;

/**
 Sets recording file name.
 @param fileName NSString Recording file name
 */
- (void) setRecordFile: (NSString*) fileName;

/**
 Retrieves recording file name.
 @return Retrieves recording file name
 */
- (NSString*) getRecordFile;

/**
 Turns mute ON/OFF.
 @param enabled BOOL Enabled flag
 */
- (void) setMuteEnabled: (BOOL) enabled;

/**
 Retrieves info if audio is muted.
 @return YES if mute is enabled, NO if not
 */
- (BOOL) getMuteEnabled;

/**
 Turns loudspeaker ON/OFF.
 @param enabled BOOL Enabled flag
 */
- (void) setLoudspeakerEnabled: (BOOL) enabled;

/**
 Retrieves info if loudspeakers is muted.
 @return YES if loudspeakers are enabled, NO if not
 */
- (BOOL) getLoudspeakerEnabled;

/**
 Retrieves output audio route.
 @return Output audio route enum
 */
- (HOPMediaEngineOutputAudioRoutes) getOutputAudioRoute;

/**
 Retrieves camera type.
 @return Camera type enum
 */
- (HOPMediaEngineCameraTypes) getCameraType;

/**
 Sets provided camera type as active.
 @param type HOPMediaEngineCameraTypes Camera type
 */
- (void) setCameraType: (HOPMediaEngineCameraTypes) type;

/**
 Retrieves video transport statistics.
 @param stat HOPMediaEngineRtpRtcpStatistics Statistics structure to be filled with stats
 @returns Error code, 0 if success
 */
- (int) getVideoTransportStatistics: (HOPMediaEngineRtpRtcpStatistics*) stat;

/**
 Retrieves video transport statistics.
 @param stat HOPMediaEngineRtpRtcpStatistics Statistics structure to be filled with stats
 @returns Error code, 0 if success
 */
- (int) getVoiceTransportStatistics: (HOPMediaEngineRtpRtcpStatistics*) stat;

@end
