//
//  ServiceOperationQueue.h
//  URLConnectionServicesDemo
//
//  Created by aJia on 2014/3/7.
//  Copyright (c) 2014年 lz. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "ServiceOperation.h"
//block
typedef void (^SOQFinishBlock)(ServiceOperation *operation);
typedef void (^SOQCompleteBlock)();

@interface ServiceOperationQueue : NSObject{
    NSOperationQueue *operationQueue_;
    NSMutableArray *operations_;
}
@property (nonatomic,readonly) NSOperationQueue *operationQueue;
@property (nonatomic,readonly) NSArray *operations;
- (void)setFinishBlock:(SOQFinishBlock)afinishBlock;
- (void)setCompleteBlock:(SOQCompleteBlock)acompleteBlock;
- (void)addOperation:(ServiceOperation*)operation;
- (void)reset;//重新开始
@end
