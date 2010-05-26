//Created by DanZimm
#import <SpringBoard/SpringBoard.h>

#import "CIRBackgroundWindow.h"

#import "DSDisplayController.h"
#import "UIModalView.h"

@interface SpringBoard (PadLauncher)
- (void)showCircuitous;
- (void)hideCircuitous;
- (int)activeInterfaceOrientation;
@end

@interface UIDevice (iPad)
- (BOOL)isWildcat;
@end

#define isWildcat ([[UIDevice currentDevice] respondsToSelector:@selector(isWildcat)] && [[UIDevice currentDevice] isWildcat])

static int _orientation = 1;
static int _backgroundIt = 0;
static int _quitIt = 0;

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
/*
static int getFreeMemory() {
	vm_size_t pageSize;
	host_page_size(mach_host_self(), &pageSize);
	struct vm_statistics vmStats;
	mach_msg_type_number_t infoCount = sizeof(vmStats);
	host_statistics(mach_host_self(), HOST_VM_INFO, (host_info_t)&vmStats, &infoCount);
	int availMem = vmStats.free_count + vmStats.inactive_count;
	return (availMem * pageSize) / 1024 / 1024;
}
*/
static BOOL stop = NO;

@implementation CIRBackgroundWindow

- (id)init
{
	id orig = [super initWithFrame:[[UIScreen mainScreen] bounds]];
	self.backgroundColor = [UIColor blackColor];
	self.windowLevel = 280;
	NSDictionary *dict = [[NSDictionary alloc] initWithContentsOfFile:@"/var/mobile/Library/Preferences/com.zimm.circuitous.plist"];
	_quitIt = [dict objectForKey:@"quit"] ? [[dict objectForKey:@"quit"] intValue] : 1;
	_backgroundIt = [dict objectForKey:@"background"] ? [[dict objectForKey:@"background"] intValue] : 0;
	[dict release];
	return orig;
}

- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event
{
	[super touchesBegan:touches withEvent:event];
	UITouch *touch = [touches anyObject];
	start = [touch locationInView:self];
}

- (void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event
{
	[super touchesEnded:touches withEvent:event];
	if isWildcat {
		_orientation = [(SpringBoard *)[UIApplication sharedApplication] activeInterfaceOrientation];
	} else {
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
	int kMinimumGestureLength = 200.0f;
	int kMaximumVariance = 1000.0f;
	if (!isWildcat) {
		kMinimumGestureLength = 100.0f;
		kMaximumVariance = 480.0f;
	}
	UITouch *touch = [touches anyObject];
	CGPoint currentPosition = [touch locationInView:self];
	
	CGFloat deltaX = fabsf(start.x - currentPosition.x);
	CGFloat deltaY = fabsf(start.y - currentPosition.y);
	
	// left gesture
	if (start.x > currentPosition.x && deltaY <= kMaximumVariance && deltaX >= kMinimumGestureLength) {
		switch (_orientation) {
			case 1:
				if (_backgroundIt == 2) {
					[[DSDisplayController sharedInstance] setBackgroundingEnabled:YES forApplication:[[DSDisplayController sharedInstance] activeApp]];
					[[DSDisplayController sharedInstance] exitApplication:[[DSDisplayController sharedInstance] activeApp] animated:YES force:NO];
				} else if (_quitIt == 2) {
					[[DSDisplayController sharedInstance] setBackgroundingEnabled:NO forApplication:[[DSDisplayController sharedInstance] activeApp]];
					[[DSDisplayController sharedInstance] exitApplication:[[DSDisplayController sharedInstance] activeApp] animated:YES force:YES];
				}
				break;
			case 2:
				if (_backgroundIt == 3) {
					[[DSDisplayController sharedInstance] setBackgroundingEnabled:YES forApplication:[[DSDisplayController sharedInstance] activeApp]];
					[[DSDisplayController sharedInstance] exitApplication:[[DSDisplayController sharedInstance] activeApp] animated:YES force:NO];
				} else if (_quitIt == 3) {
					[[DSDisplayController sharedInstance] setBackgroundingEnabled:NO forApplication:[[DSDisplayController sharedInstance] activeApp]];
					[[DSDisplayController sharedInstance] exitApplication:[[DSDisplayController sharedInstance] activeApp] animated:YES force:YES];
				}
				break;
			case 3:
				if (_backgroundIt == 0) {
					[[DSDisplayController sharedInstance] setBackgroundingEnabled:YES forApplication:[[DSDisplayController sharedInstance] activeApp]];
					[[DSDisplayController sharedInstance] exitApplication:[[DSDisplayController sharedInstance] activeApp] animated:YES force:NO];
				} else if (_quitIt == 0) {
					[[DSDisplayController sharedInstance] setBackgroundingEnabled:NO forApplication:[[DSDisplayController sharedInstance] activeApp]];
					[[DSDisplayController sharedInstance] exitApplication:[[DSDisplayController sharedInstance] activeApp] animated:YES force:YES];
				}
				break;
			case 4:
				if (_backgroundIt == 1) {
					[[DSDisplayController sharedInstance] setBackgroundingEnabled:YES forApplication:[[DSDisplayController sharedInstance] activeApp]];
					[[DSDisplayController sharedInstance] exitApplication:[[DSDisplayController sharedInstance] activeApp] animated:YES force:NO];
				} else if (_quitIt == 1) {
					[[DSDisplayController sharedInstance] setBackgroundingEnabled:NO forApplication:[[DSDisplayController sharedInstance] activeApp]];
					[[DSDisplayController sharedInstance] exitApplication:[[DSDisplayController sharedInstance] activeApp] animated:YES force:YES];
				}
				break;
			default:
				break;
		}
	}
	// right gesture
	else if (start.x < currentPosition.x && deltaY <= kMaximumVariance && deltaX >= kMinimumGestureLength) {
		switch (_orientation) {
			case 1:
				if (_backgroundIt == 3) {
					[[DSDisplayController sharedInstance] setBackgroundingEnabled:YES forApplication:[[DSDisplayController sharedInstance] activeApp]];
					[[DSDisplayController sharedInstance] exitApplication:[[DSDisplayController sharedInstance] activeApp] animated:YES force:NO];
				} else if (_quitIt == 3) {
					[[DSDisplayController sharedInstance] setBackgroundingEnabled:NO forApplication:[[DSDisplayController sharedInstance] activeApp]];
					[[DSDisplayController sharedInstance] exitApplication:[[DSDisplayController sharedInstance] activeApp] animated:YES force:YES];
				}
				break;
			case 2:
				if (_backgroundIt == 2) {
					[[DSDisplayController sharedInstance] setBackgroundingEnabled:YES forApplication:[[DSDisplayController sharedInstance] activeApp]];
					[[DSDisplayController sharedInstance] exitApplication:[[DSDisplayController sharedInstance] activeApp] animated:YES force:NO];
				} else if (_quitIt == 2) {
					[[DSDisplayController sharedInstance] setBackgroundingEnabled:NO forApplication:[[DSDisplayController sharedInstance] activeApp]];
					[[DSDisplayController sharedInstance] exitApplication:[[DSDisplayController sharedInstance] activeApp] animated:YES force:YES];
				}
				break;
			case 3:
				if (_backgroundIt == 1) {
					[[DSDisplayController sharedInstance] setBackgroundingEnabled:YES forApplication:[[DSDisplayController sharedInstance] activeApp]];
					[[DSDisplayController sharedInstance] exitApplication:[[DSDisplayController sharedInstance] activeApp] animated:YES force:NO];
				} else if (_quitIt == 1) {
					[[DSDisplayController sharedInstance] setBackgroundingEnabled:NO forApplication:[[DSDisplayController sharedInstance] activeApp]];
					[[DSDisplayController sharedInstance] exitApplication:[[DSDisplayController sharedInstance] activeApp] animated:YES force:YES];
				}
				break;
			case 4:
				if (_backgroundIt == 0) {
					[[DSDisplayController sharedInstance] setBackgroundingEnabled:YES forApplication:[[DSDisplayController sharedInstance] activeApp]];
					[[DSDisplayController sharedInstance] exitApplication:[[DSDisplayController sharedInstance] activeApp] animated:YES force:NO];
				} else if (_quitIt == 0) {
					[[DSDisplayController sharedInstance] setBackgroundingEnabled:NO forApplication:[[DSDisplayController sharedInstance] activeApp]];
					[[DSDisplayController sharedInstance] exitApplication:[[DSDisplayController sharedInstance] activeApp] animated:YES force:YES];
				}
				break;
			default:
				break;
		}
	}
	// up gesture
	else if (start.y > currentPosition.y && deltaX <= kMaximumVariance && deltaY >= kMinimumGestureLength) {
		switch (_orientation) {
			case 1:
				if (_backgroundIt == 1) {
					[[DSDisplayController sharedInstance] setBackgroundingEnabled:YES forApplication:[[DSDisplayController sharedInstance] activeApp]];
					[[DSDisplayController sharedInstance] exitApplication:[[DSDisplayController sharedInstance] activeApp] animated:YES force:NO];
				} else if (_quitIt == 1) {
					[[DSDisplayController sharedInstance] setBackgroundingEnabled:NO forApplication:[[DSDisplayController sharedInstance] activeApp]];
					[[DSDisplayController sharedInstance] exitApplication:[[DSDisplayController sharedInstance] activeApp] animated:YES force:YES];
				}
				break;
			case 2:
				if (_backgroundIt == 0) {
					[[DSDisplayController sharedInstance] setBackgroundingEnabled:YES forApplication:[[DSDisplayController sharedInstance] activeApp]];
					[[DSDisplayController sharedInstance] exitApplication:[[DSDisplayController sharedInstance] activeApp] animated:YES force:NO];
				} else if (_quitIt == 0) {
					[[DSDisplayController sharedInstance] setBackgroundingEnabled:NO forApplication:[[DSDisplayController sharedInstance] activeApp]];
					[[DSDisplayController sharedInstance] exitApplication:[[DSDisplayController sharedInstance] activeApp] animated:YES force:YES];
				}
				break;
			case 3:
				if (_backgroundIt == 2) {
					[[DSDisplayController sharedInstance] setBackgroundingEnabled:YES forApplication:[[DSDisplayController sharedInstance] activeApp]];
					[[DSDisplayController sharedInstance] exitApplication:[[DSDisplayController sharedInstance] activeApp] animated:YES force:NO];
				} else if (_quitIt == 2) {
					[[DSDisplayController sharedInstance] setBackgroundingEnabled:NO forApplication:[[DSDisplayController sharedInstance] activeApp]];
					[[DSDisplayController sharedInstance] exitApplication:[[DSDisplayController sharedInstance] activeApp] animated:YES force:YES];
				}
				break;
			case 4:
				if (_backgroundIt == 3) {
					[[DSDisplayController sharedInstance] setBackgroundingEnabled:YES forApplication:[[DSDisplayController sharedInstance] activeApp]];
					[[DSDisplayController sharedInstance] exitApplication:[[DSDisplayController sharedInstance] activeApp] animated:YES force:NO];
				} else if (_quitIt == 3) {
					[[DSDisplayController sharedInstance] setBackgroundingEnabled:NO forApplication:[[DSDisplayController sharedInstance] activeApp]];
					[[DSDisplayController sharedInstance] exitApplication:[[DSDisplayController sharedInstance] activeApp] animated:YES force:YES];
				}
				break;
			default:
				break;
		}
	}
	// down gesture
	else if (start.y < currentPosition.y && deltaX <= kMaximumVariance && deltaY >= kMinimumGestureLength) {
		switch (_orientation) {
			case 1:
				if (_backgroundIt == 0) {
					[[DSDisplayController sharedInstance] setBackgroundingEnabled:YES forApplication:[[DSDisplayController sharedInstance] activeApp]];
					[[DSDisplayController sharedInstance] exitApplication:[[DSDisplayController sharedInstance] activeApp] animated:YES force:NO];
				} else if (_quitIt == 0) {
					[[DSDisplayController sharedInstance] setBackgroundingEnabled:NO forApplication:[[DSDisplayController sharedInstance] activeApp]];
					[[DSDisplayController sharedInstance] exitApplication:[[DSDisplayController sharedInstance] activeApp] animated:YES force:YES];
				}
				break;
			case 2:
				if (_backgroundIt == 1) {
					[[DSDisplayController sharedInstance] setBackgroundingEnabled:YES forApplication:[[DSDisplayController sharedInstance] activeApp]];
					[[DSDisplayController sharedInstance] exitApplication:[[DSDisplayController sharedInstance] activeApp] animated:YES force:NO];
				} else if (_quitIt == 1) {
					[[DSDisplayController sharedInstance] setBackgroundingEnabled:NO forApplication:[[DSDisplayController sharedInstance] activeApp]];
					[[DSDisplayController sharedInstance] exitApplication:[[DSDisplayController sharedInstance] activeApp] animated:YES force:YES];
				}
				break;
			case 3:
				if (_backgroundIt == 3) {
					[[DSDisplayController sharedInstance] setBackgroundingEnabled:YES forApplication:[[DSDisplayController sharedInstance] activeApp]];
					[[DSDisplayController sharedInstance] exitApplication:[[DSDisplayController sharedInstance] activeApp] animated:YES force:NO];
				} else if (_quitIt == 3) {
					[[DSDisplayController sharedInstance] setBackgroundingEnabled:NO forApplication:[[DSDisplayController sharedInstance] activeApp]];
					[[DSDisplayController sharedInstance] exitApplication:[[DSDisplayController sharedInstance] activeApp] animated:YES force:YES];
				}
				break;
			case 4:
				if (_backgroundIt == 2) {
					[[DSDisplayController sharedInstance] setBackgroundingEnabled:YES forApplication:[[DSDisplayController sharedInstance] activeApp]];
					[[DSDisplayController sharedInstance] exitApplication:[[DSDisplayController sharedInstance] activeApp] animated:YES force:NO];
				} else if (_quitIt == 2) {
					[[DSDisplayController sharedInstance] setBackgroundingEnabled:NO forApplication:[[DSDisplayController sharedInstance] activeApp]];
					[[DSDisplayController sharedInstance] exitApplication:[[DSDisplayController sharedInstance] activeApp] animated:YES force:YES];
				}
				break;
			default:
				break;
		}
	} else if (touch.tapCount == 2) {
		stop = YES;
		[UIView beginAnimations:nil context:NULL];
		[UIView setAnimationDuration:0.1f];
		self.alpha = 0.0f;
		self.hidden = YES;
		[UIView commitAnimations];
		UIModalView *alert = [[UIModalView alloc] initWithTitle:@"Free Memory" buttons:[NSArray arrayWithObjects:@"Twice", @"Once", @"Cancel", nil] defaultButtonIndex:0 delegate:self context:NULL];
		[alert setNumberOfRows:2];
		[alert popupAlertAnimated:YES];
		[alert release];
	}
	[self performSelector:@selector(hideIt) withObject:nil afterDelay:0.3f];
}

-(void)modalView:(id)view didDismissWithButtonIndex:(int)buttonIndex
{
	switch (buttonIndex) {
		case 0:
			freeMemory();
			freeMemory();
			break;
		case 1:
			freeMemory();
			break;
		default:
			break;
	}
	[UIView beginAnimations:nil context:NULL];
	[UIView setAnimationDuration:0.1f];
	self.alpha = 0.5f;
	self.hidden = NO;
	[UIView commitAnimations];
	stop = NO;
}

- (void)hideIt
{
	if (stop)
		return;
	[(SpringBoard *)[UIApplication sharedApplication] hideCircuitous];
}

@end