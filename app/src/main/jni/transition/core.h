//
// Created by Mihail Gutan on 9/24/15.
//
#include <jni.h>

#ifndef BREADWALLET_CORE_H
#define BREADWALLET_CORE_H

#endif //BREADWALLET_CORE_H

JNIEXPORT void Java_com_breadwallet_presenter_activities_MainActivity_sendMethodCallBack
        (JNIEnv *env, jobject thiz);

JNIEXPORT jbyteArray Java_com_breadwallet_wallet_BRWalletManager_encodePhrase
        (JNIEnv *env, jobject obj, jbyteArray seed, jbyteArray wordList);

JNIEXPORT jbyteArray Java_com_breadwallet_wallet_BRWalletManager_wallet
        (JNIEnv *env, jobject obj);

