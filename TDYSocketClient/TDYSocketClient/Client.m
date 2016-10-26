//
//  Client.m
//  DYSocketOne
//
//  Created by 唐道勇 on 16/3/22.
//  Copyright © 2016年 唐道勇. All rights reserved.
//

#import "Client.h"
#import <sys/socket.h>
#import <netinet/in.h>
#import <arpa/inet.h>

@implementation Client

- (void)start{
    //添加一个错误吗
    int tdyError = -1;
    //1.创建一个socket
    int clientSocetFd = -1;
    /**
     *  创建套接字
     *  @param  ip协议族  (ipv4 & ipv6)
     *  @param  传输协议类型 (tpc,udp)
     *  @param  默认当前协议，一般是0
     *
     *  @return socket
     */
    clientSocetFd = socket(AF_INET, SOCK_STREAM, 0);
    if (!(clientSocetFd == -1)) {
        NSLog(@"创建客户端套接字成功");
        
        // 2 绑定套接字和地址(客户端是可选)
        // - 2.1 初始化一个端地址
        struct sockaddr_in clientAddr;
        // - 2.1.1 重置(清空)端地址
        memset(&clientAddr, 0, sizeof(clientAddr));
        // - 2.1.2 设置大小
        clientAddr.sin_len = sizeof(clientAddr);
        // - 2.1.3 设置ip协议族类型
        clientAddr.sin_family = AF_INET;
        // - 2.1.4 设置任意ip地址，客户端不需要绑定地址和端口
        clientAddr.sin_addr.s_addr = INADDR_ANY;
        
        /**
         *  绑定套接字和地址
         *  参数一：客户端套接字
         *  参数二：端地址的地址
         *  参数三：短地址的大小
         */
        tdyError = bind(clientSocetFd, (const struct sockaddr *)&clientAddr, sizeof(clientAddr));
        
        if (tdyError == 0) {
            printf("绑定端地址成功!\n");
            // 3 连接服务器 connect
            
            // 3.1 获取服务器端地址
            struct sockaddr_in serverAddr;
            memset(&serverAddr, 0, sizeof(serverAddr));
            serverAddr.sin_family = AF_INET;
            serverAddr.sin_len = sizeof(serverAddr);
            // 将字符串装换成ip地址
            serverAddr.sin_addr.s_addr = inet_addr("192.168.1.103");
            // 将主机字节序转换成网络字节序
            serverAddr.sin_port = htons(2016);
            
            tdyError = connect(clientSocetFd, (const struct sockaddr *)&serverAddr, sizeof(serverAddr));
            
            if (tdyError == 0) {
                printf("连接服务器成功!\n");
                
                // 获取客户端信息
                socklen_t caLen = sizeof(clientAddr);

                tdyError =  getsockname(clientSocetFd, (struct sockaddr *)&clientAddr, &caLen);

                printf("本机主机ip:%s,端口号:%d",inet_ntoa(clientAddr.sin_addr),htons(clientAddr.sin_port));
                // 连上服务器之后，立即开始接受信息 开辟子线程轮询接收信息。
                [NSThread detachNewThreadSelector:@selector(receiveMsg:) toTarget:self withObject:@(clientSocetFd)];
                char msg[]= "唐道勇：我连接上了";
                send(clientSocetFd, msg, sizeof(msg), 0);
                [[NSRunLoop currentRunLoop] run];
                
                char sendMsg[512];
                while (true) {
                    scanf("%s",sendMsg);
                    send(clientSocetFd, sendMsg, sizeof(sendMsg), 0);
                    memset(sendMsg, 0, sizeof(sendMsg));
                }
            }else {
                perror("连接服务器失败!\n");
                close(clientSocetFd);
                return;
            }
        } else{
            perror("绑定端地址失败!\n");
            // 关闭套接字
            close(clientSocetFd);
            return;
        }
    }else{
        NSLog(@"创建客户端套接字失败");
    }
}
/**连上服务器之后，立即开始接受信息 开辟子线程轮询接收信息*/
- (void)receiveMsg:(id) socketObj
{
    int socket = [socketObj intValue];
    char msg [1024];
    size_t msgLen = sizeof(msg);
    
    // 开始轮询接受
    while (true) {
        
        ssize_t ret = recv(socket, msg, msgLen, 0);
        if (ret <= 0) { // 远程套接字关闭，或出错
            break;
        }
        printf("%s",msg);
        
        // 将msg清空，
        memset(msg, 0, sizeof(msg));
        
    }
    close(socket);
}


@end
