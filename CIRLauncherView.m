//Created by DanZimm

#import <SpringBoard/SpringBoard.h>

#import "CIRLauncherView.h"
#import "CIRScrollView.h"

#import "UIModalView.h"

static BOOL _freememory = YES;
static BOOL _sb = YES;
static BOOL _wide = NO;
static BOOL _favs = YES;
static int _orientation = 1;
static BOOL _dbl = NO;
static int _place = 0;

static int GetBytesToMalloc();

static void freeMemory()
{
	id POOL = [[NSAutoreleasePool alloc] init];
	
	int AllocSize =  GetBytesToMalloc();
	void* Test = malloc(AllocSize);
	if(Test != NULL)
	{
		NSLog(@"Processing %d bytes\n", AllocSize);
		memset(Test, 0, AllocSize);
		free(Test);
	}
	
	[POOL release];
	
}

static int GetBytesToMalloc()
{
	// Get page size.
	vm_size_t pageSize;
	host_page_size(mach_host_self(), &pageSize);	
	
	// Get used memory
	struct vm_statistics VmStats;
	mach_msg_type_number_t host_info_count;
	host_info_count = sizeof(VmStats);
	host_statistics(mach_host_self(), HOST_VM_INFO, (host_info_t)&VmStats, &host_info_count);
	
	int AvailableMemory = VmStats.free_count + VmStats.inactive_count;
	AvailableMemory = AvailableMemory * pageSize;
	
	return AvailableMemory;
}



static int getFreeMemory() {
	vm_size_t pageSize;
	host_page_size(mach_host_self(), &pageSize);
	struct vm_statistics vmStats;
	mach_msg_type_number_t infoCount = sizeof(vmStats);
	host_statistics(mach_host_self(), HOST_VM_INFO, (host_info_t)&vmStats, &infoCount);
	int availMem = vmStats.free_count + vmStats.inactive_count;
	return (availMem * pageSize) / 1024 / 1024;
}


@interface SpringBoard (iPad)
-(int)activeInterfaceOrientation;
@end

@interface UIDevice (iPad)
- (BOOL)isWildcat;
@end

static UIModalView *_alert = nil;

#define isWildcat ([[UIDevice currentDevice] respondsToSelector:@selector(isWildcat)] && [[UIDevice currentDevice] isWildcat])

@implementation CIRLauncherView

+ (UIModalView *)currentView
{
	return _alert;
}


- (id)initWithActiveApps:(NSArray *)apps favoriteApps:(NSArray *)apps2 window:(UIWindow *)window
{
	NSDictionary *prefs = [[NSDictionary alloc] initWithContentsOfFile:@"/var/mobile/Library/Preferences/com.zimm.circuitous.plist"];
	_favs = [prefs objectForKey:@"favs"] ? [[prefs objectForKey:@"favs"] boolValue] : YES;
	_wide = [prefs objectForKey:@"wide"] ? [[prefs objectForKey:@"wide"] boolValue] : NO;
	_dbl = [prefs objectForKey:@"dbl"] ? [[prefs objectForKey:@"dbl"] boolValue] : YES;
	_place = [prefs objectForKey:@"place"] ? [[prefs objectForKey:@"place"] intValue] : 0;
	if isWildcat
		_orientation = [(SpringBoard *)[UIApplication sharedApplication] activeInterfaceOrientation];
	else {
		switch ([(SpringBoard *)[UIApplication sharedApplication] _frontMostAppOrientation]) {
			case 0:
				_orientation = 1;
				break;
			case 180:
				_orientation = 2;
				break;
			case 90:
				_orientation = 3;
				break;
			case -90:
				_orientation = 4;
				break;
			default:
				break;
		}
	}
	id orig;
	switch (_place) {
		case 0:
			if isWildcat {
				if (!_wide && _favs) {
					_backgroundView = [[UIImageView alloc] initWithImage:[UIImage imageWithContentsOfFile:@"/Applications/Circuitous.app/background-ipad.png"]];
					orig = [super initWithFrame:CGRectMake(0.0f,0.0f,400.0f,250.0f)];
				} else if (!_wide && !_favs) {
					_backgroundView = [[UIImageView alloc] initWithImage:[UIImage imageWithContentsOfFile:@"/Applications/Circuitous.app/background-ipad-slim.png"]];
					orig = [super initWithFrame:CGRectMake(0.0f,0.0f,400.0f,125.0f)];
				} else if (!_dbl || !_favs) {
					_backgroundView = [[UIImageView alloc] initWithImage:[UIImage imageWithContentsOfFile:@"/Applications/Circuitous.app/background-ipad-wide-slim.png"]];
					orig = [super initWithFrame:CGRectMake(0.0f,0.0f,768.0f,125.0f)];
				} else {
					_backgroundView = [[UIImageView alloc] initWithImage:[UIImage imageWithContentsOfFile:@"/Applications/Circuitous.app/background-ipad-wide.png"]];
					orig = [super initWithFrame:CGRectMake(0.0f,0.0f,768.0f,250.0f)];
				}
			} else {
				if (_favs && _dbl) {
					_backgroundView = [[UIImageView alloc] initWithImage:[UIImage imageWithContentsOfFile:@"/Applications/Circuitous.app/background-iphone.png"]];
					orig = [super initWithFrame:CGRectMake(0.0f,0.0f,320.0f,175.0f)];
				} else {
					_backgroundView = [[UIImageView alloc] initWithImage:[UIImage imageWithContentsOfFile:@"/Applications/Circuitous.app/background-iphone-slim.png"]];
					orig = [super initWithFrame:CGRectMake(0.0f,0.0f,320.0f,90.0f)];
				}
			}
			break;
		case 1:
			if isWildcat {
				if (!_wide && _favs) {
					_backgroundView = [[UIImageView alloc] initWithImage:[UIImage imageWithContentsOfFile:@"/Applications/Circuitous.app/background-ipad.png"]];
					[_backgroundView setTransform:CGAffineTransformMakeRotation(M_PI)];
					orig = [super initWithFrame:CGRectMake(0.0f,0.0f,400.0f,250.0f)];
				} else if (!_wide && !_favs) {
					_backgroundView = [[UIImageView alloc] initWithImage:[UIImage imageWithContentsOfFile:@"/Applications/Circuitous.app/background-ipad-slim.png"]];
					[_backgroundView setTransform:CGAffineTransformMakeRotation(M_PI)];
					orig = [super initWithFrame:CGRectMake(0.0f,0.0f,400.0f,125.0f)];
				} else if (!_dbl || !_favs) {
					_backgroundView = [[UIImageView alloc] initWithImage:[UIImage imageWithContentsOfFile:@"/Applications/Circuitous.app/background-ipad-wide-slim.png"]];
					[_backgroundView setTransform:CGAffineTransformMakeRotation(M_PI)];
					orig = [super initWithFrame:CGRectMake(0.0f,0.0f,768.0f,125.0f)];
				} else {
					_backgroundView = [[UIImageView alloc] initWithImage:[UIImage imageWithContentsOfFile:@"/Applications/Circuitous.app/background-ipad-wide.png"]];
					[_backgroundView setTransform:CGAffineTransformMakeRotation(M_PI)];
					orig = [super initWithFrame:CGRectMake(0.0f,0.0f,768.0f,250.0f)];
				}
			} else {
				if (_favs && _dbl) {
					_backgroundView = [[UIImageView alloc] initWithImage:[UIImage imageWithContentsOfFile:@"/Applications/Circuitous.app/background-iphone.png"]];
					[_backgroundView setTransform:CGAffineTransformMakeRotation(M_PI)];
					orig = [super initWithFrame:CGRectMake(0.0f,0.0f,320.0f,175.0f)];
				} else {
					_backgroundView = [[UIImageView alloc] initWithImage:[UIImage imageWithContentsOfFile:@"/Applications/Circuitous.app/background-iphone-slim.png"]];
					[_backgroundView setTransform:CGAffineTransformMakeRotation(M_PI)];
					orig = [super initWithFrame:CGRectMake(0.0f,0.0f,320.0f,90.0f)];
				}
			}
			break;
		case 2:
			if isWildcat {
				if (!_wide && _favs) {
					_backgroundView = [[UIImageView alloc] initWithImage:[UIImage imageWithContentsOfFile:@"/Applications/Circuitous.app/background-ipad.png"]];
					[_backgroundView setTransform:CGAffineTransformMakeRotation((M_PI/180)*-90)];
					orig = [super initWithFrame:CGRectMake(0.0f,0.0f,250.0f,400.0f)];
				} else if (!_wide && !_favs) {
					_backgroundView = [[UIImageView alloc] initWithImage:[UIImage imageWithContentsOfFile:@"/Applications/Circuitous.app/background-ipad-slim.png"]];
					[_backgroundView setTransform:CGAffineTransformMakeRotation((M_PI/180)*-90)];
					orig = [super initWithFrame:CGRectMake(0.0f,0.0f,125.0f,400.0f)];
				} else if (!_dbl || !_favs) {
					_backgroundView = [[UIImageView alloc] initWithImage:[UIImage imageWithContentsOfFile:@"/Applications/Circuitous.app/background-ipad-wide-slim.png"]];
					[_backgroundView setTransform:CGAffineTransformMakeRotation((M_PI/180)*-90)];
					orig = [super initWithFrame:CGRectMake(0.0f,0.0f,125.0f,768.0f)];
				} else {
					_backgroundView = [[UIImageView alloc] initWithImage:[UIImage imageWithContentsOfFile:@"/Applications/Circuitous.app/background-ipad-wide.png"]];
					[_backgroundView setTransform:CGAffineTransformMakeRotation((M_PI/180)*-90)];
					orig = [super initWithFrame:CGRectMake(0.0f,0.0f,250.0f,768.0f)];
				}
			} else {
				if (_favs && _dbl) {
					_backgroundView = [[UIImageView alloc] initWithImage:[UIImage imageWithContentsOfFile:@"/Applications/Circuitous.app/background-iphone.png"]];
					[_backgroundView setTransform:CGAffineTransformMakeRotation((M_PI/180)*-90)];
					orig = [super initWithFrame:CGRectMake(0.0f,0.0f,175.0f,320.0f)];
				} else {
					_backgroundView = [[UIImageView alloc] initWithImage:[UIImage imageWithContentsOfFile:@"/Applications/Circuitous.app/background-iphone-slim.png"]];
					[_backgroundView setTransform:CGAffineTransformMakeRotation((M_PI/180)*-90)];
					orig = [super initWithFrame:CGRectMake(0.0f,0.0f,90.0f,320.0f)];
				}
			}
			break;
		case 3:
			if isWildcat {
				if (!_wide && _favs) {
					_backgroundView = [[UIImageView alloc] initWithImage:[UIImage imageWithContentsOfFile:@"/Applications/Circuitous.app/background-ipad.png"]];
					[_backgroundView setTransform:CGAffineTransformMakeRotation((M_PI/180)*90)];
					orig = [super initWithFrame:CGRectMake(0.0f,0.0f,250.0f,400.0f)];
				} else if (!_wide && !_favs) {
					_backgroundView = [[UIImageView alloc] initWithImage:[UIImage imageWithContentsOfFile:@"/Applications/Circuitous.app/background-ipad-slim.png"]];
					[_backgroundView setTransform:CGAffineTransformMakeRotation((M_PI/180)*90)];
					orig = [super initWithFrame:CGRectMake(0.0f,0.0f,125.0f,400.0f)];
				} else if (!_dbl || !_favs) {
					_backgroundView = [[UIImageView alloc] initWithImage:[UIImage imageWithContentsOfFile:@"/Applications/Circuitous.app/background-ipad-wide-slim.png"]];
					[_backgroundView setTransform:CGAffineTransformMakeRotation((M_PI/180)*90)];
					orig = [super initWithFrame:CGRectMake(0.0f,0.0f,125.0f,768.0f)];
				} else {
					_backgroundView = [[UIImageView alloc] initWithImage:[UIImage imageWithContentsOfFile:@"/Applications/Circuitous.app/background-ipad-wide.png"]];
					[_backgroundView setTransform:CGAffineTransformMakeRotation((M_PI/180)*90)];
					orig = [super initWithFrame:CGRectMake(0.0f,0.0f,250.0f,768.0f)];
				}
			} else {
				if (_favs && _dbl) {
					_backgroundView = [[UIImageView alloc] initWithImage:[UIImage imageWithContentsOfFile:@"/Applications/Circuitous.app/background-iphone.png"]];
					[_backgroundView setTransform:CGAffineTransformMakeRotation((M_PI/180)*90)];
					orig = [super initWithFrame:CGRectMake(0.0f,0.0f,175.0f,320.0f)];
				} else {
					_backgroundView = [[UIImageView alloc] initWithImage:[UIImage imageWithContentsOfFile:@"/Applications/Circuitous.app/background-iphone-slim.png"]];
					[_backgroundView setTransform:CGAffineTransformMakeRotation((M_PI/180)*90)];
					orig = [super initWithFrame:CGRectMake(0.0f,0.0f,90.0f,320.0f)];
				}
			}
			break;
		default:
			orig = [super init];
			break;
	}
	mainRect = self.frame;
	self.windowLevel = 300;
	_bg = window;
	_backgroundView.frame = self.frame;
	[self addSubview:_backgroundView];
	_sb = [prefs objectForKey:@"springboard"] ? [[prefs objectForKey:@"springboard"] boolValue] : YES;
	NSMutableArray *tmp = [[NSMutableArray alloc] initWithArray:apps];
	if (_sb)
		[tmp insertObject:@"com.apple.springboard" atIndex:0];
	[apps release];
	for (NSString *app in (NSArray *)[prefs objectForKey:@"hidden"]) {
		if ([tmp containsObject:app])
			[tmp removeObject:app];
	}
	apps = [[NSArray alloc] initWithArray:tmp];
	[tmp release];
	_freememory = [prefs objectForKey:@"freememory"] ? [[prefs objectForKey:@"freememory"] boolValue] : YES;
	if (_freememory) {
		_fmTimer = [NSTimer scheduledTimerWithTimeInterval:1/1 target:self selector:@selector(timerFired:) userInfo:nil repeats:YES];
		_fm = [[UILabel alloc] initWithFrame:CGRectMake(0.0f,0.0f,100.0f,12.0f)];
		if isWildcat {
			switch (_place) {
				case 0:
					if ((_favs && !_wide) || (_favs && _dbl && _wide)) {
						_fm.center = self.center;
					} else {
						_fm.center = CGPointMake(self.center.x, 125.0f-12.0f);
					}
				case 1:
					if ((_favs && !_wide) || (_favs && _dbl && _wide)) {
						_fm.center = self.center;
					} else {
						_fm.center = CGPointMake(self.center.x, 125.0f-12.0f);
					}
					break;
				case 2:
					_fm.center = CGPointMake(self.center.x - 5.0f, 15.0f);
					break;
				case 3:
					_fm.center = CGPointMake(self.center.x - 5.0f, 15.0f);
					break;
				default:
					break;
			}
		} else {
			switch (_place) {
				case 0:
					if (_favs && _dbl) {
						_fm.center = self.center;
					} else {
						_fm.center = CGPointMake(self.center.x, 90.0f - 12.0f);
					}
					break;
				case 1:
					if (_favs && _dbl) {
						_fm.center = self.center;
					} else {
						_fm.center = CGPointMake(self.center.x, 12.0f);
					}
					break;
				case 2:
					if (_favs && _dbl) {
						_fm.center = self.center;
					} else {
						_fm.center = CGPointMake(self.center.x, 12.0f);
					}
					break;
				case 3:
					if (_favs && _dbl) {
						_fm.center = self.center;
					} else {
						_fm.center = CGPointMake(self.center.x, 12.0f);
					}
					break;
				default:
					break;
			}
		}
		_fm.font = [UIFont systemFontOfSize:12.0f];
		_fm.textAlignment = UITextAlignmentCenter;
		_fm.backgroundColor = [UIColor clearColor];
		_fm.text = [NSString stringWithFormat:@"%d mb", getFreeMemory()];
		_fm.textColor = [UIColor whiteColor];
		_fm.userInteractionEnabled = NO;
		[self addSubview:_fm];
	}
	[prefs release];
	if (_place == 0 || _place == 1) {
		if isWildcat {
			if (!_wide)
				_activeAppsScrollView = [[CIRScrollView alloc] initWithFrame:CGRectMake(10.0f,5.0f,380.0f,115.0f) apps:apps active:YES];
			else if (!_favs || (_dbl && _favs))
				_activeAppsScrollView = [[CIRScrollView alloc] initWithFrame:CGRectMake(10.0f,5.0f,748.0f,115.0f) apps:apps active:YES];
			else
				_activeAppsScrollView = [[CIRScrollView alloc] initWithFrame:CGRectMake(10.0f,5.0f,748.0f/2 - 5.0f,115.0f) apps:apps active:YES];
		} else {
			if (_favs && !_dbl)
				_activeAppsScrollView = [[CIRScrollView alloc] initWithFrame:CGRectMake(5.0f,5.0f,155.0f,80.0f) apps:apps active:YES];
			else
				_activeAppsScrollView = [[CIRScrollView alloc] initWithFrame:CGRectMake(5.0f,5.0f,310.0f,80.0f) apps:apps active:YES];
		}
	} else {
		if isWildcat {
			if (!_wide)
				_activeAppsScrollView = [[CIRScrollView alloc] initWithFrameVertically:CGRectMake(5.0f,10.0f,115.0f,380.0f) apps:apps active:YES];
			else if (!_favs || (_dbl && _favs))
				_activeAppsScrollView = [[CIRScrollView alloc] initWithFrameVertically:CGRectMake(5.0f,10.0f,115.0f,748.0f) apps:apps active:YES];
			else
				_activeAppsScrollView = [[CIRScrollView alloc] initWithFrameVertically:CGRectMake(5.0f,10.0f,115.0f,748.0f/2 - 5.0f) apps:apps active:YES];
		} else {
			if (_favs && !_dbl)
				_activeAppsScrollView = [[CIRScrollView alloc] initWithFrameVertically:CGRectMake(5.0f,5.0f,80.0f,155.0f) apps:apps active:YES];
			else
				_activeAppsScrollView = [[CIRScrollView alloc] initWithFrameVertically:CGRectMake(5.0f,5.0f,80.0f,310.0f) apps:apps active:YES];
		}
	}
	[self addSubview:_activeAppsScrollView];
	if (_favs) {
		if (_place == 0 || _place == 1) {
			if isWildcat {
				if (!_wide)
					_favoriteAppsScrollView = [[CIRScrollView alloc] initWithFrame:CGRectMake(10.0f, 130.0f, 380.0f, 115.0f) apps:apps2 active:NO];
				else if (_dbl)
					_favoriteAppsScrollView = [[CIRScrollView alloc] initWithFrame:CGRectMake(10.0f,130.0f,748.0f,115.0f) apps:apps2 active:NO];
				else
					_favoriteAppsScrollView = [[CIRScrollView alloc] initWithFrame:CGRectMake(748.0f/2 + 5.0f, 5.0f, 748.0f/2 - 5.0f, 115.0f) apps:apps2 active:NO];
				
			} else {
				if (!_dbl)
					_favoriteAppsScrollView = [[CIRScrollView alloc] initWithFrame:CGRectMake(155.0f, 5.0f, 155.0f, 80.0f) apps:apps2 active:NO];
				else
					_favoriteAppsScrollView = [[CIRScrollView alloc] initWithFrame:CGRectMake(5.0f, 90.0f, 310.0f, 80.0f) apps:apps2 active:NO];
			}
		} else {
			if isWildcat {
				if (!_wide)
					_favoriteAppsScrollView = [[CIRScrollView alloc] initWithFrameVertically:CGRectMake(130.0f, 10.0f, 115.0f, 380.0f) apps:apps2 active:NO];
				else if (_dbl)
					_favoriteAppsScrollView = [[CIRScrollView alloc] initWithFrameVertically:CGRectMake(130.0f,10.0f,115.0f,748.0f) apps:apps2 active:NO];
				else
					_favoriteAppsScrollView = [[CIRScrollView alloc] initWithFrameVertically:CGRectMake(5.0f, 748.0f/2 + 5.0f, 115.0f,748.0f/2 - 5.0f) apps:apps2 active:NO];
				
			} else {
				if (!_dbl)
					_favoriteAppsScrollView = [[CIRScrollView alloc] initWithFrameVertically:CGRectMake(5.0f, 155.0f, 80.0f, 155.0f) apps:apps2 active:NO];
				else
					_favoriteAppsScrollView = [[CIRScrollView alloc] initWithFrameVertically:CGRectMake(90.0f, 5.0f, 80.0f, 310.0f) apps:apps2 active:NO];
			}
		}
		[self addSubview:_favoriteAppsScrollView];
	}
	switch (_place) {
		case 0:
			switch (_orientation) {
				case 2:
					[self setTransform:CGAffineTransformMakeRotation((M_PI/180) * 180)];
					[self setFrame:CGRectMake(CGRectGetMaxX([[UIScreen mainScreen] bounds]) - mainRect.size.width, CGRectGetMaxY([[UIScreen mainScreen] bounds]) - 20.0f - mainRect.size.height, mainRect.size.width, mainRect.size.height)];
					break;
				case 3:
					[self setTransform:CGAffineTransformMakeRotation((M_PI/180) * 90)];
					[self setFrame:CGRectMake((CGRectGetMaxX([[UIScreen mainScreen] bounds]) - 20.0f) - mainRect.size.height, 0.0f, mainRect.size.height, mainRect.size.width)];
					[self setCenter:CGPointMake(self.center.x, CGRectGetMidY([[UIScreen mainScreen] bounds]))];
					break;
				case 4:
					[self setTransform:CGAffineTransformMakeRotation((M_PI/180) * -90)];
					[self setFrame:CGRectMake(20.0f, CGRectGetMaxY([[UIScreen mainScreen] bounds]) - mainRect.size.width, mainRect.size.height, mainRect.size.width)];
					[self setCenter:CGPointMake(self.center.x, CGRectGetMidY([[UIScreen mainScreen] bounds]))];
					break;
				case 1:
				default:
					[self setFrame:CGRectMake(0.0f, 20.0f, mainRect.size.width, mainRect.size.height)];
					break;
			}
			break;
		case 1:
			switch (_orientation) {
				case 2:
					[self setTransform:CGAffineTransformMakeRotation((M_PI/180) * 180)];
					[self setFrame:CGRectMake(CGRectGetMaxX([[UIScreen mainScreen] bounds]) - mainRect.size.width, 0.0f, mainRect.size.width, mainRect.size.height)];
					break;
				case 3:
					[self setTransform:CGAffineTransformMakeRotation((M_PI/180) * 90)];
					[self setFrame:CGRectMake(0.0f, 0.0f, mainRect.size.height, mainRect.size.width)];
					[self setCenter:CGPointMake(self.center.x, CGRectGetMidY([[UIScreen mainScreen] bounds]))];
					break;
				case 4:
					[self setTransform:CGAffineTransformMakeRotation((M_PI/180) * -90)];
					[self setFrame:CGRectMake(CGRectGetMaxX([[UIScreen mainScreen] bounds]) - mainRect.size.height, CGRectGetMaxY([[UIScreen mainScreen] bounds]) - mainRect.size.width, mainRect.size.height, mainRect.size.width)];
					[self setCenter:CGPointMake(self.center.x, CGRectGetMidY([[UIScreen mainScreen] bounds]))];
					break;
				case 1:
				default:
					[self setFrame:CGRectMake(0.0f, CGRectGetMaxY([[UIScreen mainScreen] bounds]) - mainRect.size.height, mainRect.size.width, mainRect.size.height)];
					break;
			}
			break;
		case 2:
			switch (_orientation) {
				case 2:
					[self setTransform:CGAffineTransformMakeRotation((M_PI/180) * 180)];
					[self setFrame:CGRectMake(CGRectGetMaxX([[UIScreen mainScreen] bounds]) - mainRect.size.width, CGRectGetMaxY([[UIScreen mainScreen] bounds]) - mainRect.size.height - 20.0f, mainRect.size.width, mainRect.size.height)];
					[self setCenter:CGPointMake(self.center.x, CGRectGetMidY([[UIScreen mainScreen] bounds]))];
					break;
				case 3:
					[self setTransform:CGAffineTransformMakeRotation((M_PI/180) * 90)];
					[self setFrame:CGRectMake(CGRectGetMaxX([[UIScreen mainScreen] bounds]) - mainRect.size.height - 20.0f, 0.0f, mainRect.size.height, mainRect.size.width)];
					break;
				case 4:
					[self setTransform:CGAffineTransformMakeRotation((M_PI/180) * -90)];
					[self setFrame:CGRectMake(20.0f, CGRectGetMaxY([[UIScreen mainScreen] bounds]) - mainRect.size.width, mainRect.size.height, mainRect.size.width)];
					break;
				case 1:
				default:
					[self setFrame:CGRectMake(0.0f, 20.0f, mainRect.size.width, mainRect.size.height)];
					[self setCenter:CGPointMake(self.center.x, CGRectGetMidY([[UIScreen mainScreen] bounds]))];
					break;
			}
			break;
		case 3:
			switch (_orientation) {
				case 2:
					[self setTransform:CGAffineTransformMakeRotation((M_PI/180) * 180)];
					[self setFrame:CGRectMake(0.0f, CGRectGetMaxY([[UIScreen mainScreen] bounds]) - mainRect.size.height - 20.0f, mainRect.size.width, mainRect.size.height)];
					[self setCenter:CGPointMake(self.center.x, CGRectGetMidY([[UIScreen mainScreen] bounds]))];
					break;
				case 3:
					[self setTransform:CGAffineTransformMakeRotation((M_PI/180) * 90)];
					[self setFrame:CGRectMake(CGRectGetMaxX([[UIScreen mainScreen] bounds]) - mainRect.size.height - 20.0f, CGRectGetMaxY([[UIScreen mainScreen] bounds]) - mainRect.size.width, mainRect.size.height, mainRect.size.width)];
					break;
				case 4:
					[self setTransform:CGAffineTransformMakeRotation((M_PI/180) * -90)];
					[self setFrame:CGRectMake(20.0f, 0.0f, mainRect.size.height, mainRect.size.width)];
					break;
				case 1:
				default:
					[self setFrame:CGRectMake(CGRectGetMaxX([[UIScreen mainScreen] bounds]) - mainRect.size.width, 20.0f, mainRect.size.width, mainRect.size.height)];
					[self setCenter:CGPointMake(self.center.x, CGRectGetMidY([[UIScreen mainScreen] bounds]))];
					break;
			}
			break;
		default:
			break;
	}
	return orig;
}

- (void)timerFired:(NSTimer *)timer
{
	_fm.text = [NSString stringWithFormat:@"%d mb", getFreeMemory()];
}

- (void)relayoutWithApps:(NSArray *)apps
{
	NSMutableArray *tmp = [[NSMutableArray alloc] initWithArray:apps];
	if (_sb)
		[tmp insertObject:@"com.apple.springboard" atIndex:0];
	[apps release];
	NSDictionary *prefs = [[NSDictionary alloc] initWithContentsOfFile:@"/var/mobile/Library/Preferences/com.zimm.circuitous.plist"];
	for (NSString *app in (NSArray *)[prefs objectForKey:@"hidden"]) {
		if ([tmp containsObject:app])
			[tmp removeObject:app];
	}
	apps = [[NSArray alloc] initWithArray:tmp];
	[tmp release];
	[prefs release];
	NSArray *tmp1 = [[NSArray alloc] initWithArray:[_favoriteAppsScrollView appSet]];
	[UIView beginAnimations:nil context:NULL];
	[UIView setAnimationDuration:0.25f];
	_activeAppsScrollView.alpha = 0.0f;
	[_activeAppsScrollView removeFromSuperview];
	[_activeAppsScrollView release];
	_activeAppsScrollView = nil;
	if (_favs) {
		[_favoriteAppsScrollView removeFromSuperview];
		[_favoriteAppsScrollView release];
		_favoriteAppsScrollView = nil;
	}
	if (_place == 0 || _place == 1) {
		if isWildcat {
			if (!_wide)
				_activeAppsScrollView = [[CIRScrollView alloc] initWithFrame:CGRectMake(10.0f,5.0f,380.0f,115.0f) apps:apps active:YES];
			else if (!_favs || (_dbl && _favs))
				_activeAppsScrollView = [[CIRScrollView alloc] initWithFrame:CGRectMake(10.0f,5.0f,748.0f,115.0f) apps:apps active:YES];
			else
				_activeAppsScrollView = [[CIRScrollView alloc] initWithFrame:CGRectMake(10.0f,5.0f,748.0f/2 - 5.0f,115.0f) apps:apps active:YES];
		} else {
			if (_favs && !_dbl)
				_activeAppsScrollView = [[CIRScrollView alloc] initWithFrame:CGRectMake(5.0f,5.0f,155.0f,80.0f) apps:apps active:YES];
			else
				_activeAppsScrollView = [[CIRScrollView alloc] initWithFrame:CGRectMake(5.0f,5.0f,310.0f,80.0f) apps:apps active:YES];
		}
	} else {
		if isWildcat {
			if (!_wide)
				_activeAppsScrollView = [[CIRScrollView alloc] initWithFrameVertically:CGRectMake(5.0f,10.0f,115.0f,380.0f) apps:apps active:YES];
			else if (!_favs || (_dbl && _favs))
				_activeAppsScrollView = [[CIRScrollView alloc] initWithFrameVertically:CGRectMake(5.0f,10.0f,115.0f,748.0f) apps:apps active:YES];
			else
				_activeAppsScrollView = [[CIRScrollView alloc] initWithFrameVertically:CGRectMake(5.0f,10.0f,115.0f,748.0f/2 - 5.0f) apps:apps active:YES];
		} else {
			if (_favs && !_dbl)
				_activeAppsScrollView = [[CIRScrollView alloc] initWithFrameVertically:CGRectMake(5.0f,5.0f,80.0f,155.0f) apps:apps active:YES];
			else
				_activeAppsScrollView = [[CIRScrollView alloc] initWithFrameVertically:CGRectMake(5.0f,5.0f,80.0f,310.0f) apps:apps active:YES];
		}
	}
	_activeAppsScrollView.alpha = 0.0f;
	if (_favs) {
		if (_place == 0 || _place == 1) {
			if isWildcat {
				if (!_wide)
					_favoriteAppsScrollView = [[CIRScrollView alloc] initWithFrame:CGRectMake(10.0f, 130.0f, 380.0f, 115.0f) apps:tmp1 active:NO];
				else if (_dbl)
					_favoriteAppsScrollView = [[CIRScrollView alloc] initWithFrame:CGRectMake(10.0f,130.0f,748.0f,115.0f) apps:tmp1 active:NO];
				else
					_favoriteAppsScrollView = [[CIRScrollView alloc] initWithFrame:CGRectMake(748.0f/2 + 5.0f, 5.0f, 748.0f/2 - 5.0f, 115.0f) apps:tmp1 active:NO];
				
			} else {
				if (!_dbl)
					_favoriteAppsScrollView = [[CIRScrollView alloc] initWithFrame:CGRectMake(155.0f, 5.0f, 155.0f, 80.0f) apps:tmp1 active:NO];
				else
					_favoriteAppsScrollView = [[CIRScrollView alloc] initWithFrame:CGRectMake(5.0f, 90.0f, 310.0f, 80.0f) apps:tmp1 active:NO];
			}
		} else {
			if isWildcat {
				if (!_wide)
					_favoriteAppsScrollView = [[CIRScrollView alloc] initWithFrameVertically:CGRectMake(130.0f, 10.0f, 115.0f, 380.0f) apps:tmp1 active:NO];
				else if (_dbl)
					_favoriteAppsScrollView = [[CIRScrollView alloc] initWithFrameVertically:CGRectMake(130.0f,10.0f,115.0f,748.0f) apps:tmp1 active:NO];
				else
					_favoriteAppsScrollView = [[CIRScrollView alloc] initWithFrameVertically:CGRectMake(5.0f, 748.0f/2 + 5.0f, 115.0f,748.0f/2 - 5.0f) apps:tmp1 active:NO];
				
			} else {
				if (!_dbl)
					_favoriteAppsScrollView = [[CIRScrollView alloc] initWithFrameVertically:CGRectMake(5.0f, 155.0f, 80.0f, 155.0f) apps:tmp1 active:NO];
				else
					_favoriteAppsScrollView = [[CIRScrollView alloc] initWithFrameVertically:CGRectMake(90.0f, 5.0f, 80.0f, 310.0f) apps:tmp1 active:NO];
			}
		}
		_favoriteAppsScrollView.alpha = 0.0f;
		[self addSubview:_favoriteAppsScrollView];
		_favoriteAppsScrollView.alpha = 1.0f;
	}
	[self addSubview:_activeAppsScrollView];
	_activeAppsScrollView.alpha = 1.0f;
	[UIView commitAnimations];
	[tmp1 release];
}

- (void)reorientateWithPlace:(int)place
{
	if (place == _orientation)
		return;
	_orientation = place;
	[UIView beginAnimations:nil context:NULL];
	[UIView setAnimationDuration:0.32f];
	[UIView setAnimationCurve:UIViewAnimationCurveEaseInOut];
	switch (_place) {
		case 0:
			switch (_orientation) {
				case 2:
					[self setTransform:CGAffineTransformMakeRotation((M_PI/180) * 180)];
					[self setFrame:CGRectMake(CGRectGetMaxX([[UIScreen mainScreen] bounds]) - mainRect.size.width, CGRectGetMaxY([[UIScreen mainScreen] bounds]) - 20.0f - mainRect.size.height, mainRect.size.width, mainRect.size.height)];
					break;
				case 3:
					[self setTransform:CGAffineTransformMakeRotation((M_PI/180) * 90)];
					[self setFrame:CGRectMake((CGRectGetMaxX([[UIScreen mainScreen] bounds]) - 20.0f) - mainRect.size.height, 0.0f, mainRect.size.height, mainRect.size.width)];
					[self setCenter:CGPointMake(self.center.x, CGRectGetMidY([[UIScreen mainScreen] bounds]))];
					break;
				case 4:
					[self setTransform:CGAffineTransformMakeRotation((M_PI/180) * -90)];
					[self setFrame:CGRectMake(20.0f, CGRectGetMaxY([[UIScreen mainScreen] bounds]) - mainRect.size.width, mainRect.size.height, mainRect.size.width)];
					[self setCenter:CGPointMake(self.center.x, CGRectGetMidY([[UIScreen mainScreen] bounds]))];
					break;
				case 1:
				default:
					[self setTransform:CGAffineTransformMakeRotation(0.0f)];
					[self setFrame:CGRectMake(0.0f, 20.0f, mainRect.size.width, mainRect.size.height)];
					break;
			}
			break;
		case 1:
			switch (_orientation) {
				case 2:
					[self setTransform:CGAffineTransformMakeRotation((M_PI/180) * 180)];
					[self setFrame:CGRectMake(CGRectGetMaxX([[UIScreen mainScreen] bounds]) - mainRect.size.width, 0.0f, mainRect.size.width, mainRect.size.height)];
					break;
				case 3:
					[self setTransform:CGAffineTransformMakeRotation((M_PI/180) * 90)];
					[self setFrame:CGRectMake(0.0f, 0.0f, mainRect.size.height, mainRect.size.width)];
					[self setCenter:CGPointMake(self.center.x, CGRectGetMidY([[UIScreen mainScreen] bounds]))];
					break;
				case 4:
					[self setTransform:CGAffineTransformMakeRotation((M_PI/180) * -90)];
					[self setFrame:CGRectMake(CGRectGetMaxX([[UIScreen mainScreen] bounds]) - mainRect.size.height, CGRectGetMaxY([[UIScreen mainScreen] bounds]) - mainRect.size.width, mainRect.size.height, mainRect.size.width)];
					[self setCenter:CGPointMake(self.center.x, CGRectGetMidY([[UIScreen mainScreen] bounds]))];
					break;
				case 1:
				default:
					[self setTransform:CGAffineTransformMakeRotation(0.0f)];
					[self setFrame:CGRectMake(0.0f, CGRectGetMaxY([[UIScreen mainScreen] bounds]) - mainRect.size.height, mainRect.size.width, mainRect.size.height)];
					break;
			}
			break;
		case 2:
			switch (_orientation) {
				case 2:
					[self setTransform:CGAffineTransformMakeRotation((M_PI/180) * 180)];
					[self setFrame:CGRectMake(CGRectGetMaxX([[UIScreen mainScreen] bounds]) - mainRect.size.width, CGRectGetMaxY([[UIScreen mainScreen] bounds]) - mainRect.size.height - 20.0f, mainRect.size.width, mainRect.size.height)];
					[self setCenter:CGPointMake(self.center.x, CGRectGetMidY([[UIScreen mainScreen] bounds]))];
					break;
				case 3:
					[self setTransform:CGAffineTransformMakeRotation((M_PI/180) * 90)];
					[self setFrame:CGRectMake(CGRectGetMaxX([[UIScreen mainScreen] bounds]) - mainRect.size.height - 20.0f, 0.0f, mainRect.size.height, mainRect.size.width)];
					break;
				case 4:
					[self setTransform:CGAffineTransformMakeRotation((M_PI/180) * -90)];
					[self setFrame:CGRectMake(20.0f, CGRectGetMaxY([[UIScreen mainScreen] bounds]) - mainRect.size.width, mainRect.size.height, mainRect.size.width)];
					break;
				case 1:
				default:
					[self setTransform:CGAffineTransformMakeRotation(0.0f)];
					[self setFrame:CGRectMake(0.0f, 20.0f, mainRect.size.width, mainRect.size.height)];
					[self setCenter:CGPointMake(self.center.x, CGRectGetMidY([[UIScreen mainScreen] bounds]))];
					break;
			}
			break;
		case 3:
			switch (_orientation) {
				case 2:
					[self setTransform:CGAffineTransformMakeRotation((M_PI/180) * 180)];
					[self setFrame:CGRectMake(0.0f, CGRectGetMaxY([[UIScreen mainScreen] bounds]) - mainRect.size.height - 20.0f, mainRect.size.width, mainRect.size.height)];
					[self setCenter:CGPointMake(self.center.x, CGRectGetMidY([[UIScreen mainScreen] bounds]))];
					break;
				case 3:
					[self setTransform:CGAffineTransformMakeRotation((M_PI/180) * 90)];
					[self setFrame:CGRectMake(CGRectGetMaxX([[UIScreen mainScreen] bounds]) - mainRect.size.height - 20.0f, CGRectGetMaxY([[UIScreen mainScreen] bounds]) - mainRect.size.width, mainRect.size.height, mainRect.size.width)];
					break;
				case 4:
					[self setTransform:CGAffineTransformMakeRotation((M_PI/180) * -90)];
					[self setFrame:CGRectMake(20.0f, 0.0f, mainRect.size.height, mainRect.size.width)];
					break;
				case 1:
				default:
					[self setTransform:CGAffineTransformMakeRotation(0.0f)];
					[self setFrame:CGRectMake(CGRectGetMaxX([[UIScreen mainScreen] bounds]) - mainRect.size.width, 20.0f, mainRect.size.width, mainRect.size.height)];
					[self setCenter:CGPointMake(self.center.x, CGRectGetMidY([[UIScreen mainScreen] bounds]))];
					break;
			}
			break;
		default:
			break;
	}
	[UIView commitAnimations];
}

- (void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event
{
	UITouch *touch = [touches anyObject];
	if (touch.tapCount == 2) {
		stop = YES;
		[UIView beginAnimations:nil context:NULL];
		[UIView setAnimationDuration:0.1f];
		_bg.alpha = 0.0f;
		_bg.hidden = YES;
		[UIView commitAnimations];
		if (!_alert) {
			_alert = [[UIModalView alloc] initWithTitle:@"Free Memory" buttons:[NSArray arrayWithObjects:@"Thrice", @"Twice", @"Once", @"Cancel", nil] defaultButtonIndex:0 delegate:self context:NULL];
			[_alert setNumberOfRows:2];
			[_alert popupAlertAnimated:YES];
		}
	}
}

-(void)modalView:(id)view didDismissWithButtonIndex:(int)buttonIndex
{
	switch (buttonIndex) {
		case 0:
			freeMemory();
			freeMemory();
			freeMemory();
			break;
		case 1:
			freeMemory();
			freeMemory();
			break;
		case 2:
			freeMemory();
			break;
		default:
			break;
	}
	[_alert release];
	_alert = nil;
	[UIView beginAnimations:nil context:NULL];
	[UIView setAnimationDuration:0.1f];
	_bg.alpha = 0.5f;
	_bg.hidden = NO;
	[UIView commitAnimations];
	stop = NO;
}


- (void)dealloc
{
	if (_freememory) {
		[_fmTimer invalidate];
	}
	[super dealloc];
}
	

@end