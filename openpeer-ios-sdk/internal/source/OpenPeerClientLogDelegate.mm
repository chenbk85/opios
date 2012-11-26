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


#import "OpenPeerClientLogDelegate.h"


OpenPeerClientLogDelegate::OpenPeerClientLogDelegate(id<HOPClientLogDelegate> inClientLogDelegate)
{
    clientLogDelegate = inClientLogDelegate;
}

boost::shared_ptr<OpenPeerClientLogDelegate> OpenPeerClientLogDelegate::create(id<HOPClientLogDelegate> inClientLogDelegate)
{
    return boost::shared_ptr<OpenPeerClientLogDelegate>(new OpenPeerClientLogDelegate(inClientLogDelegate));
}
    
void OpenPeerClientLogDelegate::onNewSubsystem(zsLib::PTRNUMBER subsystemID, const char *subsystemName)
{
    [clientLogDelegate onNewSubsystem:subsystemID subsystemName:[NSString stringWithUTF8String:subsystemName]];
}

void OpenPeerClientLogDelegate::onLog(
                       zsLib::PTRNUMBER subsystemID,
                       const char *subsystemName,
                       IClient::Log::Severity inSeverity,
                       IClient::Log::Level inLevel,
                       const char *inMessage,
                       const char *inFunction,
                       const char *inFilePath,
                       zsLib::ULONG inLineNumber
                       )
{
    [clientLogDelegate onLog:subsystemID subsystemName:[NSString stringWithUTF8String:subsystemName] severity:(HOPClientLogSeverities) inSeverity level:(HOPClientLogLevels) inLevel message:[NSString stringWithUTF8String:inMessage] function:[NSString stringWithUTF8String:inFunction] filePath:[NSString stringWithUTF8String:inFilePath] lineNumber:inLineNumber];
    /*const char *posBackslash = strrchr(inFilePath, '\\');
    const char *posSlash = strrchr(inFilePath, '/');

    const char *fileName = inFilePath;

    if (!posBackslash)
        posBackslash = posSlash;

    if (!posSlash)
        posSlash = posBackslash;

    if (posSlash) 
    {
        if (posBackslash > posSlash)
            posSlash = posBackslash;
        fileName = posSlash + 1;
    }

    NSString * severity = @"NONE";
    switch (inSeverity) 
    {
        case IClient::Log::Informational: severity = @"i:"; break;
        case IClient::Log::Warning:       severity = @"W:"; break;
        case IClient::Log::Error:         severity = @"E:"; break;
        case IClient::Log::Fatal:         severity = @"F:"; break;
    }*/
    // NSLog(@"%@ %@ @%@(%lu) [%@-%@]", severity, [NSString stringWithCString:inMessage encoding:NSUTF8StringEncoding],  [NSString stringWithCString:fileName encoding:NSUTF8StringEncoding], inLineNumber, [NSString stringWithCString:subsystemName encoding:NSUTF8StringEncoding], [NSString stringWithCString:inFunction encoding:NSUTF8StringEncoding]);
}
