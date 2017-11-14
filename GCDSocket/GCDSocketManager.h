//
//  GCDSocketManager.h
//  GCDSocket
//
//  Created by ls on 2017/11/13.
//  Copyright © 2017年 onePiece. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "GCDAsyncSocket.h"
@interface GCDSocketManager : NSObject
@property(nonatomic,strong) GCDAsyncSocket *socket;

//单例
+ (instancetype)sharedSocketManager;

//连接
- (void)connectToServer;

//断开
- (void)cutOffSocket;


-(void)sendDataToServer;


@end
