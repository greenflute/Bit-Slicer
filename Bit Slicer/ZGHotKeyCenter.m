/*
 * Created by Mayur Pawashe on 3/9/14.
 *
 * Copyright (c) 2014 zgcoder
 * All rights reserved.
 *
 * Redistribution and use in source and binary forms, with or without
 * modification, are permitted provided that the following conditions
 * are met:
 *
 * Redistributions of source code must retain the above copyright notice,
 * this list of conditions and the following disclaimer.
 *
 * Redistributions in binary form must reproduce the above copyright
 * notice, this list of conditions and the following disclaimer in the
 * documentation and/or other materials provided with the distribution.
 *
 * Neither the name of the project's author nor the names of its
 * contributors may be used to endorse or promote products derived from
 * this software without specific prior written permission.
 *
 * THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS
 * "AS IS" AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT
 * LIMITED TO, THE IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS
 * FOR A PARTICULAR PURPOSE ARE DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT
 * HOLDER OR CONTRIBUTORS BE LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL,
 * SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT LIMITED
 * TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES; LOSS OF USE, DATA, OR
 * PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY OF
 * LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT (INCLUDING
 * NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF THIS
 * SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
 */

#import "ZGHotKeyCenter.h"
#import <Carbon/Carbon.h>
#import "ZGHotKey.h"

@implementation ZGHotKeyCenter
{
	NSMutableArray *_registeredHotKeys;
	UInt32 _nextRegisteredHotKeyID;
}

static OSStatus hotKeyHandler(EventHandlerCallRef __unused nextHandler, EventRef theEvent, void *userData)
{
	@autoreleasepool
	{
		ZGHotKeyCenter *self = (__bridge ZGHotKeyCenter *)(userData);
	
		EventHotKeyID hotKeyID;
        if (GetEventParameter(theEvent, kEventParamDirectObject, typeEventHotKeyID, NULL, sizeof(hotKeyID), NULL, &hotKeyID) == noErr)
		{
			for (ZGHotKey *registeredHotKey in self->_registeredHotKeys)
			{
				if (registeredHotKey.internalID == hotKeyID.id)
				{
					[registeredHotKey.delegate hotKeyDidTrigger:registeredHotKey];
					break;
				}
			}
		}
	}

	return noErr;
}

- (BOOL)registerHotKey:(ZGHotKey *)hotKey delegate:(id <ZGHotKeyDelegate>)delegate
{
	for (ZGHotKey *registeredHotKey in _registeredHotKeys)
	{
		if (![registeredHotKey isInvalid] && registeredHotKey.keyCombo.code == hotKey.keyCombo.code && registeredHotKey.keyCombo.flags == hotKey.keyCombo.flags)
		{
			return NO;
		}
	}

	if (![hotKey isInvalid])
	{
		if (_registeredHotKeys == nil)
		{
			_registeredHotKeys = [NSMutableArray array];

			EventTypeSpec eventType = {.eventClass = kEventClassKeyboard, .eventKind = kEventHotKeyPressed};
			InstallApplicationEventHandler(&hotKeyHandler, 1, &eventType, (__bridge void *)self, NULL);
		}

		_nextRegisteredHotKeyID++;
		hotKey.delegate = delegate;
		hotKey.internalID = _nextRegisteredHotKeyID;

		EventHotKeyRef newHotKeyRef = hotKey.hotKeyRef;
		RegisterEventHotKey((UInt32)hotKey.keyCombo.code, (UInt32)hotKey.keyCombo.flags, (EventHotKeyID){.signature = hotKey.internalID, .id = hotKey.internalID}, GetApplicationEventTarget(), 0, &newHotKeyRef);
		hotKey.hotKeyRef = newHotKeyRef;
	}

	[_registeredHotKeys addObject:hotKey];

	return YES;
}

- (void)unregisterHotKey:(ZGHotKey *)hotKey
{
	if ([_registeredHotKeys containsObject:hotKey])
	{
		if (![hotKey isInvalid])
		{
			UnregisterEventHotKey(hotKey.hotKeyRef);
		}

		[_registeredHotKeys removeObject:hotKey];
	}
}

@end