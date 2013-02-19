#import "PMDAppDelegate.h"
#import "PMDTimer.h"

@interface PMDAppDelegate () <PMDTimerDelegate>

@property (strong, nonatomic) NSStatusItem *statusItem;

@end


@implementation PMDAppDelegate

- (void)applicationDidFinishLaunching:(NSNotification *)aNotification
{
    NSStatusBar *statusBar = [NSStatusBar systemStatusBar];
    
    self.statusItem = [statusBar statusItemWithLength:60.f];
    self.statusItem.title = @"00:00";
    self.statusItem.target = self;
    self.statusItem.action = @selector(showMenu);
    [self.statusItem setEnabled:YES];
}

- (void)showMenu
{
    PMDTimer *timer = [PMDTimer sharedTimer];
    timer.delegate = self;
    
    NSMenuItem *startMenuItem = [[NSMenuItem alloc] init];
    startMenuItem.title = @"Start";
    startMenuItem.target = timer;
    startMenuItem.action = @selector(start);
    
    NSMenuItem *stopMenuItem = [[NSMenuItem alloc] init];
    stopMenuItem.title = @"Stop";
    stopMenuItem.target = timer;
    stopMenuItem.action = @selector(stop);
    
    NSMenuItem *quitMenuItem = [[NSMenuItem alloc] init];
    quitMenuItem.title = @"Quit";
    quitMenuItem.target = [NSApplication sharedApplication];
    quitMenuItem.action = @selector(terminate:);
    
    NSMenu *menu = [[NSMenu alloc] initWithTitle:@"weeeeei"];
    [menu addItem:startMenuItem];
    [menu addItem:stopMenuItem];
    [menu addItem:quitMenuItem];
    
    [self.statusItem popUpStatusItemMenu:menu];
}

#pragma mark - PMDTimerDelegate

- (void)timerDidCount:(PMDTimer *)timer
{
    NSInteger minutes = timer.remainingSeconds / 60;
    NSInteger seconds = timer.remainingSeconds % 60;
    
    self.statusItem.title = [NSString stringWithFormat:@"%ld:%02ld", minutes, seconds];
}

- (void)timerDidChangePhase:(PMDTimer *)timer
{
    NSUserNotificationCenter *center = [NSUserNotificationCenter defaultUserNotificationCenter];
    [center removeAllDeliveredNotifications];
    
    NSUserNotification *notification = [[NSUserNotification alloc] init];
    switch (timer.phase) {
        case PMDPhaseWorking:  notification.title = @"Breaking -> Working"; break;
        case PMDPhaseBreaking: notification.title = @"Working -> Breaking"; break;
        default: break;
    }
    
    [center deliverNotification:notification];
}

@end
