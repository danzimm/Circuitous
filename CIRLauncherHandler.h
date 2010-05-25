//Created by DanZimm
#import "CIRBackgroundWindow.h"

@class CIRLauncherView;
@class CIRBackgroundWindow;
@interface CIRLauncherHandler : NSObject {
	CIRLauncherView *_mainView;
	BOOL _busy;
	CIRBackgroundWindow *_backgroundWindow;
}

- (BOOL)animateIn;
- (BOOL)animateOut;
- (BOOL)relayout;
- (void)stoppedRelaying;
- (void)updateOrientation;

@end