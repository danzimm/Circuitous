//Created by DanZimm

@interface CIRCloseView : UIImageView
{
	NSString *_identifier;
	UIActivityIndicatorView *_activity;
	BOOL _animate;
}

- (id)initWithIdentifier:(NSString *)ident animations:(BOOL)animate;
- (NSString *)identifier;
- (void)animate;

@end