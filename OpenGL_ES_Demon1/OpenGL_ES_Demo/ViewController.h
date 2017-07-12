//
//  ViewController.h
//  OpenGL_ES_Demo
//
//  Created by 童星 on 2017/7/12.
//  Copyright © 2017年 童星. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <GLKit/GLKit.h>
@interface ViewController : GLKViewController{

    GLuint vertexBufferID; // 用户盛放用到的定点数据的缓存的OpenGL ES标识符
}

@property (nonatomic, strong) GLKBaseEffect *baseEffect;

@end

