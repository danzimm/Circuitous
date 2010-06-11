//Created by DanZimm

@interface CIRScrollView : UIScrollView
{
	id _handler;
}

- (id)initWithFrame:(CGRect)frame handler:(id)handler;


@property (nonatomic, assign) id _handler;
@end