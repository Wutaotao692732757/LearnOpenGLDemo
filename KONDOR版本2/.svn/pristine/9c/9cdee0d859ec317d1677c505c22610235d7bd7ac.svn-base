/******************************************************************
 * File Name    : videorender.c
 * Description  : video render interface
 * Author       : huangchengman@aee.com
 * Date         : 2016-04-12
 ******************************************************************/

#include <time.h>
#include <stdio.h>
#include <stdlib.h>
#include <math.h>
#include <pthread.h>
#include <string.h>
#include <unistd.h>

#include <OpenGLES/ES2/gl.h>
#include <OpenGLES/ES2/glext.h>

#include "videorender.h"

static GLint ATTRIB_VERTEX, ATTRIB_TEXTURE;
static GLuint g_texYId;
static GLuint g_texUId;
static GLuint g_texVId;
static GLuint simpleProgram;

static int s_x = 0; //初始屏幕坐标，大小，初始化一次
static int s_y = 0;
static int s_width = 0;
static int s_height = 0;

static int view_x = 0;  //初始viewport坐标，大小，每次imagesize改变都重新赋值
static int view_y = 0;
static int view_width = 0;
static int view_height = 0;

/**********fragement shader***********/
static const char* FRAG_SHADER =
    "varying lowp vec2 tc;\n"
    "uniform sampler2D SamplerY;\n"
    "uniform sampler2D SamplerU;\n"
    "uniform sampler2D SamplerV;\n"
    "void main(void)\n"
    "{\n"
        "mediump vec3 yuv;\n"
        "lowp vec3 rgb;\n"
        "yuv.x = texture2D(SamplerY, tc).r;\n"
        "yuv.y = texture2D(SamplerU, tc).r - 0.5;\n"
        "yuv.z = texture2D(SamplerV, tc).r - 0.5;\n"
        "rgb = mat3( 1,   1,   1,\n"
                    "0,       -0.39465,  2.03211,\n"
                    "1.13983,   -0.58060,  0) * yuv;\n"
        "gl_FragColor = vec4(rgb, 1);\n"
    "}\n";

/*********vertex shader************/
static const char* VERTEX_SHADER =
      "attribute vec4 vPosition;    \n"
      "attribute vec2 a_texCoord;   \n"
      "varying vec2 tc;     \n"
      "void main()                  \n"
      "{                            \n"
      "   gl_Position = vPosition;  \n"
      "   tc = a_texCoord;  \n"
      "}                            \n";

static GLuint bindTexture(GLuint texture, const char *buffer, GLuint w , GLuint h)
{
    glBindTexture ( GL_TEXTURE_2D, texture );
    glTexImage2D ( GL_TEXTURE_2D, 0, GL_LUMINANCE, w, h, 0, GL_LUMINANCE, GL_UNSIGNED_BYTE, buffer);
    glTexParameteri ( GL_TEXTURE_2D, GL_TEXTURE_MIN_FILTER, GL_LINEAR );
    glTexParameteri ( GL_TEXTURE_2D, GL_TEXTURE_MAG_FILTER, GL_LINEAR );
    glTexParameteri ( GL_TEXTURE_2D, GL_TEXTURE_WRAP_S, GL_CLAMP_TO_EDGE );
    glTexParameteri ( GL_TEXTURE_2D, GL_TEXTURE_WRAP_T, GL_CLAMP_TO_EDGE );

    return texture;
}

static void renderFrame()
{
    static GLfloat squareVertices[] = {
        -1.0f, -1.0f,
        1.0f, -1.0f,
        -1.0f,  1.0f,
        1.0f,  1.0f,
    };

    static GLfloat coordVertices[] = {
        0.0f, 1.0f,
        1.0f, 1.0f,
        0.0f,  0.0f,
        1.0f,  0.0f,
    };

    glClearColor(0.0f, 0.0f, 0.0f, 1);
    glClear(GL_COLOR_BUFFER_BIT);

    GLint tex_y = glGetUniformLocation(simpleProgram, "SamplerY");
    GLint tex_u = glGetUniformLocation(simpleProgram, "SamplerU");
    GLint tex_v = glGetUniformLocation(simpleProgram, "SamplerV");

    ATTRIB_VERTEX = glGetAttribLocation(simpleProgram, "vPosition");
    ATTRIB_TEXTURE = glGetAttribLocation(simpleProgram, "a_texCoord");

    glVertexAttribPointer(ATTRIB_VERTEX, 2, GL_FLOAT, 0, 0, squareVertices);
    glEnableVertexAttribArray(ATTRIB_VERTEX);

    glVertexAttribPointer(ATTRIB_TEXTURE, 2, GL_FLOAT, 0, 0, coordVertices);
    glEnableVertexAttribArray(ATTRIB_TEXTURE);

    glActiveTexture(GL_TEXTURE0);
    glBindTexture(GL_TEXTURE_2D, g_texYId);
    glUniform1i(tex_y, 0);

    glActiveTexture(GL_TEXTURE1);
    glBindTexture(GL_TEXTURE_2D, g_texUId);
    glUniform1i(tex_u, 1);

    glActiveTexture(GL_TEXTURE2);
    glBindTexture(GL_TEXTURE_2D, g_texVId);
    glUniform1i(tex_v, 2);

    glDrawArrays(GL_TRIANGLE_STRIP, 0, 4);
}

/***********build vertex and fragement shader***************/
static GLuint buildShader(const char* source, GLenum shaderType)
{
    GLuint shaderHandle = glCreateShader(shaderType);

    if (shaderHandle)
    {
        glShaderSource(shaderHandle, 1, &source, 0);
        glCompileShader(shaderHandle);
        GLint compiled = 0;
        glGetShaderiv(shaderHandle, GL_COMPILE_STATUS, &compiled);
        if (!compiled){
            GLint infoLen = 0;
            glGetShaderiv(shaderHandle, GL_INFO_LOG_LENGTH, &infoLen);
            if (infoLen){
                char* buf = (char*) malloc(infoLen);
                if (buf){
                    glGetShaderInfoLog(shaderHandle, infoLen, NULL, buf);
                    printf("error::Could not compile shader %d:\n%s\n", shaderType, buf);
                    free(buf);
                }
                glDeleteShader(shaderHandle);
                shaderHandle = 0;
            }
        }
    }

    return shaderHandle;
}

static GLuint buildProgram(const char* vertexShaderSource,
        const char* fragmentShaderSource)
{
    GLuint vertexShader = buildShader(vertexShaderSource, GL_VERTEX_SHADER);
    GLuint fragmentShader = buildShader(fragmentShaderSource, GL_FRAGMENT_SHADER);
    GLuint programHandle = glCreateProgram();

    if (programHandle)
    {
        glAttachShader(programHandle, vertexShader);
        glAttachShader(programHandle, fragmentShader);
        glLinkProgram(programHandle);
        GLint linkStatus = GL_FALSE;
        glGetProgramiv(programHandle, GL_LINK_STATUS, &linkStatus);
        if (linkStatus != GL_TRUE) {
            GLint bufLength = 0;
            glGetProgramiv(programHandle, GL_INFO_LOG_LENGTH, &bufLength);
            if (bufLength) {
                char* buf = (char*) malloc(bufLength);
                if (buf) {
                    glGetProgramInfoLog(programHandle, bufLength, NULL, buf);
                    printf("error::Could not link program:\n%s\n", buf);
                    free(buf);
                }
            }
            glDeleteProgram(programHandle);
            programHandle = 0;
        }
    }

    return programHandle;
}

void gl_initialize(void)
{
    simpleProgram = buildProgram(VERTEX_SHADER, FRAG_SHADER);
    glUseProgram(simpleProgram);
    glGenTextures(1, &g_texYId);
    glGenTextures(1, &g_texUId);
    glGenTextures(1, &g_texVId);
}

void gl_uninitialize(void)
{
    glDeleteProgram(simpleProgram);
    glDeleteTextures(1, &g_texYId);
    glDeleteTextures(1, &g_texUId);
    glDeleteTextures(1, &g_texVId);
}

/**************************YUV444************************
****************y_planer_offset =[0 ~ img_w * img_h]*****
**u_planer_offset = [y_planer ~ img_w / 2 * img_h / 2]***
**v_planer_offset = [u_planer ~ img_w / 2 * img_h / 2]***
*********************************************************/
void gl_render_frame(int width, int height, uint8_t *buf, int len)
{
    gl_viewsize_set(width, height);
    glViewport(view_x, view_y, view_width, view_height);

    const char *y = (const char *)buf;
    const char *u = y + width * height;
    const char *v = u + width * height / 4;

    bindTexture(g_texYId, y, width,     height);
    bindTexture(g_texUId, u, width / 2, height / 2);
    bindTexture(g_texVId, v, width / 2, height / 2);

    renderFrame();
}

void gl_screen_set(int screen_x, int screen_y, int screen_width, int screen_height)
{
    s_x = screen_x;
    s_y = screen_y;
    s_width = screen_width;
    s_height = screen_height;
}

void gl_viewsize_set(int frame_width, int frame_height)
{
    int view_p = (int)((float)frame_height * 100 / frame_width);
    int screen_p = (int)((float)s_height * 100 / s_width);

    if (view_p == screen_p) {
        view_x = s_x;
        view_y = s_y;
        view_width = s_width;
        view_height = s_height;
    } else if (view_p > screen_p) {
        view_width = (int)(s_height * 100 / view_p);
        view_height = s_height;
        view_x = (int)((s_width - view_width) / 2);
        view_y = s_y;
    } else if (view_p < screen_p) {
        view_width = s_width;
        view_height = (int)(s_width * view_p / 100) ;
        view_x = s_x;
        view_y = (int)((s_height - view_height) / 2);
    }
}
