//Created by DanZimm

@interface CIRScrollView : UIScrollView
{
}

- (id)initWithFrame:(CGRect)frame apps:(NSArray *)apps active:(BOOL)active;

@property (nonatomic, retain) NSArray *appSet;

@end