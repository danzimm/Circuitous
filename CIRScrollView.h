//Created by DanZimm

@interface CIRScrollView : UIScrollView
{
	float holdTime;
}

- (id)initWithFrame:(CGRect)frame apps:(NSArray *)apps active:(BOOL)active;
- (id)initWithFrameVertically:(CGRect)frame apps:(NSArray *)apps active:(BOOL)active;

@property (nonatomic, retain) NSArray *appSet;

@end