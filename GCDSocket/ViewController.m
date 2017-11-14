//
//  ViewController.m
//  GCDSocket
//
//  Created by ls on 2017/11/13.
//  Copyright © 2017年 onePiece. All rights reserved.
//

#import "ViewController.h"
#import "GCDSocketManager.h"
@interface ViewController ()

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [[GCDSocketManager sharedSocketManager] connectToServer];
    

}

- (IBAction)sendData:(UIButton *)sender {
    
    [[GCDSocketManager sharedSocketManager] sendDataToServer];
    
}



- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


@end
