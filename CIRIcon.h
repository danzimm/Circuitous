//Created by DanZimm
#import <SpringBoard/SBIconBadge.h>

#import "CIRCloseView.h"

@class SBIconBadge;
@class CIRCloseView;
@interface CIRIcon : UIView
{
	NSString *_identifier;
	UIImageView *_iconImage;
	UILabel *_iconName;
	SBIconBadge *_badge;
	CIRCloseView *_iconClose;
	BOOL _animate;
	NSTimer *_holdTimer;
	CGPoint oldCenter;
	float holdTime;
	UIImageView *_bgBadge;
}

+ (void)setHoriz:(BOOL)horiz1;
- (id)initWithIdentifier:(NSString *)ident andFrame:(CGRect)frame labelHeight:(float)height animations:(BOOL)animations labels:(BOOL)label badges:(BOOL)badge holdTime:(float)time themedIcon:(BOOL)icon;
- (void)setActive;
- (NSString *)identifier;
- (void)setActiveWithoutBox;
- (void)setBackgrounderBadge;
- (void)removeBackgrounderBadge;
- (void)removeIsActive;

@end