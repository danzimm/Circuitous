//Created by DanZimm
#import "CIRLauncherView.h"
#import "CIRScrollView.h"
#import "CIRIcon.h"

@interface UIDevice (iPad)
- (BOOL)isWildcat;
@end

#define isWildcat ([[UIDevice currentDevice] respondsToSelector:@selector(isWildcat)] && [[UIDevice currentDevice] isWildcat])

static NSSet *_activeApps = nil;

@implementation CIRScrollView
@synthesize appSet;

- (id)initWithFrame:(CGRect)frame apps:(NSSet *)apps active:(BOOL)active
{
	id orig = [super initWithFrame:frame];
	float multi;
	if isWildcat
		multi = 55.0f;
	else
		multi = 40.0f;
	NSDictionary *prefs = [[NSDictionary alloc] initWithContentsOfFile:@"/var/mobile/Library/Preferences/com.zimm.circuitous.plist"];
	if (active) {
		if (_activeApps)
			[_activeApps release];
		_activeApps = [[NSSet alloc] initWithSet:apps];
	}
	appSet = [[NSSet alloc] initWithSet:apps];
	float width = 11.0f;
	int place = -1;
	_icons = [[NSMutableArray alloc] init];
	for (NSString *app in apps) {
		place++;
		CIRIcon *icon = [[CIRIcon alloc] initWithIdentifier:app andXCoor:(11.0f + (place * multi)) animations:([prefs objectForKey:@"appanimations"] ? [[prefs objectForKey:@"appanimations"] boolValue] : YES) labels:([prefs objectForKey:@"icontext"] ? [[prefs objectForKey:@"icontext"] boolValue] : YES) badges:([prefs objectForKey:@"badges"] ? [[prefs objectForKey:@"badges"] boolValue] : YES)];
		width = icon.frame.size.width + icon.frame.origin.x;
		icon.tag = place++;
		if ([_activeApps containsObject:app])
			[icon setActive];
		[self addSubview:icon];
		[_icons addObject:icon];
	}
	[prefs release];
	width = width + 11.0f;
	self.contentSize = CGSizeMake(width, self.frame.size.height);
	self.showsVerticalScrollIndicator = NO;
	self.showsHorizontalScrollIndicator = YES;
	self.scrollsToTop = NO;
	self.alwaysBounceVertical = NO;
	self.alwaysBounceHorizontal = YES;
	self.pagingEnabled = NO;
	self.scrollEnabled = YES;
	return orig;
}

- (void)dealloc
{
	for (CIRIcon *icon in _icons) {
		[_icons removeObject:icon];
		[icon removeFromSuperview];
		[icon release];
	}
	[_icons release];
	if (_activeApps) {
		[_activeApps release];
		_activeApps = nil;
	}
	[appSet release];
	[super dealloc];
}

@end