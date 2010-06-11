//Created by DanZimm
#import "CIRLauncherView.h"
#import "CIRScrollViewHandler.h"
#import "CIRIcon.h"

#import "DSDisplayController.h"

@interface UIDevice (iPad)
- (BOOL)isWildcat;
@end

#define isWildcat ([[UIDevice currentDevice] respondsToSelector:@selector(isWildcat)] && [[UIDevice currentDevice] isWildcat])

static BOOL horiz = YES;

static NSMutableArray *_activeApps = nil;

@implementation CIRScrollViewHandler
@synthesize apps;

- (id)initWithFrame:(CGRect)frame apps:(NSArray *)apps2 active:(BOOL)active
{
	horiz = YES;
	[CIRIcon setHoriz:horiz];
	isActive = active;
	id orig = [super init];
	_mainScroll = [[CIRScrollView alloc] initWithFrame:frame handler:self];
	_icons = [[NSMutableArray alloc] init];
	NSDictionary *prefs = [[NSDictionary alloc] initWithContentsOfFile:@"/var/mobile/Library/Preferences/com.zimm.circuitous.plist"];
	if (active) {
		if (_activeApps)
			[_activeApps release];
		NSArray *apps1 = [[DSDisplayController sharedInstance] activeApps];
		_activeApps = [[NSMutableArray alloc] initWithArray:apps1];
		[apps1 release];
		if ([prefs objectForKey:@"springboardquit"] ? [[prefs objectForKey:@"springboardquit"] boolValue] : YES)
			[_activeApps addObject:@"com.apple.springboard"];
	}
	holdTime = [prefs objectForKey:@"holdtime"] ? [[prefs objectForKey:@"holdtime"] floatValue] : 0.5f;
	BOOL closeBox = [prefs objectForKey:@"close"] ? [[prefs objectForKey:@"close"] boolValue] : YES;
	BOOL backgrounderBadge = [prefs objectForKey:@"backgrounderbadge"] ? [[prefs objectForKey:@"backgrounderbadge"] boolValue] : YES;
	float iconWidth;
	if isWildcat
		iconWidth = [prefs objectForKey:@"iconwidth"] ? [[prefs objectForKey:@"iconwidth"] floatValue] : 74.0f;
	else
		iconWidth = [prefs objectForKey:@"iconwidth"] ? [[prefs objectForKey:@"iconwidth"] floatValue] : 57.0f;
	float iconHeight;
	if isWildcat
		iconHeight = [prefs objectForKey:@"iconheight"] ? [[prefs objectForKey:@"iconheight"] floatValue] : 78.0f;
	else
		iconHeight = [prefs objectForKey:@"iconheight"] ? [[prefs objectForKey:@"iconheight"] floatValue] : 57.0f;	
	float lblheight;
	if isWildcat
		lblheight = [prefs objectForKey:@"labelheight"] ? [[prefs objectForKey:@"labelheight"] floatValue] : 16.0f;
	else
		lblheight = [prefs objectForKey:@"labelheight"] ? [[prefs objectForKey:@"labelheight"] floatValue] : 12.0f;	
	float padding;
	if isWildcat
		padding = [prefs objectForKey:@"padding"] ? [[prefs objectForKey:@"padding"] floatValue] : 95.0f;
	else
		padding = [prefs objectForKey:@"padding"] ? [[prefs objectForKey:@"padding"] floatValue] : 72.0f;
	apps = [[NSMutableArray alloc] initWithArray:apps2];
	float width = 11.0f;
	int place = -1;
	for (NSString *app in apps) {
		place++;
		CIRIcon *icon = [[CIRIcon alloc] initWithIdentifier:app andFrame:CGRectMake((11.0f + (place * padding)),5.0f, iconWidth, iconHeight) labelHeight:lblheight animations:([prefs objectForKey:@"appanimations"] ? [[prefs objectForKey:@"appanimations"] boolValue] : YES) labels:([prefs objectForKey:@"icontext"] ? [[prefs objectForKey:@"icontext"] boolValue] : YES) badges:([prefs objectForKey:@"badges"] ? [[prefs objectForKey:@"badges"] boolValue] : YES) holdTime:holdTime themedIcon:([prefs objectForKey:@"themeicons"] ? [[prefs objectForKey:@"themeicons"] boolValue] : YES)];
		width = icon.frame.size.width + icon.frame.origin.x;
		if ([_activeApps containsObject:app] && closeBox)
			[icon setActive];
		else if ([_activeApps containsObject:app])
			[icon setActiveWithoutBox];
		if (backgrounderBadge && [_activeApps containsObject:app])
			[icon setBackgrounderBadge];
		[_mainScroll addSubview:icon];
		[_icons addObject:icon];
	}
	[prefs release];
	width = width + 11.0f;
	_mainScroll.contentSize = CGSizeMake(width, _mainScroll.frame.size.height);
	_mainScroll.showsVerticalScrollIndicator = NO;
	_mainScroll.showsHorizontalScrollIndicator = YES;
	_mainScroll.scrollsToTop = NO;
	_mainScroll.alwaysBounceVertical = NO;
	_mainScroll.alwaysBounceHorizontal = YES;
	_mainScroll.pagingEnabled = NO;
	_mainScroll.scrollEnabled = YES;
	return orig;
}

- (id)initWithFrameVertically:(CGRect)frame apps:(NSArray *)apps2 active:(BOOL)active
{
	horiz = NO;
	[CIRIcon setHoriz:horiz];
	isActive = active;
	id orig = [super init];
	_mainScroll = [[CIRScrollView alloc] initWithFrame:frame handler:self];
	NSDictionary *prefs = [[NSDictionary alloc] initWithContentsOfFile:@"/var/mobile/Library/Preferences/com.zimm.circuitous.plist"];
	if (active) {
		if (_activeApps)
			[_activeApps release];
		NSArray *apps1 = [[DSDisplayController sharedInstance] activeApps];
		_activeApps = [[NSMutableArray alloc] initWithArray:apps1];
		[apps1 release];
		if ([prefs objectForKey:@"springboardquit"] ? [[prefs objectForKey:@"springboardquit"] boolValue] : YES)
			[_activeApps addObject:@"com.apple.springboard"];
	}
	holdTime = [prefs objectForKey:@"holdtime"] ? [[prefs objectForKey:@"holdtime"] floatValue] : 0.5f;
	BOOL closeBox = [prefs objectForKey:@"close"] ? [[prefs objectForKey:@"close"] boolValue] : YES;
	BOOL backgrounderBadge = [prefs objectForKey:@"backgrounderbadge"] ? [[prefs objectForKey:@"backgrounderbadge"] boolValue] : YES;
	float iconWidth;
	if isWildcat
		iconWidth = [prefs objectForKey:@"iconwidth"] ? [[prefs objectForKey:@"iconwidth"] floatValue] : 74.0f;
	else
		iconWidth = [prefs objectForKey:@"iconwidth"] ? [[prefs objectForKey:@"iconwidth"] floatValue] : 57.0f;
	float iconHeight;
	if isWildcat
		iconHeight = [prefs objectForKey:@"iconheight"] ? [[prefs objectForKey:@"iconheight"] floatValue] : 78.0f;
	else
		iconHeight = [prefs objectForKey:@"iconheight"] ? [[prefs objectForKey:@"iconheight"] floatValue] : 57.0f;
	float lblheight;
	if isWildcat
		lblheight = [prefs objectForKey:@"labelheight"] ? [[prefs objectForKey:@"labelheight"] floatValue] : 16.0f;
	else
		lblheight = [prefs objectForKey:@"labelheight"] ? [[prefs objectForKey:@"labelheight"] floatValue] : 12.0f;	
	float padding;
	if isWildcat
		padding = [prefs objectForKey:@"padding"] ? [[prefs objectForKey:@"padding"] floatValue] : 95.0f;
	else
		padding = [prefs objectForKey:@"padding"] ? [[prefs objectForKey:@"padding"] floatValue] : 72.0f;
	apps = [[NSMutableArray alloc] initWithArray:apps2];
	float width = 11.0f;
	int place = -1;
	for (NSString *app in apps) {
		place++;
		CIRIcon *icon = [[CIRIcon alloc] initWithIdentifier:app andFrame:CGRectMake(7.5f,(11.0f + (place * padding)), iconWidth, iconHeight) labelHeight:lblheight animations:([prefs objectForKey:@"appanimations"] ? [[prefs objectForKey:@"appanimations"] boolValue] : YES) labels:([prefs objectForKey:@"icontext"] ? [[prefs objectForKey:@"icontext"] boolValue] : YES) badges:([prefs objectForKey:@"badges"] ? [[prefs objectForKey:@"badges"] boolValue] : YES) holdTime:holdTime themedIcon:([prefs objectForKey:@"themeicons"] ? [[prefs objectForKey:@"themeicons"] boolValue] : YES)];
		width = icon.frame.size.height + icon.frame.origin.y;
		if ([_activeApps containsObject:app] && closeBox)
			[icon setActive];
		else if ([_activeApps containsObject:app])
			[icon setActiveWithoutBox];
		if (backgrounderBadge && [_activeApps containsObject:app])
			[icon setBackgrounderBadge];
		[_mainScroll addSubview:icon];
		[_icons addObject:icon];
	}
	[prefs release];
	width = width + 11.0f;
	_mainScroll.contentSize = CGSizeMake(_mainScroll.frame.size.width, width);
	_mainScroll.showsVerticalScrollIndicator = YES;
	_mainScroll.showsHorizontalScrollIndicator = NO;
	_mainScroll.scrollsToTop = NO;
	_mainScroll.alwaysBounceVertical = YES;
	_mainScroll.alwaysBounceHorizontal = NO;
	_mainScroll.pagingEnabled = NO;
	_mainScroll.scrollEnabled = YES;
	return orig;
}

- (UIView *)view
{
	return _mainScroll;
}

- (void)moveApp:(CIRIcon *)app place:(int)place
{
	NSDictionary *prefs = [[NSDictionary alloc] initWithContentsOfFile:@"/var/mobile/Library/Preferences/com.zimm.circuitous.plist"];
	float padding;
	if isWildcat
		padding = [prefs objectForKey:@"padding"] ? [[prefs objectForKey:@"padding"] floatValue] : 95.0f;
	else
		padding = [prefs objectForKey:@"padding"] ? [[prefs objectForKey:@"padding"] floatValue] : 72.0f;	
	[prefs release];
	int place1 = -1;
	int where = 0;
	for (CIRIcon *icon in _icons) {
		place1++;
		if ([icon isEqual:app])
			where = place1;
	}
	if ((where == 0 && place < 0) || (where == ((int)[_icons count] - 1) && place > 0))
		return;
	if (place > 0) {
		CIRIcon *move = [_icons objectAtIndex:(where + 1)];
		if (horiz)
			[move setFrame:CGRectMake(move.frame.origin.x - padding, move.frame.origin.y, move.frame.size.width, move.frame.size.height)];
		else
			[move setFrame:CGRectMake(move.frame.origin.x, move.frame.origin.y - padding, move.frame.size.width, move.frame.size.height)];
	} else {
		CIRIcon *move = [_icons objectAtIndex:(where - 1)];
		if (horiz)
			[move setFrame:CGRectMake(move.frame.origin.x + padding, move.frame.origin.y, move.frame.size.width, move.frame.size.height)];
		else
			[move setFrame:CGRectMake(move.frame.origin.x, move.frame.origin.y + padding, move.frame.size.width, move.frame.size.height)];
	}
}												

- (void)dealloc
{
	if (_activeApps) {
		[_activeApps release];
		_activeApps = nil;
	}
	[_mainScroll release];
	[apps release];
	[super dealloc];
}

@end