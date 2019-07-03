//
//  ViewController.m
//  GLKitLearnDemo
//
//  Created by 赵泓博 on 2019/7/2.
//  Copyright © 2019 zhaohongbo. All rights reserved.
//
#import <GLKit/GLKit.h>
#import "ViewController.h"

typedef struct {
    GLKVector3 positionCoord;   //顶点坐标 GLKVector3三维向量
    GLKVector2 textureCoord;    //纹理坐标
    GLKVector3 normal;          //法线
} CCVertex;
// 顶点数
static NSInteger const kCoordCount = 36;
@interface ViewController ()<GLKViewDelegate>

/**GLkit作用的View*/
@property (nonatomic,strong) GLKView *glkView;
@property (nonatomic, strong) GLKBaseEffect *baseEffect;
@property (nonatomic, assign) CCVertex *vertices;
/**顶点缓冲区*/
@property (nonatomic, assign) GLuint vertexBuffer;
@property (nonatomic, strong) CADisplayLink *displayLink;
@property (nonatomic, assign) NSInteger angle;
@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.view.backgroundColor = [UIColor blueColor];
    //2. OpenGL ES 相关初始化
    [self commonInit];
    
    //3.顶点/纹理坐标数据
    [self vertexDataSetup];
    // Do any additional setup after loading the view.
    [self addCADisplayLink];
}

-(void)commonInit
{
    /**初始化上下文，指定OpenGL3*/
    EAGLContext *context = [[EAGLContext alloc]initWithAPI:kEAGLRenderingAPIOpenGLES3];
    
    //设置当前context
    [EAGLContext setCurrentContext:context];
    
    self.glkView = [[GLKView alloc]initWithFrame:CGRectMake(0, 100, self.view.bounds.size.width, self.view.bounds.size.width) context:context];
    self.glkView.backgroundColor = [UIColor blackColor];
    
    self.glkView.delegate = self;
    
    //3.使用深度缓存
    self.glkView.drawableDepthFormat = GLKViewDrawableDepthFormat24;
    
    //4.将GLKView 添加self.view 上
    [self.view addSubview:self.glkView];
    //5.获取纹理图片
    NSString *imagePath = [[[NSBundle mainBundle] resourcePath] stringByAppendingPathComponent:@"sundown.jpeg"];
    UIImage *image = [UIImage imageWithContentsOfFile:imagePath];
    
    //6.设置纹理参数
    NSDictionary *options = @{GLKTextureLoaderOriginBottomLeft : @(YES)};//纹理翻转
    /**GLKTextureInfo 固定纹理抽象类*/
    GLKTextureInfo *textureInfo = [GLKTextureLoader textureWithCGImage:[image CGImage]
                                                               options:options
                                                                 error:NULL];
    
    // 使用苹果GLKit提供GLKBaseEffect完成着色器工作（顶点/片元）
    
    //苹果内部封装了固定的顶点、片元着色器，GLKBaseEffect的作用即像这两个着色器传递参数
    //7.使用baseEffect
    
    self.baseEffect = [[GLKBaseEffect alloc] init];
    self.baseEffect.texture2d0.name = textureInfo.name;
    self.baseEffect.texture2d0.target = textureInfo.target;
}

/**设置顶点数据*/
-(void)vertexDataSetup
{
    /**开辟指定点大小的固定空间
     在OpenGL中，OpenGL设置了固定的一个地址作为目标地址OpenGL会不断的从某个位置中读取数据，所以我们使用OpenGL编程的过程中，经常需要绑定数据。
     
     如需要绑定多个数据，则通常开辟连续的地址空间存储数据。将数据首地址赋值给指定地址
     
     所以OpenGL中没有指针概念  因为1  给定的地址都是连续的  2 操作的目标地址都是固定的
     
     
     */
    //顶点信息存储空间开辟  kCoordCount 顶点结构体数量
    self.vertices = malloc(sizeof(CCVertex) * kCoordCount);
    // 前面
    self.vertices[0] = (CCVertex){{-0.5, 0.5, 0.5},  {0, 1}};
    self.vertices[1] = (CCVertex){{-0.5, -0.5, 0.5}, {0, 0}};
    self.vertices[2] = (CCVertex){{0.5, 0.5, 0.5},   {1, 1}};
    
    self.vertices[3] = (CCVertex){{-0.5, -0.5, 0.5}, {0, 0}};
    self.vertices[4] = (CCVertex){{0.5, 0.5, 0.5},   {1, 1}};
    self.vertices[5] = (CCVertex){{0.5, -0.5, 0.5},  {1, 0}};
    
    // 上面
    self.vertices[6] = (CCVertex){{0.5, 0.5, 0.5},    {1, 1}};
    self.vertices[7] = (CCVertex){{-0.5, 0.5, 0.5},   {0, 1}};
    self.vertices[8] = (CCVertex){{0.5, 0.5, -0.5},   {1, 0}};
    self.vertices[9] = (CCVertex){{-0.5, 0.5, 0.5},   {0, 1}};
    self.vertices[10] = (CCVertex){{0.5, 0.5, -0.5},  {1, 0}};
    self.vertices[11] = (CCVertex){{-0.5, 0.5, -0.5}, {0, 0}};
    
    // 下面
    self.vertices[12] = (CCVertex){{0.5, -0.5, 0.5},    {1, 1}};
    self.vertices[13] = (CCVertex){{-0.5, -0.5, 0.5},   {0, 1}};
    self.vertices[14] = (CCVertex){{0.5, -0.5, -0.5},   {1, 0}};
    self.vertices[15] = (CCVertex){{-0.5, -0.5, 0.5},   {0, 1}};
    self.vertices[16] = (CCVertex){{0.5, -0.5, -0.5},   {1, 0}};
    self.vertices[17] = (CCVertex){{-0.5, -0.5, -0.5},  {0, 0}};
    
    // 左面
    self.vertices[18] = (CCVertex){{-0.5, 0.5, 0.5},    {1, 1}};
    self.vertices[19] = (CCVertex){{-0.5, -0.5, 0.5},   {0, 1}};
    self.vertices[20] = (CCVertex){{-0.5, 0.5, -0.5},   {1, 0}};
    self.vertices[21] = (CCVertex){{-0.5, -0.5, 0.5},   {0, 1}};
    self.vertices[22] = (CCVertex){{-0.5, 0.5, -0.5},   {1, 0}};
    self.vertices[23] = (CCVertex){{-0.5, -0.5, -0.5},  {0, 0}};
    
    // 右面
    self.vertices[24] = (CCVertex){{0.5, 0.5, 0.5},    {1, 1}};
    self.vertices[25] = (CCVertex){{0.5, -0.5, 0.5},   {0, 1}};
    self.vertices[26] = (CCVertex){{0.5, 0.5, -0.5},   {1, 0}};
    self.vertices[27] = (CCVertex){{0.5, -0.5, 0.5},   {0, 1}};
    self.vertices[28] = (CCVertex){{0.5, 0.5, -0.5},   {1, 0}};
    self.vertices[29] = (CCVertex){{0.5, -0.5, -0.5},  {0, 0}};
    
    // 后面
    self.vertices[30] = (CCVertex){{-0.5, 0.5, -0.5},   {0, 1}};
    self.vertices[31] = (CCVertex){{-0.5, -0.5, -0.5},  {0, 0}};
    self.vertices[32] = (CCVertex){{0.5, 0.5, -0.5},    {1, 1}};
    self.vertices[33] = (CCVertex){{-0.5, -0.5, -0.5},  {0, 0}};
    self.vertices[34] = (CCVertex){{0.5, 0.5, -0.5},    {1, 1}};
    self.vertices[35] = (CCVertex){{0.5, -0.5, -0.5},   {1, 0}};
    glGenBuffers(1, &_vertexBuffer);
    glBindBuffer(GL_ARRAY_BUFFER, _vertexBuffer);
    GLsizeiptr bufferSizeBytes = sizeof(CCVertex) * kCoordCount;
    glBufferData(GL_ARRAY_BUFFER, bufferSizeBytes, self.vertices, GL_STATIC_DRAW);
    /**
     注册指针
     绑定指针
     数据指针填充数据
     */
    
    /**
     和顶点着色器交互方式
     1. 打开交互通道glEnableVertexAttribArray
     2. 设置读取值
     交互的方式包括 顶点和索引两种
     */
    //顶点数据
    glEnableVertexAttribArray(GLKVertexAttribPosition);
    glVertexAttribPointer(GLKVertexAttribPosition, 3, GL_FLOAT, GL_FALSE, sizeof(CCVertex), NULL + offsetof(CCVertex, positionCoord));
    
    //纹理数据
    glEnableVertexAttribArray(GLKVertexAttribTexCoord0);
    glVertexAttribPointer(GLKVertexAttribTexCoord0, 2, GL_FLOAT, GL_FALSE, sizeof(CCVertex), NULL + offsetof(CCVertex, textureCoord));
    
    
    
}


#pragma mark - GLKViewDelegate  和drawRect类似，每次执行渲染都会调用该方法，相当于给渲染设置环境，比如开启深度测试等
- (void)glkView:(GLKView *)view drawInRect:(CGRect)rect {
    
    
    //1.开启深度测试
    glEnable(GL_DEPTH_TEST);
    glClearColor(0, 1, 0, 1);
    //2.清除颜色缓存区&深度缓存区
    glClear(GL_COLOR_BUFFER_BIT | GL_DEPTH_BUFFER_BIT);
    //3.准备绘制
    [self.baseEffect prepareToDraw];
    
    //4.绘图
    glDrawArrays(GL_TRIANGLES, 0, kCoordCount);
}






-(void) addCADisplayLink{
    
    //CADisplayLink 类似定时器,提供一个周期性调用.属于QuartzCore.framework中.
    //具体可以参考该博客 https://www.cnblogs.com/panyangjun/p/4421904.html
    self.angle = 0;
    self.displayLink = [CADisplayLink displayLinkWithTarget:self selector:@selector(update)];
    [self.displayLink addToRunLoop:[NSRunLoop mainRunLoop] forMode:NSRunLoopCommonModes];
}

#pragma mark - update
- (void)update {
    
    //1.计算旋转度数
    self.angle = (self.angle + 5) % 360;
    //2.修改baseEffect.transform.modelviewMatrix  修改模型视图矩阵
    self.baseEffect.transform.modelviewMatrix = GLKMatrix4MakeRotation(GLKMathDegreesToRadians(self.angle), 0.3, 1, -0.7);
    //3.重新渲染
    [self.glkView display];
}

@end
