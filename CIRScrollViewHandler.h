//Created by DanZimm
#import "CIRScrollView.h"

@class CIRIcon;
@interface CIRScrollViewHandler : NSObject
{
	float holdTime;
	CIRScrollView *_mainScroll;
	NSMutableArray *_icons;
	BOOL isActive;
}

- (id)initWithFrame:(CGRect)frame apps:(NSArray *)apps active:(BOOL)active;
- (id)initWithFrameVertically:(CGRect)frame apps:(NSArray *)apps active:(BOOL)active;
- (UIView *)view;

@property (nonatomic, retain) NSMutableArray *apps;

@end