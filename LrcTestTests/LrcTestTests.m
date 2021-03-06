//
//  LrcTestTests.m
//  LrcTestTests
//
//  Created by pengyucheng on 08/03/2017.
//  Copyright © 2017 PBBReader. All rights reserved.
//

#import <XCTest/XCTest.h>
#import "CLLrcTool.h"
#import "CLLrcLine.h"
#import "LrcTestTests-Swift.h"


@interface LrcTestTests : XCTestCase

@end

@implementation LrcTestTests

- (void)setUp {
    [super setUp];
    // Put setup code here. This method is called before the invocation of each test method in the class.
}

- (void)tearDown {
    // Put teardown code here. This method is called after the invocation of each test method in the class.
    [super tearDown];
}

- (void)testExample {
    // This is an example of a functional test case.
    // Use XCTAssert and related functions to verify your tests produce the correct results.
    NSString *lineText = @"[02:45.23][01:18.45]让我一等再等";
    //正则表达式实现
    NSRegularExpression *regex = [[NSRegularExpression alloc] initWithPattern:@"\d{1,2}"
                                                                      options:NSRegularExpressionCaseInsensitive
                                                                        error:nil];
    NSLog(@"============");
    [regex enumerateMatchesInString:lineText
                            options:0
                              range:NSMakeRange(0, [lineText length])
                         usingBlock:^(NSTextCheckingResult *match, NSMatchingFlags flags, BOOL *stop){
                             NSRange matchRange = [match range];
                             NSLog(@"=======ddddd=====%@",match);
                             NSRange firstHalfRange = [match rangeAtIndex:0];
//                             NSRange secondHalfRange = [match rangeAtIndex:2];
                             NSString *time = [lineText substringWithRange:firstHalfRange];
                             NSLog(@"时间：%@",matchRange);
                         }];
}

-(void)testExampleFor
{
    NSString *lineText = @"[02:45.23][01:18.45]让我一等再等";
    NSRegularExpression *reg = [[NSRegularExpression alloc] initWithPattern:@"\\d{2}:\\d{2}.\\d{2}" options:0 error:nil];
    NSRegularExpression *regLrc = [[NSRegularExpression alloc] initWithPattern:@"][^\\]]*" options:0 error:nil];
    NSArray *matchsLrc = [regLrc matchesInString:lineText options:0 range:NSMakeRange(0, [lineText length])];
    NSString *lrcc = @"";
    for (NSTextCheckingResult *match in matchsLrc)
    {
        NSRange lrcRange = [match rangeAtIndex:0];
        lrcc = [lineText substringWithRange:lrcRange];
    }
    NSArray *matchs = [reg matchesInString:lineText options:0 range:NSMakeRange(0, [lineText length])];
    for (NSTextCheckingResult * match in matchs)
    {
        NSRange lastRange = [[matchs lastObject] rangeAtIndex:0];
        lrcc = [lineText substringFromIndex:lastRange.location + lastRange.length + 1];
        NSString *text = [lineText substringWithRange:[match rangeAtIndex:0]];
        NSLog(@"匹配字符：%@",text);
    }
    
    
}

- (void)testPerformanceExample {
    // This is an example of a performance test case.
    [self measureBlock:^{
        // Put the code you want to measure the time of here.
    }];
}


-(void)testParserLrcFile
{
    NSString *lrcPath = [[NSBundle mainBundle] pathForResource:@"qbd" ofType:@"lrc"];
    NSArray *lrcArray = [[CLLrcTool shared]ParserLrcWithPath:lrcPath];
    for (CLLrcLine * line in lrcArray)
    {
        NSLog(@"%@\n",line.description);
    }
//    [ enumerateObjectsUsingBlock:^(id  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
//        CLLrcLine *line = (CLLrcLine *)obj;
//        NSLog(@"%@\n",line.description);
//    }];
}


-(void)testVerVersion
{
    NSString *url = @"http://192.168.85.13:8660/DRM/client/product/verifyAppVersion";
    HttpClientManager *manager = [HttpClientManager new];
    VerifyAppVersionModel *model = [[VerifyAppVersionModel alloc] initWithUsername:@"222" token:@"dddd"];
    [manager verifyAppVersionByWithURL:url
                                 about:model
                      completionHander:^(VerifyAppVersionModel * app) {
                          //
                          NSLog(@"-------%@",app.msg);
                      }];

}

-(void)testLoadLRCFile
{
    XCTestExpectation *expre = [self expectationWithDescription:@"2342342342"];
    NSString  *host = @"http://192.168.85.13:8660/DRM/";
    NSString *fileid = @"6dd1d187-9e51-4dda-afcd-315f383734fa";
    NSString *userNam = @"13717795774";
    NSString *token = @"098dda0a733863fc0faca940ef527f25";
    NSString *url2 = [NSString stringWithFormat:@"%@/client/downloadMusicLyric/%@",host,fileid];
    MusicLrcModel *lrcmodel = [[MusicLrcModel alloc] initWithUsername: userNam
                                                                token: token
                                                               lrcURL: url2
                                                        musiclyric_id: fileid
                               localPath:@""];

    [[HttpClientManager shareInstance] downMusicLrcByLrcModel:lrcmodel loadLrc:^(NSString * lrcPath,NSString *log) {
       // NSLog(@"----路径：%@",lrcPath);
        [expre fulfill];
    }];
    
    [self waitForExpectationsWithTimeout:20 handler:^(NSError * _Nullable error) {
        NSLog(@"error-----%@",[error localizedDescription]);
    }];
}
/*
-(void)verifyAppVersion
{
    SZUser *user = [SZUser shared];
    NSString *hostURL = [NSString stringWithFormat:@"%@/client/product/verifyAppVersion",kBaseHost];
    [VerifyAppTool verifyByVersionOwer:user.name token:user.token OnHost:hostURL handler:^(NSString *code, NSString *msg) {
        //版本号过低 16002
        if (code.integerValue != 16002)
        {
            //根据状态码提示
            
            return;
        }
        
        if(code.integerValue == 16002)
        {
            msg = @"当前版本存在安全隐患，\n为保障您的权益，请立即升级！";
            UIAlertController *alertVC = [UIAlertController alertControllerWithTitle:@"版本升级" message:msg preferredStyle:UIAlertControllerStyleAlert];
            UIAlertAction *okAction = [UIAlertAction actionWithTitle:@"立即升级" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
                //
                [self openAppStore];
            }];
            
            UIAlertAction *cancelAction = [UIAlertAction actionWithTitle:@"退出" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
                //退出到home界面操作
                
            }];
            
            [alertVC addAction:okAction];
            [alertVC addAction:cancelAction];
            [self presentViewController:alertVC animated:YES completion:nil];
        }
        
        
    }];
    
}
 */

-(void)verifyAppVersion
{
    SZUser *user = [SZUser shared];
    NSString *hostURL = [NSString stringWithFormat:@"%@/client/product/verifyAppVersion",kBaseHost];
    [VerifyAppTool verifyByVersionOwer:user.name token:user.token OnHost:hostURL handler:^(NSString *code, NSString *msg) {
        //版本号过低 16002
        if (code.integerValue != 16002)
        {
            //根据状态码提示
            
            return;
        }
        
        if(code.integerValue == 16002)
        {
            msg = @"当前版本存在安全隐患，\n为保障您的权益，请立即升级！";
            UIAlertController *alertVC = [UIAlertController alertControllerWithTitle:@"版本升级" message:msg preferredStyle:UIAlertControllerStyleAlert];
            UIAlertAction *okAction = [UIAlertAction actionWithTitle:@"立即升级" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
                //
                [self openAppStore];
            }];
            
            UIAlertAction *cancelAction = [UIAlertAction actionWithTitle:@"退出" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
                //退出到home界面操作
                
            }];
            
            [alertVC addAction:okAction];
            [alertVC addAction:cancelAction];
            [self presentViewController:alertVC animated:YES completion:nil];
        }
        
        
    }];
    
}
 */

@end
