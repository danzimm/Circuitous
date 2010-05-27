//Created by DanZimm

#import "CIRLauncherHandler.h"
#import "CIRLauncherView.h"
#import "CIRBackgroundWindow.h"

#import "DSDisplayController.h"

#import <SpringBoard/SBUIController.h>
#import <SpringBoard/SpringBoard.h>

#import <objc/runtime.h>

@interface SpringBoard (iPad)
-(int)activeInterfaceOrientation;
@end

@interface UIDevice (iPad)
- (BOOL)isWildcat;
@end

#define isWildcat ([[UIDevice currentDevice] respondsToSelector:@selector(isWildcat)] && [[UIDevice currentDevice] isWildcat])

static BOOL _window = YES;
static int _transition = 0;

@implementation CIRLauncherHandler

- (id)init
{
	self = [super init];
	NSDictionary *prefs = [[NSDictionary alloc] initWithContentsOfFile:@"/var/mobile/Library/Preferences/com.zimm.circuitous.plist"];
	_window = [prefs objectForKey:@"window"] ? [[prefs objectForKey:@"window"] boolValue] : YES;
	_transition = [prefs objectForKey:@"trans"] ? [[prefs objectForKey:@"trans"] intValue] : 0;
	if (_window) {
		_backgroundWindow = [[CIRBackgroundWindow alloc] init];
		_backgroundWindow.alpha = 0.0f;
		_backgroundWindow.hidden = NO;
	} else {
		_backgroundWindow = nil;
	}
	NSArray *apps = [[DSDisplayController sharedInstance] activeApps];
	NSArray *array = [[NSArray alloc] initWithArray:(NSArray *)[prefs objectForKey:@"favorites"]];
	_mainView = [[CIRLauncherView alloc] initWithActiveApps:apps favoriteApps:array window:_backgroundWindow];
	NSLog(@"Got main view");
	[array release];
	NSLog(@"Released the array");
	_busy = NO;
	[prefs release];
	NSLog(@"released prefs");
	return self;
}

- (BOOL)animateIn
{
	if (_busy)
		return NO;
	_busy = YES;
	CGAffineTransform original = _mainView.transform;
	CGRect old;
	switch (_transition) {
		case 0:
			_mainView.alpha = 0.0f;
			_mainView.hidden = NO;
			[UIView beginAnimations:nil context:NULL];
			[UIView setAnimationDuration:0.2f];
			[UIView setAnimationDelegate:self];
			[UIView setAnimationDidStopSelector:@selector(animationDidStopIn:finished:context:)];
			_mainView.alpha = 1.0f;
			if (_window)
				_backgroundWindow.alpha = 0.5f;
			[UIView commitAnimations];
			break;
		case 1:
			[_mainView setTransform:CGAffineTransformConcat(original,CGAffineTransformMakeScale(0.1f,0.1f))];
			_mainView.hidden = NO;
			[UIView beginAnimations:nil context:NULL];
			[UIView setAnimationDuration:0.2f];
			[UIView setAnimationDelegate:self];
			[UIView setAnimationDidStopSelector:@selector(animationDidStopIn:finished:context:)];
			[_mainView setTransform:CGAffineTransformConcat(original,CGAffineTransformMakeScale(1.0f,1.0f))];
			if (_window)
				_backgroundWindow.alpha = 0.5f;
			[UIView commitAnimations];
			break;
		case 2:
			old = _mainView.frame;
			[_mainView setFrame:CGRectMake(-_mainView.frame.size.width, - _mainView.frame.size.height, _mainView.frame.size.width, _mainView.frame.size.height)];
			/*
			if ((isWildcat && _mainView.frame.origin.y > 700.0f))
				[_mainView setTransform:CGAffineTransformConcat(original,CGAffineTransformMakeTranslation(0.0f, _mainView.frame.size.height))];
			else if isWildcat
				[_mainView setTransform:CGAffineTransformConcat(original,CGAffineTransformMakeTranslation(0.0f, -_mainView.frame.size.height))];
			else if (_mainView.frame.origin.y > 300.0f)
				[_mainView setTransform:CGAffineTransformConcat(original,CGAffineTransformMakeTranslation(0.0f, _mainView.frame.size.height))];
			else
				[_mainView setTransform:CGAffineTransformConcat(original,CGAffineTransformMakeTranslation(0.0f, -_mainView.frame.size.height))];
			 */
			_mainView.hidden = NO;
			[UIView beginAnimations:nil context:NULL];
			[UIView setAnimationDuration:0.2f];
			[UIView setAnimationDelegate:self];
			[UIView setAnimationDidStopSelector:@selector(animationDidStopIn:finished:context:)];
			[_mainView setFrame:old];
			if (_window)
				_backgroundWindow.alpha = 0.5f;
			[UIView commitAnimations];
			break;
		default:
			break;
	}
	return YES;
}

- (void)animationDidStopIn:(NSString *)animationID finished:(NSNumber *)finished context:(void *)context
{
	[self stoppedRelaying];
}

- (BOOL)animateOut
{
	if (_busy)
		return NO;
	_busy = YES;
	switch (_transition) {
		case 0:
			[UIView beginAnimations:nil context:NULL];
			[UIView setAnimationDuration:0.2f];
			[UIView setAnimationDelegate:self];
			[UIView setAnimationDidStopSelector:@selector(animationDidStopOut:finished:context:)];
			_mainView.alpha = 0.0f;
			if (_window)
				_backgroundWindow.alpha = 0.0f;
			[UIView commitAnimations];
			break;
		case 1:
			[UIView beginAnimations:nil context:NULL];
			[UIView setAnimationDuration:0.1f];
			[UIView setAnimationDelegate:self];
			[UIView setAnimationDidStopSelector:@selector(animationDidStopOut:finished:context:)];
			_mainView.alpha = 0.0f;
			if (_window)
				_backgroundWindow.alpha = 0.0f;
			[UIView commitAnimations];
			break;
		case 2:
			[UIView beginAnimations:nil context:NULL];
			[UIView setAnimationDuration:0.2f];
			[UIView setAnimationDelegate:self];
			[UIView setAnimationDidStopSelector:@selector(animationDidStopOut:finished:context:)];
			/*
			if ((isWildcat && _mainView.frame.origin.y > 700.0f))
				[_mainView setTransform:CGAffineTransformConcat(original,CGAffineTransformMakeTranslation(0.0f, _mainView.frame.size.height))];
			else if isWildcat
				[_mainView setTransform:CGAffineTransformConcat(original,CGAffineTransformMakeTranslation(0.0f, -_mainView.frame.size.height))];
			else if (_mainView.frame.origin.y > 300.0f)
				[_mainView setTransform:CGAffineTransformConcat(original,CGAffineTransformMakeTranslation(0.0f, _mainView.frame.size.height))];
			else
				[_mainView setTransform:CGAffineTransformConcat(original,CGAffineTransformMakeTranslation(0.0f, -_mainView.frame.size.height))];
			 */
			[_mainView setFrame:CGRectMake(-_mainView.frame.size.width, -_mainView.frame.size.height, _mainView.frame.size.width, _mainView.frame.size.height)];
			if (_window)
				_backgroundWindow.alpha = 0.0f;
			[UIView commitAnimations];
		default:
			break;
	}
	return YES;
}

- (void)animationDidStopOut:(NSString *)animationID finished:(NSNumber *)finished context:(void *)context
{
	_mainView.hidden = YES;
	[_mainView release];
	_mainView = nil;
	if (_window) {
		_backgroundWindow.hidden = YES;
		[_backgroundWindow release];
		_backgroundWindow = nil;
	}
	_busy = NO;
}

- (BOOL)relayout
{
	if (_busy)
		return NO;
	_busy = YES;
	NSArray *apps = [[DSDisplayController sharedInstance] activeApps];
	[_mainView relayoutWithApps:apps];
	[self performSelector:@selector(stoppedRelaying) withObject:nil afterDelay:0.26f];
	return YES;
}

- (void)stoppedRelaying
{
	_busy = NO;
}

- (void)updateOrientation
{
	if isWildcat
		[_mainView reorientateWithPlace:[(SpringBoard *)[UIApplication sharedApplication] activeInterfaceOrientation]];
	else {
		switch ([(SpringBoard *)[UIApplication sharedApplication] _frontMostAppOrientation]) {
			case 0:
				[_mainView reorientateWithPlace:1];
				break;
			case 180:
				[_mainView reorientateWithPlace:2];
				break;
			case 90:
				[_mainView reorientateWithPlace:3];
				break;
			case -90:
				[_mainView reorientateWithPlace:4];
				break;
			default:
				break;
		}
	}
}

@end









