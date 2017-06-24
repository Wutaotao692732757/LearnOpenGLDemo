//
//  ViewController.m
//  ch6-2
//
//  Created by wutaotao on 2017/6/24.
//  Copyright © 2017年 wutaotao. All rights reserved.
//

#import "ViewController.h"
#import "AGLKContext.h"
#import "SceneAnimatedMesh.h"


@interface ViewController ()

@property (strong, nonatomic) GLKBaseEffect
*baseEffect;
@property (strong, nonatomic) SceneAnimatedMesh
*animatedMesh;

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    // Interface Builder storyboard
    GLKView *view = (GLKView *)self.view;
    NSAssert([view isKindOfClass:[GLKView class]],
             @"View controller's view is not a GLKView");
    
    // Create an OpenGL ES 2.0 context and provide it to the
    // view
    view.context = [[AGLKContext alloc]
                    initWithAPI:kEAGLRenderingAPIOpenGLES2];
    view.drawableDepthFormat = GLKViewDrawableDepthFormat16;
    
    // Make the new context current
    [AGLKContext setCurrentContext:view.context];
    
    // Create a base effect that provides standard OpenGL ES 2.0
    // shading language programs and set constants to be used for
    // all subsequent rendering
    self.baseEffect = [[GLKBaseEffect alloc] init];
    
    // Configure a light
    self.baseEffect.light0.enabled = GL_TRUE;
    self.baseEffect.light0.ambientColor = GLKVector4Make(
                                                         0.6f, // Red
                                                         0.6f, // Green
                                                         0.6f, // Blue
                                                         1.0f);// Alpha
    
    self.baseEffect.light0.diffuseColor = GLKVector4Make(
                                                         1.0f, // Red
                                                         1.0f, // Green
                                                         1.0f, // Blue
                                                         1.0f);// Alpha
    
    self.baseEffect.light0.position = GLKVector4Make(
                                                     1.0f,
                                                     0.8f,
                                                     0.4f,
                                                     0.0f);
    
    // Set the background color stored in the current context 
    ((AGLKContext *)view.context).clearColor = GLKVector4Make(
                                                              0.0f, // Red 
                                                              0.0f, // Green 
                                                              0.0f, // Blue 
                                                              1.0f);// Alpha 
    
    // Create a mesh to animate
    _animatedMesh = [[SceneAnimatedMesh alloc] init];
    
    // set the modelview matrix to match current eye and look-at 
    // positions
    self.baseEffect.transform.modelviewMatrix =  
    GLKMatrix4MakeLookAt(
                         20, 25, 5, 
                         20, 0, -15, 
                         0, 1, 0);
    
    [(AGLKContext *)view.context enable:GL_DEPTH_TEST];
}


- (void)glkView:(GLKView *)view drawInRect:(CGRect)rect
{
    // Clear back frame buffer (erase previous drawing)
    [((AGLKContext *)view.context)
     clear:GL_COLOR_BUFFER_BIT|GL_DEPTH_BUFFER_BIT];
    
    // Calculate the aspect ratio for the scene and setup a
    // perspective projection
    const GLfloat  aspectRatio =
    (GLfloat)view.drawableWidth / (GLfloat)view.drawableHeight;
    
    self.baseEffect.transform.projectionMatrix =
    GLKMatrix4MakePerspective(
                              GLKMathDegreesToRadians(60.0f),// Standard field of view
                              aspectRatio,
                              0.1f,   // Don't make near plane too close
                              255.0f);// Far is arbitrarily far enough to contain scene
    
    [self.animatedMesh
     updateMeshWithElapsedTime:self.timeSinceLastResume];
    
    // Draw the mesh
    [self.baseEffect prepareToDraw];
    [self.animatedMesh prepareToDraw];
    [self.animatedMesh drawEntireMesh];
}
- (void)viewDidUnload
{
    [super viewDidUnload];
    
    // Make the view's context current
    GLKView *view = (GLKView *)self.view;
    [AGLKContext setCurrentContext:view.context];
    
    // Stop using the context created in -viewDidLoad
    ((GLKView *)self.view).context = nil;
    [EAGLContext setCurrentContext:nil];
    
    _animatedMesh = nil;
}
- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    // Return YES for supported orientations
    return (interfaceOrientation !=
            UIInterfaceOrientationPortraitUpsideDown &&
            interfaceOrientation !=
            UIInterfaceOrientationPortrait);
}


@end
