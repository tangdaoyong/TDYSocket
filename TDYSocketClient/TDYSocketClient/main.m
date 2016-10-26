//
//  main.m
//  TDYSocketClient
//
//  Created by 唐道勇 on 16/10/26.
//  Copyright © 2016年 唐道勇. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "Client.h"
/*
 *TCPScoket的客户端
 */
int main(int argc, const char * argv[]) {
    @autoreleasepool {
        // insert code here...
        NSLog(@"Hello, World!");
        //开始
        Client *tdyClient = [Client new];
        [tdyClient start];
    }
    return 0;
}
