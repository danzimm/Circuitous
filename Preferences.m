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
/*
static NSInteger compareDisplayNames(NSString *a, NSString *b, void *context)
{
    NSInteger ret;
	
    NSString *name_a = SBSCopyLocalizedApplicationNameForDisplayIdentifier(a);
    NSString *name_b = SBSCopyLocalizedApplicationNameForDisplayIdentifier(b);
    ret = [name_a caseInsensitiveCompare:name_b];
    [name_a release];
    [name_b release];
	
    return ret;
}
*/
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
	int _transition;
	int _quitIt;
	int _backgroundIt;
}
//- (id)initForContentSize:(CGSize)size;
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
@end

@implementation CIRPreferencesController

- (id)initForContentSize:(CGSize)size
{
	return [self init];
}

- (id)init
{
	 if ((self = [super init]) != nil) {
		 systemApps = [[NSMutableArray alloc] init];
		 NSMutableArray *paths = [NSMutableArray array];
		 
		 // ... scan /Applications (System/Jailbreak applications)
		 NSFileManager *fileManager = [NSFileManager defaultManager];
		 for (NSString *path in [fileManager directoryContentsAtPath:@"/Applications"]) {
			 if ([path hasSuffix:@".app"] && ![path hasPrefix:@"."])
				 [paths addObject:[NSString stringWithFormat:@"/Applications/%@", path]];
		 }
		 NSMutableArray *identifiers = [NSMutableArray array];
		 
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
		 _tutorial = [[UITextView alloc] initWithFrame:CGRectMake(0, 0, 320, 480-64)];
		 if isWildcat
			 _tutorial.text = @"Welcome to Circuitous! \n\nNOTE: BACKGROUNDER MUST BE INSTALLED TO HAVE APPS RUN IN THE BACKGROUND\n\nDock Activation: Set your activator method to activate the dock with your currently running applications, and, if you choose, your favorite applications as well.\n\nFavorite Apps: You can set your favorites by going into the favorites tab, and checking the apps that you want to appear. Make sure the favorites are enabled as well.\n\nHidden Apps:The hidden apps are kept out of the active applications, however, they can appear in the favorites if you wish. Just check off the one you wish to hide and you're good to go!\n\n\nDsiplay Options:\n\n\nFavorites:Enables or disables favorites shown.\n\nWider:This makes the entire dock wider, for more room to use the dock\n\nDouble Row:This option is only shown if both favorites and wider are enabled. This makes the dock two rows rather than one, where favorites and active apps would be half the size.\n\nTransition:The way that the dock appears and disaapears.\n\n\nSpringBoard Enabled:This adds an icon in the active apps dock to get back to the springboard, or close the springboard if you wish.\n\nApp Animations: This adds animations to launching and quitting apps, if enabled. Otherwise the apps just appear and disappear.\n\nIcon Labels: Adds labels to the icons in the dock.\n\nIcon Badges: Adds badges to icons if they have badges.\n\nBecome Homescreen: Whenever you go to the homescreen the dock will automatically apopear.\n\nIcon: This adds an icon to the springboard allowing you to launch the dock when tapping it. (Note this icon will do nothing when in safe mode)\n\nLockscreen: If enabled, the dock will be allowed to show on the lockscreen.\n\nDimmed Window: If enabled there will be a window behind the dock which, when tapped, will dismiss the dock. On this window you can also slide up to unbackground, and quit the foreground application, or slide down and background and dismiss the foreground application.\n\nFree Memory: When enabled shows the current free RAM in megabytes.\n\nOther Features: You can tap and hold an icon then drag it up or down out of the dock to quit it. The dock supports all orientations, and will change automatically according to how you hold the device, even when the dock is active!\n\nOther Notes: If you have any questions or comments email me: Daniel.zimmerman@me.com. I am planning on adding an option to show the dock at any place on the screen, however I might drop this idea because of how inefficient the program would then be. Other features I have planned are: Specified time to hold an icon to drag, specified time for the transitions, the dock growing even larger when the wide option is enabled and the device is turned to landscape orientation.";
		 else
			 _tutorial.text = @"Welcome to Circuitous! \n\nNOTE: BACKGROUNDER MUST BE INSTALLED TO HAVE APPS RUN IN THE BACKGROUND\n\nDock Activation: Set your activator method to activate the dock with your currently running applications, and, if you choose, your favorite applications as well.\n\nFavorite Apps: You can set your favorites by going into the favorites tab, and checking the apps that you want to appear. Make sure the favorites are enabled as well.\n\nHidden Apps:The hidden apps are kept out of the active applications, however, they can appear in the favorites if you wish. Just check off the one you wish to hide and you're good to go!\n\n\nDsiplay Options:\n\n\nFavorites:Enables or disables favorites shown.\n\nTransition:The way that the dock appears and disaapears.\n\n\nSpringBoard Enabled:This adds an icon in the active apps dock to get back to the springboard, or close the springboard if you wish.\n\nApp Animations: This adds animations to launching and quitting apps, if enabled. Otherwise the apps just appear and disappear.\n\nIcon Labels: Adds labels to the icons in the dock.\n\nIcon Badges: Adds badges to icons if they have badges.\n\nBecome Homescreen: Whenever you go to the homescreen the dock will automatically apopear.\n\nIcon: This adds an icon to the springboard allowing you to launch the dock when tapping it. (Note this icon will do nothing when in safe mode)\n\nLockscreen: If enabled, the dock will be allowed to show on the lockscreen.\n\nDimmed Window: If enabled there will be a window behind the dock which, when tapped, will dismiss the dock. On this window you can set the gestures for backgrounding and quitting the foreground application. Also, you can souble tap it to show a free memory alert, alowing you to free up memory.\n\nFree Memory: When enabled shows the current free RAM in megabytes. You can free up memory by double tapping on the dimmed window.\n\nOther Features: You can tap and hold an icon then drag it up or down out of the dock to quit it. The dock supports all orientations, and will change automatically according to how you hold the device, even when the dock is active!\n\nOther Notes: If you have any questions or comments email me: Daniel.zimmerman@me.com. I am planning on adding an option to show the dock at any place on the screen, however I might drop this idea because of how inefficient the program would then be. Other features I have planned are: Specified time to hold an icon to drag, specified time for the transitions, the dock growing even larger when the wide option is enabled and the device is turned to landscape orientation.";
		 _tutorial.font = [UIFont systemFontOfSize:16.0f];
		 _tutorial.editable = NO;
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
	switch (_use) {
		case 0:
			applicationsHere = [[NSMutableArray alloc] initWithArray:(NSArray *)[dict objectForKey:@"favorites"]];
			break;
		case 1:
			applicationsHere = [[NSMutableArray alloc] initWithArray:(NSArray *)[dict objectForKey:@"hidden"]];	
			break;
		case 3:
			_favs = [dict objectForKey:@"favs"] ? [[dict objectForKey:@"favs"] boolValue] : YES;
			_wide = [dict objectForKey:@"wide"] ? [[dict objectForKey:@"wide"] boolValue] : NO;
			_double = [dict objectForKey:@"dbl"] ? [[dict objectForKey:@"dbl"] boolValue] : YES;
			_transition = [dict objectForKey:@"trans"] ? [[dict objectForKey:@"trans"] intValue] : 0;
			break;
		case 4:
			_quitIt = [dict objectForKey:@"quit"] ? [[dict objectForKey:@"quit"] intValue] : 1;
			_backgroundIt = [dict objectForKey:@"background"] ? [[dict objectForKey:@"background"] intValue] : 0;
			UITextView *gestureInfo = [[UITextView alloc] initWithFrame:CGRectMake(0.0f,0.0f,_tableView.frame.size.height, 40.0f)];
			gestureInfo.font = [UIFont systemFontOfSize:16.0f];
			gestureInfo.editable = NO;
			gestureInfo.backgroundColor = [UIColor clearColor];
			gestureInfo.text = @"These gestures are used on the dim window, and will only work if you have the dim window enabled";
			_tableView.tableFooterView = gestureInfo;
			[gestureInfo release];
			break;
		default:
			break;
	}
	[dict release];
	[self setNavigationTitle:[self navigationTitle]];
}

- (void) dealloc {
    [_tableView release];
	[applicationsHere release];
	[appStoreApps release];
	[systemApps release];
	[_tutorial release];
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
	return 2;
}

- (id) tableView:(UITableView *)tableView titleForHeaderInSection:(int)section
{
	switch (_use) {
		case 0:
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
				case 1:
					return @"Transition";
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
					if isWildcat {
						if (_favs && _wide)
							return 3;
						else
							return 2;
					} else {
						return 1;
					}
					break;
				case 1:
					return 3;
					break;
				default:
					return 0;
					break;
			}
			break;
		case 4:
			return 4;
			break;
		default:
			return 0;
			break;
	}
}

- (id) tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
	static NSString *reuseIdentifier = @"ApplicationCell";
	
    // Try to retrieve from the table view a now-unused cell with the given identifier
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:reuseIdentifier];
    if (cell == nil) {
        // Cell does not exist, create a new one
        cell = [[[CIRApplicationCell alloc] initWithFrame:CGRectZero reuseIdentifier:reuseIdentifier] autorelease];
        cell.selectionStyle = UITableViewCellSelectionStyleGray;
    }
	NSString *identifier;
	switch (_use) {
		case 0:
		case 1:
			switch (indexPath.section) {
				case 0:
					identifier = [systemApps objectAtIndex:indexPath.row];
					break;
				default:
				case 1:
					identifier = [appStoreApps objectAtIndex:indexPath.row];
					break;
			}
			NSString *displayName = SBSCopyLocalizedApplicationNameForDisplayIdentifier(identifier);
			[cell textLabel].text = displayName;
			[displayName release];
			
			UIImage *icon = nil;
			NSString *iconPath = SBSCopyIconImagePathForDisplayIdentifier(identifier);
			if (iconPath != nil) {
				icon = [UIImage imageWithContentsOfFile:iconPath];
				[iconPath release];
			}
			
			[cell imageView].image = icon;
			
			cell.accessoryType = [applicationsHere containsObject:identifier] ? UITableViewCellAccessoryCheckmark : UITableViewCellAccessoryNone;
			break;
		case 3:
			switch (indexPath.section) {
				case 0:
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
					break;
				case 1:
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
				default:
					break;
			}
			break;
		case 4:
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
			if ((indexPath.section == 0 && (int)indexPath.row == _backgroundIt) || (indexPath.section == 1 && (int)indexPath.row == _quitIt))
				cell.accessoryType = UITableViewCellAccessoryCheckmark;
			break;
		default:
			break;
	}
	return cell;
}

- (void) tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
	NSMutableDictionary *dict = [[NSMutableDictionary alloc] initWithContentsOfFile:@"/var/mobile/Library/Preferences/com.zimm.circuitous.plist"];
	UITableViewCell *cell = [[self _tableView] cellForRowAtIndexPath:indexPath];
	NSString *identifier;
	switch (_use) {
		case 0:
		case 1:
			switch (indexPath.section) {
				case 0:
					identifier = [systemApps objectAtIndex:indexPath.row];
					break;
				default:
				case 1:
					identifier = [appStoreApps objectAtIndex:indexPath.row];
					break;
			}
			if (cell.accessoryType == UITableViewCellAccessoryNone) {
				[applicationsHere addObject:identifier];
				cell.accessoryType = UITableViewCellAccessoryCheckmark;
			} else {
				[applicationsHere removeObject:identifier];
				cell.accessoryType = UITableViewCellAccessoryNone;
			}
			if (_use == 0)
				[dict setObject:applicationsHere forKey:@"favorites"];
			else
				[dict setObject:applicationsHere forKey:@"hidden"];
			break;
		case 3:
			switch (indexPath.section) {
				case 1:
					[[[self _tableView] cellForRowAtIndexPath:[NSIndexPath indexPathForRow:0 inSection:1]] setAccessoryType:UITableViewCellAccessoryNone];
					[[[self _tableView] cellForRowAtIndexPath:[NSIndexPath indexPathForRow:1 inSection:1]] setAccessoryType:UITableViewCellAccessoryNone];
					[[[self _tableView] cellForRowAtIndexPath:[NSIndexPath indexPathForRow:2 inSection:1]] setAccessoryType:UITableViewCellAccessoryNone];
					[cell setAccessoryType:UITableViewCellAccessoryCheckmark];
					_transition = indexPath.row;
					[dict setObject:[NSNumber numberWithInt:_transition] forKey:@"trans"];
					break;
				case 0:
					if ((UITableViewCellAccessoryType *)cell.accessoryType == UITableViewCellAccessoryNone)
						cell.accessoryType = UITableViewCellAccessoryCheckmark;
					else
						cell.accessoryType = UITableViewCellAccessoryNone;
					switch (indexPath.row) {
						case 0:
							if ((UITableViewCellAccessoryType *)cell.accessoryType == UITableViewCellAccessoryNone)
								_favs = NO;
							else
								_favs = YES;
							if (_favs && _wide) {
								[[self _tableView] insertRowsAtIndexPaths:[NSArray arrayWithObjects:[NSIndexPath indexPathForRow:2 inSection:0], nil] withRowAnimation:UITableViewRowAnimationTop];
							} else if (_wide) {
								[[self _tableView] deleteRowsAtIndexPaths:[NSArray arrayWithObjects:[NSIndexPath indexPathForRow:2 inSection:0], nil] withRowAnimation:UITableViewRowAnimationTop];
							}
							[dict setObject:[NSNumber numberWithBool:_favs] forKey:@"favs"];
							break;
						case 1:
							if ((UITableViewCellAccessoryType *)cell.accessoryType == UITableViewCellAccessoryNone)
								_wide = NO;
							else
								_wide = YES;
							if (_favs && _wide) {
								[[self _tableView] insertRowsAtIndexPaths:[NSArray arrayWithObjects:[NSIndexPath indexPathForRow:2 inSection:0], nil] withRowAnimation:UITableViewRowAnimationTop];
							} else if (_favs) {
								[[self _tableView] deleteRowsAtIndexPaths:[NSArray arrayWithObjects:[NSIndexPath indexPathForRow:2 inSection:0], nil] withRowAnimation:UITableViewRowAnimationTop];
							}
							[dict setObject:[NSNumber numberWithBool:_wide] forKey:@"wide"];
							break;
						case 2:
							if ((UITableViewCellAccessoryType *)cell.accessoryType == UITableViewCellAccessoryNone)
								_double = NO;
							else
								_double = YES;
							[dict setObject:[NSNumber numberWithBool:_double] forKey:@"dbl"];
							break;
						default:
							break;
					}
					break;
				default:
					break;
			}
			break;
		case 4:
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
						[alert setBodyText:@"You cannot have the backgrounding and quitting gesture be the same. Please select another gesture for quitting."];
						[alert setNumberOfRows:1];
						[alert popupAlertAnimated:YES];
						[alert release];
						_quitIt = 5;
						[dict setObject:[NSNumber numberWithInt:_quitIt] forKey:@"quit"];
					}
					[dict setObject:[NSNumber numberWithInt:_backgroundIt] forKey:@"background"];
					break;
				case 1:
					_quitIt = indexPath.row;
					if (_backgroundIt == _quitIt) {
						[[[self _tableView] cellForRowAtIndexPath:[NSIndexPath indexPathForRow:0 inSection:0]] setAccessoryType:UITableViewCellAccessoryNone];
						[[[self _tableView] cellForRowAtIndexPath:[NSIndexPath indexPathForRow:1 inSection:0]] setAccessoryType:UITableViewCellAccessoryNone];
						[[[self _tableView] cellForRowAtIndexPath:[NSIndexPath indexPathForRow:2 inSection:0]] setAccessoryType:UITableViewCellAccessoryNone];
						[[[self _tableView] cellForRowAtIndexPath:[NSIndexPath indexPathForRow:3 inSection:0]] setAccessoryType:UITableViewCellAccessoryNone];
						UIModalView *alert = [[UIModalView alloc] initWithTitle:@"Error" buttons:[NSArray arrayWithObjects:@"Okay", nil] defaultButtonIndex:0 delegate:nil context:NULL];
						[alert setBodyText:@"You cannot have the backgrounding and quitting gesture be the same. Please select another gesture for backgrounding."];
						[alert setNumberOfRows:1];
						[alert popupAlertAnimated:YES];
						[alert release];
						_backgroundIt = 5;
						[dict setObject:[NSNumber numberWithInt:_backgroundIt] forKey:@"background"];
					}
					[dict setObject:[NSNumber numberWithInt:_quitIt] forKey:@"quit"];
					break;
				default:
					break;
			}
			break;
		default:
			break;
	}
	[dict writeToFile:@"/var/mobile/Library/Preferences/com.zimm.circuitous.plist" atomically:YES];
	CFNotificationCenterPostNotification(CFNotificationCenterGetDarwinNotifyCenter(), CFSTR("com.zimm.circuitous.settingschanged"), NULL, NULL, true);
	[dict release];
	[tableView deselectRowAtIndexPath:indexPath animated:YES];
}

@end
