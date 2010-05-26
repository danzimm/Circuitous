//Created by DanZimm

@interface CIRScrollView : UIScrollView
{
}

- (id)initWithFrame:(CGRect)frame apps:(NSSet *)apps active:(BOOL)active;

@property (nonatomic, retain) NSSet *appSet;

@end