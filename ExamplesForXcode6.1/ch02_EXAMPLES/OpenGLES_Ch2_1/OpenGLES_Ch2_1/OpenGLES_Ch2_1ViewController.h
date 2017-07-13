//
//  OpenGLES_Ch2_1ViewController.h
//  OpenGLES_Ch2_1
//

#import <GLKit/GLKit.h>

@interface OpenGLES_Ch2_1ViewController : GLKViewController
{
   GLuint vertexBufferID; // 用户盛放用到的定点数据的缓存的OpenGL ES标识符
}

@property (strong, nonatomic) GLKBaseEffect *baseEffect; // 

@end
