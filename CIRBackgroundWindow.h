//Created by DanZimm
#import <mach/mach_host.h>
#import <dirent.h>
#include <stdio.h>
#include <unistd.h>
#include <stdlib.h>
#include <ctype.h>
#include <time.h>

@interface CIRBackgroundWindow : UIWindow
{
	CGPoint start;
}
- (void)hideIt;
@end