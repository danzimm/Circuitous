//Created by DanZimm
#import <SpringBoard/SBIconModel.h>
#import <SpringBoard/SBIcon.h>
#import <SpringBoard/SBIconBadge.h>
#import <SpringBoard/SpringBoard.h>
#import <SpringBoard/SBApplication.h>
#import <SpringBoard/SBApplicationController.h>
#import <SpringBoard/SBRoundedCornerView.h>

#import "DSDisplayController.h"

#import "CIRIcon.h"
#import "CIRCloseView.h"
#import "CIRScrollView.h"

#import <objc/runtime.h>
#import "UIModalView.h"

@interface SBIcon (iPad)
- (UIImage *)getIconImage:(int)image;
@end

@interface SpringBoard (PadLauncher)
- (void)showCircuitous;
- (void)hideCircuitous;
@end

@interface UIDevice (iPad)
- (BOOL)isWildcat;
@end

static BOOL horiz = NO;

#define isWildcat ([[UIDevice currentDevice] respondsToSelector:@selector(isWildcat)] && [[UIDevice currentDevice] isWildcat])

@implementation CIRIcon

+ (void)setHoriz:(BOOL)horiz1
{
	horiz = horiz1;
}

- (id)initWithIdentifier:(NSString *)ident andFrame:(CGRect)frame labelHeight:(float)height animations:(BOOL)animations labels:(BOOL)label badges:(BOOL)badge holdTime:(float)time themedIcon:(BOOL)icon
{
	holdTime = time;
	icon = YES;
	if isWildcat {
		id orig = [super initWithFrame:CGRectMake(frame.origin.x, frame.origin.y, frame.size.width, frame.size.height+height+5.0f)];
		_animate = animations;
		_identifier = [ident retain];
		if ([_identifier isEqualToString:@"com.apple.springboard"])
			_iconImage = [[UIImageView alloc] initWithImage:[UIImage imageWithContentsOfFile:[NSString stringWithFormat:@"/Applications/Circuitous.app/springboard.png"]]];
		else {
			if (icon)
				_iconImage = [[UIImageView alloc] initWithImage:[(SBIcon *)[[objc_getClass("SBIconModel") sharedInstance] iconForDisplayIdentifier:ident] getIconImage:2]];
			else {
				_iconImage = [[UIImageView alloc] initWithImage:[(SBIcon *)[[objc_getClass("SBIconModel") sharedInstance] iconForDisplayIdentifier:ident] getIconImage:1]];
			}
		}
		_iconImage.frame = CGRectMake(0.0f, 5.0f, frame.size.width, frame.size.height);
		[self addSubview:_iconImage];
		if (label) {
			_iconName = [[UILabel alloc] initWithFrame:CGRectMake(0.0f, frame.size.height + 5.0f, frame.size.width, height)];
			_iconName.font = [UIFont systemFontOfSize:height];
			_iconName.text = [[[objc_getClass("SBIconModel") sharedInstance] iconForDisplayIdentifier:ident] displayName];
			_iconName.backgroundColor = [UIColor clearColor];
			_iconName.textColor = [UIColor whiteColor];
			_iconName.textAlignment = UITextAlignmentCenter;
			_iconName.adjustsFontSizeToFitWidth = YES;
			[self addSubview:_iconName];
		}
		if (((int)[(SBIcon *)[[objc_getClass("SBIconModel") sharedInstance] iconForDisplayIdentifier:ident] badgeValue] != 0) && badge) {
			_badge = [[objc_getClass("SBIconBadge") alloc] initWithBadge:[NSString stringWithFormat:@"%d", [(SBIcon *)[[objc_getClass("SBIconModel") sharedInstance] iconForDisplayIdentifier:ident] badgeValue]]];
			_badge.center = CGPointMake(_iconImage.frame.size.width,7.5f);
			[self addSubview:_badge];
		} else
			_badge = nil;
		_iconClose = nil;
		_bgBadge = nil;
		return orig;
	} else {
		id orig = [super initWithFrame:CGRectMake(frame.origin.x, frame.origin.y, frame.size.width, frame.size.height+height+5.0f)];
		_animate = animations;
		_identifier = [ident retain];
		if ([_identifier isEqualToString:@"com.apple.springboard"])
			_iconImage = [[UIImageView alloc] initWithImage:[UIImage imageWithContentsOfFile:[NSString stringWithFormat:@"/Applications/Circuitous.app/springboard-phone.png"]]];
		else {
			if (icon)
				_iconImage = [[UIImageView alloc] initWithImage:[(SBIcon *)[[objc_getClass("SBIconModel") sharedInstance] iconForDisplayIdentifier:ident] icon]];
			else {
				_iconImage = [[UIImageView alloc] initWithImage:[(SBIcon *)[[objc_getClass("SBIconModel") sharedInstance] iconForDisplayIdentifier:ident] smallIcon]];
			}
		}
		_iconImage.frame = CGRectMake(0.0f, 5.0f, frame.size.width, frame.size.height);
		[self addSubview:_iconImage];
		if (label) {
			_iconName = [[UILabel alloc] initWithFrame:CGRectMake(0.0f, frame.size.height, frame.size.width, height)];
			_iconName.font = [UIFont systemFontOfSize:height];
			_iconName.text = [[[objc_getClass("SBIconModel") sharedInstance] iconForDisplayIdentifier:ident] displayName];
			_iconName.backgroundColor = [UIColor clearColor];
			_iconName.textColor = [UIColor whiteColor];
			_iconName.textAlignment = UITextAlignmentCenter;
			_iconName.adjustsFontSizeToFitWidth = YES;
			[self addSubview:_iconName];
		}
		if (((int)[(SBIcon *)[[objc_getClass("SBIconModel") sharedInstance] iconForDisplayIdentifier:ident] badgeValue] != 0) && badge) {
			_badge = [[objc_getClass("SBIconBadge") alloc] initWithBadge:[NSString stringWithFormat:@"%d", [(SBIcon *)[[objc_getClass("SBIconModel") sharedInstance] iconForDisplayIdentifier:ident] badgeValue]]];
			_badge.center = CGPointMake(_iconImage.frame.size.width,7.5f);
			[self addSubview:_badge];
		} else
			_badge = nil;
		_iconClose = nil;
		_bgBadge = nil;
		return orig;
	}
}


- (void)setActive
{
	_iconClose = [[CIRCloseView alloc] initWithIdentifier:_identifier animations:_animate];
	if (horiz) {
		_iconClose.center = CGPointMake(0.0f, 7.5f);
	} else {
		_iconClose.center = CGPointMake(2.5f, 7.5f);
	}
	[self addSubview:_iconClose];
}

- (void)setActiveWithoutBox
{
	_iconClose = [[CIRCloseView alloc] initWithIdentifier:_identifier animations:_animate];
}

- (void)setBackgrounderBadge
{
	UIImage *image = [UIImage imageWithContentsOfFile:@"/System/Library/CoreServices/SpringBoard.app/Backgrounder_Badge.png"];
	if (image) {
		_bgBadge = [[UIImageView alloc] initWithImage:image];
		_bgBadge.center = CGPointMake(CGRectGetMaxX(_iconImage.frame) - 5.0f, CGRectGetMaxY(_iconImage.frame) - 5.0f);
		[self addSubview:_bgBadge];
	}
}

- (NSString *)identifier
{
	return _identifier;
}

static CGPoint _start;

- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event
{
	[UIView beginAnimations:nil context:NULL];
	self.alpha = 0.5f;
	[UIView commitAnimations];
	UITouch *touch = [touches anyObject];
	_start = [touch locationInView:self];
	oldCenter = self.center;
	if (_iconClose)
		_holdTimer = [NSTimer scheduledTimerWithTimeInterval:holdTime/1 target:self selector:@selector(timerFired:) userInfo:nil repeats:NO];
}

- (void)timerFired:(NSTimer *)timer
{
	[_holdTimer invalidate];
	_holdTimer = nil;
	[UIView beginAnimations:nil context:NULL];
	[self setTransform:CGAffineTransformMakeScale(1.25f, 1.25f)];
	[self setAlpha:0.85f];
	[[self superview] bringSubviewToFront:self];
	[(UIScrollView *)[self superview] setScrollEnabled:NO];
	[UIView commitAnimations];
}

- (void)touchesMoved:(NSSet *)touches withEvent:(UIEvent *)event
{
	UITouch *touch = [touches anyObject];
	CGPoint currentPosition = [touch locationInView:[self superview]];
	if (_holdTimer || (!_holdTimer && !_iconClose)) {
		int kMinimumGestureLength = 3.0f;
		int kMaximumVariance = 200.0f;
		CGFloat deltaX = fabsf(_start.x - currentPosition.x);
		CGFloat deltaY = fabsf(_start.y - currentPosition.y);
		
		// left gesture
		if (_start.x > currentPosition.x && deltaY <= kMaximumVariance && deltaX >= kMinimumGestureLength) {
			self.alpha = 1.0f;
		}
			// right gesture
		else if (_start.x < currentPosition.x && deltaY <= kMaximumVariance && deltaX >= kMinimumGestureLength) {
			self.alpha = 1.0f;
		}// up gesture
		else if (_start.y > currentPosition.y && deltaX <= kMaximumVariance && deltaY >= kMinimumGestureLength) {
			self.alpha = 1.0f;
		}
		// down gesture
		else if (_start.y < currentPosition.y && deltaX <= kMaximumVariance && deltaY >= kMinimumGestureLength) {
			self.alpha = 1.0f;
		}
	} else {
		if (horiz)
			self.center = CGPointMake(self.center.x, currentPosition.y);
		else
			self.center = CGPointMake(currentPosition.x, self.center.y);
	}
}

- (void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event
{
	UITouch *touch = [touches anyObject];
	self.alpha = 1.0f;
	if (_holdTimer || (!_holdTimer && !_iconClose)) {
		[_holdTimer invalidate];
		_holdTimer = nil;
		if (_iconClose) {
			float size;
			if isWildcat
				size = 30.0f;
			else
				size = 20.0f;
			if (!CGRectContainsPoint(CGRectMake(-10.0f, -10.0f, size, size), [touch locationInView:self])) {
				[[DSDisplayController sharedInstance] setBackgroundingEnabled:YES forApplication:[[DSDisplayController sharedInstance] activeApp]];
				[[DSDisplayController sharedInstance] activateAppWithDisplayIdentifier:_identifier animated:_animate];
				[(SpringBoard *)[UIApplication sharedApplication] hideCircuitous];
			} else {
				[_iconClose animate];
				if ([_identifier isEqualToString:@"com.apple.springboard"])
					[(SpringBoard *)[UIApplication sharedApplication] relaunchSpringBoard];
				[[DSDisplayController sharedInstance] setBackgroundingEnabled:NO forDisplayIdentifier:_identifier];
				[[DSDisplayController sharedInstance] exitAppWithDisplayIdentifier:_identifier animated:_animate force:YES];
			}
		} else {
			[[DSDisplayController sharedInstance] setBackgroundingEnabled:YES forApplication:[[DSDisplayController sharedInstance] activeApp]];
			[[DSDisplayController sharedInstance] activateAppWithDisplayIdentifier:_identifier animated:_animate];
			[(SpringBoard *)[UIApplication sharedApplication] hideCircuitous];
		}
	} else {
		if (((self.center.y < 0.0f || self.center.y > [self superview].frame.size.height) && horiz) || ((self.center.x < 0.0f || self.center.x > [self superview].frame.size.width) && !horiz)) {
			if ([_identifier isEqualToString:@"com.apple.springboard"])
				[(SpringBoard *)[UIApplication sharedApplication] relaunchSpringBoard];
			[[DSDisplayController sharedInstance] setBackgroundingEnabled:NO forDisplayIdentifier:_identifier];
			[[DSDisplayController sharedInstance] exitAppWithDisplayIdentifier:_identifier animated:_animate force:YES];
		} else {
			[UIView beginAnimations:nil context:NULL];
			self.center = oldCenter;
			[self setTransform:CGAffineTransformMakeScale(1.0f, 1.0f)];
			[self setAlpha:1.0f];
			[(UIScrollView *)[self superview] setScrollEnabled:YES];
			[UIView commitAnimations];
		}
	}
}

- (void)removeBackgrounderBadge
{
	if (!_bgBadge)
		return;
	[_bgBadge removeFromSuperview];
	[_bgBadge release];
	_bgBadge = nil;
}

- (void)removeIsActive
{
	if (!_iconClose)
		return;
	[_iconClose removeFromSuperview];
	[_iconClose release];
	_iconClose = nil;
}

- (void)dealloc
{
	[_identifier release];
	[super dealloc];
}

@end