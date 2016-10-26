//
//  Server.m
//  DYSocket
//
//  Created by 唐道勇 on 16/3/21.
//  Copyright © 2016年 唐道勇. All rights reserved.
//

#import "Server.h"
/*导入三个头文件*/
#import <sys/socket.h>
#import <netinet/in.h>
#import <arpa/inet.h>

@implementation Server

/**开始*/
- (void)start{
    int tdyErr = -1;
    //1.创建服务端套接字
    int serverSocketFd = -1;
    serverSocketFd = socket(AF_INET, SOCK_STREAM, 0);
    /*
     socket（）是一个函数，创建一个套接字，
     AF_INET 表示用IPV4地址族，
     SOCK_STREAM 是说是要是用流式套接字
     0 是指不指定协议类型，系统自动根据情况指定
     */
    if (!(serverSocketFd == -1)) {
        NSLog(@"创建套接字成功");
        //2。绑定套接字和端口
        struct sockaddr_in serverAddr;//创建套接字结构体
        /*
         struct sockaddr是通用的套接字地址，而struct sockaddr_in则是internet环境下套接字的地址形式，二者长度一样，都是16个字节。二者是并列结构，指向sockaddr_in结构的指针也可以指向sockaddr。一般情况下，需要把sockaddr_in结构强制转换成sockaddr结构再传入系统调用函数中。
         */
        memset(&serverAddr, 0, sizeof(serverAddr));//将已经创建的套接字空间初始化0
        /*
         void *memset(void *s,int c,size_t n)
         　　总的作用：将已开辟内存空间 s 的首 n 个字节的值设为值 c
         */
        serverAddr.sin_len = sizeof(serverAddr);
        serverAddr.sin_family = AF_INET;
        serverAddr.sin_addr.s_addr = inet_addr("192.168.1.103");//当前网络的ip
        serverAddr.sin_port = htons(2016);
        /*
         sin_family指代协议族，在socket编程中只能是AF_INET
         sin_port存储端口号（使用网络字节顺序）
         sin_addr存储IP地址，使用in_addr这个数据结构
         sin_zero是为了让sockaddr与sockaddr_in两个数据结构保持大小相同而保留的空字节。
         s_addr按照网络字节顺序存储IP地址
         */
        //绑定套接字
        tdyErr = bind(serverSocketFd, (const struct sockaddr *)&serverAddr, sizeof(serverAddr));
        if (tdyErr == 0) {
            NSLog(@"绑定套接字成功\n");
            //监听连接 设置最大连接数
            tdyErr = listen(serverSocketFd, 9);//监听
            if (tdyErr == 0) {
                NSLog(@"监听成功\n");
                
                //4,接收连接
                /*
                 获取客户端的套接字
                 */
                //4.1初始化一个客户端的端地址
                int clientSocketFD = -1;
                struct sockaddr_in clientSocketAddr;
                socklen_t clientAddrLen = sizeof(clientSocketAddr);
                NSLog(@"接收连接之前\n");
                
                //轮询（接收）
                while (1) {
                    //接收到客户端连接， 获取到客户端的socket
                    clientSocketFD = accept(serverSocketFd, (struct sockaddr *restrict)&clientSocketAddr, &clientAddrLen);
                    NSLog(@"接收连接之后\n");
                    if (!(clientSocketFD == -1)) {
                        NSLog(@"有新的用户连接\n");
                        //5.打印用户的ip的地址
                        NSLog(@"new ip = %s,port = %d\n",inet_ntoa(clientSocketAddr.sin_addr),htons(clientSocketAddr.sin_port));
                        //给新的用户发送一个欢迎语
                        char welcome[] = "欢迎连接，我接收到了";
                        send(clientSocketFD, welcome, sizeof(welcome), 0);
                        
                        //开辟一个子线程去执行数据的收发
                        [NSThread detachNewThreadSelector:@selector(receieveMsg:) toTarget:self withObject:@(clientSocketFD)];
                    }else{
                        
                    }
                }
            }else{
                NSLog(@"监听连接失败\n");
               // perror(serverSocketFd);
                close(serverSocketFd);
                return;
            }
            
        }else{
            NSLog(@"绑定失败\n");
            close(serverSocketFd);
            return;
        }
        
    }else{
        NSLog(@"创建套接字失败\n");
        close(serverSocketFd);//关闭
    }
}
/** 在新的线程中执行收发数据*/
- (void)receieveMsg:(id)socketOjbect{
    int socketFd = [socketOjbect intValue];
    //6.收取客户端发来的消息
    char rcvdMsg[800];
    while (1) {
        ssize_t ret = recv(socketFd, rcvdMsg, sizeof(rcvdMsg), 0);
        if (ret <= 0) {
            NSLog(@"接收失败\n");
            break;
        }else{
            NSLog(@"%s\n", rcvdMsg);// 你好   、、 服务器接收到了你发的：你好
            
            //做一个回射
            char returnMsg[1024];
            strcpy(returnMsg, "服务器接受到了发的：");//复制
            strcat(returnMsg, rcvdMsg);//拼接
            
            send(socketFd, returnMsg, sizeof(returnMsg), 0);//给客户端发送消息
            
            memset(returnMsg, 0, sizeof(returnMsg));//用完之后清零，方便复用
            memset(rcvdMsg, 0, sizeof(rcvdMsg));
            
            /*
             void *memset(void *s,int c,size_t n)
             　　总的作用：将已开辟内存空间 s 的首 n 个字节的值设为值 c
             */
        }
    }
    close(socketFd);//关闭
}

@end
