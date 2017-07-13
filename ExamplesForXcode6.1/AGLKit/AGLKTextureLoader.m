//
//  AGLKTextureLoader.m
//  OpenGLES_Ch3_2
//

#import "AGLKTextureLoader.h"

/////////////////////////////////////////////////////////////////
// This data type is used specify power of 2 values.  OpenGL ES 
// best supports texture images that have power of 2 dimensions.
typedef enum
{
   AGLK1 = 1,
   AGLK2 = 2,
   AGLK4 = 4,
   AGLK8 = 8,
   AGLK16 = 16,
   AGLK32 = 32,
   AGLK64 = 64,
   AGLK128 = 128,
   AGLK256 = 256,
   AGLK512 = 512,
   AGLK1024 = 1024,
} 
AGLKPowerOf2;


/////////////////////////////////////////////////////////////////
// Forward declaration of function
static AGLKPowerOf2 AGLKCalculatePowerOf2ForDimension(
   GLuint dimension);

/////////////////////////////////////////////////////////////////
// Forward declaration of function
static NSData *AGLKDataWithResizedCGImageBytes(
   CGImageRef cgImage,
   size_t *widthPtr,
   size_t *heightPtr);
                              
/////////////////////////////////////////////////////////////////
// Instances of AGLKTextureInfo are immutable once initialized
@interface AGLKTextureInfo (AGLKTextureLoader)

- (id)initWithName:(GLuint)aName
   target:(GLenum)aTarget
   width:(GLuint)aWidth
   height:(GLuint)aHeight;
   
@end


@implementation AGLKTextureInfo (AGLKTextureLoader)

/////////////////////////////////////////////////////////////////
// This method is the designated initializer.
- (id)initWithName:(GLuint)aName
   target:(GLenum)aTarget
   width:(GLuint)aWidth
   height:(GLuint)aHeight
{
    if (nil != (self = [super init])) 
    {
        name = aName;
        target = aTarget;
        width = aWidth;
        height = aHeight;
    }
    
    return self;
}

@end


@implementation AGLKTextureInfo

@synthesize name;
@synthesize target;
@synthesize width;
@synthesize height;

@end


@implementation AGLKTextureLoader

/////////////////////////////////////////////////////////////////
// This method generates a new OpenGL ES texture buffer and 
// initializes the buffer contents using pixel data from the 
// specified Core Graphics image, cgImage. This method returns an
// immutable AGLKTextureInfo instance initialized with 
// information about the newly generated texture buffer.
//    The generated texture buffer has power of 2 dimensions. The
// provided image data is scaled (re-sampled) by Core Graphics as
// necessary to fit within the generated texture buffer.
+ (AGLKTextureInfo *)textureWithCGImage:(CGImageRef)cgImage                           options:(NSDictionary *)options
   error:(NSError **)outError; 
{
   // Get the bytes to be used when copying data into new texture
   // buffer
   size_t width;
   size_t height;
   NSData *imageData = AGLKDataWithResizedCGImageBytes(
      cgImage,
      &width,
      &height);
   
   // Generation, bind, and copy data into a new texture buffer
   GLuint      textureBufferID;
   
   glGenTextures(1, &textureBufferID);                  // Step 1
   glBindTexture(GL_TEXTURE_2D, textureBufferID);       // Step 2
   
    /**
     用于复制图片像素的颜色数据到绑定的纹理缓存中
     第一个参数：用于2D 纹理的GL_TEXTURE_2D
     第二个参数：用于指定MIP贴图的初始细节级别,如果没有使用 MIP 贴图，则必须为0,否则要明确的舒适化每个细节级别，需要注意的是，因为从全分辨率到只有一纹素的每个级别都必须被指定，否则 GPU 不接受这个纹理缓存
     第三个参数是 imageFormat,用于指定在文理缓存内每个纹理需要保存的信息的数量,对于 iOS 设备来说，纹理信息要么是 GL_RGB,要么是 GL_RGBA，
        GL_RGB为每个纹素保存红蓝绿三种颜色元素
        GL_RGBA保存了一个额外的用于指定每个纹素透明度的透明度元素
     第四个参数：用于指定图像宽度
     第五个参数：用于指定图像高度
        高度和宽度需要时2的幂次方
     第六个参数：border,用来确定围绕纹理的纹素的一个边界的大小，但是在OpenGL ES 中它总是被设置为0
     第七个参数:format:用于指定初始化缓存所使用的图像数据中每个像素索要保存的信息,这个参数应该总是和imageFormat参数相同，
     第八个参数：用于指定缓存中的纹素数据所使用的位编码类型，可是是下面的符号之一：
        GL_UNSIGNED_BYTE 提供最佳色彩质量,但是它每个纹素中每个颜色元素的保存需要一字节的存储空间,结果是每次取样一个 RGB 类型的纹素,GPU 都必须最少读取3字节（24位），每个 RGBA 类型的纹素需要读取4字节,其他的纹素格式使用多种编码方式来把每个纹素的所有颜色元素的信息保存在2字节中。
        GL_UNSIGNED_SHORT_5_6_5, 把5位用于红色，6位用于绿色，5位用于蓝色。但是没有透明度部分
        GL_UNSIGNED_SHORT_5_5_5_1：为红绿蓝各使用5位，但是透明度只是用1位,这种格式会让每个纹素要么完全透明，要么完全不透明
        GL_UNSIGNED_SHORT_4_4_4_4 ：平均为每个纹素的颜色元素使用4位
     第九个参数：是一个要被复制到绑定的纹理缓存中的图片的像素验收数据的指针
     */
   glTexImage2D(                                        // Step 3
      GL_TEXTURE_2D, 
      0, 
      GL_RGBA, 
      (GLuint)width,
      (GLuint)height,
      0, 
      GL_RGBA, 
      GL_UNSIGNED_BYTE, 
      [imageData bytes]);
   
   // Set parameters that control texture sampling for the bound
   // texture
  glTexParameteri(GL_TEXTURE_2D, 
     GL_TEXTURE_MIN_FILTER, 
     GL_LINEAR); 
   
   // Allocate and initialize the AGLKTextureInfo instance to be
   // returned
   AGLKTextureInfo *result = [[AGLKTextureInfo alloc] 
      initWithName:textureBufferID
      target:GL_TEXTURE_2D
      width:(GLuint)width
      height:(GLuint)height];
   
   return result;
}
                                 
@end


/////////////////////////////////////////////////////////////////
// This function returns an NSData object that contains bytes
// loaded from the specified Core Graphics image, cgImage. This
// function also returns (by reference) the power of 2 width and 
// height to be used when initializing an OpenGL ES texture buffer
// with the bytes in the returned NSData instance. The widthPtr 
// and heightPtr arguments must be valid pointers.
static NSData *AGLKDataWithResizedCGImageBytes(
   CGImageRef cgImage,
   size_t *widthPtr,
   size_t *heightPtr)
{
   NSCParameterAssert(NULL != cgImage);
   NSCParameterAssert(NULL != widthPtr);
   NSCParameterAssert(NULL != heightPtr);
   
   GLuint originalWidth = (GLuint)CGImageGetWidth(cgImage);
   GLuint originalHeight = (GLuint)CGImageGetWidth(cgImage);
   
   NSCAssert(0 < originalWidth, @"Invalid image width");
   NSCAssert(0 < originalHeight, @"Invalid image width");
   
   // Calculate the width and height of the new texture buffer
   // The new texture buffer will have power of 2 dimensions.
   GLuint width = AGLKCalculatePowerOf2ForDimension(
      originalWidth);
   GLuint height = AGLKCalculatePowerOf2ForDimension(
      originalHeight);
      
   // Allocate sufficient storage for RGBA pixel color data with 
   // the power of 2 sizes specified
   NSMutableData    *imageData = [NSMutableData dataWithLength:
      height * width * 4];  // 4 bytes per RGBA pixel

   NSCAssert(nil != imageData, 
      @"Unable to allocate image storage");
   
   // Create a Core Graphics context that draws into the 
   // allocated bytes
   CGColorSpaceRef colorSpace = CGColorSpaceCreateDeviceRGB();
   CGContextRef cgContext = CGBitmapContextCreate( 
      [imageData mutableBytes], width, height, 8, 
      4 * width, colorSpace, 
      kCGImageAlphaPremultipliedLast);
   CGColorSpaceRelease(colorSpace);
   
   // Flip the Core Graphics Y-axis for future drawing
   CGContextTranslateCTM (cgContext, 0, height);
   CGContextScaleCTM (cgContext, 1.0, -1.0);
   
   // Draw the loaded image into the Core Graphics context 
   // resizing as necessary
   CGContextDrawImage(cgContext, CGRectMake(0, 0, width, height),
      cgImage);
   
   CGContextRelease(cgContext);
   
   *widthPtr = width;
   *heightPtr = height;
   
   return imageData;
}


/////////////////////////////////////////////////////////////////
// This function calculates and returns the nearest power of 2 
// that is greater than or equal to the dimension argument and 
// less than or equal to 1024.
static AGLKPowerOf2 AGLKCalculatePowerOf2ForDimension(
   GLuint dimension)
{
   AGLKPowerOf2  result = AGLK1;
   
   if(dimension > (GLuint)AGLK512)
   {
      result = AGLK1024;
   }
   else if(dimension > (GLuint)AGLK256)
   {
      result = AGLK512;
   }
   else if(dimension > (GLuint)AGLK128)
   {
      result = AGLK256;
   }
   else if(dimension > (GLuint)AGLK64)
   {
      result = AGLK128;
   }
   else if(dimension > (GLuint)AGLK32)
   {
      result = AGLK64;
   }
   else if(dimension > (GLuint)AGLK16)
   {
      result = AGLK32;
   }
   else if(dimension > (GLuint)AGLK8)
   {
      result = AGLK16;
   }
   else if(dimension > (GLuint)AGLK4)
   {
      result = AGLK8;
   }
   else if(dimension > (GLuint)AGLK2)
   {
      result = AGLK4;
   }
   else if(dimension > (GLuint)AGLK1)
   {
      result = AGLK2;
   }
   
   return result;
}
