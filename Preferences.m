#import "PSViewController.h"
#import "PSListController.h"

#import <CoreGraphics/CGGeometry.h>
#import <QuartzCore/CALayer.h>
#import <CoreFoundation/CFPreferences.h>
#import <Foundation/Foundation.h>
#import "UIModalView.h"

#import <objc/runtime.h>

@interface PSViewController (iPhone)
- (id)initForContentSize:(CGSize)size;
- (void)viewWillBecomeVisible:(void*)source;
-(void)showLeftButton:(id)button withStyle:(int)style rightButton:(id)button3 withStyle:(int)style4;
-(void)navigationBarButtonClicked:(int)clicked;
- (void)pushNavigationItem:(id)item;
@end

@interface UITableView (tabview)
- (BOOL)editing;
@end

@interface UIDevice (iPad)
- (BOOL)isWildcat;
@end

#define isWildcat ([[UIDevice currentDevice] respondsToSelector:@selector(isWildcat)] && [[UIDevice currentDevice] isWildcat])

@interface CIRApplicationCell : UITableViewCell {
	
}

@end


@implementation CIRApplicationCell
- (void)layoutSubviews
{
    [super layoutSubviews];
	
    // Resize icon image
    CGSize size = self.bounds.size;
    self.imageView.frame = CGRectMake(4.0f, 4.0f, size.height - 8.0f, size.height - 8.0f);
    self.imageView.contentMode = UIViewContentModeScaleAspectFit;
}

@end

extern NSString * SBSCopyLocalizedApplicationNameForDisplayIdentifier(NSString *identifier);
extern NSString * SBSCopyIconImagePathForDisplayIdentifier(NSString *identifier);

@interface CIRPreferencesController : PSViewController <UITableViewDelegate, UITableViewDataSource> {
	UITableView *_tableView;
	NSMutableArray *systemApps;
	NSMutableArray *appStoreApps;
	NSMutableArray *applicationsHere;
	int _use;
	UITextView *_tutorial;
	BOOL _wide;
	BOOL _double;
	BOOL _favs;
	BOOL _mega;
	int _transition;
	int _quitIt;
	int _backgroundIt;
	int _cycleIt;
	int _reverseIt;
	int _randomIt;
	CGSize sizeIs;
	int _place;
	NSString *_currentTheme;
	NSMutableArray *_themes;
	float iconWidth;
	float iconHeight;
	float lblHeight;
	float padding;
	UISlider *slider;
	UISlider *slider1;
	UISlider *slider2;
	UISlider *slider3;
	UILabel *valueLbl;
	UILabel *valueLbl1;
	UILabel *valueLbl2;
	UILabel *valueLbl3;
	BOOL added;
	BOOL added1;
	BOOL added2;
	BOOL added3;
}
- (id) view;
- (NSString *) navigationTitle;
- (id)_tableView;
- (int) numberOfSectionsInTableView:(UITableView *)tableView;
- (id) tableView:(UITableView *)tableView titleForHeaderInSection:(int)section;
- (int) tableView:(UITableView *)tableView numberOfRowsInSection:(int)section;
- (id) tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath;
- (void) tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath;
- (void)setNavigationTitle:(NSString *)navigationTitle;
- (void)loadFromSpecifier:(PSSpecifier *)specifier;
- (void)buttonTapped:(UIButton *)button;
@end

@implementation CIRPreferencesController

- (id)initForContentSize:(CGSize)size
{
	sizeIs = size;
	return [self init];
}

- (id)init
{
	 if ((self = [super init]) != nil) {
	 }
	return self;
}

- (void)viewWillBecomeVisible:(void *)source
{
	if (source)
		[self loadFromSpecifier:(PSSpecifier *)source];
	[super viewWillBecomeVisible:source];
}

- (void)setSpecifier:(PSSpecifier *)specifier
{
	[self loadFromSpecifier:specifier];
	[super setSpecifier:specifier];
}

- (void)loadFromSpecifier:(PSSpecifier *)specifier
{
	_use = [[specifier propertyForKey:@"use"] intValue];
	NSDictionary *dict = [[NSDictionary alloc] initWithContentsOfFile:@"/var/mobile/Library/Preferences/com.zimm.circuitous.plist"];
	_tutorial = nil;
	applicationsHere = nil;
	systemApps = nil;
	appStoreApps = nil;
	_themes = nil;
	_tableView = nil;
	_currentTheme = nil;
	NSMutableArray *identifiers;
	NSMutableArray *paths;
	NSFileManager *fileManager;
	switch (_use) {
		case 0:
			systemApps = [[NSMutableArray alloc] init];
			paths = [NSMutableArray array];
			
			// ... scan /Applications (System/Jailbreak applications)
			fileManager = [NSFileManager defaultManager];
			for (NSString *path in [fileManager directoryContentsAtPath:@"/Applications"]) {
				if ([path hasSuffix:@".app"] && ![path hasPrefix:@"."])
					[paths addObject:[NSString stringWithFormat:@"/Applications/%@", path]];
			}
			identifiers = [NSMutableArray array];
			
			for (NSString *path in paths) {
				NSBundle *bundle = [NSBundle bundleWithPath:path];
				if (bundle) {
					NSString *identifier = [bundle bundleIdentifier];
					if (isWildcat || [[[UIDevice currentDevice] model] isEqualToString:@"iPod touch"]) {
						if ([[bundle bundleIdentifier] isEqualToString:@"com.apple.mobileipod"]) {
							[identifiers addObject:@"com.apple.mobileipod-AudioPlayer"];
							[identifiers addObject:@"com.apple.mobileipod-VideoPlayer"];
							identifier = nil;
						} else if ([[bundle bundleIdentifier] isEqualToString:@"com.apple.mobileslideshow"]) {
							[identifiers addObject:@"com.apple.mobileslideshow-Photos"];
							
							identifier = nil;
						}
					} else {
						if ([[bundle bundleIdentifier] isEqualToString:@"com.apple.mobileipod"]) {
							[identifiers addObject:@"com.apple.mobileipod-MediaPlayer"];
							identifier = nil;
						} else if ([[bundle bundleIdentifier] isEqualToString:@"com.apple.mobileslideshow"]) {
							[identifiers addObject:@"com.apple.mobileslideshow-Photos"];
							[identifiers addObject:@"com.apple.mobileslideshow-Camera"];
							identifier = nil;
						}
					}
					// Filter out non-applications and apps that should remain hidden
					// FIXME: The proper fix is to only show non-hidden apps and apps
					//        that are in Categories; unfortunately, the design of
					//        Categories does not make it easy to determine what apps
					//        a given folder contains.
					if (identifier &&
						![identifier hasPrefix:@"jp.ashikase.springjumps."] &&
						![identifier isEqualToString:@"com.apple.webapp"])
						[identifiers addObject:identifier];
				}
			}
			[systemApps setArray:identifiers];
			[identifiers removeAllObjects];
			[paths removeAllObjects];
			appStoreApps = [[NSMutableArray alloc] init];
			for (NSString *path in [fileManager directoryContentsAtPath:@"/var/mobile/Applications"]) {
				for (NSString *subpath in [fileManager directoryContentsAtPath:
										   [NSString stringWithFormat:@"/var/mobile/Applications/%@", path]]) {
					if ([subpath hasSuffix:@".app"])
						[paths addObject:[NSString stringWithFormat:@"/var/mobile/Applications/%@/%@", path, subpath]];
				}
			}
			for (NSString *path in paths) {
				NSBundle *bundle = [NSBundle bundleWithPath:path];
				if (bundle) {
					NSString *identifier = [bundle bundleIdentifier];
					// Filter out non-applications and apps that should remain hidden
					// FIXME: The proper fix is to only show non-hidden apps and apps
					//        that are in Categories; unfortunately, the design of
					//        Categories does not make it easy to determine what apps
					//        a given folder contains.
					if (identifier &&
						![identifier hasPrefix:@"jp.ashikase.springjumps."] &&
						![identifier isEqualToString:@"com.apple.webapp"])
						[identifiers addObject:identifier];
				}
			}
			[appStoreApps setArray:identifiers];
			_tableView = [[UITableView alloc] initWithFrame:CGRectMake(0, 0, 320, 480-64) style:UITableViewStyleGrouped];
			[_tableView setDataSource:self];
			[_tableView setDelegate:self];
			applicationsHere = [[NSMutableArray alloc] initWithArray:(NSArray *)[dict objectForKey:@"favorites"]];
			UIButton *button = [UIButton buttonWithType:UIButtonTypeRoundedRect];
			button.selected = NO;
			[button setTitle:@"Edit" forState:UIControlStateNormal];
			[button setTitle:@"Done" forState:UIControlStateSelected];
			button.frame = CGRectMake(0.0f,0.0f,_tableView.frame.size.width, 40.0f);
			[button addTarget:self action:@selector(buttonTapped:) forControlEvents:UIControlEventTouchDown];
			_tableView.tableHeaderView = button;
			break;
		case 1:
			systemApps = [[NSMutableArray alloc] init];
			paths = [NSMutableArray array];
			
			// ... scan /Applications (System/Jailbreak applications)
			fileManager = [NSFileManager defaultManager];
			for (NSString *path in [fileManager directoryContentsAtPath:@"/Applications"]) {
				if ([path hasSuffix:@".app"] && ![path hasPrefix:@"."])
					[paths addObject:[NSString stringWithFormat:@"/Applications/%@", path]];
			}
			identifiers = [NSMutableArray array];
			
			for (NSString *path in paths) {
				NSBundle *bundle = [NSBundle bundleWithPath:path];
				if (bundle) {
					NSString *identifier = [bundle bundleIdentifier];
					if (isWildcat || [[[UIDevice currentDevice] model] isEqualToString:@"iPod touch"]) {
						if ([[bundle bundleIdentifier] isEqualToString:@"com.apple.mobileipod"]) {
							[identifiers addObject:@"com.apple.mobileipod-AudioPlayer"];
							[identifiers addObject:@"com.apple.mobileipod-VideoPlayer"];
							identifier = nil;
						} else if ([[bundle bundleIdentifier] isEqualToString:@"com.apple.mobileslideshow"]) {
							[identifiers addObject:@"com.apple.mobileslideshow-Photos"];
							
							identifier = nil;
						}
					} else {
						if ([[bundle bundleIdentifier] isEqualToString:@"com.apple.mobileipod"]) {
							[identifiers addObject:@"com.apple.mobileipod-MediaPlayer"];
							identifier = nil;
						} else if ([[bundle bundleIdentifier] isEqualToString:@"com.apple.mobileslideshow"]) {
							[identifiers addObject:@"com.apple.mobileslideshow-Photos"];
							[identifiers addObject:@"com.apple.mobileslideshow-Camera"];
							identifier = nil;
						}
					}
					// Filter out non-applications and apps that should remain hidden
					// FIXME: The proper fix is to only show non-hidden apps and apps
					//        that are in Categories; unfortunately, the design of
					//        Categories does not make it easy to determine what apps
					//        a given folder contains.
					if (identifier &&
						![identifier hasPrefix:@"jp.ashikase.springjumps."] &&
						![identifier isEqualToString:@"com.apple.webapp"])
						[identifiers addObject:identifier];
				}
			}
			[systemApps setArray:identifiers];
			[identifiers removeAllObjects];
			[paths removeAllObjects];
			appStoreApps = [[NSMutableArray alloc] init];
			for (NSString *path in [fileManager directoryContentsAtPath:@"/var/mobile/Applications"]) {
				for (NSString *subpath in [fileManager directoryContentsAtPath:
										   [NSString stringWithFormat:@"/var/mobile/Applications/%@", path]]) {
					if ([subpath hasSuffix:@".app"])
						[paths addObject:[NSString stringWithFormat:@"/var/mobile/Applications/%@/%@", path, subpath]];
				}
			}
			for (NSString *path in paths) {
				NSBundle *bundle = [NSBundle bundleWithPath:path];
				if (bundle) {
					NSString *identifier = [bundle bundleIdentifier];
					// Filter out non-applications and apps that should remain hidden
					// FIXME: The proper fix is to only show non-hidden apps and apps
					//        that are in Categories; unfortunately, the design of
					//        Categories does not make it easy to determine what apps
					//        a given folder contains.
					if (identifier &&
						![identifier hasPrefix:@"jp.ashikase.springjumps."] &&
						![identifier isEqualToString:@"com.apple.webapp"])
						[identifiers addObject:identifier];
				}
			}
			[appStoreApps setArray:identifiers];
			_tableView = [[UITableView alloc] initWithFrame:CGRectMake(0, 0, 320, 480-64) style:UITableViewStyleGrouped];
			[_tableView setDataSource:self];
			[_tableView setDelegate:self];
			applicationsHere = [[NSMutableArray alloc] initWithArray:(NSArray *)[dict objectForKey:@"hidden"]];	
			break;
		case 2:
			_tutorial = [[UITextView alloc] initWithFrame:CGRectMake(0, 0, 320, 480-64)];
			if isWildcat
				_tutorial.text = @"Welcome to Circuitous! \n\nNOTE: BACKGROUNDER MUST BE INSTALLED TO HAVE APPS RUN IN THE BACKGROUND\n\nDock Activation: Set your activator method to activate the dock with your currently running applications, and, if you choose, your favorite applications as well.\n\nCycler Activator: Cycles through your open apps.\n\nReverse Cycler: Cycles backwards through your apps.\n\nRandom Cycler: Cycles randomly through open applications.\n\nFavorite Apps: You can set your favorites by going into the favorites tab, and checking the apps that you want to appear. Make sure the favorites are enabled as well.\n\nHidden Apps:The hidden apps are kept out of the active applications, however, they can appear in the favorites if you wish. Just check off the one you wish to hide and you're good to go!\n\n\nDisplay Options:\n\n\nMegaDock: Enables both favorites and active apps to be in one dock\n\nFavorites:Enables or disables favorites shown.\n\nWider:This makes the entire dock wider, for more room to use the dock\n\nDouble Row:This option is only shown if both favorites and wider are enabled. This makes the dock two rows rather than one, where favorites and active apps would be half the size.\n\nTransition: The way that the dock appears and disaapears.\n\nPlace: This decides where the place of the dock is.\n\nIcon width, height, padding and label height: Allows you to change how big the padding between icons are, as well as the icon's height width, and label height. This is targeted at themers.\n\n\nSpringBoard Enabled:This adds an icon in the active apps dock to get back to the springboard, or close the springboard if you wish.\n\nSpringBoard Quittable: This enables or disables respringing with the circuitous dock.\n\nApp Animations: This adds animations to launching and quitting apps, if enabled. Otherwise the apps just appear and disappear.\n\nIcon Labels: Adds labels to the icons in the dock.\n\nIcon Badges: Adds badges to icons if they have badges.\n\nClose Box: This shows or hides the little (x) to close the apps.\n\nBecome Homescreen: Whenever you go to the homescreen the dock will automatically apopear.\n\nIcon: This adds an icon to the springboard allowing you to launch the dock when tapping it. (Note this icon will do nothing when in safe mode)\n\nLockscreen: If enabled, the dock will be allowed to show on the lockscreen.\n\nDimmed Window: If enabled there will be a window behind the dock which, when tapped, will dismiss the dock. On this window you can configure gestures to do different things such as background foreground app, quit foreground app, cycle apps, or reverse cycle apps. You can also double tap on this window to get a free memory alert so that you can free up memory.\n\nFree Memory: When enabled shows the current free RAM in megabytes. You can free up memory by double tapping on the dimmed window.\n\nBackgrounder Badge: Shows the backgrounder badge on the currently backgrounded/active applications(Useful if you have megadock on).\n\nThemed Icons: When on uses themed icons, when off uses the default ones.\n\nOther Features: You can tap and hold an icon then drag it up or down out of the dock to quit it (when on top or bottom) or drag it left or right out of the dock (when on left or right) to quit the app. The dock supports all orientations, and will change automatically according to how you hold the device, even when the dock is active!\n\nOther Notes: If you have any questions or comments email me: Daniel.zimmerman@me.com. Other features I have planned are: Specified time to hold an icon to drag, specified time for the transitions, the dock growing even larger when the wide option is enabled and the device is turned to landscape orientation.";
			else
				_tutorial.text = @"Welcome to Circuitous! \n\nNOTE: BACKGROUNDER MUST BE INSTALLED TO HAVE APPS RUN IN THE BACKGROUND\n\nDock Activation: Set your activator method to activate the dock with your currently running applications, and, if you choose, your favorite applications as well.\n\nCycler Activator: Cycles through your open apps.\n\nReverse Cycler: Cycles backwards through your apps.\n\nRandom Cycler: Cycles randomly through open applications.\n\nFavorite Apps: You can set your favorites by going into the favorites tab, and checking the apps that you want to appear. Make sure the favorites are enabled as well.\n\nHidden Apps:The hidden apps are kept out of the active applications, however, they can appear in the favorites if you wish. Just check off the one you wish to hide and you're good to go!\n\n\nDisplay Options:\n\n\nMegaDock: Enables both favorites and active apps to be in one dock\n\nFavorites:Enables or disables favorites shown.\n\nDouble Row:This option is only shown if both favorites and wider are enabled. This makes the dock two rows rather than one, where favorites and active apps would be half the size.\n\nTransition:The way that the dock appears and disaapears.\n\nPlace: This decides where the place of the dock is.\n\nIcon width, height, padding and label height: Allows you to change how big the padding between icons are, as well as the icon's height width, and label height. This is targeted at themers.\n\n\nSpringBoard Enabled:This adds an icon in the active apps dock to get back to the springboard, or close the springboard if you wish.\n\nSpringBoard Quittable: This enables or disables respringing with the circuitous dock.\n\nApp Animations: This adds animations to launching and quitting apps, if enabled. Otherwise the apps just appear and disappear.\n\nIcon Labels: Adds labels to the icons in the dock.\n\nIcon Badges: Adds badges to icons if they have badges.\n\nClose Box: This shows or hides the little (x) to close the apps.\n\nBecome Homescreen: Whenever you go to the homescreen the dock will automatically apopear.\n\nIcon: This adds an icon to the springboard allowing you to launch the dock when tapping it. (Note this icon will do nothing when in safe mode)\n\nLockscreen: If enabled, the dock will be allowed to show on the lockscreen.\n\nDimmed Window: If enabled there will be a window behind the dock which, when tapped, will dismiss the dock. On this window you can configure gestures to do different things such as background foreground app, quit foreground app, cycle apps, or reverse cycle apps. You can also double tap on this window to get a free memory alert so that you can free up memory.\n\nFree Memory: When enabled shows the current free RAM in megabytes. You can free up memory by double tapping on the dimmed window.\n\nBackgrounder Badge: Shows the backgrounder badge on the currently backgrounded/active applications(Useful if you have megadock on).\n\nThemed Icons: When on uses themed icons, when off uses the default ones.\n\nOther Features: You can tap and hold an icon then drag it up or down out of the dock to quit it (when on top or bottom) or drag it left or right out of the dock (when on left or right) to quit the app. The dock supports all orientations, and will change automatically according to how you hold the device, even when the dock is active!\n\nOther Notes: If you have any questions or comments email me: Daniel.zimmerman@me.com. Other features I have planned are: Specified time to hold an icon to drag, specified time for the transitions, the dock growing even larger when the wide option is enabled and the device is turned to landscape orientation.";
			_tutorial.font = [UIFont systemFontOfSize:16.0f];
			_tutorial.editable = NO;
			break;
		case 3:
			_favs = [dict objectForKey:@"favs"] ? [[dict objectForKey:@"favs"] boolValue] : YES;
			_wide = [dict objectForKey:@"wide"] ? [[dict objectForKey:@"wide"] boolValue] : NO;
			_double = [dict objectForKey:@"dbl"] ? [[dict objectForKey:@"dbl"] boolValue] : YES;
			_mega = [dict objectForKey:@"mega"] ? [[dict objectForKey:@"mega"] boolValue] : NO;
			_transition = [dict objectForKey:@"trans"] ? [[dict objectForKey:@"trans"] intValue] : 0;
			_place = [dict objectForKey:@"place"] ? [[dict objectForKey:@"place"] intValue] : 0;
			if isWildcat
				iconWidth = [dict objectForKey:@"iconwidth"] ? [[dict objectForKey:@"iconwidth"] floatValue] : 74.0f;
			else
				iconWidth = [dict objectForKey:@"iconwidth"] ? [[dict objectForKey:@"iconwidth"] floatValue] : 57.0f;
			if isWildcat
				iconHeight = [dict objectForKey:@"iconheight"] ? [[dict objectForKey:@"iconheight"] floatValue] : 78.0f;
			else
				iconHeight = [dict objectForKey:@"iconheight"] ? [[dict objectForKey:@"iconheight"] floatValue] : 57.0f;	
			if isWildcat
				lblHeight = [dict objectForKey:@"labelheight"] ? [[dict objectForKey:@"labelheight"] floatValue] : 16.0f;
			else
				lblHeight = [dict objectForKey:@"labelheight"] ? [[dict objectForKey:@"labelheight"] floatValue] : 12.0f;	
			if isWildcat
				padding = [dict objectForKey:@"padding"] ? [[dict objectForKey:@"padding"] floatValue] : 95.0f;
			else
				padding = [dict objectForKey:@"padding"] ? [[dict objectForKey:@"padding"] floatValue] : 72.0f;
			_tableView = [[UITableView alloc] initWithFrame:CGRectMake(0, 0, 320, 480-64) style:UITableViewStyleGrouped];
			[_tableView setDataSource:self];
			[_tableView setDelegate:self];
			added = NO;
			added1 = NO;
			added2 = NO;
			added3 = NO;
			break;
		case 4:
			_quitIt = [dict objectForKey:@"quit"] ? [[dict objectForKey:@"quit"] intValue] : 1;
			_backgroundIt = [dict objectForKey:@"background"] ? [[dict objectForKey:@"background"] intValue] : 0;
			_cycleIt = [dict objectForKey:@"cycle"] ? [[dict objectForKey:@"cycle"] intValue] : 3;
			_reverseIt = [dict objectForKey:@"reverse"] ? [[dict objectForKey:@"reverse"] intValue] : 2;
			_randomIt = [dict objectForKey:@"random"] ? [[dict objectForKey:@"random"] intValue] : 5;
			UITextView *gestureInfo = [[UITextView alloc] initWithFrame:CGRectMake(0.0f,0.0f,_tableView.frame.size.height, 50.0f)];
			gestureInfo.font = [UIFont systemFontOfSize:12.0f];
			gestureInfo.editable = NO;
			gestureInfo.backgroundColor = [UIColor clearColor];
			gestureInfo.text = @"These gestures are used on the dim window, and will only work if you have the dim window enabled";
			_tableView.tableFooterView = gestureInfo;
			[gestureInfo release];
			_tableView = [[UITableView alloc] initWithFrame:CGRectMake(0, 0, 320, 480-64) style:UITableViewStyleGrouped];
			[_tableView setDataSource:self];
			[_tableView setDelegate:self];			
			break;
		case 5:
			_currentTheme = [dict objectForKey:@"theme"] ? [[dict objectForKey:@"theme"] retain]: [[NSString alloc] initWithString:@"Default"];
			_themes = [[NSMutableArray alloc] init];
			fileManager = [NSFileManager defaultManager];
			for (NSString *path in [fileManager directoryContentsAtPath:@"/Applications/Circuitous.app/Themes"]) {
				if ([path hasSuffix:@".theme"] && ![path hasPrefix:@"."]) {
					[_themes addObject:[path stringByReplacingOccurrencesOfString:@".theme" withString:@""]];
				}
			}
			_tableView = [[UITableView alloc] initWithFrame:CGRectMake(0, 0, 320, 480-64) style:UITableViewStyleGrouped];
			[_tableView setDataSource:self];
			[_tableView setDelegate:self];			
			break;
		default:
			break;
	}
	[dict release];
	[self setNavigationTitle:[self navigationTitle]];
}

- (void)buttonTapped:(UIButton *)button
{
	button.selected = !button.selected;
	[_tableView setEditing:button.selected animated:YES];
}

- (void) dealloc {
	if (_tableView)
		[_tableView release];
	if (applicationsHere)
		[applicationsHere release];
	if (appStoreApps)
		[appStoreApps release];
	if (systemApps)
		[systemApps release];
	if (_tutorial)
		[_tutorial release];
	if (_themes)
		[_themes release];
	if (_currentTheme)
		[_currentTheme release];
	[super dealloc];
}

- (NSString *) navigationTitle {
	switch (_use) {
		case 0:
			return @"Favorites";
			break;
		case 1:
			return @"Hidden Apps";
			break;
		case 2: 
			return @"Tutorial";
			break;
		case 3:
			return @"Displaying";
			break;
		case 4:
			return @"Gestures";
			break;
		case 5:
			return @"Themes";
			break;
		default:
			return @"Error wrong use";
			break;
	}
}

- (void)setNavigationTitle:(NSString *)navigationTitle
{
	if ([self respondsToSelector:@selector(navigationItem)])
		[[self navigationItem] setTitle:navigationTitle];
}

- (id) view
{
	switch (_use) {
		case 0:
		case 1:
		case 3:
		case 4:
		case 5:
			return _tableView;
			break;
		case 2: 
			return _tutorial;
			break;
		default:
			return nil;
			break;
	}
}

- (id) _tableView {
	return _tableView;
}

- (int) numberOfSectionsInTableView:(UITableView *)tableView {
	switch (_use) {
		case 0:
			return 3;
			break;
		case 1:
			return 2;
			break;
		case 3:
			return 9;
			break;
		case 4:
			return 4;
			break;
		case 5:
			return 1;
			break;
		default:
			return 0;
			break;
	}
}

- (id) tableView:(UITableView *)tableView titleForHeaderInSection:(int)section
{
	switch (_use) {
		case 0:
			switch (section) {
				case 0:
					return @"Reorder";
					break;
				case 1:
					return @"System";
					break;
				case 2:
					return @"App Store";
					break;
				default:
					return nil;
					break;
			}
			break;
		case 1:
			switch (section) {
				case 0:
					return @"System";
					break;
				case 1:
					return @"App Store";
					break;
				default:
					return nil;
					break;
			}
			break;
		case 3:
			switch (section) {
				case 2:
					return @"Transition";
					break;
				case 3:
					return @"Place";
					break;
				case 4:
					return @"Icon Width";
					break;
				case 5:
					return @"Icon Height";
					break;
				case 6:
					return @"Icon Padding";
					break;
				case 7:
					return @"Icon Label Height";
					break;
				default:
					return nil;
					break;
			}
			break;
		case 4:
			switch (section) {
				case 0:
					return @"Backgrounding Gesture";
					break;
				case 1:
					return @"Quitting Gesture";
					break;
				case 2:
					return @"Cycling Gesture";
					break;
				case 3:
					return @"Reverse Cycling Gesture";
					break;
				default:
					return nil;
					break;
			}
		default:
			return nil;
	}
	
}

- (int) tableView:(UITableView *)tableView numberOfRowsInSection:(int)section
{
	switch (_use) {
		case 0:
			switch (section) {
				case 0:
					return [applicationsHere count];
					break;
				case 1:
					return [systemApps count];
					break;
				case 2:
					return [appStoreApps count];
					break;
				default:
					return 0;
					break;
			}
			break;
		case 1:
			switch (section) {
				case 0:
					return [systemApps count];
					break;
				case 1:
					return [appStoreApps count];
					break;
				default:
					return 0;
					break;
			}
			break;
		case 3:
			switch (section) {
				case 0:
					return 1;
					break;
				case 1:
					if isWildcat {
						if (_favs && _wide)
							return 3;
						else
							return 2;
					} else {
						if (_favs)
							return 2;
						else
							return 1;
					}
					break;
				case 2:
					return 3;
					break;
				case 3:
					return 4;
					break;
				case 4:
				case 5:
				case 6:
				case 7:
				case 8:
					return 1;
					break;
				default:
					return 0;
					break;
			}
			break;
		case 4:
			return 4;
			break;
		case 5:
			return [_themes count];
			break;
		default:
			return 0;
			break;
	}
}

- (id) tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
	NSString *reuseIdentifier = [NSString stringWithFormat:@"ApplicationCell %i %i", indexPath.section, indexPath.row]; 
	
    // Try to retrieve from the table view a now-unused cell with the given identifier
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:reuseIdentifier];
    if (cell == nil) {
        // Cell does not exist, create a new one
        cell = [[[CIRApplicationCell alloc] initWithFrame:CGRectZero reuseIdentifier:reuseIdentifier] autorelease];
        cell.selectionStyle = UITableViewCellSelectionStyleGray;
    }
	NSString *identifier;
	NSString *displayName;
	UIImage *icon = nil;
	NSString *iconPath;
	switch (_use) {
		case 0:
			switch (indexPath.section) {
				case 0:
					identifier = [applicationsHere objectAtIndex:indexPath.row];
					break;
				case 1:
					identifier = [systemApps objectAtIndex:indexPath.row];
					cell.accessoryType = [applicationsHere containsObject:identifier] ? UITableViewCellAccessoryCheckmark : UITableViewCellAccessoryNone;
					break;
				case 2:
					identifier = [appStoreApps objectAtIndex:indexPath.row];
					cell.accessoryType = [applicationsHere containsObject:identifier] ? UITableViewCellAccessoryCheckmark : UITableViewCellAccessoryNone;
					break;
				default:
					identifier = nil;
					break;
			}
			displayName = SBSCopyLocalizedApplicationNameForDisplayIdentifier(identifier);
			[cell textLabel].text = displayName;
			[displayName release];
			
			iconPath = SBSCopyIconImagePathForDisplayIdentifier(identifier);
			if (iconPath != nil) {
				icon = [UIImage imageWithContentsOfFile:iconPath];
				[iconPath release];
			}
			
			[cell imageView].image = icon;
			break;
		case 1:
			switch (indexPath.section) {
				case 0:
					identifier = [systemApps objectAtIndex:indexPath.row];
					break;
				case 1:
					identifier = [appStoreApps objectAtIndex:indexPath.row];
					break;
				default:
					identifier = nil;
					break;
			}
			displayName = SBSCopyLocalizedApplicationNameForDisplayIdentifier(identifier);
			[cell textLabel].text = displayName;
			[displayName release];
			
			iconPath = SBSCopyIconImagePathForDisplayIdentifier(identifier);
			if (iconPath != nil) {
				icon = [UIImage imageWithContentsOfFile:iconPath];
				[iconPath release];
			}
			
			[cell imageView].image = icon;
			
			cell.accessoryType = [applicationsHere containsObject:identifier] ? UITableViewCellAccessoryCheckmark : UITableViewCellAccessoryNone;
			break;
		case 3:
			identifier = nil;
			switch (indexPath.section) {
				case 0:
					cell.textLabel.text = @"MegaDock";
					if (_mega)
						cell.accessoryType = UITableViewCellAccessoryCheckmark;
					else
						cell.accessoryType = UITableViewCellAccessoryNone;
					break;
				case 1:
					if isWildcat {
						switch (indexPath.row) {
							case 0:
								cell.textLabel.text = @"Favorites";
								if (_favs)
									cell.accessoryType = UITableViewCellAccessoryCheckmark;
								else
									cell.accessoryType = UITableViewCellAccessoryNone;
								break;
							case 1:
								cell.textLabel.text = @"Wider";
								if (_wide)
									cell.accessoryType = UITableViewCellAccessoryCheckmark;
								else
									cell.accessoryType = UITableViewCellAccessoryNone;
								break;
							case 2:
								cell.textLabel.text = @"Double Row";
								if (_double)
									cell.accessoryType = UITableViewCellAccessoryCheckmark;
								else
									cell.accessoryType = UITableViewCellAccessoryNone;
								break;
							default:
								break;
						}
					} else {
						switch (indexPath.row) {
							case 0:
								cell.textLabel.text = @"Favorites";
								if (_favs)
									cell.accessoryType = UITableViewCellAccessoryCheckmark;
								else
									cell.accessoryType = UITableViewCellAccessoryNone;
								break;
							case 1:
								cell.textLabel.text = @"Double Row";
								if (_double)
									cell.accessoryType = UITableViewCellAccessoryCheckmark;
								else
									cell.accessoryType = UITableViewCellAccessoryNone;
								break;
							default:
								break;
						}
					}
					break;
				case 2:
					switch (indexPath.row) {
						case 0:
							cell.textLabel.text = @"Fade In";
							break;
						case 1:
							cell.textLabel.text = @"Pop In";
							break;
						case 2:
							cell.textLabel.text = @"Slide In";
							break;
						default:
							break;
					}
					if ((int)indexPath.row == _transition)
						cell.accessoryType = UITableViewCellAccessoryCheckmark;
					break;
				case 3:
					switch (indexPath.row) {
						case 0:
							cell.textLabel.text = @"Top";
							break;
						case 1:
							cell.textLabel.text = @"Bottom";
							break;
						case 2:
							cell.textLabel.text = @"Left";
							break;
						case 3:
							cell.textLabel.text = @"Right";
							break;
						default:
							break;
					}
					if ((int)indexPath.row == _place)
						cell.accessoryType = UITableViewCellAccessoryCheckmark;
					else
						cell.accessoryType = UITableViewCellAccessoryNone;
					break;
				case 4:
					if (!added) {
						added = YES;
						valueLbl = [[UILabel alloc] initWithFrame:CGRectMake(5.0f,2.0f, 100.0f, 10.0f)];
						valueLbl.backgroundColor = [UIColor clearColor];
						valueLbl.textColor = [UIColor grayColor];
						valueLbl.font = [UIFont systemFontOfSize:10.0f];
						valueLbl.text = [NSString stringWithFormat:@"%f", iconWidth];
						valueLbl.tag = 9999;
						slider = [[UISlider alloc] initWithFrame:CGRectMake(5.0f,12.0f,cell.contentView.frame.size.width - 20.0f, cell.contentView.frame.size.height - 20.0f)];
						slider.minimumValue = 1.0f;
						slider.maximumValue = 100.0f;
						slider.value = iconWidth;
						slider.continuous = YES;
						[slider addTarget:self action:@selector(sliderChanged:) forControlEvents:UIControlEventValueChanged];
						[cell.contentView addSubview:slider];
						[cell.contentView addSubview:valueLbl];
					}
					break;
				case 5:
					if (!added1) {
						added1 = YES;
						valueLbl1 = [[UILabel alloc] initWithFrame:CGRectMake(5.0f,2.0f, 100.0f, 10.0f)];
						valueLbl1.backgroundColor = [UIColor clearColor];
						valueLbl1.textColor = [UIColor grayColor];
						valueLbl1.font = [UIFont systemFontOfSize:10.0f];
						valueLbl1.text = [NSString stringWithFormat:@"%f", iconHeight];
						valueLbl1.tag = 9999;
						slider1 = [[UISlider alloc] initWithFrame:CGRectMake(5.0f,10.0f,cell.contentView.frame.size.width - 20.0f, cell.contentView.frame.size.height - 20.0f)];
						slider1.minimumValue = 1.0f;
						slider1.maximumValue = 100.0f;
						slider1.value = iconHeight;
						slider1.continuous = YES;
						[slider1 addTarget:self action:@selector(sliderChanged:) forControlEvents:UIControlEventValueChanged];
						[cell.contentView addSubview:slider1];
						[cell.contentView addSubview:valueLbl1];
					}
					break;
				case 6:
					if (!added2) {
						added2 = YES;
						valueLbl2 = [[UILabel alloc] initWithFrame:CGRectMake(5.0f,2.0f, 100.0f, 10.0f)];
						valueLbl2.backgroundColor = [UIColor clearColor];
						valueLbl2.textColor = [UIColor grayColor];
						valueLbl2.font = [UIFont systemFontOfSize:10.0f];
						valueLbl2.text = [NSString stringWithFormat:@"%f", padding];
						valueLbl2.tag = 9999;
						slider2 = [[UISlider alloc] initWithFrame:CGRectMake(5.0f,10.0f,cell.contentView.frame.size.width - 20.0f, cell.contentView.frame.size.height - 20.0f)];
						slider2.minimumValue = 20.0f;
						slider2.maximumValue = 150.0f;
						slider2.value = padding;
						slider2.continuous = YES;
						[slider2 addTarget:self action:@selector(sliderChanged:) forControlEvents:UIControlEventValueChanged];
						[cell.contentView addSubview:slider2];
						[cell.contentView addSubview:valueLbl2];
					}
					break;
				case 7:
					if (!added3) {
						added3 = YES;
						valueLbl3 = [[UILabel alloc] initWithFrame:CGRectMake(5.0f,2.0f, 100.0f, 10.0f)];
						valueLbl3.backgroundColor = [UIColor clearColor];
						valueLbl3.textColor = [UIColor grayColor];
						valueLbl3.font = [UIFont systemFontOfSize:10.0f];
						valueLbl3.text = [NSString stringWithFormat:@"%f", lblHeight];
						valueLbl3.tag = 9999;
						slider3 = [[UISlider alloc] initWithFrame:CGRectMake(5.0f,10.0f,cell.contentView.frame.size.width - 20.0f, cell.contentView.frame.size.height - 20.0f)];
						slider3.minimumValue = 1.0f;
						slider3.maximumValue = 100.0f;
						slider3.value = lblHeight;
						slider3.continuous = YES;
						[slider3 addTarget:self action:@selector(sliderChanged:) forControlEvents:UIControlEventValueChanged];
						[cell.contentView addSubview:slider3];
						[cell.contentView addSubview:valueLbl3];
					}
					break;
				case 8:
					cell.textLabel.text = @"Restore Defaults for Icon";
					break;
				default:
					break;
			}
			break;
		case 4:
			identifier = nil;
			switch (indexPath.row) {
				case 0:
					cell.textLabel.text = @"Slide Down";
					break;
				case 1:
					cell.textLabel.text = @"Slide Up";
					break;
				case 2:
					cell.textLabel.text = @"Slide Left";
					break;
				case 3:
					cell.textLabel.text = @"Slide Right";
					break;
				default:
					break;
			}
			switch (indexPath.section) {
				case 0:
					if (indexPath.row == _backgroundIt)
						[cell setAccessoryType:UITableViewCellAccessoryCheckmark];
					else
						[cell setAccessoryType:UITableViewCellAccessoryNone];
					break;
				case 1:
					if (indexPath.row == _quitIt)
						[cell setAccessoryType:UITableViewCellAccessoryCheckmark];
					else
						[cell setAccessoryType:UITableViewCellAccessoryNone];
					break;
				case 2:
					if (indexPath.row == _cycleIt)
						[cell setAccessoryType:UITableViewCellAccessoryCheckmark];
					else
						[cell setAccessoryType:UITableViewCellAccessoryNone];
					break;
				case 3:
					if (indexPath.row == _reverseIt)
						[cell setAccessoryType:UITableViewCellAccessoryCheckmark];
					else
						[cell setAccessoryType:UITableViewCellAccessoryNone];
					break;
				default:
					[cell setAccessoryType:UITableViewCellAccessoryNone];
					break;
			}
			break;
		case 5:
			cell.textLabel.text = [_themes objectAtIndex:indexPath.row];
			if ([cell.textLabel.text isEqualToString:_currentTheme])
				[cell setAccessoryType:UITableViewCellAccessoryCheckmark];
			else
				[cell setAccessoryType:UITableViewCellAccessoryNone];
			break;
		default:
			identifier = nil;
			break;
	}
	return cell;
}

- (void)sliderChanged:(UISlider *)slidera
{
//	UITableViewCell *cell = (UITableViewCell *)[slidera superview];
	NSMutableDictionary *prefs = [[NSMutableDictionary alloc] initWithContentsOfFile:@"/var/mobile/Library/Preferences/com.zimm.circuitous.plist"] ?: [[NSMutableDictionary alloc] init];
	if ([slidera isEqual:slider]) {
		iconWidth = slider.value;
		[prefs setObject:[NSNumber numberWithFloat:iconWidth] forKey:@"iconwidth"];
		[valueLbl setText:[NSString stringWithFormat:@"%f", iconWidth]];
	} else if ([slidera isEqual:slider1]) {
		iconHeight = slider1.value;
		[prefs setObject:[NSNumber numberWithFloat:iconHeight] forKey:@"iconheight"];
		[valueLbl1 setText:[NSString stringWithFormat:@"%f", iconHeight]];
	} else if ([slidera isEqual:slider2]) {
		padding = slider2.value;
		[prefs setObject:[NSNumber numberWithFloat:padding] forKey:@"padding"];
		[valueLbl2 setText:[NSString stringWithFormat:@"%f", padding]];
	} else if ([slidera isEqual:slider3]) {
		lblHeight = slider3.value;
		[prefs setObject:[NSNumber numberWithFloat:lblHeight] forKey:@"labelheight"];
		[valueLbl3 setText:[NSString stringWithFormat:@"%f", lblHeight]];
	}
	[prefs writeToFile:@"/var/mobile/Library/Preferences/com.zimm.circuitous.plist" atomically:YES];
	[prefs release];
}

- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath
{
	return (indexPath.section == 0 && _use == 0);
}

- (BOOL)tableView:(UITableView *)tableView canMoveRowAtIndexPath:(NSIndexPath *)indexPath
{
	return (indexPath.section == 0 && _use == 0);
}

- (void)tableView:(UITableView *)tableView moveRowAtIndexPath:(NSIndexPath *)fromIndexPath toIndexPath:(NSIndexPath *)toIndexPath
{
	NSString *ident = [[NSString alloc] initWithString:[applicationsHere objectAtIndex:fromIndexPath.row]];
	[applicationsHere removeObject:ident];
	[applicationsHere insertObject:ident atIndex:toIndexPath.row];
	NSMutableDictionary *prefs = [[NSMutableDictionary alloc] initWithContentsOfFile:@"/var/mobile/Library/Preferences/com.zimm.circuitous.plist"] ?: [[NSMutableDictionary alloc] init];
	[prefs setObject:applicationsHere forKey:@"favorites"];
	[prefs writeToFile:@"/var/mobile/Library/Preferences/com.zimm.circuitous.plist" atomically:YES];
	CFNotificationCenterPostNotification(CFNotificationCenterGetDarwinNotifyCenter(), CFSTR("com.zimm.circuitous.settingschanged"), NULL, NULL, true);
	[prefs release];
	[ident release];
}
	
- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath
{
	if (editingStyle == UITableViewCellEditingStyleDelete) {
		[applicationsHere removeObjectAtIndex:indexPath.row];
		[tableView deleteRowsAtIndexPaths:[NSArray arrayWithObjects:indexPath, nil] withRowAnimation:UITableViewRowAnimationTop];
		NSMutableDictionary *prefs = [[NSMutableDictionary alloc] initWithContentsOfFile:@"/var/mobile/Library/Preferences/com.zimm.circuitous.plist"];
		[prefs setObject:applicationsHere forKey:@"favorites"];
		[prefs writeToFile:@"/var/mobile/Library/Preferences/com.zimm.circuitous.plist" atomically:YES];
		CFNotificationCenterPostNotification(CFNotificationCenterGetDarwinNotifyCenter(), CFSTR("com.zimm.circuitous.settingschanged"), NULL, NULL, true);
		[prefs release];
	}
}


- (void) tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
	NSMutableDictionary *dict = [[NSMutableDictionary alloc] initWithContentsOfFile:@"/var/mobile/Library/Preferences/com.zimm.circuitous.plist"] ?: [[NSMutableDictionary alloc] init];
	UITableViewCell *cell = [[self _tableView] cellForRowAtIndexPath:indexPath];
	NSString *identifier;
	BOOL errored;
	int start;
	switch (_use) {
		case 0:
			switch (indexPath.section) {
				case 0:
					[dict release];
					[tableView deselectRowAtIndexPath:indexPath animated:YES];
					return;
					break;
				case 1:
					identifier = [systemApps objectAtIndex:indexPath.row];
					break;
				case 2:
					identifier = [appStoreApps objectAtIndex:indexPath.row];
					break;
				default:
					identifier = nil;
					break;
			}
			if (cell.accessoryType == UITableViewCellAccessoryNone) {
				[applicationsHere addObject:identifier];
				[[self _tableView] insertRowsAtIndexPaths:[NSArray arrayWithObjects:[NSIndexPath indexPathForRow:([applicationsHere count] - 1) inSection:0], nil] withRowAnimation:UITableViewRowAnimationTop];
				cell.accessoryType = UITableViewCellAccessoryCheckmark;
			} else {
				int i = -1;
				int where = 0;
				for (NSString *app in applicationsHere) {
					i++;
					if ([app isEqualToString:identifier]) {
						where = i;
					}
				}
				[applicationsHere removeObject:identifier];
				[[self _tableView] deleteRowsAtIndexPaths:[NSArray arrayWithObjects:[NSIndexPath indexPathForRow:where inSection:0], nil] withRowAnimation:UITableViewRowAnimationTop];
				cell.accessoryType = UITableViewCellAccessoryNone;
			}
			[dict setObject:applicationsHere forKey:@"favorites"];
			break;
		case 1:
			switch (indexPath.section) {
				case 0:
					identifier = [systemApps objectAtIndex:indexPath.row];
					break;
				case 1:
					identifier = [appStoreApps objectAtIndex:indexPath.row];
					break;
				default:
					identifier = nil;
					break;
			}
			if (cell.accessoryType == UITableViewCellAccessoryNone) {
				[applicationsHere addObject:identifier];
				cell.accessoryType = UITableViewCellAccessoryCheckmark;
			} else {
				[applicationsHere removeObject:identifier];
				cell.accessoryType = UITableViewCellAccessoryNone;
			}
			[dict setObject:applicationsHere forKey:@"hidden"];
			break;
		case 3:
			identifier = nil;
			switch (indexPath.section) {
				case 0:
					if ((UITableViewCellAccessoryType *)cell.accessoryType == UITableViewCellAccessoryNone)
						cell.accessoryType = UITableViewCellAccessoryCheckmark;
					else
						cell.accessoryType = UITableViewCellAccessoryNone;
					_mega = (cell.accessoryType == UITableViewCellAccessoryCheckmark);
					[dict setObject:[NSNumber numberWithBool:_mega] forKey:@"mega"];
					break;
				case 2:
					[[[self _tableView] cellForRowAtIndexPath:[NSIndexPath indexPathForRow:0 inSection:2]] setAccessoryType:UITableViewCellAccessoryNone];
					[[[self _tableView] cellForRowAtIndexPath:[NSIndexPath indexPathForRow:1 inSection:2]] setAccessoryType:UITableViewCellAccessoryNone];
					[[[self _tableView] cellForRowAtIndexPath:[NSIndexPath indexPathForRow:2 inSection:2]] setAccessoryType:UITableViewCellAccessoryNone];
					[cell setAccessoryType:UITableViewCellAccessoryCheckmark];
					_transition = indexPath.row;
					[dict setObject:[NSNumber numberWithInt:_transition] forKey:@"trans"];
					break;
				case 1:
					if ((UITableViewCellAccessoryType *)cell.accessoryType == UITableViewCellAccessoryNone)
						cell.accessoryType = UITableViewCellAccessoryCheckmark;
					else
						cell.accessoryType = UITableViewCellAccessoryNone;
					if isWildcat {
						switch (indexPath.row) {
							case 0:
								_favs = (cell.accessoryType == UITableViewCellAccessoryCheckmark);
								if (_favs && _wide) {
									[[self _tableView] insertRowsAtIndexPaths:[NSArray arrayWithObjects:[NSIndexPath indexPathForRow:2 inSection:1], nil] withRowAnimation:UITableViewRowAnimationTop];
								} else if (_wide) {
									[[self _tableView] deleteRowsAtIndexPaths:[NSArray arrayWithObjects:[NSIndexPath indexPathForRow:2 inSection:1], nil] withRowAnimation:UITableViewRowAnimationTop];
								}
								[dict setObject:[NSNumber numberWithBool:_favs] forKey:@"favs"];
								break;
							case 1:
								_wide = (cell.accessoryType == UITableViewCellAccessoryCheckmark);
								if (_favs && _wide) {
									[[self _tableView] insertRowsAtIndexPaths:[NSArray arrayWithObjects:[NSIndexPath indexPathForRow:2 inSection:1], nil] withRowAnimation:UITableViewRowAnimationTop];
								} else if (_favs) {
									[[self _tableView] deleteRowsAtIndexPaths:[NSArray arrayWithObjects:[NSIndexPath indexPathForRow:2 inSection:1], nil] withRowAnimation:UITableViewRowAnimationTop];
								}
								[dict setObject:[NSNumber numberWithBool:_wide] forKey:@"wide"];
								break;
							case 2:
								_double = (cell.accessoryType == UITableViewCellAccessoryCheckmark);
								[dict setObject:[NSNumber numberWithBool:_double] forKey:@"dbl"];
								break;
							default:
								break;
						}
					} else {
						switch (indexPath.row) {
							case 0:
								_favs = (cell.accessoryType == UITableViewCellAccessoryCheckmark);
								if (_favs) {
									[[self _tableView] insertRowsAtIndexPaths:[NSArray arrayWithObjects:[NSIndexPath indexPathForRow:1 inSection:1], nil] withRowAnimation:UITableViewRowAnimationTop];
								} else {
									[[self _tableView] deleteRowsAtIndexPaths:[NSArray arrayWithObjects:[NSIndexPath indexPathForRow:1 inSection:1], nil] withRowAnimation:UITableViewRowAnimationTop];
								}
								[dict setObject:[NSNumber numberWithBool:_favs] forKey:@"favs"];
								break;
							case 1:
								_double = (cell.accessoryType == UITableViewCellAccessoryCheckmark);
								[dict setObject:[NSNumber numberWithBool:_double] forKey:@"dbl"];
								break;
							default:
								break;
						}
					}
					break;
				case 3:
					[[[self _tableView] cellForRowAtIndexPath:[NSIndexPath indexPathForRow:0 inSection:3]] setAccessoryType:UITableViewCellAccessoryNone];
					[[[self _tableView] cellForRowAtIndexPath:[NSIndexPath indexPathForRow:1 inSection:3]] setAccessoryType:UITableViewCellAccessoryNone];
					[[[self _tableView] cellForRowAtIndexPath:[NSIndexPath indexPathForRow:2 inSection:3]] setAccessoryType:UITableViewCellAccessoryNone];
					[[[self _tableView] cellForRowAtIndexPath:[NSIndexPath indexPathForRow:3 inSection:3]] setAccessoryType:UITableViewCellAccessoryNone];
					[cell setAccessoryType:UITableViewCellAccessoryCheckmark];
					_place = indexPath.row;
					[dict setObject:[NSNumber numberWithInt:_place] forKey:@"place"];
					break;
				case 8:
					if isWildcat {
						iconWidth = 74.0f;
						iconHeight = 78.0f;
						lblHeight = 16.0f;
						padding = 95.0f;
					} else {
						iconHeight = 57.0f;
						iconWidth = 57.0f;
						lblHeight = 12.0f;
						padding = 72.0f;
					}
					[dict setObject:[NSNumber numberWithFloat:iconHeight] forKey:@"iconheight"];
					[dict setObject:[NSNumber numberWithFloat:iconWidth] forKey:@"iconwidth"];
					[dict setObject:[NSNumber numberWithFloat:padding] forKey:@"padding"];
					[dict setObject:[NSNumber numberWithFloat:lblHeight] forKey:@"labelheight"];
					valueLbl.text = [NSString stringWithFormat:@"%f",iconWidth];
					valueLbl1.text = [NSString stringWithFormat:@"%f",iconHeight];
					valueLbl2.text = [NSString stringWithFormat:@"%f",padding];
					valueLbl3.text = [NSString stringWithFormat:@"%f",lblHeight];
					slider.value = iconWidth;
					slider1.value = iconHeight;
					slider2.value = padding;
					slider3.value = lblHeight;
				default:
					break;
			}
			break;
		case 4:
			identifier = nil;
			[[[self _tableView] cellForRowAtIndexPath:[NSIndexPath indexPathForRow:0 inSection:indexPath.section]] setAccessoryType:UITableViewCellAccessoryNone];
			[[[self _tableView] cellForRowAtIndexPath:[NSIndexPath indexPathForRow:1 inSection:indexPath.section]] setAccessoryType:UITableViewCellAccessoryNone];
			[[[self _tableView] cellForRowAtIndexPath:[NSIndexPath indexPathForRow:2 inSection:indexPath.section]] setAccessoryType:UITableViewCellAccessoryNone];
			[[[self _tableView] cellForRowAtIndexPath:[NSIndexPath indexPathForRow:3 inSection:indexPath.section]] setAccessoryType:UITableViewCellAccessoryNone];
			[cell setAccessoryType:UITableViewCellAccessoryCheckmark];
			switch (indexPath.section) {
				case 0:
					_backgroundIt = indexPath.row;
					if (_backgroundIt == _quitIt) {
						[[[self _tableView] cellForRowAtIndexPath:[NSIndexPath indexPathForRow:0 inSection:1]] setAccessoryType:UITableViewCellAccessoryNone];
						[[[self _tableView] cellForRowAtIndexPath:[NSIndexPath indexPathForRow:1 inSection:1]] setAccessoryType:UITableViewCellAccessoryNone];
						[[[self _tableView] cellForRowAtIndexPath:[NSIndexPath indexPathForRow:2 inSection:1]] setAccessoryType:UITableViewCellAccessoryNone];
						[[[self _tableView] cellForRowAtIndexPath:[NSIndexPath indexPathForRow:3 inSection:1]] setAccessoryType:UITableViewCellAccessoryNone];
						UIModalView *alert = [[UIModalView alloc] initWithTitle:@"Error" buttons:[NSArray arrayWithObjects:@"Okay", nil] defaultButtonIndex:0 delegate:nil context:NULL];
						[alert setBodyText:@"You cannot have the backgrounding and quitting gestures be the same. Please select another gesture for quitting."];
						[alert setNumberOfRows:1];
						[alert popupAlertAnimated:YES];
						[alert release];
						_quitIt = 5;
						[dict setObject:[NSNumber numberWithInt:_quitIt] forKey:@"quit"];
					} else if (_backgroundIt == _cycleIt) {
						[[[self _tableView] cellForRowAtIndexPath:[NSIndexPath indexPathForRow:0 inSection:2]] setAccessoryType:UITableViewCellAccessoryNone];
						[[[self _tableView] cellForRowAtIndexPath:[NSIndexPath indexPathForRow:1 inSection:2]] setAccessoryType:UITableViewCellAccessoryNone];
						[[[self _tableView] cellForRowAtIndexPath:[NSIndexPath indexPathForRow:2 inSection:2]] setAccessoryType:UITableViewCellAccessoryNone];
						[[[self _tableView] cellForRowAtIndexPath:[NSIndexPath indexPathForRow:3 inSection:2]] setAccessoryType:UITableViewCellAccessoryNone];
						UIModalView *alert = [[UIModalView alloc] initWithTitle:@"Error" buttons:[NSArray arrayWithObjects:@"Okay", nil] defaultButtonIndex:0 delegate:nil context:NULL];
						[alert setBodyText:@"You cannot have the backgrounding and the cycling gestures be the same. Please select another gesture for cycling."];
						[alert setNumberOfRows:1];
						[alert popupAlertAnimated:YES];
						[alert release];
						_cycleIt = 5;
						[dict setObject:[NSNumber numberWithInt:_cycleIt] forKey:@"cycle"];
					} else if (_backgroundIt == _reverseIt) {
						[[[self _tableView] cellForRowAtIndexPath:[NSIndexPath indexPathForRow:0 inSection:3]] setAccessoryType:UITableViewCellAccessoryNone];
						[[[self _tableView] cellForRowAtIndexPath:[NSIndexPath indexPathForRow:1 inSection:3]] setAccessoryType:UITableViewCellAccessoryNone];
						[[[self _tableView] cellForRowAtIndexPath:[NSIndexPath indexPathForRow:2 inSection:3]] setAccessoryType:UITableViewCellAccessoryNone];
						[[[self _tableView] cellForRowAtIndexPath:[NSIndexPath indexPathForRow:3 inSection:3]] setAccessoryType:UITableViewCellAccessoryNone];
						UIModalView *alert = [[UIModalView alloc] initWithTitle:@"Error" buttons:[NSArray arrayWithObjects:@"Okay", nil] defaultButtonIndex:0 delegate:nil context:NULL];
						[alert setBodyText:@"You cannot have the backgrounding and the reverse cycling gestures be the same. Please select another gesture for reverse cycling."];
						[alert setNumberOfRows:1];
						[alert popupAlertAnimated:YES];
						[alert release];
						_reverseIt = 5;
						[dict setObject:[NSNumber numberWithInt:_reverseIt] forKey:@"reverse"];
					}
					[dict setObject:[NSNumber numberWithInt:_backgroundIt] forKey:@"background"];
					break;
				case 1:
					_quitIt = indexPath.row;
					if (_quitIt == _backgroundIt) {
						[[[self _tableView] cellForRowAtIndexPath:[NSIndexPath indexPathForRow:0 inSection:0]] setAccessoryType:UITableViewCellAccessoryNone];
						[[[self _tableView] cellForRowAtIndexPath:[NSIndexPath indexPathForRow:1 inSection:0]] setAccessoryType:UITableViewCellAccessoryNone];
						[[[self _tableView] cellForRowAtIndexPath:[NSIndexPath indexPathForRow:2 inSection:0]] setAccessoryType:UITableViewCellAccessoryNone];
						[[[self _tableView] cellForRowAtIndexPath:[NSIndexPath indexPathForRow:3 inSection:0]] setAccessoryType:UITableViewCellAccessoryNone];
						UIModalView *alert = [[UIModalView alloc] initWithTitle:@"Error" buttons:[NSArray arrayWithObjects:@"Okay", nil] defaultButtonIndex:0 delegate:nil context:NULL];
						[alert setBodyText:@"You cannot have the quiting and backgrounding gestures be the same. Please select another gesture for backgrounding."];
						[alert setNumberOfRows:1];
						[alert popupAlertAnimated:YES];
						[alert release];
						_backgroundIt = 5;
						[dict setObject:[NSNumber numberWithInt:_backgroundIt] forKey:@"background"];
					} else if (_quitIt == _cycleIt) {
						[[[self _tableView] cellForRowAtIndexPath:[NSIndexPath indexPathForRow:0 inSection:2]] setAccessoryType:UITableViewCellAccessoryNone];
						[[[self _tableView] cellForRowAtIndexPath:[NSIndexPath indexPathForRow:1 inSection:2]] setAccessoryType:UITableViewCellAccessoryNone];
						[[[self _tableView] cellForRowAtIndexPath:[NSIndexPath indexPathForRow:2 inSection:2]] setAccessoryType:UITableViewCellAccessoryNone];
						[[[self _tableView] cellForRowAtIndexPath:[NSIndexPath indexPathForRow:3 inSection:2]] setAccessoryType:UITableViewCellAccessoryNone];
						UIModalView *alert = [[UIModalView alloc] initWithTitle:@"Error" buttons:[NSArray arrayWithObjects:@"Okay", nil] defaultButtonIndex:0 delegate:nil context:NULL];
						[alert setBodyText:@"You cannot have the quitting and the cycling gestures be the same. Please select another gesture for cycling."];
						[alert setNumberOfRows:1];
						[alert popupAlertAnimated:YES];
						[alert release];
						_cycleIt = 5;
						[dict setObject:[NSNumber numberWithInt:_cycleIt] forKey:@"cycle"];
					} else if (_quitIt == _reverseIt) {
						[[[self _tableView] cellForRowAtIndexPath:[NSIndexPath indexPathForRow:0 inSection:3]] setAccessoryType:UITableViewCellAccessoryNone];
						[[[self _tableView] cellForRowAtIndexPath:[NSIndexPath indexPathForRow:1 inSection:3]] setAccessoryType:UITableViewCellAccessoryNone];
						[[[self _tableView] cellForRowAtIndexPath:[NSIndexPath indexPathForRow:2 inSection:3]] setAccessoryType:UITableViewCellAccessoryNone];
						[[[self _tableView] cellForRowAtIndexPath:[NSIndexPath indexPathForRow:3 inSection:3]] setAccessoryType:UITableViewCellAccessoryNone];
						UIModalView *alert = [[UIModalView alloc] initWithTitle:@"Error" buttons:[NSArray arrayWithObjects:@"Okay", nil] defaultButtonIndex:0 delegate:nil context:NULL];
						[alert setBodyText:@"You cannot have the quitting and the reverse cycling gestures be the same. Please select another gesture for reverse cycling."];
						[alert setNumberOfRows:1];
						[alert popupAlertAnimated:YES];
						[alert release];
						_reverseIt = 5;
						[dict setObject:[NSNumber numberWithInt:_reverseIt] forKey:@"reverse"];
					}
					[dict setObject:[NSNumber numberWithInt:_quitIt] forKey:@"quit"];
					break;
				case 2:
					_cycleIt = indexPath.row;
					if (_cycleIt == _backgroundIt) {
						[[[self _tableView] cellForRowAtIndexPath:[NSIndexPath indexPathForRow:0 inSection:0]] setAccessoryType:UITableViewCellAccessoryNone];
						[[[self _tableView] cellForRowAtIndexPath:[NSIndexPath indexPathForRow:1 inSection:0]] setAccessoryType:UITableViewCellAccessoryNone];
						[[[self _tableView] cellForRowAtIndexPath:[NSIndexPath indexPathForRow:2 inSection:0]] setAccessoryType:UITableViewCellAccessoryNone];
						[[[self _tableView] cellForRowAtIndexPath:[NSIndexPath indexPathForRow:3 inSection:0]] setAccessoryType:UITableViewCellAccessoryNone];
						UIModalView *alert = [[UIModalView alloc] initWithTitle:@"Error" buttons:[NSArray arrayWithObjects:@"Okay", nil] defaultButtonIndex:0 delegate:nil context:NULL];
						[alert setBodyText:@"You cannot have the cycling and backgrounding gestures be the same. Please select another gesture for backgrounding."];
						[alert setNumberOfRows:1];
						[alert popupAlertAnimated:YES];
						[alert release];
						_backgroundIt = 5;
						[dict setObject:[NSNumber numberWithInt:_backgroundIt] forKey:@"background"];
					} else if (_cycleIt == _quitIt) {
						[[[self _tableView] cellForRowAtIndexPath:[NSIndexPath indexPathForRow:0 inSection:1]] setAccessoryType:UITableViewCellAccessoryNone];
						[[[self _tableView] cellForRowAtIndexPath:[NSIndexPath indexPathForRow:1 inSection:1]] setAccessoryType:UITableViewCellAccessoryNone];
						[[[self _tableView] cellForRowAtIndexPath:[NSIndexPath indexPathForRow:2 inSection:1]] setAccessoryType:UITableViewCellAccessoryNone];
						[[[self _tableView] cellForRowAtIndexPath:[NSIndexPath indexPathForRow:3 inSection:1]] setAccessoryType:UITableViewCellAccessoryNone];
						UIModalView *alert = [[UIModalView alloc] initWithTitle:@"Error" buttons:[NSArray arrayWithObjects:@"Okay", nil] defaultButtonIndex:0 delegate:nil context:NULL];
						[alert setBodyText:@"You cannot have the cycling and the quitting gestures be the same. Please select another gesture for quitting."];
						[alert setNumberOfRows:1];
						[alert popupAlertAnimated:YES];
						[alert release];
						_quitIt = 5;
						[dict setObject:[NSNumber numberWithInt:_quitIt] forKey:@"quit"];
					} else if (_cycleIt == _reverseIt) {
						[[[self _tableView] cellForRowAtIndexPath:[NSIndexPath indexPathForRow:0 inSection:3]] setAccessoryType:UITableViewCellAccessoryNone];
						[[[self _tableView] cellForRowAtIndexPath:[NSIndexPath indexPathForRow:1 inSection:3]] setAccessoryType:UITableViewCellAccessoryNone];
						[[[self _tableView] cellForRowAtIndexPath:[NSIndexPath indexPathForRow:2 inSection:3]] setAccessoryType:UITableViewCellAccessoryNone];
						[[[self _tableView] cellForRowAtIndexPath:[NSIndexPath indexPathForRow:3 inSection:3]] setAccessoryType:UITableViewCellAccessoryNone];
						UIModalView *alert = [[UIModalView alloc] initWithTitle:@"Error" buttons:[NSArray arrayWithObjects:@"Okay", nil] defaultButtonIndex:0 delegate:nil context:NULL];
						[alert setBodyText:@"You cannot have the cycling and the reverse cycling gestures be the same. Please select another gesture for reverse cycling."];
						[alert setNumberOfRows:1];
						[alert popupAlertAnimated:YES];
						[alert release];
						_reverseIt = 5;
						[dict setObject:[NSNumber numberWithInt:_reverseIt] forKey:@"reverse"];
					}
					[dict setObject:[NSNumber numberWithInt:_cycleIt] forKey:@"cycle"];
					break;
				case 3:
					_reverseIt = indexPath.row;
					if (_reverseIt == _backgroundIt) {
						[[[self _tableView] cellForRowAtIndexPath:[NSIndexPath indexPathForRow:0 inSection:0]] setAccessoryType:UITableViewCellAccessoryNone];
						[[[self _tableView] cellForRowAtIndexPath:[NSIndexPath indexPathForRow:1 inSection:0]] setAccessoryType:UITableViewCellAccessoryNone];
						[[[self _tableView] cellForRowAtIndexPath:[NSIndexPath indexPathForRow:2 inSection:0]] setAccessoryType:UITableViewCellAccessoryNone];
						[[[self _tableView] cellForRowAtIndexPath:[NSIndexPath indexPathForRow:3 inSection:0]] setAccessoryType:UITableViewCellAccessoryNone];
						UIModalView *alert = [[UIModalView alloc] initWithTitle:@"Error" buttons:[NSArray arrayWithObjects:@"Okay", nil] defaultButtonIndex:0 delegate:nil context:NULL];
						[alert setBodyText:@"You cannot have the reverse cycling and backgrounding gestures be the same. Please select another gesture for backgrounding."];
						[alert setNumberOfRows:1];
						[alert popupAlertAnimated:YES];
						[alert release];
						_backgroundIt = 5;
						[dict setObject:[NSNumber numberWithInt:_backgroundIt] forKey:@"background"];
					} else if (_reverseIt == _quitIt) {
						[[[self _tableView] cellForRowAtIndexPath:[NSIndexPath indexPathForRow:0 inSection:1]] setAccessoryType:UITableViewCellAccessoryNone];
						[[[self _tableView] cellForRowAtIndexPath:[NSIndexPath indexPathForRow:1 inSection:1]] setAccessoryType:UITableViewCellAccessoryNone];
						[[[self _tableView] cellForRowAtIndexPath:[NSIndexPath indexPathForRow:2 inSection:1]] setAccessoryType:UITableViewCellAccessoryNone];
						[[[self _tableView] cellForRowAtIndexPath:[NSIndexPath indexPathForRow:3 inSection:1]] setAccessoryType:UITableViewCellAccessoryNone];
						UIModalView *alert = [[UIModalView alloc] initWithTitle:@"Error" buttons:[NSArray arrayWithObjects:@"Okay", nil] defaultButtonIndex:0 delegate:nil context:NULL];
						[alert setBodyText:@"You cannot have the reverse cycling and the cycling gestures be the same. Please select another gesture for cycling."];
						[alert setNumberOfRows:1];
						[alert popupAlertAnimated:YES];
						[alert release];
						_quitIt = 5;
						[dict setObject:[NSNumber numberWithInt:_quitIt] forKey:@"quit"];
					} else if (_reverseIt == _cycleIt) {
						[[[self _tableView] cellForRowAtIndexPath:[NSIndexPath indexPathForRow:0 inSection:2]] setAccessoryType:UITableViewCellAccessoryNone];
						[[[self _tableView] cellForRowAtIndexPath:[NSIndexPath indexPathForRow:1 inSection:2]] setAccessoryType:UITableViewCellAccessoryNone];
						[[[self _tableView] cellForRowAtIndexPath:[NSIndexPath indexPathForRow:2 inSection:2]] setAccessoryType:UITableViewCellAccessoryNone];
						[[[self _tableView] cellForRowAtIndexPath:[NSIndexPath indexPathForRow:3 inSection:2]] setAccessoryType:UITableViewCellAccessoryNone];
						UIModalView *alert = [[UIModalView alloc] initWithTitle:@"Error" buttons:[NSArray arrayWithObjects:@"Okay", nil] defaultButtonIndex:0 delegate:nil context:NULL];
						[alert setBodyText:@"You cannot have the reverse cycling and the cycling gestures be the same. Please select another gesture for cycling."];
						[alert setNumberOfRows:1];
						[alert popupAlertAnimated:YES];
						[alert release];
						_cycleIt = 5;
						[dict setObject:[NSNumber numberWithInt:_cycleIt] forKey:@"cycle"];
					}
					[dict setObject:[NSNumber numberWithInt:_reverseIt] forKey:@"reverse"];
					break;
				default:
					break;
			}
			break;
		case 5:
			errored = NO;
			start = -1;
			for (NSString *theme in _themes) {
				start++;
				[[[self _tableView] cellForRowAtIndexPath:[NSIndexPath indexPathForRow:start inSection:0]] setAccessoryType:UITableViewCellAccessoryNone];
			}
			[cell setAccessoryType:UITableViewCellAccessoryCheckmark];
			_currentTheme = [cell.textLabel.text retain];
			[dict setObject:_currentTheme forKey:@"theme"];
			break;
		default:
			identifier = nil;
			break;
	}
	[dict writeToFile:@"/var/mobile/Library/Preferences/com.zimm.circuitous.plist" atomically:YES];
	CFNotificationCenterPostNotification(CFNotificationCenterGetDarwinNotifyCenter(), CFSTR("com.zimm.circuitous.settingschanged"), NULL, NULL, true);
	[dict release];
	[tableView deselectRowAtIndexPath:indexPath animated:YES];
}

@end
