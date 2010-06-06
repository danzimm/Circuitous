//Created by DanZimm
#import <mach/mach_host.h>
#import <dirent.h>
#include <stdio.h>
#include <unistd.h>
#include <stdlib.h>
#include <ctype.h>
#include <time.h>
#import "UIModalViewDelegate.h"
#import "UIModalView.h"
@class UIImageView;
@class CIRScrollView;
@class UIView;
@interface CIRLauncherView : UIWindow<UIModalViewDelegate>
{
	UIImageView *_backgroundView;
	CIRScrollView *_activeAppsScrollView;
	CIRScrollView *_favoriteAppsScrollView;
	UILabel *_fm;
	NSTimer *_fmTimer;
	UIWindow *_bg;
	CGRect mainRect;
	BOOL stop;
}

+ (UIModalView *)currentView;

- (id)initWithActiveApps:(NSArray *)apps favoriteApps:(NSArray *)apps2 window:(UIWindow *)window;
- (void)relayoutWithApps:(NSArray *)apps;
- (void)reorientateWithPlace:(int)place;

@end