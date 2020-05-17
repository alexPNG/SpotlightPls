// SpotlightPls by alex_png
// Invoke Spotlight Search anywhere with gestures or triggers.
// https://github.com/alexPNG

#import <SpringBoard/SpringBoard.h>
#import <AudioToolbox/AudioToolbox.h>

// Preferences stuff
static NSMutableDictionary *settings;
static BOOL useHaptic;
static BOOL useShake;
static BOOL useSwipeL;
static BOOL useSwipeR;
static BOOL useLongPress;
static BOOL useTwoFingers;

// Preferences Update
static void refreshPrefs() {
	CFArrayRef keyList = CFPreferencesCopyKeyList(CFSTR("com.alexpng.spotlightpls"), kCFPreferencesCurrentUser, kCFPreferencesAnyHost);
	if (keyList) {
		settings = (NSMutableDictionary *)CFBridgingRelease(CFPreferencesCopyMultiple(keyList, CFSTR("com.alexpng.spotlightpls"), kCFPreferencesCurrentUser, kCFPreferencesAnyHost));
		CFRelease(keyList);
	} else {
		settings = nil;
	}
	if (!settings) {
		settings = [[NSMutableDictionary alloc] initWithContentsOfFile:@"/var/mobile/Library/Preferences/com.alexpng.spotlightpls.plist"];
	}
	useHaptic = [([settings objectForKey:@"useHaptic"] ?: @(YES)) boolValue];
	useShake = [([settings objectForKey:@"useShake"] ?: @(NO)) boolValue];
	useSwipeL = [([settings objectForKey:@"useSwipeL"] ?: @(NO)) boolValue];
	useSwipeR = [([settings objectForKey:@"useSwipeR"] ?: @(YES)) boolValue];
	useLongPress = [([settings objectForKey:@"useLongPress"] ?: @(NO)) boolValue];
	useTwoFingers = [([settings objectForKey:@"useTwoFingers"] ?: @(NO)) boolValue];
	}
static void PreferencesChangedCallback(CFNotificationCenterRef center, void *observer, CFStringRef name, const void *object, CFDictionaryRef userInfo) {
  refreshPrefs();
}

// This is the way (any Mando fans out there)
// This invokes spotlight search
@interface AXSpringBoardServer
	+ (id)server;
	- (void)revealSpotlight;
@end

// Status bar gestures
@interface UIStatusBar : UIView
@end

@interface UIStatusBar_Modern : UIView
@end

// Long press gesture for in-app
@interface SBMainDisplaySceneLayoutStatusBarView : UIView
@end

// Swipe down status bar with 2 fingers
@interface UIWindow(X)

@property (nonatomic, retain) UIPanGestureRecognizer *xGestureRecognizer;
- (void)xEnable;
- (void)InvokeSpot;

@end

@interface SBWindow : UIWindow
@end

// For the shake/2 fingers to invoke
%hook UIWindow

- (void)motionEnded:(UIEventSubtype)motion withEvent:(UIEvent *)event
{
    %orig;
    if(event.subtype == UIEventSubtypeMotionShake && self.keyWindow)
    {

if (useHaptic && useShake) {
//Haptic Feedback
AudioServicesPlaySystemSound(1519);
}

if (useShake) {
// Invoke Spotlight Search
[(AXSpringBoardServer *)[%c(AXSpringBoardServer) server] revealSpotlight];
    }
  }
}

%property (nonatomic, retain) UIPanGestureRecognizer *xGestureRecognizer;

%new
- (void)InvokeSpot {
    if (self.xGestureRecognizer.state != UIGestureRecognizerStateBegan) return;

if (useHaptic && useTwoFingers) {
AudioServicesPlaySystemSound(1519);
}

if (useTwoFingers) {
[(AXSpringBoardServer *)[%c(AXSpringBoardServer) server] revealSpotlight];
  }
}

%new
- (void)xEnable {
    if (self.xGestureRecognizer) return;
    self.xGestureRecognizer = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(InvokeSpot)];
    self.xGestureRecognizer.minimumNumberOfTouches = 2;
    self.xGestureRecognizer.cancelsTouchesInView = NO;
    [self addGestureRecognizer:self.xGestureRecognizer];
}

- (id)initWithFrame:(CGRect)frame {
    %orig;
    [self xEnable];
    return self;
}

%end

// For the SB gestures to invoke spotlight 
%hook UIStatusBar

-(void)layoutSubviews {
		%orig;

      if (self.gestureRecognizers) {
	  return; 
    }

	 UISwipeGestureRecognizer *swipeGestureLeft = [[[UISwipeGestureRecognizer alloc] initWithTarget:self action:@selector(leftSwipe:)] autorelease];
	 [swipeGestureLeft setDirection:(UISwipeGestureRecognizerDirectionLeft)];
	 swipeGestureLeft.numberOfTouchesRequired = 1;
	 [self addGestureRecognizer:swipeGestureLeft];
	 
	 UISwipeGestureRecognizer *swipeGestureRight = [[[UISwipeGestureRecognizer alloc] initWithTarget:self action:@selector(rightSwipe:)] autorelease];
	 [swipeGestureRight setDirection:(UISwipeGestureRecognizerDirectionRight)];
	 swipeGestureRight.numberOfTouchesRequired = 1;
	 [self addGestureRecognizer:swipeGestureRight];

UILongPressGestureRecognizer *longPress = [[UILongPressGestureRecognizer alloc] initWithTarget:self action:@selector(handleLongPress:)];

longPress.numberOfTouchesRequired = 1;

[self addGestureRecognizer:longPress];
	 
		%orig;
  
}

%new -(void)rightSwipe:(UISwipeGestureRecognizer *)sender {

if (useHaptic && useSwipeR) {
AudioServicesPlaySystemSound(1519);
}

if (useSwipeR) {
[(AXSpringBoardServer *)[%c(AXSpringBoardServer) server] revealSpotlight];
  }
}

%new -(void)leftSwipe:(UISwipeGestureRecognizer *)sender {

if (useHaptic && useSwipeL) {
AudioServicesPlaySystemSound(1519);
}

if (useSwipeL) {
[(AXSpringBoardServer *)[%c(AXSpringBoardServer) server] revealSpotlight];
  }
}

%new
-(void)handleLongPress:(UILongPressGestureRecognizer*)sender{

if (useHaptic && useLongPress) {
AudioServicesPlaySystemSound(1519);
}

if (useLongPress) {
[(AXSpringBoardServer *)[%c(AXSpringBoardServer) server] revealSpotlight];
  }
}

%end

%hook UIStatusBar_Modern

-(void)layoutSubviews {
	 %orig;
	self.userInteractionEnabled = YES;

      if (self.gestureRecognizers) {
        return;
    }

	 UISwipeGestureRecognizer *swipeGestureLeft = [[[UISwipeGestureRecognizer alloc] initWithTarget:self action:@selector(leftSwipe:)] autorelease];
	 [swipeGestureLeft setDirection:(UISwipeGestureRecognizerDirectionLeft)];
	 swipeGestureLeft.numberOfTouchesRequired = 1;
	 [self addGestureRecognizer:swipeGestureLeft];
	 
	 UISwipeGestureRecognizer *swipeGestureRight = [[[UISwipeGestureRecognizer alloc] initWithTarget:self action:@selector(rightSwipe:)] autorelease];
	 [swipeGestureRight setDirection:(UISwipeGestureRecognizerDirectionRight)];
	 swipeGestureRight.numberOfTouchesRequired = 1;
	 [self addGestureRecognizer:swipeGestureRight];
	
UILongPressGestureRecognizer *longPress = [[UILongPressGestureRecognizer alloc] initWithTarget:self action:@selector(handleLongPress:)];

longPress.numberOfTouchesRequired = 1;

[self addGestureRecognizer:longPress];

		%orig;
	
}

%new -(void)rightSwipe:(UISwipeGestureRecognizer *)sender {

if (useHaptic && useSwipeR) {
AudioServicesPlaySystemSound(1519);
}

if (useSwipeR) {
[(AXSpringBoardServer *)[%c(AXSpringBoardServer) server] revealSpotlight];
  }
}

%new -(void)leftSwipe:(UISwipeGestureRecognizer *)sender {

if (useHaptic && useSwipeL) {
AudioServicesPlaySystemSound(1519);
}

if (useSwipeL) {
[(AXSpringBoardServer *)[%c(AXSpringBoardServer) server] revealSpotlight];
  }
}

%new
-(void)handleLongPress:(UILongPressGestureRecognizer*)sender{

if (useHaptic && useLongPress) {
AudioServicesPlaySystemSound(1519);
}

if (useLongPress) {
[(AXSpringBoardServer *)[%c(AXSpringBoardServer) server] revealSpotlight];
  }
}

%end

%hook SBMainDisplaySceneLayoutStatusBarView
- (void)_addStatusBarIfNeeded {
	%orig;

	UIView *statusBar = [self valueForKey:@"_statusBar"];
	[statusBar addGestureRecognizer:[[UILongPressGestureRecognizer alloc]
        initWithTarget:self action:@selector(PressGesture:)
    ]];
}

%new
- (void)PressGesture:(UILongPressGestureRecognizer *)recognizer {
	if (recognizer.state == UIGestureRecognizerStateBegan) {

if (useHaptic && useLongPress) {
AudioServicesPlaySystemSound(1519);
}

if (useLongPress) {
[(AXSpringBoardServer *)[%c(AXSpringBoardServer) server] revealSpotlight];
       }
	}
}

%end

// 2 fingers down SB to invoke Spotlight
%hook SBWindow

- (id)initWithFrame:(CGRect)frame {
    %orig;
    [self xEnable];
    return self;
}

-(id)_initWithScreen:(id)arg1 layoutStrategy:(id)arg2 debugName:(id)arg3 rootViewController:(id)arg4 scene:(id)arg5 {
    %orig;
    [self xEnable];
    return self;
}

-(id)initWithScreen:(id)arg1 layoutStrategy:(id)arg2 debugName:(id)arg3 {
    %orig;
    [self xEnable];
    return self;
}

-(id)initWithScreen:(id)arg1 debugName:(id)arg2 rootViewController:(id)arg3 {
    %orig;
    [self xEnable];
    return self;
}

-(id)initWithScreen:(id)arg1 layoutStrategy:(id)arg2 debugName:(id)arg3 scene:(id)arg4 {
    %orig;
    [self xEnable];
    return self;
}

-(id)initWithScreen:(id)arg1 debugName:(id)arg2 {
    self = %orig;
    [self xEnable];
    return self;
}

%end

%ctor {
	CFNotificationCenterAddObserver(CFNotificationCenterGetDarwinNotifyCenter(), NULL, (CFNotificationCallback) PreferencesChangedCallback, CFSTR("com.alexpng.spotlightpls.prefschanged"), NULL, CFNotificationSuspensionBehaviorDeliverImmediately);
	refreshPrefs();
}