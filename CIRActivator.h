//
//  IASafetyMethod.h
//  iAccounts
//
//  Created by Dan on 2/13/10.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import "libactivator.h"
@class libactivator;
@class LAListener;
@interface CIRActivator : NSObject<LAListener> {
@private
}

@end
@interface CIRActivatorCycler : NSObject<LAListener> {
@private
}

@end
@interface CIRActivatorReverseCycler : NSObject<LAListener> {
@private
}

@end
@interface CIRActivatorRandom : NSObject<LAListener> {
@private
}

@end