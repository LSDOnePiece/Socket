//
//  GCDSocketManager.m
//  GCDSocket
//
//  Created by ls on 2017/11/13.
//  Copyright © 2017年 onePiece. All rights reserved.
//

#import "GCDSocketManager.h"

#define SocketHost @"47.93.57.18"
#define SocketPort 2346

@interface GCDSocketManager()<GCDAsyncSocketDelegate>
{
    long TAG_SEND;
    long TAG_RECIVED;
}

//握手次数
@property(nonatomic,assign) NSInteger pushCount;

//断开重连定时器
@property(nonatomic,strong) NSTimer *timer;

//重连次数
@property(nonatomic,assign) NSInteger reconnectCount;


@end

@implementation GCDSocketManager


+(instancetype)sharedSocketManager{
    
    static GCDSocketManager *_instance = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        _instance = [[self alloc] init];

    });
    return _instance;
}

//可以在这里做一些初始化操作
- (instancetype)init
{
    self = [super init];
    if (self) {
     
    }
    return self;
}

#pragma mark 请求连接
//连接
- (void)connectToServer {
    self.pushCount = 0;

    self.socket = [[GCDAsyncSocket alloc] initWithDelegate:self delegateQueue:dispatch_get_main_queue()];
    NSError *error = nil;
    [self.socket connectToHost:SocketHost onPort:SocketPort error:&error];
    
    if (error) {
        NSLog(@"SocketConnectError:%@",error);
    }
    
}

#pragma mark 连接成功
//连接成功的回调
- (void)socket:(GCDAsyncSocket *)sock didConnectToHost:(NSString *)host port:(uint16_t)port {
    NSLog(@"socket连接成功");
    
    NSLog(@"%@---%zd",host,port);

}

//连接成功后向服务器发送数据
- (void)sendDataToServer {
    //发送数据代码省略...
    
    NSString *str = @"1";
    
    NSData *jsonData = [str dataUsingEncoding:NSUTF8StringEncoding];
    
    //发送
    [self.socket writeData:jsonData withTimeout:-1 tag:1];
    
}

// 数据成功发送到服务器
- (void)socket:(GCDAsyncSocket *)sock didWriteDataWithTag:(long)tag{
    
    // 需要自己调用读取方法，socket才会调用代理方法读取数据
    [self.socket readDataWithTimeout:-1 tag:tag];
    
}


//连接成功向服务器发送数据后,服务器会有响应
- (void)socket:(GCDAsyncSocket *)sock didReadData:(NSData *)data withTag:(long)tag {
    
    NSString *str = [[NSString alloc]initWithData:data encoding:NSUTF8StringEncoding];
    
    NSLog(@"%@",str);
    
    //服务器推送次数
    self.pushCount++;
    
    //在这里进行校验操作,情况分为成功和失败两种,成功的操作一般都是拉取数据
}

#pragma mark 连接失败
//连接失败的回调
- (void)socketDidDisconnect:(GCDAsyncSocket *)sock withError:(NSError *)err {
    NSLog(@"Socket连接失败");
    
    self.pushCount = 0;
    
    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
    
    NSString *currentStatu = [userDefaults valueForKey:@"Statu"];
    
    //程序在前台才进行重连
    if ([currentStatu isEqualToString:@"foreground"]) {
        
        //重连次数
        self.reconnectCount++;
        
        //如果连接失败 累加1秒重新连接 减少服务器压力
        NSTimer *timer = [NSTimer scheduledTimerWithTimeInterval:1.0 * self.reconnectCount target:self selector:@selector(reconnectServer) userInfo:nil repeats:NO];
        
        self.timer = timer;
    }
}

//如果连接失败,5秒后重新连接
- (void)reconnectServer {
    
    self.pushCount = 0;
    
    self.reconnectCount = 0;
    
    //连接失败重新连接
    NSError *error = nil;
    [self.socket connectToHost:SocketHost onPort:SocketPort error:&error];
    if (error) {
        NSLog(@"SocektConnectError:%@",error);
    }
}

#pragma mark 断开连接
//切断连接
- (void)cutOffSocket {
    NSLog(@"socket断开连接");
    
    self.pushCount = 0;
    
    self.reconnectCount = 0;
    
    [self.timer invalidate];
    self.timer = nil;
    
    [self.socket disconnect];
}

@end
