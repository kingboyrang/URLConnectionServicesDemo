//
//  ServiceQueue.h
//  URLConnectionServicesDemo
//
//  Created by aJia on 2014/3/11.
//  Copyright (c) 2014年 lz. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "ServiceOperation.h"
//block
typedef void (^SOQFinishBlock)(ServiceOperation *operation);
typedef void (^SOQCompleteBlock)();

@interface ServiceOperationQueue : NSOperationQueue{
   BOOL finished_;
   NSMutableArray *items_;
}
@property (nonatomic,assign) BOOL showNetworkActivityIndicator;
@property (nonatomic,readonly) NSArray *items;
- (void)setFinishBlock:(SOQFinishBlock)afinishBlock;
- (void)setCompleteBlock:(SOQCompleteBlock)acompleteBlock;
- (void)reset;//重置
@end
