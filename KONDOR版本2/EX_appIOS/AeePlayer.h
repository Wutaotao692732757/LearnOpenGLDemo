/******************************************************************
 * File Name    : AeePlayer.h
 * Description  : simple AeePlayer implementation
 * Author       : huangchengman@aee.com
 * Date         : 2016-04-18
 ******************************************************************/

#ifndef __AEEPLAYER_H__
#define __AEEPLAYER_H__


typedef struct{
    int x;  //起始点设置
    int y;
    int width;  //ViewPort长宽设置
    int height;
    void (*CallbackFunc)(void *data);
} AEE_VIDEO_CONF;

typedef struct{
    int state;   // 0: 正常； 其他值: 错误；
    int streamState;  // 流状态：0:准备好数据 其他值:未准备好；
    void *statedata;  //错误信息
    //正常：
    //-1, -1, NULL 初始配置成功；
    //0, 0, str  成功打开流，准备好数据；
    //1, 0, NULL 成功初始化Opengl，等待渲染；
    //1, 1, NULL destroy释放完成；

    //错误：
    //2, 0, NULL 启动解码线程失败（已有一个解码线程）
    //0, 1, err  打开网络流失败；
} OGCBDATA;

int AeePlayer_GetVersion(char *version);//AeePlayer 版本号
int AeePlayer_Config(AEE_VIDEO_CONF *conf);//设置显示窗口
int AeePlayer_SetUrl(char *pUrl);//码流链接：rtsp://xxx
int AeePlayer_RenderFrame();//渲染视频帧
int AeePlayer_Destroy(void);//播放器退出销毁

int AeePlayer_SetState(int state);//网络连接状态

#endif
