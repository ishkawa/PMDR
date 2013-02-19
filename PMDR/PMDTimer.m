#import "PMDTimer.h"

static NSString *const PMDTimerPhaseKey = @"phase";
static NSString *const PMDTimerRemainingSecondsKey = @"remainingSeconds";

static NSInteger const PMDWorkingInterval = 25 * 60;
static NSInteger const PMDBreakingInterval = 5 * 60;

@interface PMDTimer ()

@property (nonatomic) PMDPhase phase;
@property (nonatomic) NSInteger remainingSeconds;
@property (nonatomic, strong) NSTimer *timer;

@end

@implementation PMDTimer

+ (PMDTimer *)sharedTimer
{
    static PMDTimer *timer = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        timer = [[PMDTimer alloc] init];
    });
    
    return timer;
}

- (id)init
{
    self = [super init];
    if (self) {
        [self addObserver:self forKeyPath:PMDTimerPhaseKey options:0 context:NULL];
        [self addObserver:self forKeyPath:PMDTimerRemainingSecondsKey options:0 context:NULL];
    }
    return self;
}

- (void)dealloc
{
    [self removeObserver:self forKeyPath:PMDTimerPhaseKey];
    [self removeObserver:self forKeyPath:PMDTimerRemainingSecondsKey];
}

#pragma mark - KVO

- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context
{
    if (object == self && [keyPath isEqualToString:PMDTimerPhaseKey]) {
        switch (self.phase) {
            case PMDPhaseWorking:  self.remainingSeconds = PMDWorkingInterval; break;
            case PMDPhaseBreaking: self.remainingSeconds = PMDBreakingInterval; break;
            case PMDPhaseStopped:  self.remainingSeconds = 0; break;
            default: break;
        }
        
        if ([self.delegate respondsToSelector:@selector(timerDidChangePhase:)]) {
            [self.delegate timerDidChangePhase:self];
        }
        return;
    }
    
    if (object == self && [keyPath isEqualToString:PMDTimerRemainingSecondsKey]) {
        if ([self.delegate respondsToSelector:@selector(timerDidCount:)]) {
            [self.delegate timerDidCount:self];
        }
        return;
    }
    
    [super observeValueForKeyPath:keyPath ofObject:object change:change context:context];
}

#pragma mark - public action

- (void)start
{
    if (self.timer) {
        [self.timer invalidate];
    }
    self.phase = PMDPhaseWorking;
    self.timer = [NSTimer scheduledTimerWithTimeInterval:1.0
                                                  target:self
                                                selector:@selector(countDown)
                                                userInfo:nil
                                                 repeats:YES];
}

- (void)stop
{
    [self.timer invalidate];
    self.timer = nil;
    
    self.phase = PMDPhaseStopped;
}

#pragma mark - timer

- (void)countDown
{
    self.remainingSeconds--;
    
    if (self.remainingSeconds <= 0) {
        switch (self.phase) {
            case PMDPhaseWorking:  self.phase = PMDPhaseBreaking; break;
            case PMDPhaseBreaking: self.phase = PMDPhaseWorking;  break;
            default: break;
        }
    }
}

@end
