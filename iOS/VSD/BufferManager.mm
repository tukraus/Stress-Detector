//
//  BufferManager.cpp
//  VSD
//
//  Created by Natan Facchin on 6/3/14.
//  Copyright (c) 2014 nfsindustries. All rights reserved.
//

#include "BufferManager.h"

#define min(x,y) (x < y) ? x : y


BufferManager::BufferManager( UInt32 inMaxFramesPerSlice ) :
inputBuffer(NULL),
inputBufferFrameIndex(0),
inputBufferLen(inMaxFramesPerSlice)
{
    inputBuffer = (Float32*) calloc(inMaxFramesPerSlice, sizeof(Float32));
    inputBufferFrameIndex = 0;
    int num_taps = 768; //950, 0.18
    double lowPassFreq = 0.040; //0.017
    my_filter = new Filter(LPF, num_taps, 8000, lowPassFreq);
}

BufferManager::~BufferManager()
{
    free(inputBuffer);
}

void BufferManager::CopyAudioDataToInputBuffer( Float32* inData, UInt32 numFrames )
{
    UInt32 framesToCopy = min(numFrames, kBufferLength - inputBufferFrameIndex);
    int i = 0;
    for (i = inputBufferFrameIndex; i < (inputBufferFrameIndex + numFrames); i++) {
        inputBuffer[i] = inData[i - inputBufferFrameIndex];
    }
    inputBufferFrameIndex += framesToCopy;
    if (inputBufferFrameIndex >= kBufferLength) {
        
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_HIGH, 0), ^{
            
            double stressCoefficient = 0.0;
            double inputBufferDouble[kBufferLength];
            if( my_filter->get_error_flag() < 0 ) {
                NSLog(@"ERR CREATING LOW PASS FILTER\n");
                exit(1);
            }
            for(int i = 0; i < kBufferLength - 1; i++){
                inputBufferDouble[i] = my_filter->do_sample((double)inputBuffer[i+1]);
            }
            inputBufferDouble[kBufferLength - 1] = (double)inputBuffer[kBufferLength - 1];
            
            stressCoefficient = processAudio(inputBufferDouble, finalIMF);

            #ifndef NDEBUG
            NSLog(@"%.2f Hz \n", stressCoefficient);
            #endif
            
            NSNumber *stressCoefNSNumber = [NSNumber numberWithFloat:stressCoefficient];
            NSDictionary *userInfo = [NSDictionary dictionaryWithObject:stressCoefNSNumber forKey:kStressCoefVarName];
            
            [[NSNotificationCenter defaultCenter] postNotificationName:kStressProcessedNotification object:nil userInfo:userInfo];
            
            inputBufferFrameIndex = 0;
        });
    }
}
