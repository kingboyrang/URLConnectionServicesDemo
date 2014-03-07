//
//  ServiceOperationQueue.m
//  URLConnectionServicesDemo
//
//  Created by aJia on 2014/3/7.
//  Copyright (c) 2014年 lz. All rights reserved.
//

#import "ServiceOperationQueue.h"

@interface ServiceOperationQueue ()
@property (readwrite, nonatomic, copy) SOQFinishBlock finishBlock;
@property (readwrite, nonatomic, copy) SOQCompleteBlock completeBlock;
@end

@implementation ServiceOperationQueue
@synthesize operationQueue=operationQueue_,operations=operations_;
- (void)dealloc{
    [operationQueue_ removeObserver:self forKeyPath:@"operations"];
    [operationQueue_ cancelAllOperations];
    [operationQueue_ release],operationQueue_=nil;
    [operations_ release],operations_=nil;
    [super dealloc];
}
- (id)init {
    self = [super init];
    if (self) {
        operationQueue_ = [[NSOperationQueue alloc] init];
        [operationQueue_ addObserver:self forKeyPath:@"operations" options:0 context:NULL];
        operationQueue_.maxConcurrentOperationCount = 10;
        
        operations_=[[NSMutableArray array] retain];
    }
    return self;
}
- (void)setFinishBlock:(SOQFinishBlock)afinishBlock{
    if (_finishBlock!=afinishBlock) {
        [_finishBlock release];
        _finishBlock=[afinishBlock copy];
    }
}
- (void)setCompleteBlock:(SOQCompleteBlock)acompleteBlock{
    if (_completeBlock!=acompleteBlock) {
        [_completeBlock release];
        _completeBlock=[acompleteBlock copy];
    }
}
-(void)addOperation:(ServiceOperation*)operation{
    [operation addObserver:self forKeyPath:@"isFinished" options:NSKeyValueObservingOptionNew context:NULL];
    [operationQueue_ addOperation:operation];
}
- (void)observeValueForKeyPath:(NSString *)keyPath
ofObject:(id)object
change:(NSDictionary *)change
context:(void *)context
{
    if (object==operationQueue_) {
        if ([keyPath isEqualToString:@"operations"])
        {
            if (0 == operationQueue_.operations.count)
            {
                
                [operationQueue_ setSuspended:YES];
                if (self.completeBlock) {
                    self.completeBlock();
                }
            }
        }
        else
        {
            [super observeValueForKeyPath:keyPath ofObject:object change:change context:context];
        }
    }else{
        if ([object isKindOfClass:[ServiceOperation class]]) {
            ServiceOperation *operation=(ServiceOperation*)object;
            [operations_ addObject:operation];
            if (self.finishBlock) {
                self.finishBlock(operation);
            }
            [operation removeObserver:self forKeyPath:@"isFinished"];
        }else{
            [super observeValueForKeyPath:keyPath ofObject:object change:change context:context];
        }
    }
    
}


@end
