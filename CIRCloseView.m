//Created by DanZimm

#import <SpringBoard/SpringBoard.h>

#import "CIRCloseView.h"

#import "DSDisplayController.h"

@interface UIDevice (iPad)
- (BOOL)isWildcat;
@end

#define isWildcat ([[UIDevice currentDevice] respondsToSelector:@selector(isWildcat)] && [[UIDevice currentDevice] isWildcat])

@implementation CIRCloseView

- (id)initWithIdentifier:(NSString *)ident animations:(BOOL)animate
{
	id orig;
	if isWildcat {
		orig = [super initWithImage:[UIImage imageWithContentsOfFile:@"/Applications/Circuitous.app/closebox-ipad.png"]];
	} else {
		orig = [super initWithImage:[UIImage imageWithContentsOfFile:@"/Applications/Circuitous.app/closebox-iphone.png"]];
	}
	_animate = animate;
	self.userInteractionEnabled = YES;
	_identifier = [ident retain];
	_activity = nil;
	return orig;
}

- (NSString *)identifier
{
	return _identifier;
}

- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event
{
	if (!_activity) {
		[self setImage:nil];
		_activity = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleGray];
		[self addSubview:_activity];
		[_activity startAnimating];
	}
	if ([_identifier isEqualToString:@"com.apple.springboard"])
		[(SpringBoard *)[UIApplication sharedApplication] relaunchSpringBoard];
	[[DSDisplayController sharedInstance] setBackgroundingEnabled:NO forDisplayIdentifier:_identifier];
	[[DSDisplayController sharedInstance] exitAppWithDisplayIdentifier:_identifier animated:_animate force:YES];
}

- (void)dealloc
{
	[_identifier release];
	[super dealloc];
}

- (void)animate
{
	if (!_activity) {
		[self setImage:nil];
		_activity = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleGray];
		[self addSubview:_activity];
		[_activity startAnimating];
	}
}

@end