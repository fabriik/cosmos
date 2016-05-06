package com.breadwallet.tools.security;

import android.app.Activity;
import android.app.KeyguardManager;
import android.content.Context;
import android.content.Intent;
import android.security.keystore.KeyGenParameterSpec;
import android.security.keystore.KeyProperties;
import android.security.keystore.UserNotAuthenticatedException;
import android.util.Log;

import com.breadwallet.presenter.activities.IntroActivity;
import com.breadwallet.presenter.activities.MainActivity;
import com.breadwallet.tools.TypesConverter;

import org.apache.commons.io.IOUtils;

import java.io.File;
import java.io.FileInputStream;
import java.io.FileNotFoundException;
import java.io.FileOutputStream;
import java.io.IOException;
import java.io.InputStream;
import java.io.UnsupportedEncodingException;
import java.nio.ByteBuffer;
import java.nio.CharBuffer;
import java.nio.charset.Charset;
import java.security.InvalidAlgorithmParameterException;
import java.security.InvalidKeyException;
import java.security.KeyStore;
import java.security.KeyStoreException;
import java.security.NoSuchAlgorithmException;
import java.security.NoSuchProviderException;
import java.security.UnrecoverableKeyException;
import java.security.cert.CertificateException;
import java.util.Arrays;
import java.util.Enumeration;

import javax.crypto.Cipher;
import javax.crypto.CipherInputStream;
import javax.crypto.CipherOutputStream;
import javax.crypto.KeyGenerator;
import javax.crypto.NoSuchPaddingException;
import javax.crypto.SecretKey;
import javax.crypto.spec.IvParameterSpec;

/**
 * BreadWallet
 * <p/>
 * Created by Mihail Gutan on 9/29/15.
 * Copyright (c) 2016 breadwallet llc <mihail@breadwallet.com>
 * <p/>
 * Permission is hereby granted, free of charge, to any person obtaining a copy
 * of this software and associated documentation files (the "Software"), to deal
 * in the Software without restriction, including without limitation the rights
 * to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
 * copies of the Software, and to permit persons to whom the Software is
 * furnished to do so, subject to the following conditions:
 * <p/>
 * The above copyright notice and this permission notice shall be included in
 * all copies or substantial portions of the Software.
 * <p/>
 * THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
 * IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
 * FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
 * AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
 * LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
 * OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
 * THE SOFTWARE.
 */

public class KeyStoreManager {
    private static final String TAG = KeyStoreManager.class.getName();

    private static final String CIPHER_ALGORITHM = "AES/CBC/PKCS7Padding";
    private static final String PADDING = KeyProperties.ENCRYPTION_PADDING_PKCS7;
    private static final String BLOCK_MODE = KeyProperties.BLOCK_MODE_CBC;
    private static final String ANDROID_KEY_STORE = "AndroidKeyStore";

    private static final String PHRASE_IV = "ivphrase";
    private static final String CANARY_IV = "ivcanary";
    private static final String PUB_KEY_IV = "ivpubkey";
    private static final String TIME_IV = "ivtime";
    private static final String PASS_CODE_IV = "ivpasscode";

    public static final String PHRASE_ALIAS = "phrase";
    public static final String CANARY_ALIAS = "canary";
    private static final String PUB_KEY_ALIAS = "pubKey";
    private static final String WALLET_CREATION_TIME_ALIAS = "creationTime";
    private static final String PASS_CODE_ALIAS = "passCode";
    private static final String PHRASE_FILENAME = "my_phrase";
    private static final String CANARY_FILENAME = "my_canary";
    private static final String PUB_KEY_FILENAME = "my_pub_key";
    private static final String WALLET_CREATION_TIME_FILENAME = "my_creation_time";
    private static final String PASS_CODE_FILENAME = "my_pass_code";

    private static final int AUTH_DURATION_SEC = 300; //TODO make 300
//    private static final int CANARY_AUTH_DURATION_SEC = Integer.MAX_VALUE;

    private static boolean setData(Activity context, byte[] data, String alias, String alias_file, String alias_iv, int request_code, boolean auth_required) {
        try {
            KeyStore keyStore = KeyStore.getInstance(ANDROID_KEY_STORE);
            keyStore.load(null);
            int nBefore = keyStore.size();
            // Create the keys if necessary
            if (!keyStore.containsAlias(alias)) {
                KeyGenerator keyGenerator = KeyGenerator.getInstance(
                        KeyProperties.KEY_ALGORITHM_AES, ANDROID_KEY_STORE);

                // Set the alias of the entry in Android KeyStore where the key will appear
                // and the constrains (purposes) in the constructor of the Builder
                keyGenerator.init(new KeyGenParameterSpec.Builder(alias,
                        KeyProperties.PURPOSE_ENCRYPT | KeyProperties.PURPOSE_DECRYPT)
                        .setBlockModes(BLOCK_MODE)
                        .setKeySize(256)
                        .setUserAuthenticationRequired(auth_required)
                        .setUserAuthenticationValidityDurationSeconds(AUTH_DURATION_SEC)
                        .setRandomizedEncryptionRequired(false)
                        .setEncryptionPaddings(PADDING)
                        .build());
                SecretKey key = keyGenerator.generateKey();

            }

            int nAfter = keyStore.size();

            String filesDirectory = context.getFilesDir().getAbsolutePath();
            String encryptedDataFilePath = filesDirectory + File.separator + alias_file;

            SecretKey secret = (SecretKey) keyStore.getKey(alias, null);
            Cipher inCipher = Cipher.getInstance(CIPHER_ALGORITHM);
            inCipher.init(Cipher.ENCRYPT_MODE, secret);
            byte[] iv = inCipher.getIV();
            String path = filesDirectory + File.separator + alias_iv;
            boolean success = writeBytesToFile(path, iv);
            if (!success) throw new NullPointerException("FAILED TO WRITE BYTES TO FILE");
            CipherOutputStream cipherOutputStream = new CipherOutputStream(
                    new FileOutputStream(encryptedDataFilePath), inCipher);
            cipherOutputStream.write(data);
            try {
                cipherOutputStream.close();
            } catch (Exception ex) {
                ex.printStackTrace();
            }
            return true;
        } catch (UserNotAuthenticatedException e) {
            Log.e(TAG, Log.getStackTraceString(e));
            Log.e(TAG, "showAuthenticationScreen");
            showAuthenticationScreen(context, request_code);
        } catch (CertificateException | NoSuchAlgorithmException | InvalidKeyException | NullPointerException
                | NoSuchPaddingException | KeyStoreException | UnrecoverableKeyException |
                InvalidAlgorithmParameterException | NoSuchProviderException | IOException e) {
            e.printStackTrace();
        }
        return false;
    }

    public static byte[] getData(Activity context, String alias, String alias_file, String alias_iv, int request_code) {
        KeyStore keyStore;
        String filesDirectory = context.getFilesDir().getAbsolutePath();
        String encryptedDataFilePath = filesDirectory + File.separator + alias_file;
        byte[] result = new byte[0];
        try {
            keyStore = KeyStore.getInstance(ANDROID_KEY_STORE);
            keyStore.load(null);
            SecretKey secretKey = (SecretKey)
                    keyStore.getKey(alias, null);
            if (secretKey == null) throw new NullPointerException("secretKey is null");
            String path = filesDirectory + File.separator + alias_iv;
            byte[] iv = readBytesFromFile(path);
            Cipher outCipher;
            outCipher = Cipher.getInstance(CIPHER_ALGORITHM);
            outCipher.init(Cipher.DECRYPT_MODE, secretKey, new IvParameterSpec(iv));

            CipherInputStream cipherInputStream = new CipherInputStream(
                    new FileInputStream(encryptedDataFilePath), outCipher);
            result = IOUtils.toByteArray(cipherInputStream);
        } catch (UserNotAuthenticatedException e) {
            Log.e(TAG, Log.getStackTraceString(e));
            Log.e(TAG, "showAuthenticationScreen");
            showAuthenticationScreen(context, request_code);
        } catch (IOException | CertificateException | NoSuchAlgorithmException | UnrecoverableKeyException | NullPointerException |
                InvalidAlgorithmParameterException | NoSuchPaddingException | KeyStoreException | InvalidKeyException e) {
            e.printStackTrace();
        }
        return result;
    }

    public static boolean putKeyStorePhrase(String strToStore, Activity context, int requestCode) {
        if (strToStore == null || strToStore.isEmpty()) return false;

        byte[] strBytes = new byte[0];
        try {
            strBytes = strToStore.getBytes("UTF-8");
        } catch (UnsupportedEncodingException e) {
            e.printStackTrace();
        }
        return strBytes.length != 0 && setData(context, strBytes, PHRASE_ALIAS, PHRASE_FILENAME, PHRASE_IV, requestCode, true);
    }

    public static String getKeyStorePhrase(final Activity context, int requestCode) {

        KeyguardManager myKM = (KeyguardManager) context.getSystemService(Context.KEYGUARD_SERVICE);
        if (myKM.inKeyguardRestrictedInputMode()) {
            Log.e(TAG, "THE SCREEN IS LOCKED!");
            return null;
        } else {
            Log.e(TAG, "THE SCREEN IS UNLOCKED!");
        }
        byte[] data = getData(context, PHRASE_ALIAS, PHRASE_FILENAME, PHRASE_IV, requestCode);
        String result = null;
        try {
            result = new String(data, "UTF-8");
        } catch (UnsupportedEncodingException e) {
            e.printStackTrace();
        }

        return result;
    }

    public static boolean putKeyStoreCanary(String strToStore, Activity context, int requestCode) {
        if (strToStore == null || strToStore.isEmpty()) return false;

        byte[] strBytes = new byte[0];
        try {
            strBytes = strToStore.getBytes("UTF-8");
        } catch (UnsupportedEncodingException e) {
            e.printStackTrace();
        }
        return strBytes.length != 0 && setData(context, strBytes, CANARY_ALIAS, CANARY_FILENAME, CANARY_FILENAME, requestCode, true);
    }

    public static String getKeyStoreCanary(final Activity context, int requestCode) {
        byte[] data = getData(context, CANARY_ALIAS, CANARY_FILENAME, CANARY_IV, requestCode);
        String result = null;
        try {
            result = new String(data, "UTF-8");
        } catch (UnsupportedEncodingException e) {
            e.printStackTrace();
        }
        return result;
    }

    public static boolean putMasterPublicKey(byte[] masterPubKey, Activity context) {
        return masterPubKey != null && masterPubKey.length != 0 && setData(context, masterPubKey, PUB_KEY_ALIAS, PUB_KEY_FILENAME, PUB_KEY_IV, 0, false);
    }

    public static byte[] getMasterPublicKey(final Activity context) {
        return getData(context, PUB_KEY_ALIAS, PUB_KEY_FILENAME, PUB_KEY_IV, 0);
    }

    public static boolean putWalletCreationTime(int creationTime, Activity context) {
        byte[] bytesToStore = TypesConverter.intToBytes(creationTime);
        return bytesToStore.length != 0 && setData(context, bytesToStore, WALLET_CREATION_TIME_ALIAS, WALLET_CREATION_TIME_FILENAME, TIME_IV, 0, false);
    }

    public static int getWalletCreationTime(final Activity context) {
        byte[] result = getData(context, WALLET_CREATION_TIME_ALIAS, WALLET_CREATION_TIME_FILENAME, TIME_IV, 0);
        return result.length > 0 ? TypesConverter.bytesToInt(result) : 0;
    }

    public static boolean putPassCode(int passcode, Activity context) {

        byte[] bytesToStore = TypesConverter.intToBytes(passcode);
        return bytesToStore.length != 0 && setData(context, bytesToStore, PASS_CODE_ALIAS, PASS_CODE_FILENAME, PASS_CODE_IV, 0, false);
    }

    public static int getPassCode(final Activity context) {
        byte[] result = getData(context, PASS_CODE_ALIAS, PASS_CODE_FILENAME, PASS_CODE_IV, 0);
        return result.length > 0 ? TypesConverter.bytesToInt(result) : 0;
    }

    public static boolean resetWalletKeyStore() {
        KeyStore keyStore;
        try {
            keyStore = KeyStore.getInstance(ANDROID_KEY_STORE);
            keyStore.load(null);
            keyStore.deleteEntry(PHRASE_ALIAS);
            keyStore.deleteEntry(PUB_KEY_ALIAS);
            keyStore.deleteEntry(WALLET_CREATION_TIME_ALIAS);
            keyStore.deleteEntry(PASS_CODE_ALIAS);
            keyStore.deleteEntry(CANARY_ALIAS);
        } catch (NoSuchAlgorithmException e) {
            e.printStackTrace();
            return false;
        } catch (KeyStoreException e) {
            e.printStackTrace();
            return false;
        } catch (IOException e) {
            e.printStackTrace();
            return false;
        } catch (java.security.cert.CertificateException e) {
            e.printStackTrace();
        }
        return true;
    }

    public static void showAuthenticationScreen(Activity context, int requestCode) {
        // Create the Confirm Credentials screen. You can customize the title and description. Or
        // we will provide a generic one for you if you leave it null
        KeyguardManager mKeyguardManager = (KeyguardManager) context.getSystemService(Context.KEYGUARD_SERVICE);
        Intent intent = mKeyguardManager.createConfirmDeviceCredentialIntent("Authentication required", "The phone has been unlocked for too long");
        if (intent != null) {
            context.startActivityForResult(intent, requestCode);
        } else {
            Log.e(TAG, "NO PASS SETUP");
        }
    }

    public static byte[] readBytesFromFile(String path) {
        byte[] bytes = null;
        try {
            File file = new File(path);
            FileInputStream fin = new FileInputStream(file);
            bytes = IOUtils.toByteArray(fin);
        } catch (IOException e) {
            e.printStackTrace();
        }
        return bytes;
    }

    public static boolean writeBytesToFile(String path, byte[] data) {

        FileOutputStream fos = null;

        try {
            File file = new File(path);
            fos = new FileOutputStream(file);

            // Writes bytes from the specified byte array to this file output stream
            fos.write(data);
            return true;
        } catch (FileNotFoundException e) {
            System.out.println("File not found" + e);
        } catch (IOException ioe) {
            System.out.println("Exception while writing file " + ioe);
        } finally {
            // close the streams using close method
            try {
                if (fos != null) {
                    fos.close();
                }
            } catch (IOException ioe) {
                System.out.println("Error while closing stream: " + ioe);
            }

        }
        return false;
    }

}