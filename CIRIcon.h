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
}

- (id)initWithIdentifier:(NSString *)ident andXCoor:(int)coor animations:(BOOL)animations labels:(BOOL)label badges:(BOOL)badge;
- (void)setActive;
- (NSString *)identifier;
- (void)setActiveWithoutBox;

@end