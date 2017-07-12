//
//  ViewController.m
//  OpenGL_ES_Demo
//
//  Created by 童星 on 2017/7/12.
//  Copyright © 2017年 童星. All rights reserved.
//

#import "ViewController.h"

@interface ViewController ()

@end

@implementation ViewController

typedef struct {
    GLKVector3 positionCoords;
}SceneVertex;

static const SceneVertex vertices[] = {

    {-0.5f,-0.5f,0.0},
    {0.5f, -0.5f, 0.0},
    {-0.5f, 0.5f, 0.0}
};

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    GLKView *view = (GLKView *)self.view;
    NSAssert([view isKindOfClass:[GLKView class]], @"view controller's view is not a GLKView");
    
    view.context = [[EAGLContext alloc] initWithAPI:(kEAGLRenderingAPIOpenGLES2)];
    [EAGLContext setCurrentContext:view.context];
    self.baseEffect = [[GLKBaseEffect alloc] init];
    self.baseEffect.useConstantColor = GL_TRUE;
    self.baseEffect.constantColor = GLKVector4Make(1.0, 1.0, 1.0, 1.0);
    // 设置当前 OpenGL ES 的上下文的‘清除颜色’
    glClearColor(0.0, 0.0, 0.0, 1.0); // backgroundColor
    
    /**
     第一个参数用于指定要生成的缓存标识符的数量
     第二个参数是一个指针，指向生成的标识符的内存保存位置
     */
    glGenBuffers(1, &vertexBufferID); // step1
    
    /**
     第一个参数是一个常亮，用于指定要绑定那一种类型的缓存,OpenGL ES2.0只支持两种类型的缓存
     1.GL_ARRAY_BUFFER 用于指定一个定点属性数组
     2. GL_ELEMENT_ARRAY_BUFFER
     第二个参数是要绑定缓存的标识符,缓存标识符实际上是无符号整形，0表示没有缓存，缓存标识符在 OpenGLES 文档中又叫做‘names’
     */
    glBindBuffer(GL_ARRAY_BUFFER, vertexBufferID); // step2
    
    /**
     第一个参数用于指定要更新当前上下文中所绑定的是哪一个缓存
     第二个参数指定要复制进这个缓存的字节的数量
     第三个参数是要复制的字节的地址
     第四个提示了缓存在未来的运算中可能将会被怎么样的使用
     GL_STATIC_DRAW提示会告诉上下文，缓存中的内容适合复制到 GPU 控制的内存，因为很少对其修改
     GL_DYNAMIC_DRAW作为提示会告诉上下文，缓存内的数据会频繁的改变，同时提示 OpenGL ES 以不同的方式来处理缓存的存储
     */
    glBufferData(GL_ARRAY_BUFFER, sizeof(vertices), vertices, GL_STATIC_DRAW);// step3
    
}

/**
 每当一个 GLKView 实例需要被重新绘制时，他都会让保存在视图的上下文属性中的OpenGL ES 的上下文成为当前上下文，如果需要的话，GLKView 实例会绑定与一个CoreAnimation层分享的帧缓存，执行其他的标注的 OpenGL ES 配置，并发送一个请求来调用下面这个委托方法。
 这个方法的实现告诉 baseEffect 准备好当前 OpenGL ES 的上下文，以便使用 baseEffect 生成的属性和‘Shading Language’程序的绘图做好准备，接着调用 glClear()函数来设置当前绑定的帧缓存的像素颜色渲染缓存中的每个像素的颜色为前面使用 glClearColor 函数设定的值，
 */
- (void)glkView:(GLKView *)view drawInRect:(CGRect)rect{

    [self.baseEffect prepareToDraw];
    
    glClear(GL_COLOR_BUFFER_BIT);
    /**
     在帧缓存被清除之后，是时候用存储在当前版否定的 OpenGL ES 的GL_ARRAY_BUFFER类型的缓存中的定点数据绘制图像，
     1. 启用缓存
     2. 设置指针
     3. 绘图
     */

    
    /**
     启用定点缓存渲染操作
     */
    glEnableVertexAttribArray(GLKVertexAttribPosition);//step4
    /**
     glVertexAttribPointer()函数会告诉 OpenGL ES 定点数据在哪里，以及怎么解释为每个定点保存的数据
     第一个参数:指示当前绑定的缓存包含每个定点的位置信息
     第二个参数:指示每个位置有3个部分
     第三个参数告诉 OpenGL ES 每个部分都保存为一个浮点类型的值
     第四个参数告诉 OpenGL ES 小数点固定数据是否可以被改变
     第五个参数叫做‘步幅’，它指定了每个定点的保存需要多少个字节，也就是说，‘步幅’指定了 GPU 从一个定点的内存开始开始转到下一个定点的内存开始位置需要跳过多少字节，
     第六个参数是 NULL，这告诉 OpenGL ES 可以从当前绑定的定点缓存的开始位置访问定点数据
     */
    glVertexAttribPointer(GLKVertexAttribPosition, 3, GL_FLOAT, GL_FALSE, sizeof(SceneVertex), NULL);//step5
    
    /**
     执行绘图
     第一个参数：告诉 GPU 怎么处理在绑定的定点缓存内的定点数据
     第二个参数：指定缓存内的需要渲染的第一个定点的位置
     第三个参数：需要渲染的定点的数量
     */
    glDrawArrays(GL_TRIANGLES, 0, 3);//step6
}

- (void)dealloc{

    GLKView *view = (GLKView *)self.view;
    [EAGLContext setCurrentContext:view.context];
    if (0!= vertexBufferID) {
        /**
         删除不再需要的定点缓存和上下文，设置标识符为0避免了在对应的缓存被删除以后还是用其无效的标识符，
         */
        glDeleteBuffers(1, &vertexBufferID);//step7
        vertexBufferID = 0;
    }
    ((GLKView *)self.view).context = nil;
    [EAGLContext setCurrentContext:nil];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


@end
