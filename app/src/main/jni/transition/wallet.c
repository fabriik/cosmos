//// Created by Mihail Gutan on 12/4/15.//#include "wallet.h"#include "PeerManager.h"#include "BRPeerManager.h"//#include "WalletCallbacks.h"#include "BRBIP39Mnemonic.h"#include <android/log.h>#include "BRBIP32Sequence.h"#include "BRTransaction.h"static JavaVM *_jvm;BRWallet *_wallet;static BRMasterPubKey _pubKey;static BRTransaction **_transactions;static size_t _transactionsCounter = 0;static jclass _walletManagerClass;static JNIEnv* getEnv() {    static JNIEnv *env;    int status = (*_jvm)->GetEnv(_jvm,(void**)&env, JNI_VERSION_1_6);    if(status < 0) {        status = (*_jvm)->AttachCurrentThread(_jvm, &env, NULL);        if(status < 0) {            return NULL;        }    }    return env;}//callback for tx publishingvoid callback(void *info, int error){    if(error){        __android_log_print(ANDROID_LOG_ERROR, "Message from callback: ", "publishing Failed: %s", strerror(error));    } else {        __android_log_print(ANDROID_LOG_ERROR, "Message from callback: ", "publishing Succeeded!");    }}static void balanceChanged(void *info, uint64_t balance) {    __android_log_print(ANDROID_LOG_ERROR, "Message from C: ", "balanceChanged: %d", (int) balance);    JNIEnv *globalEnv = getEnv();    jmethodID mid = (*globalEnv)->GetStaticMethodID(globalEnv, _walletManagerClass, "onBalanceChanged", "(J)V");//    uint64_t walletBalance = BRWalletBalance(wallet);//    __android_log_print(ANDROID_LOG_ERROR, "Message from C: ",//                        "BRWalletBalance(wallet): %d", BRWalletBalance(wallet));    //call java methods    (*globalEnv)->CallStaticVoidMethod(globalEnv, _walletManagerClass, mid, balance);    (*_jvm)->DetachCurrentThread(_jvm);}static void txAdded(void *info, BRTransaction *tx) {    __android_log_print(ANDROID_LOG_ERROR, "Message from C: ", "txAdded");    JNIEnv *globalEnv = getEnv();    jmethodID mid = (*globalEnv)->GetStaticMethodID(globalEnv, _walletManagerClass, "onTxAdded", "([BIJJ)V");    //call java methods    __android_log_print(ANDROID_LOG_ERROR, "******TX ADDED CALLBACK AFTER PARSE******: ",                        "BRWalletAmountReceivedFromTx: %d, ", (int) BRWalletAmountReceivedFromTx(_wallet, tx));    uint8_t buf[BRTransactionSerialize(tx, NULL, 0)];    size_t len = BRTransactionSerialize(tx, buf, sizeof(buf));    uint64_t fee = BRWalletFeeForTx(_wallet, tx) == -1 ? 0 : BRWalletFeeForTx(_wallet, tx);    jlong amount;    __android_log_print(ANDROID_LOG_ERROR, "Message from C: ", "fee: %d", (int) fee);    if (BRWalletAmountSentByTx(_wallet, tx) == 0) {        amount = BRWalletAmountReceivedFromTx(_wallet, tx);    } else {        amount = (BRWalletAmountSentByTx(_wallet, tx) - BRWalletAmountReceivedFromTx(_wallet, tx) - fee) * -1;    }//    __android_log_print(ANDROID_LOG_ERROR, "Message from C: ",//                        "blockHeight: %d, timestamp: %d bytes: %d",//                        tx->blockHeight, tx->timestamp, len);    jbyteArray result = (*globalEnv)->NewByteArray(globalEnv, len);    (*globalEnv)->SetByteArrayRegion(globalEnv, result, 0, len, (jbyte *)buf);    (*globalEnv)->CallStaticVoidMethod(globalEnv, _walletManagerClass, mid, result, (jlong) tx->blockHeight,                                 (jlong) tx->timestamp, (jlong) amount);    (*_jvm)->DetachCurrentThread(_jvm);}static void txUpdated(void *info, const UInt256 txHashes[], size_t count, uint32_t blockHeight,                      uint32_t timestamp) {    __android_log_print(ANDROID_LOG_ERROR, "Message from C: ", "txUpdated");    JNIEnv *globalEnv = getEnv();    jmethodID mid = (*globalEnv)->GetStaticMethodID(globalEnv, _walletManagerClass, "onTxUpdated", "(I)V");    (*globalEnv)->CallStaticVoidMethod(globalEnv, _walletManagerClass, mid, (jint)blockHeight);    (*_jvm)->DetachCurrentThread(_jvm);}static void txDeleted(void *info, UInt256 txHash) {    __android_log_print(ANDROID_LOG_ERROR, "Message from C: ", "txDeleted");    JNIEnv *globalEnv;    jint rs = (*_jvm)->AttachCurrentThread(_jvm, &globalEnv, NULL);    //create class    jclass clazz = (*globalEnv)->FindClass(globalEnv, "com/breadwallet/wallet/BRWalletManager");    jmethodID mid = (*globalEnv)->GetStaticMethodID(globalEnv, clazz, "onTxDeleted", "()V");    //call java methods    (*globalEnv)->CallStaticVoidMethod(globalEnv, clazz, mid);    (*_jvm)->DetachCurrentThread(_jvm);}JNIEXPORT jbyteArray Java_com_breadwallet_wallet_BRWalletManager_encodeSeed(JNIEnv *env,                                                                            jobject thiz,                                                                            jbyteArray seed,                                                                            jobjectArray stringArray) {    __android_log_print(ANDROID_LOG_ERROR, "Message from C: ", "encodeSeed");    int wordsCount = (*env)->GetArrayLength(env, stringArray);    int seedLength = (*env)->GetArrayLength(env, seed);    const char *wordList[wordsCount];    for (int i = 0; i < wordsCount; i++) {        jstring string = (jstring) (*env)->GetObjectArrayElement(env, stringArray, i);        const char *rawString = (*env)->GetStringUTFChars(env, string, 0);        wordList[i] = rawString;        (*env)->DeleteLocalRef(env, string);        // Don't forget to call `ReleaseStringUTFChars` when you're done.    }    jbyte *byteSeed = (*env)->GetByteArrayElements(env, seed, 0);    const char result[BRBIP39Encode(NULL, 0, wordList, (uint8_t *) byteSeed, seedLength)];    size_t len = BRBIP39Encode((char *) result, sizeof(result), wordList, (const uint8_t *) theSeed, (size_t) seedLength);    const jbyte *phraseJbyte = (const jbyte *) result;    int size = sizeof(result);    jbyteArray bytePhrase = (*env)->NewByteArray(env, size);    (*env)->SetByteArrayRegion(env, bytePhrase, 0, size, phraseJbyte);    return bytePhrase;}JNIEXPORT void Java_com_breadwallet_wallet_BRWalletManager_createWallet(JNIEnv *env,                                                                        jobject thiz,                                                                        size_t txCount,                                                                        jstring bytePubKeyEncoded,                                                                        int r) {    __android_log_print(ANDROID_LOG_ERROR, "Message from C: ", "createWallet");    if (r) {        const char *stringPk = (*env)->GetStringUTFChars(env, bytePubKeyEncoded, 0);        __android_log_print(ANDROID_LOG_ERROR, "Message from C: ", "stringPk: %s", stringPk);        uint8_t buf[BRBase58Decode(NULL, 0, stringPk)];        size_t bufLength = BRBase58Decode(buf, sizeof(buf), stringPk);        _pubKey = *(BRMasterPubKey *) buf;    }    jint rs = (*env)->GetJavaVM(env, &_jvm); // cache the JavaVM pointer    jclass peerManagerCLass = (*env)->FindClass(env,"com/breadwallet/wallet/BRWalletManager");    _walletManagerClass = (jclass) (*env)->NewGlobalRef(env, (jobject) peerManagerCLass);//    if(_wallet) BRWalletFree(_wallet);    if (rs != JNI_OK) {        __android_log_print(ANDROID_LOG_ERROR, "Message from C: ", "WARNING, GetJavaVM is not JNI_OK");    }    int pubKeySize = sizeof(_pubKey);    if (pubKeySize < 5) {        __android_log_print(ANDROID_LOG_ERROR, "Message from C: ", "WARNING, pubKey is corrupt!");        return;    }//    __android_log_print(ANDROID_LOG_ERROR, "Message from C: ", "Pubkey: %s", pubKey.pubKey);//    __android_log_print(ANDROID_LOG_ERROR, "Message from C: ", "txCount: %d", txCount);    if (txCount > 0) {        __android_log_print(ANDROID_LOG_ERROR, "Message from C: ",                            "CREATING WALLET FROM TXS - txCount: %d", txCount);        _wallet = BRWalletNew(_transactions, txCount, _pubKey, NULL, theSeed);    } else {        __android_log_print(ANDROID_LOG_INFO, "Message from C: ", "CREATING EMPTY WALLET");        _wallet = BRWalletNew(NULL, 0, _pubKey, NULL, theSeed);    }    BRWalletSetCallbacks(_wallet, NULL, balanceChanged, txAdded, txUpdated, txDeleted);//    free(_transactions);    //create class    jclass clazz = (*env)->FindClass(env, "com/breadwallet/wallet/BRWalletManager");    jobject entity = thiz;    jmethodID mid = (*env)->GetStaticMethodID(env, clazz, "onBalanceChanged", "(J)V");    //call java methods    (*env)->CallStaticVoidMethod(env, clazz, mid, BRWalletBalance(_wallet));//    balanceChanged(NULL, BRWalletBalance(_wallet));}JNIEXPORT jstring Java_com_breadwallet_wallet_BRWalletManager_getMasterPubKey(JNIEnv *env,                                                                                 jobject thiz,                                                                                 jstring phrase) {    __android_log_print(ANDROID_LOG_ERROR, "Message from C: ", "getMasterPubKey");    const char *rawPhrase = (*env)->GetStringUTFChars(env, phrase, 0);    UInt512 key = UINT512_ZERO;    BRBIP39DeriveKey(key.u8, rawPhrase, NULL);    _pubKey = BRBIP32MasterPubKey(key.u8, sizeof(key));    size_t pubKeySize = sizeof(_pubKey);    char buff[BRBase58Encode(NULL, 0, &_pubKey, pubKeySize)];    size_t bufLength = BRBase58Encode(buff, sizeof(buff), &_pubKey, pubKeySize);    __android_log_print(ANDROID_LOG_ERROR, "Message from C: ", "buff: %s", buff);    char *result = (*env)->NewStringUTF(env, buff);    (*env)->ReleaseStringUTFChars(env, phrase, rawPhrase);    return result;}//Call multiple times with all the transactions from the DBJNIEXPORT jbyteArray Java_com_breadwallet_wallet_BRWalletManager_putTransaction(JNIEnv *env,                                                                                jobject thiz,                                                                                jbyteArray transaction,                                                                                jlong jBlockHeight,                                                                                jlong jTimeStamp) {    int txLength = (*env)->GetArrayLength(env, transaction);    jbyte *byteTx = (*env)->GetByteArrayElements(env, transaction, 0);    BRTransaction *tmpTx = BRTransactionParse((uint8_t *) byteTx, txLength);    tmpTx->blockHeight = jBlockHeight;    tmpTx->timestamp = jTimeStamp;    int i = 0;    _transactions[_transactionsCounter++] = tmpTx;}JNIEXPORT void Java_com_breadwallet_wallet_BRWalletManager_createTxArrayWithCount(JNIEnv *env,                                                                                        jobject thiz,                                                                                        int txCount) {    __android_log_print(ANDROID_LOG_ERROR, "Message from C: ", "createTxArrayWithCount: %d", txCount);//    _transactions = calloc(txCount, sizeof(BRTransaction));    _transactionsCounter = 0;    // need to call free(transactions);}JNIEXPORT jstring Java_com_breadwallet_wallet_BRWalletManager_getReceiveAddress(JNIEnv *env,                                                                                jobject thiz) {    __android_log_print(ANDROID_LOG_ERROR, "Message from C: ", "getReceiveAddress");    if (_wallet == NULL) return "";    BRAddress receiveAddress = BRWalletReceiveAddress(_wallet);    jstring result = (*env)->NewStringUTF(env, receiveAddress.s);    return result;}JNIEXPORT jobjectArray Java_com_breadwallet_wallet_BRWalletManager_getTransactions(JNIEnv *env,                                                                                   jobject thiz) {    __android_log_print(ANDROID_LOG_ERROR, "Message from C: ", "getTransactions: BRTxs - %d",                        (int) BRWalletTransactions(_wallet, NULL, 0));    if (_wallet == NULL) return NULL;    if (BRWalletTransactions(_wallet, NULL, 0) == 0) return NULL;//    __android_log_print(ANDROID_LOG_ERROR, "***LOLOLOLOLOLOLO*********: ", "BRWalletTransactions(_wallet, NULL, 0): %d", BRWalletTransactions(_wallet, NULL, 0));    //Retrieve the txs array    BRTransaction *transactions_sqlite[BRWalletTransactions(_wallet, NULL, 0)];    size_t temp = sizeof(transactions_sqlite) / sizeof(*transactions_sqlite);    __android_log_print(ANDROID_LOG_ERROR, "THIS IS THE TEMP: ", "temp: %d", (int) temp);    size_t txCount = BRWalletTransactions(_wallet, transactions_sqlite, temp);//    __android_log_print(ANDROID_LOG_ERROR, "***LOLOLOLOLOLOLO*********: ", "txCount: %d", txCount);//    return NULL;    //Find the class and populate the array of objects of this class    jclass txClass = (*env)->FindClass(env, "com/breadwallet/presenter/entities/TransactionListItem");    jobjectArray transactionObjects = (*env)->NewObjectArray(env, txCount, txClass, 0);    for (int i = 0; i < txCount; i++) {        jmethodID txObjMid = (*env)->GetMethodID(env, txClass, "<init>",                                                 "(JI[BJJJ[Ljava/lang/String;[Ljava/lang/String;J[J)V");//      if(BRWalletAmountReceivedFromTx(_wallet, transactions_sqlite[i]) == 0 && BRWalletAmountSentByTx(_wallet, transactions_sqlite[i])==0) continue;        jlong JtimeStamp = transactions_sqlite[i]->timestamp;        __android_log_print(ANDROID_LOG_ERROR, "Message from C: ", "transactions_sqlite[i]->timestamp: %d", transactions_sqlite[i]->timestamp);        jint JblockHeight = transactions_sqlite[i]->blockHeight;        __android_log_print(ANDROID_LOG_ERROR, "Message from C: !!!!!!!!!", "transactions_sqlite[i]->blockHeight: %d", transactions_sqlite[i]->blockHeight);        __android_log_print(ANDROID_LOG_ERROR, "Message from C: !!!!!!!!!", "JblockHeight: %d", JblockHeight);        jbyteArray JtxHash = (*env)->NewByteArray(env, sizeof(transactions_sqlite[i]->txHash));//        __android_log_print(ANDROID_LOG_ERROR, "Message from C: ", "uint256_hex_encode(transactions_sqlite[i]->txHash)h: %s",//                            uint256_hex_encode(transactions_sqlite[i]->txHash));        (*env)->SetByteArrayRegion(env, JtxHash, 0, sizeof(transactions_sqlite[i]->txHash),                                   (const jbyte *) &transactions_sqlite[i]->txHash);        jlong Jsent = (jlong) BRWalletAmountSentByTx(_wallet, transactions_sqlite[i]);//        __android_log_print(ANDROID_LOG_ERROR, "Message from C: ", "BRWalletAmountSentByTx(wallet, transactions_sqlite[i]): %d",//         BRWalletAmountSentByTx(_wallet, transactions_sqlite[i]));        jlong Jreceived = (jlong) BRWalletAmountReceivedFromTx(_wallet, transactions_sqlite[i]);        __android_log_print(ANDROID_LOG_ERROR, "Message from C: ",                            "BRWalletAmountReceivedFromTx(): %d",                            (int) BRWalletAmountReceivedFromTx(_wallet, transactions_sqlite[i]));        jlong Jfee = (jlong) BRWalletFeeForTx(_wallet, transactions_sqlite[i]);//        __android_log_print(ANDROID_LOG_ERROR, "Message from C: ", "BRWalletFeeForTx(wallet, transactions_sqlite[i]): %d",//                BRWalletFeeForTx(_wallet, transactions_sqlite[i]));        int outCountTemp = transactions_sqlite[i]->outCount;        jlongArray JoutAmounts = (*env)->NewLongArray(env, outCountTemp);        jobjectArray JtoAddresses = (*env)->NewObjectArray(env, outCountTemp, (*env)->FindClass(env,                                                                                                "java/lang/String"), 0);        int outCountAfterFilter = 0;        for (int j = 0; j < outCountTemp; j++) {            if(Jsent > 0) {                if (!BRWalletContainsAddress(_wallet, transactions_sqlite[i]->outputs[j].address)) {                    jstring str = (*env)->NewStringUTF(env,                                                       transactions_sqlite[i]->outputs[j].address);                    (*env)->SetObjectArrayElement(env, JtoAddresses, outCountAfterFilter, str);                    (*env)->SetLongArrayRegion(env, JoutAmounts, outCountAfterFilter++, 1,                                               (const jlong *) &transactions_sqlite[i]->outputs[j].amount);                }            } else {                if (BRWalletContainsAddress(_wallet, transactions_sqlite[i]->outputs[j].address)) {                    jstring str = (*env)->NewStringUTF(env,                                                       transactions_sqlite[i]->outputs[j].address);                    (*env)->SetObjectArrayElement(env, JtoAddresses, outCountAfterFilter, str);                    (*env)->SetLongArrayRegion(env, JoutAmounts, outCountAfterFilter++, 1,                                           (const jlong *) &transactions_sqlite[i]->outputs[j].amount);                }            }        }//        jstring Jto = (*env)->NewStringUTF(env, transactions_sqlite[i]->outputs[0].address);//        unsigned int* cIntegers = getFromSomewhere();//        int elements = sizeof(cIntegers) / sizeof(int);////        jfieldID jLongArrayId = env->GetFieldID(javaClass, "longArray", "[J");//        jlongArray jLongArray = (jlongArray) env->GetObjectField(javaObject, jLongArrayId);//        for (unsigned int i = 0; i < elements; ++i) {//            unsigned int cInteger = cIntegers[i];//            long cLong = doSomehowConvert(cInteger);//            env->SetLongArrayElement(jLongArray, i, (jlong) cLong);//        }        int inCountTemp = transactions_sqlite[i]->inCount;        jobjectArray JfromAddresses = (*env)->NewObjectArray(                env, inCountTemp, (*env)->FindClass(env, "java/lang/String"), 0);        int inCountAfterFilter = 0;        for (int j = 0; j < inCountTemp; j++) {            if(Jsent > 0) {                if(BRWalletContainsAddress(_wallet, transactions_sqlite[i]->outputs[j].address)) {                    jstring str = (*env)->NewStringUTF(env, transactions_sqlite[i]->inputs[j].address);                    (*env)->SetObjectArrayElement(env, JfromAddresses, inCountAfterFilter++, str);                }            } else {//                if(!BRWalletContainsAddress(_wallet, transactions_sqlite[i]->outputs[j].address)) {                    jstring str = (*env)->NewStringUTF(env, transactions_sqlite[i]->inputs[j].address);                    (*env)->SetObjectArrayElement(env, JfromAddresses, inCountAfterFilter++, str);//                }            }        }//      jstring Jfrom = (*env)->NewStringUTF(env, transactions_sqlite[i]->inputs[0].address);        jlong JbalanceAfterTx = (jlong) BRWalletBalanceAfterTx(_wallet, transactions_sqlite[i]);//        __android_log_print(ANDROID_LOG_ERROR, "Message from C: ", "BRWalletBalanceAfterTx(_wallet, transactions_sqlite[i]: %d",//                            BRWalletBalanceAfterTx(_wallet, transactions_sqlite[i]));        //long timeStamp, long blockHeight, byte[] hash, long sent, long received, long fee, String to, String fromvector//        __android_log_print(ANDROID_LOG_ERROR, "Message from C: ", "call Constructor with i: %d", i);        jobject txObject = (*env)->NewObject(env, txClass, txObjMid, JtimeStamp, JblockHeight,                                             JtxHash, Jsent, Jreceived, Jfee, JtoAddresses,                                             JfromAddresses,                                             JbalanceAfterTx, JoutAmounts);        (*env)->SetObjectArrayElement(env, transactionObjects, txCount - 1 - i, txObject);    }    return transactionObjects;}const void *theSeed(void *info, const char *authPrompt, uint64_t amount, size_t *seedLen) {    JNIEnv *env = getEnv();    jclass clazz = (*env)->FindClass(env, "com/breadwallet/tools/security/KeyStoreManager");    jmethodID midGetSeed = (*env)->GetStaticMethodID(env, clazz, "getSeed", "()Ljava/lang/String;");    //call java methods    jstring jStringSeed = (jstring) (*env)->CallStaticObjectMethod(env, clazz, midGetSeed);    const char *rawString = (*env)->GetStringUTFChars(env, jStringSeed, 0);    __android_log_print(ANDROID_LOG_ERROR, "Message from C: ", "theSeed: address %s", rawString);    static UInt512 key = UINT512_ZERO;    BRBIP39DeriveKey(key.u8, rawString, NULL);    __android_log_print(ANDROID_LOG_ERROR, "Message from C: ", "sizeof(key):%d", sizeof(key));    size_t theSize = sizeof(key);    *seedLen = theSize;    __android_log_print(ANDROID_LOG_ERROR, "Message from C: ", "theSeed: seedLen %d", theSize);    return key.u8;}JNIEXPORT jboolean JNICALL Java_com_breadwallet_wallet_BRWalletManager_validateAddress        (JNIEnv *env, jobject obj, jstring address) {//    jbyte *byte_address = (*env)->GetByteArrayElements(env, address, NULL);//    jsize size = (*env)->GetArrayLength(env, address);//    for (int i = 0; i < size; ++i) {//        printf("bytes[%d] = %x\n", i, ((const unsigned char *) byte_address)[i]);//        __android_log_print(ANDROID_LOG_DEBUG, "From C:>>>>", charString[i]);//    __android_log_print(ANDROID_LOG_DEBUG, "LOG_TAG", "Need to print : %s", charString);//    }    jboolean b;    const char *str;    str = (char *) (*env)->GetStringUTFChars(env, address, NULL);//    __android_log_print(ANDROID_LOG_ERROR, "LOG_TAG", "Need to print : %s", str);    int result = BRAddressIsValid(str);    (*env)->ReleaseStringUTFChars(env, address, str);//    __android_log_print(ANDROID_LOG_ERROR, "LOG_TAG", "This is the result : %d", result);    return result ? JNI_TRUE : JNI_FALSE;}JNIEXPORT jboolean JNICALL Java_com_breadwallet_wallet_BRWalletManager_addressContainedInWallet        (JNIEnv *env, jobject obj, jstring address) {    jboolean b;    const char *str;    str = (char *) (*env)->GetStringUTFChars(env, address, NULL);    int result = BRWalletContainsAddress(_wallet, str);    (*env)->ReleaseStringUTFChars(env, address, str);    return result ? JNI_TRUE : JNI_FALSE;}JNIEXPORT jlong JNICALL Java_com_breadwallet_wallet_BRWalletManager_getMinOutputAmount        (JNIEnv *env, jobject obj) {    return (jlong) TX_MIN_OUTPUT_AMOUNT;}JNIEXPORT jboolean JNICALL Java_com_breadwallet_wallet_BRWalletManager_addressIsUsed        (JNIEnv *env, jobject obj, jstring address) {    jboolean b;    const char *str;    str = (char *) (*env)->GetStringUTFChars(env, address, NULL);    int result = BRWalletAddressIsUsed(_wallet, str);    (*env)->ReleaseStringUTFChars(env, address, str);    return result ? JNI_TRUE : JNI_FALSE;}JNIEXPORT jint JNICALL Java_com_breadwallet_wallet_BRWalletManager_feeForTransaction        (JNIEnv *env, jobject obj, jstring address, jlong amount) {    const char *rawAddress = (*env)->GetStringUTFChars(env, address, NULL);    BRTransaction *tx = BRWalletCreateTransaction(_wallet, (uint64_t) amount, rawAddress);    return (jint) BRWalletFeeForTx(_wallet, tx);}JNIEXPORT void Java_com_breadwallet_wallet_BRWalletManager_pay(JNIEnv *env, jobject thiz,                                                               jstring address, jlong amount) {    const char *rawAddress = (*env)->GetStringUTFChars(env, address, NULL);    __android_log_print(ANDROID_LOG_ERROR, "Message from C: ", "SENDING: address %s, amount %llu",                        rawAddress, (uint64_t) amount);//    __android_log_print(ANDROID_LOG_ERROR,"in Pay", "rawAddress:%s,sizeof(rawAddress):%d\n", rawAddress, sizeof(rawAddress));    BRTransaction *tx = BRWalletCreateTransaction(_wallet, (uint64_t) amount, rawAddress);//    uint8_t buf[BRTransactionSerialize(tx, NULL, 0)];//    size_t bufLen = BRTransactionSerialize(tx, buf, sizeof(buf));//    for (size_t i = 0; i < bufLen; i++)//        __android_log_print(ANDROID_LOG_ERROR, "Message from C: ", "%02x", buf[i]);//    __android_log_print(ANDROID_LOG_ERROR, "Message from C: ", "inCount: %d, outCount: %d", tx->inCount, tx->outCount);    int sign_result = BRWalletSignTransaction(_wallet, tx, NULL);//    __android_log_print(ANDROID_LOG_ERROR, "Message from C: ", "BRTransactionIsSigned(tx): %d, tx->txHash: %s", BRTransactionIsSigned(tx), uint256_hex_encode(tx->txHash));//    __android_log_print(ANDROID_LOG_ERROR, "Message from C: ", "sign_result: %d", sign_result);    BRPeerManagerPublishTx(_peerManager, tx, NULL, callback);}//TODO delete this testing methodvoid printBits(unsigned int num) {    __android_log_print(ANDROID_LOG_ERROR, "Message from C: ", "\n\n");    while (num) {        if (num & 1)            __android_log_print(ANDROID_LOG_ERROR, "Message from C: ", "1");        else            __android_log_print(ANDROID_LOG_ERROR, "Message from C: ", "0");        num >>= 1;    }    __android_log_print(ANDROID_LOG_ERROR, "Message from C: ", "\n\n");}