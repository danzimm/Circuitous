#import <SpringBoard/SpringBoard.h>
#import <SpringBoard/SBApplication.h>
#import <SpringBoard/SBAwayController.h>
#import <SpringBoard/SBIconList.h>
#import <SpringBoard/SBApplicationIcon.h>
#import <SpringBoard/SBIconModel.h>
#import <SpringBoard/SBUIController.h>

#import "CIRActivator.h"
#import "CIRLauncherHandler.h"
#import "CIRBackgroundWindow.h"
#import "CIRLauncherView.h"

#import "UIModalView.h"
#import "DSDisplayController.h"

#include <stdlib.h>
#include <dlfcn.h>
#include <notify.h>

static CIRLauncherHandler *sharedLauncher = nil;
static BOOL _becomeHomeScreen = NO;
static BOOL _onLock = YES;
static BOOL _hasIcon = YES;
static BOOL _uninstalled = NO;
static int _orientation = 0;
static BOOL _animations = YES;
static BOOL _busy = NO;

%class SBAwayController;
%class SBIconModel;


static BOOL setIconHiding()
{
    // Open the libhide helper library.
    void* libHandle = dlopen("/usr/lib/hide.dylib", RTLD_LAZY);
    BOOL Changed = NO;

    if (libHandle != NULL) {
		BOOL (*HideIcon)(NSString*) =  (BOOL (*)(NSString*)) dlsym(libHandle, "HideIconViaDisplayId");
		BOOL (*UnHideIcon)(NSString*) =  (BOOL (*)(NSString*)) dlsym(libHandle, "UnHideIconViaDisplayId");

		if (HideIcon != NULL && UnHideIcon != NULL) {

			// Lets always unhide the icon first. If we were unhiding, this works.
			// If we are hiding,
			// prevents possibility of duplicate hidden entries in the hidden list.
	
			Changed = UnHideIcon(@"com.zimm.circuitous");
			// Hiding. 
			if (_hasIcon == NO) {
				Changed = HideIcon(@"com.zimm.circuitous");
			}
		}
		dlclose(libHandle);
	}
    // Tell libhide to reevaluate the hidden icon state.
    if(Changed == YES) {
        notify_post("com.libhide.hiddeniconschanged"); 
    }
    return Changed;
}

static void UpdatePreferences() {
	if (_uninstalled)
		return;
	NSDictionary *prefs = [[NSDictionary alloc] initWithContentsOfFile:@"/var/mobile/Library/Preferences/com.zimm.circuitous.plist"];
	_becomeHomeScreen = [prefs objectForKey:@"becomehome"] ? [[prefs objectForKey:@"becomehome"] boolValue] : NO;
	_onLock = [prefs objectForKey:@"onlock"] ? [[prefs objectForKey:@"onlock"] boolValue] : YES;
	_animations = [prefs objectForKey:@"appanimations"] ? [[prefs objectForKey:@"appanimations"] boolValue] : YES;
	_hasIcon = [prefs objectForKey:@"icon"] ? [[prefs objectForKey:@"icon"] boolValue] : YES;
	setIconHiding();
	[prefs release];
}

@interface SpringBoard (PadLauncher)
- (void)showCircuitous;
- (void)hideCircuitous;
- (void)cycleAppsWithPlace:(int)place;
- (void)releaseCIRDelegate:(id)delegate;
@end
@interface UIDevice (iPad)
- (BOOL)isWildcat;
@end


@interface CIRModalDelegate : NSObject<UIModalViewDelegate> {
}
-(void)modalView:(id)view didDismissWithButtonIndex:(int)buttonIndex;
@end

@implementation CIRModalDelegate

-(void)modalView:(id)view didDismissWithButtonIndex:(int)buttonIndex
{
	UIModalView *view1 = (UIModalView *)view;
	if ([view1.title isEqualToString:@"Welcome to Circuitous 2.2"]) {
		switch (buttonIndex) {
			case 0:
				[[DSDisplayController sharedInstance] activateAppWithDisplayIdentifier:@"com.apple.Preferences" animated:_animations];
				break;
			default:
				break;
		}
	} else if ([view1.title isEqualToString:@"Circuitous Uninstalled"]) {
		switch (buttonIndex) {
			case 0:
				[(SpringBoard *)[UIApplication sharedApplication] relaunchSpringBoard];
				break;
			default:
				break;
		}
	}
	[(SpringBoard *)[UIApplication sharedApplication] releaseCIRDelegate:self];
}

@end


#define isWildcat ([[UIDevice currentDevice] respondsToSelector:@selector(isWildcat)] && [[UIDevice currentDevice] isWildcat])


@implementation CIRActivator
- (void)activator:(LAActivator *)activator receiveEvent:(LAEvent *)event
{
	if ((!_onLock) && ([[$SBAwayController sharedAwayController] isLocked]) || (_uninstalled) || ([CIRBackgroundWindow currentView]) || ([CIRLauncherView currentView]) || (_busy))
		return;
	if (!sharedLauncher) {
		sharedLauncher = [[CIRLauncherHandler alloc] init];
		[sharedLauncher animateIn];
	} else if ([sharedLauncher animateOut]) {
		[sharedLauncher release];
		sharedLauncher = nil;
	}
	[event setHandled:YES];
}

- (void)activator:(LAActivator *)activator abortEvent:(LAEvent *)event
{
}

+ (void)load
{
	[[LAActivator sharedInstance] registerListener:[self new] forName:@"com.zimm.circuitous.activator"];
}

@end

@implementation CIRActivatorCycler
- (void)activator:(LAActivator *)activator receiveEvent:(LAEvent *)event
{
	if ((!_onLock) && ([[$SBAwayController sharedAwayController] isLocked]) || (_uninstalled) || ([CIRBackgroundWindow currentView]) || ([CIRLauncherView currentView]) || (_busy))
		return;
	[(SpringBoard *)[UIApplication sharedApplication] cycleAppsWithPlace:1];
	[event setHandled:YES];
}

- (void)activator:(LAActivator *)activator abortEvent:(LAEvent *)event
{
}

+ (void)load
{
	[[LAActivator sharedInstance] registerListener:[self new] forName:@"com.zimm.circuitous.cycler.activator"];
}

@end

@implementation CIRActivatorReverseCycler
- (void)activator:(LAActivator *)activator receiveEvent:(LAEvent *)event
{
	if ((!_onLock) && ([[$SBAwayController sharedAwayController] isLocked]) || (_uninstalled) || ([CIRBackgroundWindow currentView]) || ([CIRLauncherView currentView]) || (_busy))
		return;
	[(SpringBoard *)[UIApplication sharedApplication] cycleAppsWithPlace:-1];
	[event setHandled:YES];
}

- (void)activator:(LAActivator *)activator abortEvent:(LAEvent *)event
{
}

+ (void)load
{
	[[LAActivator sharedInstance] registerListener:[self new] forName:@"com.zimm.circuitous.reverse.activator"];
}

@end

@implementation CIRActivatorRandom
- (void)activator:(LAActivator *)activator receiveEvent:(LAEvent *)event
{
	if ((!_onLock) && ([[$SBAwayController sharedAwayController] isLocked]) || (_uninstalled) || ([CIRBackgroundWindow currentView]) || ([CIRLauncherView currentView]) || (_busy))
		return;
	int rand = (arc4random() % 10) + 1;
	if (rand > 5) {
		rand = -(rand - 5);
	}
	[(SpringBoard *)[UIApplication sharedApplication] cycleAppsWithPlace:rand];
	[event setHandled:YES];
}

- (void)activator:(LAActivator *)activator abortEvent:(LAEvent *)event
{
}

+ (void)load
{
	[[LAActivator sharedInstance] registerListener:[self new] forName:@"com.zimm.circuitous.random.activator"];
}

@end

%hook SpringBoard

- (void)applicationDidFinishLaunching:(id)application
{
	NSDictionary *prefs = [[NSDictionary alloc] initWithContentsOfFile:@"/var/mobile/Library/Preferences/com.zimm.circuitous.plist"];
	_becomeHomeScreen = [prefs objectForKey:@"becomehome"] ? [[prefs objectForKey:@"becomehome"] boolValue] : NO;
	_onLock = [prefs objectForKey:@"onlock"] ? [[prefs objectForKey:@"onlock"] boolValue] : YES;
	_hasIcon = [prefs objectForKey:@"icon"] ? [[prefs objectForKey:@"icon"] boolValue] : YES;
	_animations = [prefs objectForKey:@"appanimations"] ? [[prefs objectForKey:@"appanimations"] boolValue] : YES;
	[prefs release];
	CFNotificationCenterAddObserver(CFNotificationCenterGetDarwinNotifyCenter(), NULL, (void (*)(CFNotificationCenterRef, void *, CFStringRef, const void *, CFDictionaryRef))UpdatePreferences, CFSTR("com.zimm.circuitous.settingschanged"), NULL, CFNotificationSuspensionBehaviorHold);
	%orig;
}

- (void)_handleMenuButtonEvent
{
	if (sharedLauncher) {
		if ([CIRBackgroundWindow currentView] || [CIRLauncherView currentView])
			return;
		if ([sharedLauncher animateOut]) {
			[sharedLauncher release];
			sharedLauncher = nil;
		}
		unsigned int &_menuButtonClickCount = MSHookIvar<unsigned int>(self, "_menuButtonClickCount");
		_menuButtonClickCount = 0x8000;
	} else {
		%orig;
	}
}

- (void)autoLock
{
	%orig;
	if (sharedLauncher) {
		if ([CIRBackgroundWindow currentView] || [CIRLauncherView currentView])
			return;
		if ([sharedLauncher animateOut]) {
			[sharedLauncher release];
			sharedLauncher = nil;
		}
	}
}

-(void)lockButtonDown:(GSEventRef)down
{
	%orig;
	if (sharedLauncher) {
		if ([CIRBackgroundWindow currentView] || [CIRLauncherView currentView])
			return;
		if ([sharedLauncher animateOut]) {
			[sharedLauncher release];
			sharedLauncher = nil;
		}
	}
}

-(void)noteUIOrientationChanged:(int)changed display:(id)display
{
	_orientation = changed;
	%orig;
	if (sharedLauncher) {
		[sharedLauncher updateOrientation];
	}
}

- (int)_frontMostAppOrientation
{
	if isWildcat
		return %orig;
	else
		return _orientation;
}

-(void)noteInterfaceOrientationChanged:(int)changed
{
	%orig;
	if (sharedLauncher) {
		[sharedLauncher updateOrientation];
	}
}

-(void)relaunchSpringBoard
{
	_busy = YES;
	%orig;
}

%new(v@:)
- (void)showCircuitous
{
	if (sharedLauncher || _uninstalled || _busy) {
		return;
	}
	_busy = YES;
	sharedLauncher = [[CIRLauncherHandler alloc] init];
	[sharedLauncher animateIn];
	_busy = NO;
}

%new(v@:)
- (void)hideCircuitous
{
	if (!sharedLauncher || [CIRBackgroundWindow currentView] || [CIRLauncherView currentView] || _busy)
		return;
	_busy = YES;
	if ([sharedLauncher animateOut]) {
		[sharedLauncher release];
		sharedLauncher = nil;
	}
	_busy = NO;
}

%new(v@:i)
- (void)cycleAppsWithPlace:(int)place
{
	if (_busy)
		return;
	_busy = YES;
	NSDictionary *prefs = [[NSDictionary alloc] initWithContentsOfFile:@"/var/mobile/Library/Preferences/com.zimm.circuitous.plist"];
	NSArray *hidden = [[NSArray alloc] initWithArray:(NSArray *)[prefs objectForKey:@"hidden"]];
	NSArray *apps = [[DSDisplayController sharedInstance] activeApps];
	BOOL sb = [prefs objectForKey:@"springboard"] ? [[prefs objectForKey:@"springboard"] boolValue] : YES;
	int i = -1;
	int currentApp = i;
	for (NSString *app in apps) {
		i++;
		if ([app isEqualToString:[[[DSDisplayController sharedInstance] activeApp] displayIdentifier]])
			currentApp = i;
	}
	currentApp = currentApp + place;
	if (currentApp >= (int)[apps count]) {
		currentApp = -1;
	} else if (currentApp == -2)
		currentApp = (int)[apps count] - 1;
	[[DSDisplayController sharedInstance] backgroundTopApplication];
	NSLog(@"Current app is: %d", currentApp);
	if (currentApp == -1 && sb) {
		[[DSDisplayController sharedInstance] activateAppWithDisplayIdentifier:@"com.apple.springboard" animated:_animations];
		[apps release];
		[hidden release];
		[prefs release];
		_busy = NO;
		return;
	} else if (currentApp == -1)
		currentApp++;
	NSString *appIs = @"NONE";
	for (int z = 0; z < (int)[apps count]; z++) {
		if (place > 0) {
			if (![hidden containsObject:[apps objectAtIndex:z]] && [appIs isEqualToString:@"NONE"] && z == currentApp) {
				appIs = [apps objectAtIndex:z];
			} else if ([hidden containsObject:[apps objectAtIndex:z]] && z == currentApp)
				currentApp++;
		} else {
			if (![hidden containsObject:[apps objectAtIndex:((int)[apps count] - z - 1)]] && [appIs isEqualToString:@"NONE"] && ((int)[apps count] - z - 1) == currentApp) {
				appIs = [apps objectAtIndex:((int)[apps count] - z - 1)];
			} else if ([hidden containsObject:[apps objectAtIndex:z]] && ((int)[apps count] - z - 1) == currentApp)
				currentApp--;
		}
	}
	if ([appIs isEqualToString:@"NONE"]) {
		if (currentApp >= (int)[apps count] && place > 0)
			appIs = @"com.apple.springboard";
		else if (place  < 0) {
			for (int z = 0; z < (int)[apps count]; z++) {
				if (![hidden containsObject:[apps objectAtIndex:((int)[apps count] - z - 1)]] && [appIs isEqualToString:@"NONE"]) {
					appIs = [apps objectAtIndex:((int)[apps count] - z - 1)];
				}
			}
		}
	}
	NSLog(@"App is: %@", appIs);
	[[DSDisplayController sharedInstance] activateAppWithDisplayIdentifier:appIs animated:_animations];
	[hidden release];
	[apps release];
	[prefs release];
	_busy = NO;
}	
%new(v@:@)
- (void)releaseCIRDelegate:(id)delegate
{
	[delegate release];
}

%end

%hook SBApplication


- (void)launchSucceeded:(BOOL)unknownFlag
{
	%orig;
	if (_busy)
		return;
	if (sharedLauncher) {
		[sharedLauncher relayout];
	}
}

- (void)exitedAbnormally
{
	%orig;
	if (_busy)
		return;
	if (sharedLauncher) {
		[sharedLauncher relayout];
	}
}

- (void)exitedCommon
{
    %orig;
	if (_busy)
		return;
	if (sharedLauncher) {
		[sharedLauncher relayout];
	}
}

%end

%hook SBIconList

-(void)unscatterAnimationDidStop
{
	%orig;
	if (_becomeHomeScreen && ![[$SBAwayController sharedAwayController] isLocked]) {
		[(SpringBoard *)[UIApplication sharedApplication] showCircuitous];
	}
}

-(void)unscatter:(BOOL)unscatter startTime:(double)time
{
	%orig;
	if (_becomeHomeScreen && ![[$SBAwayController sharedAwayController] isLocked]) {
		[(SpringBoard *)[UIApplication sharedApplication] showCircuitous];
	}
}


%end

%subclass CIRCircuitousIcon : SBApplicationIcon

- (void)launch
{
	if (sharedLauncher) {
		[(SpringBoard *)[UIApplication sharedApplication] hideCircuitous];
	} else {
		[(SpringBoard *)[UIApplication sharedApplication] showCircuitous];
	}
}

- (void)completeUninstall
{
	%orig;
	_uninstalled = YES;
	[(SpringBoard *)[UIApplication sharedApplication] hideCircuitous];
	UIModalView *alert = [[UIModalView alloc] initWithTitle:@"Circuitous Uninstalled" buttons:[NSArray arrayWithObjects:@"Respring", @"Later", nil] defaultButtonIndex:0 delegate:[[CIRModalDelegate alloc] init] context:NULL];
	[alert setBodyText:@"The SpringBoard needs to respring, do you want to do it now or later?"];
	[alert setNumberOfRows:1];
	[alert popupAlertAnimated:YES];
	[alert release];
}


%end

%hook SBUIController

- (void)finishLaunching
{
	%orig;
	NSMutableDictionary *prefs = [[NSMutableDictionary alloc] initWithContentsOfFile:@"/var/mobile/Library/Preferences/com.zimm.circuitous.plist"]?:[[NSMutableDictionary alloc] init];
	if (![prefs objectForKey:@"2.2-1"]) {
		[prefs setObject:@"OK" forKey:@"2.2-1"];
		[prefs writeToFile:@"/var/mobile/Library/Preferences/com.zimm.circuitous.plist" atomically:YES];
		UIModalView *alert = [[UIModalView alloc] initWithTitle:@"Welcome to Circuitous 2.2" buttons:[NSArray arrayWithObjects:@"Settings", @"Later", nil] defaultButtonIndex:0 delegate:[[CIRModalDelegate alloc] init] context:NULL];
		[alert setBodyText:@"Go configure your preferences in the settings app. They have changed yet again, even MORE opetions!"];
		[alert setNumberOfRows:1];
		[alert popupAlertAnimated:YES];
		[alert release];
	}
	[prefs release];
}

%end

