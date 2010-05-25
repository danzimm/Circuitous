//Created by DanZimm

#import <SpringBoard/SpringBoard.h>

#import "CIRCloseView.h"

#import "DSDisplayController.h"

@implementation CIRCloseView

- (id)initWithIdentifier:(NSString *)ident animations:(BOOL)animate
{
	id orig = [super initWithImage:[UIImage imageNamed:@"closebox.png"]];
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
//	[super touchesEnded:touches withEvent:event];
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