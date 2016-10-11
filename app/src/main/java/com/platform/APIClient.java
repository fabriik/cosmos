package com.platform;

import android.app.Activity;

import android.content.Context;
import android.util.Log;

import com.breadwallet.presenter.activities.MainActivity;
import com.breadwallet.tools.manager.SharedPreferencesManager;
import com.breadwallet.tools.security.KeyStoreManager;
import com.breadwallet.wallet.BRWalletManager;
import com.jniwrappers.BRBase58;
import com.jniwrappers.BRKey;

import org.apache.commons.compress.archivers.tar.TarArchiveEntry;
import org.apache.commons.compress.archivers.tar.TarArchiveInputStream;
import org.apache.commons.compress.compressors.CompressorException;
import org.apache.commons.io.FileUtils;
import org.apache.commons.io.IOUtils;
import org.json.JSONArray;
import org.json.JSONException;
import org.json.JSONObject;

import java.io.File;
import java.io.FileInputStream;
import java.io.FileOutputStream;
import java.io.IOException;
import java.nio.charset.StandardCharsets;
import java.security.MessageDigest;
import java.security.NoSuchAlgorithmException;
import java.text.SimpleDateFormat;
import java.util.Date;
import java.util.Locale;
import java.util.TimeZone;

import io.sigpipe.jbsdiff.InvalidHeaderException;
import io.sigpipe.jbsdiff.ui.FileUI;
import okhttp3.MediaType;
import okhttp3.OkHttpClient;
import okhttp3.Request;
import okhttp3.RequestBody;
import okhttp3.Response;


/**
 * BreadWallet
 * <p/>
 * Created by Mihail Gutan on <mihail@breadwallet.com> 9/29/16.
 * Copyright (c) 2016 breadwallet LLC
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
public class APIClient {

    public static final String TAG = APIClient.class.getName();

    // proto is the transport protocol to use for talking to the API (either http or https)
    private static final String PROTO = "https";
    // host is the server(s) on which the API is hosted
    private static final String HOST = "api.breadwallet.com";
    // convenience getter for the API endpoint
    private static final String BASE_URL = PROTO + "://" + HOST;
    //feePerKb url
    private static final String FEE_PER_KB_URL = "/v1/fee-per-kb";
    //token
    private static final String TOKEN = "/token";
    //me
    private static final String ME = "/me";
    //singleton instance
    private static APIClient ourInstance;

    private static final String GET = "GET";
    private static final String POST = "POST";

    public static final String BUNDLES = "bundles";
    public static final String BREAD_BUY = "bread-buy";

    public static String bundlesFileName = String.format("/%s", BUNDLES);
    public static String bundleFileName = String.format("/%s/%s.tar", BUNDLES, BREAD_BUY);
    public static String bundleFileNameExtracted = String.format("/%s/%s-extracted", BUNDLES, BREAD_BUY);
    private Activity ctx;

    public static synchronized APIClient getInstance(Activity context) {

        if (ourInstance == null) ourInstance = new APIClient(context);
        return ourInstance;
    }

    private APIClient(Activity context) {
        ctx = context;
    }

    public static synchronized APIClient getInstance() {
        if (ourInstance == null) ourInstance = new APIClient();
        return ourInstance;
    }

    private APIClient() {
    }

    //returns the fee per kb or 0 if something went wrong
    public long feePerKb() {

        try {
            String strUtl = BASE_URL + FEE_PER_KB_URL;
            Request request = new Request.Builder().url(strUtl).get().build();
            String body = null;
            try {
                Response response = sendRequest(request, false);
                Log.e(TAG, "feePerKb: ");
                body = response.body().string();
            } catch (IOException e) {
                e.printStackTrace();
            }
            Log.e(TAG, "feePerKb: response: " + body);
            JSONObject object = null;
            object = new JSONObject(body);
            return (long) object.getInt("fee_per_kb");
        } catch (JSONException e) {
            e.printStackTrace();

        }
        return 0;
    }

    public String buyBitcoinMe() {
        if (ctx == null) ctx = MainActivity.app;
        if (ctx == null) return null;
        String strUtl = BASE_URL + ME;
        Log.e(TAG, "buyBitcoinMe: strUrl: " + strUtl);
        Request request = new Request.Builder()
                .url(strUtl)
                .get()
                .build();
        String response = null;
        try {
            response = sendRequest(request, true).body().string();
            if (response.isEmpty()) {
                response = sendRequest(request, true).body().string();
            }
        } catch (IOException e) {
            e.printStackTrace();
        }

        if (response == null) throw new NullPointerException();

        Log.e(TAG, "buyBitcoinMe: response: " + response);

        return response;
    }

    public String getToken() {
        Log.e(TAG, "getToken");
        if (ctx == null) ctx = MainActivity.app;
        if (ctx == null) return null;
        try {
            String strUtl = BASE_URL + TOKEN;

            JSONObject requestMessageJSON = new JSONObject();
            String base58PubKey = BRWalletManager.getAuthPublicKeyForAPI(KeyStoreManager.getAuthKey(ctx));
//            Log.e(TAG, "getToken: base58PubKey: " + base58PubKey);
            requestMessageJSON.put("pubKey", base58PubKey);
            requestMessageJSON.put("deviceID", SharedPreferencesManager.getDeviceId(ctx));
//            Log.e(TAG, "getToken: message: " + requestMessageJSON.toString());

            final MediaType JSON
                    = MediaType.parse("application/json; charset=utf-8");
            RequestBody requestBody = RequestBody.create(JSON, requestMessageJSON.toString());
            Request request = new Request.Builder()
                    .url(strUtl)
                    .header("Content-Type", "application/json")
                    .header("Accept", "application/json")
                    .post(requestBody).build();
            String response = null;
            try {
                response = sendRequest(request, false).body().string();
            } catch (IOException e) {
                e.printStackTrace();
            }
            Log.e(TAG, "getToken: response: " + response);
            if (response == null) return null;
            JSONObject obj = null;
            obj = new JSONObject(response);
            String token = obj.getString("token");
            KeyStoreManager.putToken(token.getBytes(), ctx);

            return token;
        } catch (JSONException e) {
            e.printStackTrace();

        }
        return null;

    }

    private String createRequest(String reqMethod, String base58Body, String contentType, String dateHeader, String url) {
        return (reqMethod == null ? "" : reqMethod) + "\n" +
                (base58Body == null ? "" : base58Body) + "\n" +
                (contentType == null ? "" : contentType) + "\n" +
                (dateHeader == null ? "" : dateHeader) + "\n" +
                (url == null ? "" : url);
    }

    public String signRequest(String request) {
        MessageDigest digest = null;
        try {
            digest = MessageDigest.getInstance("SHA-256");
        } catch (NoSuchAlgorithmException e) {
            e.printStackTrace();
            return null;
        }
        byte[] sha256First = digest.digest(request.getBytes(StandardCharsets.UTF_8));
        byte[] sha256Second = digest.digest(sha256First);
        byte[] signedBytes = BRKey.getInstance().compactSign(KeyStoreManager.getAuthKey(ctx), sha256Second);
        return BRBase58.getInstance().base58Encode(signedBytes);

    }

    public Response sendRequest(Request request, boolean needsAuth) {
        if (needsAuth) {
            Request.Builder modifiedRequest = request.newBuilder();
            String base58Body = "";
            RequestBody body = request.body();
            if (body != null) {
                base58Body = BRWalletManager.base58ofSha256(body.toString());
            }
            SimpleDateFormat sdf =
                    new SimpleDateFormat("EEE, dd MMM yyyy HH:mm:ss z", Locale.US);
            sdf.setTimeZone(TimeZone.getTimeZone("GMT"));
            String httpDate = sdf.format(new Date(System.currentTimeMillis()));

            request = modifiedRequest.header("Date", httpDate.substring(0, httpDate.length() - 6)).build();
            String requestString = createRequest(request.method(), base58Body, request.header("Content-Type"), request.header("Date"), "/me");

            Log.e(TAG, "sendRequest: requestString: " + requestString);

            String signedRequest = signRequest(requestString);

            String token = new String(KeyStoreManager.getToken(ctx));
            if (token.isEmpty()) token = getToken();
            if (token == null || token.isEmpty()) {
                Log.e(TAG, "sendRequest: failed to retrieve token");
                return null;
            }
            String authValue = "bread " + token + ":" + signedRequest;
            Log.e(TAG, "sendRequest: authValue: " + authValue);
            modifiedRequest = request.newBuilder();
            request = modifiedRequest.header("Authorization", authValue).build();

        }
        Response response = null;
        try {
            OkHttpClient client = new OkHttpClient();
            Log.e(TAG, "sendRequest: dateHeader: " + request.header("Date"));
            Log.e(TAG, "sendRequest: Authorization: " + request.header("Authorization"));
            response = client.newCall(request).execute();
            System.out.println("sendRequest: response code: " + response.code() + " for: " + request.url());
            System.out.println("sendRequest: response message: " + response.message());
        } catch (IOException e) {
            e.printStackTrace();
        }

        return response;
    }

    public void updateBundle(Context context) {

        Log.e(TAG, "updateBundle");

        File bundlesFolder = new File(context.getFilesDir().getAbsolutePath() + bundlesFileName);
        File bundleFile = new File(context.getFilesDir().getAbsolutePath() + bundleFileName);
        File bundleExtractedFolder = new File(context.getFilesDir().getAbsolutePath() + bundleFileNameExtracted);
        FileOutputStream bundlesOutStream = null;
        FileOutputStream extractedOutStream = null;

        //test
        APIClient apiClient = APIClient.getInstance();
        Request testRequest = new Request.Builder()
                .get()
                .url(String.format("%s/assets/bundles/%s/diff/%s", BASE_URL, BREAD_BUY, "6b8a9b11f89387902d4d30c22f08a62c9335de7f3e658173aa9e4111711ba5b0")).build();
        Response testResponse = apiClient.sendRequest(testRequest, false);
        apiClient.downloadBundle(testResponse, bundleFile);
        //end test

        if (bundleFile.exists()) {
            Log.e(TAG, "updateBundle: exists");
            tryExtractTar(bundleFile, bundleFileNameExtracted);

            byte[] bFile = new byte[0];
            try {
                bFile = IOUtils.toByteArray(new FileInputStream(bundleFile));
            } catch (IOException e) {
                e.printStackTrace();
            }

            String response = null;
            try {
                response = sendRequest(new Request.Builder()
                        .get()
                        .url(String.format("%s/assets/bundles/%s/versions", BASE_URL, BREAD_BUY))
                        .build(), false).body().string();
            } catch (IOException e) {
                e.printStackTrace();
            }
            String respBody = "";
            respBody = response;
            Log.e(TAG, "updateBundle: response: " + respBody);
            String latestVersion = null;
            String currentTarVersion = null;
            try {
                JSONObject versionsJson = new JSONObject(respBody);
                JSONArray jsonArray = versionsJson.getJSONArray("versions");
                latestVersion = (String) jsonArray.get(jsonArray.length() - 1);
                Log.e(TAG, "updateBundle: latestVersion: " + latestVersion);
                //todo here is the problem with the version
                MessageDigest digest = MessageDigest.getInstance("SHA-256");
                byte[] hash = digest.digest(bFile);
                currentTarVersion = bytesToHex(hash);
                Log.e(TAG, "updateBundle: version of the current tar: " + currentTarVersion);
            } catch (JSONException | NoSuchAlgorithmException e) {
                e.printStackTrace();
            }

            if (latestVersion != null && currentTarVersion != null) {
                if (latestVersion.equals(currentTarVersion)) {
                    Log.e(TAG, "updateBundle: have the latest version");
                    tryExtractTar(bundleFile, bundleFileNameExtracted);
                } else {
                    Log.e(TAG, "updateBundle: don't have the most recent version, download diff");
                    Log.e(TAG, "downloadDiff: currentTarVersion: " + currentTarVersion);
                    downloadDiff(bundleFile, currentTarVersion);

                }
            } else {
                Log.e(TAG, "updateBundle: something is null: latestVersion: " + latestVersion + ", currentTarVersion: " + currentTarVersion);
            }

        } else {
            Log.e(TAG, "updateBundle: bundle doesn't exist, downloading new copy");
            Request request = new Request.Builder()
                    .url(String.format("%s/assets/bundles/%s/download", BASE_URL, BREAD_BUY))
                    .get().build();
            Response response = null;
            response = sendRequest(request, false);
            downloadBundle(response, bundleFile);

            tryExtractTar(bundleFile, bundleFileNameExtracted);

            Log.e(TAG, "updateBundle: bundleFile.length(): " + bundleFile.length());

        }

    }

    public void downloadDiff(File bundleFile, String currentTarVersion) {
        Log.e(TAG, "downloadDiff");
        Request diffRequest = new Request.Builder()
                .url(String.format("%s/assets/bundles/%s/diff/%s", BASE_URL, BREAD_BUY, currentTarVersion))
                .get().build();
        Response diffResponse = sendRequest(diffRequest, false);
        File patchFile = null;
        File tempFile = null;
        byte[] patchBytes = null;
        try {
            patchFile = new File(String.format("/%s/%s.diff", BUNDLES, "patch"));
            patchBytes = diffResponse.body().bytes();
            FileUtils.writeByteArrayToFile(patchFile, patchBytes);

            String compression = System.getProperty("jbsdiff.compressor", "tar");
            compression = compression.toLowerCase();
            tempFile = new File(String.format("/%s/%s.tar", BUNDLES, "temp"));
            FileUI.diff(bundleFile, tempFile, patchFile, compression);

            byte[] updatedBundleBytes = IOUtils.toByteArray(new FileInputStream(tempFile));

            FileUtils.writeByteArrayToFile(bundleFile, updatedBundleBytes);

        } catch (IOException | InvalidHeaderException | CompressorException e) {
            e.printStackTrace();
        } finally {
            if (patchFile != null)
                patchFile.delete();
            if (tempFile != null)
                tempFile.delete();
        }
        Log.e(TAG, "downloadDiff: patchBytes.length: " + (patchBytes == null ? null : patchBytes.length));
    }

    public void downloadBundle(Response response, File bundleFile) {
        if (response == null) Log.e(TAG, "downloadBundle: WARNING: response is null");
        byte[] bodyBytes;
        FileOutputStream fileOutputStream = null;
        try {
            if (response == null) {
                Log.e(TAG, "downloadBundle: WARNING, response is null");
                return;
            }
            bodyBytes = response.body().bytes();
            FileUtils.writeByteArrayToFile(bundleFile, bodyBytes);
            Log.e(TAG, "downloadBundle: bodyBytes.length: " + bodyBytes.length);

        } catch (IOException e) {
            e.printStackTrace();
        } finally {
            try {
                if (fileOutputStream != null) {
                    fileOutputStream.close();
                }
            } catch (IOException e) {
                e.printStackTrace();
            }
        }
    }

    public void tryExtractTar(File tarFile, String toPath) {
        Log.e(TAG, "tryExtractTar: tarFile: " + tarFile);
        Log.e(TAG, "tryExtractTar: path: " + toPath);
        TarArchiveInputStream myTarFile = null;
        try {
            myTarFile = new TarArchiveInputStream(new FileInputStream(tarFile));
            TarArchiveEntry entry = null;
            String individualFiles;
            int offset;

            while ((entry = myTarFile.getNextTarEntry()) != null) {
                individualFiles = entry.getName();
                byte[] content = new byte[(int) entry.getSize()];
                offset = 0;
                System.out.println("File Name in TAR File is: " + individualFiles);
                System.out.println("Size of the File is: " + entry.getSize());
                System.out.println("Byte Array length: " + content.length);
                myTarFile.read(content, offset, content.length - offset);
                FileUtils.writeByteArrayToFile(new File(String.format("%s/%s", toPath, individualFiles)), content);

            }
            Log.e(TAG, "tryExtractTar: SUCCESS!");
        } catch (IOException e) {
            e.printStackTrace();
        } finally {
            try {
                if (myTarFile != null) {
                    myTarFile.close();
                }
            } catch (IOException e) {
                e.printStackTrace();
            }
        }

    }

    final protected static char[] hexArray = "0123456789ABCDEF".toCharArray();
    public static String bytesToHex(byte[] bytes) {
        char[] hexChars = new char[bytes.length * 2];
        for ( int j = 0; j < bytes.length; j++ ) {
            int v = bytes[j] & 0xFF;
            hexChars[j * 2] = hexArray[v >>> 4];
            hexChars[j * 2 + 1] = hexArray[v & 0x0F];
        }
        return new String(hexChars);
    }

}