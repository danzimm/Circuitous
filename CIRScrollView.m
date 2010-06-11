//Created by DanZimm

#import <SpringBoard/SpringBoard.h>

#import "CIRScrollView.h"

#import "DSDisplayController.h"

@interface UIDevice (iPad)
- (BOOL)isWildcat;
@end

#define isWildcat ([[UIDevice currentDevice] respondsToSelector:@selector(isWildcat)] && [[UIDevice currentDevice] isWildcat])

@implementation CIRScrollView
@synthesize _handler;

- (id)initWithFrame:(CGRect)frame handler:(id)handler
{
	id orig = [super initWithFrame:frame];
	_handler = handler;
	return orig;
}

@end