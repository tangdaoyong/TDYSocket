//
//  main.m
//  TDYSocketServer
//
//  Created by 唐道勇 on 16/10/26.
//  Copyright © 2016年 唐道勇. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "Server.h"
/*
 *TCPSocket服务器的搭建
 */
int main(int argc, const char * argv[]) {
    @autoreleasepool {
        // insert code here...
        NSLog(@"Hello, World!");
        //开始运行
        Server *tdyServer = [Server new];
        [tdyServer start];
    }
    return 0;
}
