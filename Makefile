TWEAK_NAME = Circuitous

Circuitous_OBJC_FILES = CIRCloseView.m \
	CIRLauncherView.m \
	CIRScrollView.m \
	CIRBackgroundWindow.m \
	CIRLauncherHandler.m \
	CIRIcon.m
Circuitous_OBJCC_FILES = CIRActivator.mm
Circuitous_FRAMEWORKS = UIKit Foundation CoreFoundation CoreGraphics
Circuitous_LDFLAGS = -L/Users/Dan/Desktop/libdisplaystack/obj -ldisplaystack -lactivator 

BUNDLE_NAME = CIRPrefs

CIRPrefs_OBJC_FILES = Preferences.m
CIRPrefs_FRAMEWORKS = UIKit Foundation CoreFoundation CoreGraphics
CIRPrefs_PRIVATE_FRAMEWORKS = SpringBoardServices Preferences

include framework/makefiles/common.mk
include framework/makefiles/tweak.mk
include framework/makefiles/bundle.mk