//
//  PaintingView.m
//  绘图
//
//  Created by wutaotao on 2017/4/19.
//  Copyright © 2017年 wutaotao. All rights reserved.
//

#import "PaintingView.h"
#import <QuartzCore/QuartzCore.h>
#import <OpenGLES/EAGLDrawable.h>
#import <GLKit/GLKit.h>

#import "shaderUtil.h"
#import "fileUtil.h"
#import "debug.h"

#define kBrushOpacity       (1.0 / 3.0)
#define kBrushPixelStep     3
#define kBrushScale         2

enum {
    PROGRAM_POINT,
    NUM_PROGRAMS
};

enum {
    UNIFORM_MVP,
    UNIFORM_POINT_SIZE,
    UNIFORM_VERTEX_COLOR,
    UNIFORM_TEXTURE,
    NUM_UNIFORMS
};

enum {
    ATTRIB_VERTEX,
    NUM_ATTRIBS
};

typedef struct {
    char *vert, *frag;
    GLint uniform[NUM_UNIFORMS];
    GLuint id;
} programInfo_t;

programInfo_t program[NUM_PROGRAMS] = {
    { "point.vsh",   "point.fsh" },     // PROGRAM_POINT
};

// Texture
typedef struct {
    GLuint id;
    GLsizei width, height;
} textureInfo_t;

@implementation LYPoint

- (instancetype)initWithCGPoint:(CGPoint)point {
    self = [super init];
    
    if (self) {
        self.mX = [NSNumber numberWithDouble:point.x];
        self.mY = [NSNumber numberWithDouble:point.y];
    }
    
    return self;
}

@end



@interface PaintingView()
{
    // The pixel dimensions of the backbuffer
    GLint backingWidth;
    GLint backingHeight;
    
    EAGLContext *context;
    
    // OpenGL names for the renderbuffer and framebuffers used to render to this view
    GLuint viewRenderbuffer, viewFramebuffer;
    
    // OpenGL name for the depth buffer that is attached to viewFramebuffer, if it exists (0 if it does not exist)
    GLuint depthRenderbuffer;
    
    textureInfo_t brushTexture;     // brush texture
    GLfloat brushColor[4];          // brush color
    
    Boolean	firstTouch;
    Boolean needsErase;
    
    // Shader objects
    GLuint vertexShader;
    GLuint fragmentShader;
    GLuint shaderProgram;
    
    // Buffer Objects
    GLuint vboId;
    
    BOOL initialized;
    
    NSMutableArray* lyArr;
}

@end

@implementation PaintingView

@synthesize location;
@synthesize previousLocation;

+ (Class)layerClass{
    return [CAEAGLLayer class];
}

-(id)initWithCoder:(NSCoder *)coder{
    
    if ((self = [super initWithCoder:coder])) {
        CAEAGLLayer *eaglLayer = (CAEAGLLayer *)self.layer;
        
        eaglLayer.opaque = YES;
        eaglLayer.drawableProperties = [NSDictionary dictionaryWithObjectsAndKeys:
                                        [NSNumber numberWithBool:YES], kEAGLDrawablePropertyRetainedBacking, kEAGLColorFormatRGBA8, kEAGLDrawablePropertyColorFormat, nil];
        
        context = [[EAGLContext alloc] initWithAPI:kEAGLRenderingAPIOpenGLES2];
        
        if (!context || ![EAGLContext setCurrentContext:context]) {
            return nil;
        }
        
        self.contentScaleFactor = [[UIScreen mainScreen] scale];
        
        needsErase = YES;
}
 
    return self;
}

-(void)layoutSubviews{
    
    [EAGLContext setCurrentContext:context];
    
    if (!initialized) {
        initialized = [self initGL];
    }
    else{
       [self resizeFromLayer:(CAEAGLLayer*)self.layer];

    }
    
    if (needsErase) {
        [self erase];
        needsErase = NO;
    }
    
}

-(void)setupShaders{
    
    for (int i = 0; i < NUM_PROGRAMS; i++) {
        
        char *vsrc = readFile(pathForResource(program[i].vert));
        char *fsrc = readFile(pathForResource(program[i].frag));
        GLsizei attribCt = 0;
        GLchar *attribUsed[NUM_ATTRIBS];
        GLint attrib[NUM_ATTRIBS];
        GLchar *attribName[NUM_ATTRIBS] = {
            "inVertex",
        };
        const GLchar *uniformName[NUM_UNIFORMS] = {
            
            "MVP", "pointSize", "vertexColor", "texture",
        };
        
        for (int j = 0; j <NUM_ATTRIBS; j++) {
            
            if (strstr(vsrc, attribName[j])) {
                attrib[attribCt] = j;
                attribUsed[attribCt++] = attribName[j];
            }
        }
        
        glueCreateProgram(vsrc, fsrc, attribCt, (const GLchar **)&attribUsed[0], attrib, NUM_UNIFORMS, &uniformName[0], program[i].uniform, &program[i].id);
        free(vsrc);
        free(fsrc);
        
        if (i == PROGRAM_POINT) {
            
            glUseProgram(program[PROGRAM_POINT].id);
            glUniform1i(program[PROGRAM_POINT].uniform[UNIFORM_TEXTURE], 0);
            
            GLKMatrix4 projectionMatrix = GLKMatrix4MakeOrtho(0, backingWidth, 0, backingHeight, -1, -1);
            GLKMatrix4 modelViewMatrix = GLKMatrix4Identity;
            GLKMatrix4 MVPMatrix = GLKMatrix4Multiply(projectionMatrix, modelViewMatrix);
            glUniformMatrix4fv(program[PROGRAM_POINT].uniform[UNIFORM_MVP], 1, GL_FALSE, MVPMatrix.m);
            
            glUniform1f(program[PROGRAM_POINT].uniform[UNIFORM_POINT_SIZE], brushTexture.width / kBrushScale);
            glUniform4fv(program[PROGRAM_POINT].uniform[UNIFORM_VERTEX_COLOR], 1, brushColor);
            
        }
   
    }
    glError();
 
}

-(textureInfo_t)textureFromName:(NSString *)name{
    
    CGImageRef brushImage;
    CGContextRef brushContext;
    GLubyte *brushData;
    size_t width, height;
    GLuint texId;
    textureInfo_t texture;
    
    brushImage = [UIImage imageNamed:name].CGImage;
    
    width = CGImageGetWidth(brushImage);
    height = CGImageGetHeight(brushImage);
    
    if (brushImage) {
        
        brushData = (GLubyte *)calloc(width * height * 4, sizeof(GLubyte));
        brushContext = CGBitmapContextCreate(brushData, width, height, 8, width * 4, CGImageGetColorSpace(brushImage), kCGImageAlphaPremultipliedLast);
        CGContextDrawImage(brushContext, CGRectMake(0.0, 0.0, (CGFloat)width, (CGFloat)height), brushImage);
        CGContextRelease(brushContext);
        glGenTextures(1, &texId);
        glBindTexture(GL_TEXTURE_2D, texId);
        glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_MIN_FILTER, GL_LINEAR);
        glTexImage2D(GL_TEXTURE_2D, 0, GL_RGBA, (int)width, (int)height, 0, GL_RGBA, GL_UNSIGNED_BYTE, brushData);
        free(brushData);
        
        texture.id = texId;
        texture.width = (int)width;
        texture.height = (int)height;
    }
    return texture;
}

-(BOOL)initGL{
    
    glGenFramebuffers(1, &viewFramebuffer);
    glGenRenderbuffers(1, &viewRenderbuffer);
    
    glBindFramebuffer(GL_FRAMEBUFFER, viewFramebuffer);
    glBindRenderbuffer(GL_RENDERBUFFER, viewRenderbuffer);
    
    [context renderbufferStorage:GL_RENDERBUFFER fromDrawable:(id<EAGLDrawable>)self.layer];
    glFramebufferRenderbuffer(GL_FRAMEBUFFER, GL_COLOR_ATTACHMENT0, GL_RENDERBUFFER, viewRenderbuffer);
    glGetRenderbufferParameteriv(GL_RENDERBUFFER, GL_RENDERBUFFER_WIDTH, &backingWidth);
    glGetRenderbufferParameteriv(GL_RENDERBUFFER, GL_RENDERBUFFER_HEIGHT, &backingWidth);
    
    if (glCheckFramebufferStatus(GL_FRAMEBUFFER) != GL_FRAMEBUFFER_COMPLETE) {
        NSLog(@"failed to make complete framebuffer object %x",glCheckFramebufferStatus(GL_FRAMEBUFFER));
        return NO;
    }
    
    glViewport(0, 0, backingWidth, backingHeight);
    glGenBuffers(1, &vboId);
    
    brushTexture = [self textureFromName:@"Particle.png"];
    
    [self setupShaders];
    
    glEnable(GL_BLEND);
    glBlendFunc(GL_ONE, GL_ONE_MINUS_SRC_ALPHA);
    
    NSString *path = [[NSBundle mainBundle] pathForResource:@"abc" ofType:@"string"];
    NSString *str = [NSString stringWithContentsOfFile:path encoding:NSUTF8StringEncoding error:nil];
    lyArr = [NSMutableArray array];
    
    NSArray *jsonArr = [NSJSONSerialization JSONObjectWithData:[str dataUsingEncoding:NSUTF8StringEncoding] options:NSJSONReadingAllowFragments error:nil];
    for (NSDictionary *dict in jsonArr) {
        LYPoint *point = [LYPoint new];
        point.mX = [dict objectForKey:@"mX"];
        point.mY = [dict objectForKey:@"mY"];
        [lyArr addObject:point];
    }
    [self performSelector:@selector(paint) withObject:nil afterDelay:0];
    
    return YES;
}

-(BOOL)resizeFromLayer:(CAEAGLLayer *)layer{
    
    glBindRenderbuffer(GL_RENDERBUFFER, viewRenderbuffer);
    [context renderbufferStorage:GL_RENDERBUFFER fromDrawable:layer];
    glGetRenderbufferParameteriv(GL_RENDERBUFFER, GL_RENDERBUFFER_WIDTH, &backingWidth);
    glGetRenderbufferParameteriv(GL_RENDERBUFFER, GL_RENDERBUFFER_HEIGHT, &backingHeight);
    
    if (glCheckFramebufferStatus(GL_FRAMEBUFFER) != GL_FRAMEBUFFER_COMPLETE) {
        NSLog(@"Failed to make complete framebuffer objectz %x", glCheckFramebufferStatus(GL_FRAMEBUFFER));
        return NO;
    }
    
    GLKMatrix4 projectionMatrix = GLKMatrix4MakeOrtho(0, backingWidth, 0, backingHeight, -1, 1);
    GLKMatrix4 modelViewMatrix = GLKMatrix4Identity;
    GLKMatrix4 MVPMatrix = GLKMatrix4Multiply(projectionMatrix, modelViewMatrix);
    glUseProgram(program[PROGRAM_POINT].id);
    glUniformMatrix4fv(program[PROGRAM_POINT].uniform[UNIFORM_MVP], 1, GL_FALSE, MVPMatrix.m);
    glViewport(0, 0, backingWidth, backingHeight);
    return YES;
}

-(void)dealloc{
    
    if (viewFramebuffer) {
        glDeleteFramebuffers(1, &viewFramebuffer);
        viewFramebuffer = 0;
    }
    
    if (viewRenderbuffer) {
        glDeleteRenderbuffers(1, &viewRenderbuffer);
        viewRenderbuffer = 0;
    }
    
    if (depthRenderbuffer) {
        glDeleteRenderbuffers(1, &depthRenderbuffer);
        depthRenderbuffer = 0;
    }
    
    if (brushTexture.id) {
        glDeleteTextures(1, &brushTexture.id);
        brushTexture.id = 0;
    }
    
    if (vboId) {
        glDeleteBuffers(1, &vboId);
        vboId = 0;
    }
    
    if ([EAGLContext currentContext] == context) {
        [EAGLContext setCurrentContext:nil];
    }
    
}

-(void)erase{
    [EAGLContext setCurrentContext:context];
    glBindFramebuffer(GL_FRAMEBUFFER, viewFramebuffer);
    glClearColor(0.0, 0.0, 0.0, 0.0);
    glClear(GL_COLOR_BUFFER_BIT);
    
    glBindRenderbuffer(GL_RENDERBUFFER, viewRenderbuffer);
    [context presentRenderbuffer:GL_RENDERBUFFER];
    
}

-(void)renderLineFromPoint:(CGPoint)start toPoint:(CGPoint)end{
    
    static GLfloat * vertexbuffer = NULL;
    static NSUInteger vertexMax = 64;
    NSUInteger vertexCount = 0, count, i;
    
    [EAGLContext setCurrentContext:context];
    glBindFramebuffer(GL_FRAMEBUFFER, viewFramebuffer);
    
    CGFloat scale = self.contentScaleFactor;
    start.x *= scale;
    start.y *= scale;
    end.x *= scale;
    end.y *= scale;
    
    if (vertexbuffer == NULL) {
        vertexbuffer = malloc(vertexMax * 2 * sizeof(GLfloat));
    }
    count = MAX(ceilf(sqrtf((end.x - start.x) * (end.x - start.x) + (end.y - start.y)*(end.y - start.y)) / kBrushPixelStep), 1);
    for (i = 0; i < count; ++i) {
        if (vertexCount == vertexMax) {
            vertexMax = 2 * vertexMax;
            vertexbuffer = realloc(vertexbuffer, vertexMax *2 *sizeof(GLfloat));
        }
        vertexbuffer[2 * vertexCount + 0] = start.x + (end.x - start.x) * ((GLfloat)i / (GLfloat)count);
        vertexbuffer[2 * vertexCount + 1] = start.y + (end.y - start.y) * ((GLfloat)i / (GLfloat)count);
        vertexCount += 1;
  
    }
    
    glBindBuffer(GL_ARRAY_BUFFER, vboId);
    glBufferData(GL_ARRAY_BUFFER, vertexCount*2*sizeof(GLfloat), vertexbuffer, GL_DYNAMIC_DRAW);
    glEnableVertexAttribArray(ATTRIB_VERTEX);
    glVertexAttribPointer(ATTRIB_VERTEX, 2, GL_FLOAT, GL_FALSE, 0, 0);
    
    glUseProgram(program[PROGRAM_POINT].id);
    glDrawArrays(GL_POINTS, 0, (int)vertexCount);
    
    glBindRenderbuffer(GL_RENDERBUFFER, viewRenderbuffer);
    [context presentRenderbuffer:GL_RENDERBUFFER];
    
}

-(void)paint{
    
    NSMutableArray *mutableArr = [NSMutableArray array];
    
    for (LYPoint *point in lyArr) {
        NSMutableDictionary *dict = [NSMutableDictionary dictionary];
        [dict setObject:point.mX forKey:@"mX"];
        [dict setObject:point.mY forKey:@"mY"];
        [mutableArr addObject:dict];
    }
    
    for (int i = 0; i + 1 < lyArr.count; i += 2) {
        LYPoint *lyPoint1 = lyArr[i];
        LYPoint *lyPoint2 = lyArr[i + 1];
        CGPoint point1, point2;
        point1.x = lyPoint1.mX.floatValue;
        point1.y = lyPoint1.mY.floatValue;
        
        point2.x = lyPoint2.mX.floatValue;
        point2.y = lyPoint2.mY.floatValue;
        [self renderLineFromPoint:point1 toPoint:point2];
    }
    
}

-(void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event
{
    CGRect bounds = [self bounds];
    
    UITouch * touch = [[event touchesForView:self] anyObject];
    firstTouch = YES;
    
    location = [touch locationInView:self];
    location.y = bounds.size.height - location.y;
}

-(void)touchesMoved:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event
{
    
    CGRect bounds = [self bounds];
    UITouch * touch = [[event touchesForView:self] anyObject];
    
    if (firstTouch) {
        firstTouch = NO;
        previousLocation = [touch previousLocationInView:self];
        previousLocation.y = bounds.size.height - previousLocation.y;
    }else{
        location = [touch locationInView:self];
        location.y = bounds.size.height - location.y;
        previousLocation = [touch previousLocationInView:self];
        previousLocation.y = bounds.size.height - previousLocation.y;
    }
    
    [self renderLineFromPoint:previousLocation toPoint:location];
    
}

- (void)touchesEnded:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event
{
    CGRect bounds = [self bounds];
    UITouch * touch = [[event touchesForView:self] anyObject];
    
    if (firstTouch) {
        firstTouch = NO;
        previousLocation = [touch previousLocationInView:self];
        previousLocation.y = bounds.size.height - previousLocation.y;
        [self renderLineFromPoint:previousLocation toPoint:location];
    }
}

-(void)touchesCancelled:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event
{
    NSLog(@"cancel");
}

-(void)setBrushColorwithRed:(CGFloat)red green:(CGFloat)green blue:(CGFloat)blue
{
    brushColor[0] = red * kBrushOpacity;
    brushColor[1] = green * kBrushOpacity;
    brushColor[2] = blue * kBrushOpacity;
    brushColor[3] = kBrushOpacity;
    
    if (initialized) {
        glUseProgram(program[PROGRAM_POINT].id);
        glUniform4fv(program[PROGRAM_POINT].uniform[UNIFORM_VERTEX_COLOR], 1, brushColor);
    }
}

-(BOOL)canBecomeFirstResponder{
    return YES;
}


@end






























