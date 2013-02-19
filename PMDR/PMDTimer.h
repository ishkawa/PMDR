#import <Foundation/Foundation.h>

typedef NS_ENUM(NSInteger, PMDPhase) {
    PMDPhaseStopped = 0,
    PMDPhaseWorking,
    PMDPhaseBreaking,
};

@protocol PMDTimerDelegate;

@interface PMDTimer : NSObject

@property (nonatomic, readonly) PMDPhase phase;
@property (nonatomic, readonly) NSInteger remainingSeconds;
@property (nonatomic, weak) id <PMDTimerDelegate> delegate;

+ (PMDTimer *)sharedTimer;

- (void)start;
- (void)stop;

@end

@protocol PMDTimerDelegate <NSObject>
@optional
- (void)timerDidCount:(PMDTimer *)timer;
- (void)timerDidChangePhase:(PMDTimer *)timer;

@end

