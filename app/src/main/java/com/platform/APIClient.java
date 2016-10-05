package com.platform;

import android.app.Activity;

import android.util.Log;

import com.breadwallet.presenter.activities.MainActivity;
import com.breadwallet.tools.manager.SharedPreferencesManager;
import com.breadwallet.tools.security.KeyStoreManager;
import com.breadwallet.wallet.BRWalletManager;

import org.json.JSONException;
import org.json.JSONObject;

import java.io.BufferedReader;
import java.io.IOException;
import java.io.InputStreamReader;
import java.io.OutputStream;
import java.net.HttpURLConnection;
import java.net.URL;
import java.text.SimpleDateFormat;
import java.util.Date;
import java.util.HashMap;
import java.util.Iterator;
import java.util.Locale;
import java.util.Map;
import java.util.Set;
import java.util.TimeZone;

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
            HTTPRequest request = new HTTPRequest(strUtl, HTTPRequest.GET, true, true);
            String response = sendRequest(request, false);

            JSONObject object = new JSONObject(response);
            return (long) object.getInt("fee_per_kb");
        } catch (JSONException e) {
            e.printStackTrace();

        }
        return 0;
    }

    public String buyBitcoinMe() {
        if (ctx == null) ctx = MainActivity.app;
        if (ctx == null) return null;
        try {
            String strUtl = BASE_URL + ME;
            Log.e(TAG, "getToken: strUrl: " + strUtl);
            HTTPRequest request = new HTTPRequest(strUtl, HTTPRequest.GET, true, true);
            Map<String, String> properties = new HashMap<>();
//            properties.put("Content-Type", "application/json");
//            properties.put("Accept", "application/json");
            request.setHeaders(properties);
//            JSONObject requestMessageJSON = new JSONObject();
//            String base58PubKey = BRWalletManager.getAuthPublicKeyForAPI(KeyStoreManager.getAuthKey(ctx));
//            Log.e(TAG, "getToken: base58PubKey: " + base58PubKey);
//            requestMessageJSON.put("pubKey", base58PubKey);
//            requestMessageJSON.put("deviceID", SharedPreferencesManager.getDeviceId(ctx));
//            request.setMessage(requestMessageJSON.toString());
//            Log.e(TAG, "getToken: message: " + requestMessageJSON.toString());
            String response = sendRequest(request, true);
            if (response.equalsIgnoreCase("401")) {
                getToken();
                response = sendRequest(request, true);
            }

            Log.e(TAG, "getToken: response: " + response);
            if (response.isEmpty()) return null;
            JSONObject obj = new JSONObject(response);
            String token = obj.getString("token");
            KeyStoreManager.putToken(token.getBytes(), ctx);

            return null;
        } catch (JSONException e) {
            e.printStackTrace();

        }
        return null;
    }

    public Map<String, String> getToken() {
        if (ctx == null) ctx = MainActivity.app;
        if (ctx == null) return null;
        try {
            String strUtl = BASE_URL + TOKEN;
            Log.e(TAG, "getToken: strUrl: " + strUtl);
            HTTPRequest request = new HTTPRequest(strUtl, HTTPRequest.POST, true, true);
            Map<String, String> properties = new HashMap<>();
            properties.put("Content-Type", "application/json");
            properties.put("Accept", "application/json");
            request.setHeaders(properties);
            JSONObject requestMessageJSON = new JSONObject();
            String base58PubKey = BRWalletManager.getAuthPublicKeyForAPI(KeyStoreManager.getAuthKey(ctx));
            Log.e(TAG, "getToken: base58PubKey: " + base58PubKey);
            requestMessageJSON.put("pubKey", base58PubKey);
            requestMessageJSON.put("deviceID", SharedPreferencesManager.getDeviceId(ctx));
            request.setMessage(requestMessageJSON.toString());
            Log.e(TAG, "getToken: message: " + requestMessageJSON.toString());
            String response = sendRequest(request, false);
            Log.e(TAG, "getToken: response: " + response);
            if (response.isEmpty()) return null;
            JSONObject obj = new JSONObject(response);
            String token = obj.getString("token");
            KeyStoreManager.putToken(token.getBytes(), ctx);

            return null;
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
                (url == null ? "" : url) + "\n";
    }

    public String signRequest(String request) {
        return BRWalletManager.signString(request, KeyStoreManager.getAuthKey(ctx));
    }

    public String sendRequest(HTTPRequest req, boolean needsAuth) {
        StringBuilder builder = new StringBuilder();
        String result = "";
        int responseCode = 0;
        BufferedReader bufferedReader = null;
        HttpURLConnection conn = null;
        if (needsAuth) {
            String base58Body = "";
            if (req.getMessage() != null) {
                base58Body = BRWalletManager.base58ofSha256(req.getMessage());
            }
            SimpleDateFormat sdf =
                    new SimpleDateFormat("EEE, dd MMM yyyy HH:mm:ss z", Locale.US);
            sdf.setTimeZone(TimeZone.getTimeZone("GMT"));
            String httpDate = sdf.format(new Date(System.currentTimeMillis()));

            req.getHeaders().put("Date", httpDate.substring(0, httpDate.length() - 6));
            String requestString = createRequest(req.getMethod(), base58Body, req.getHeaders().get("Content-Type"), req.getHeaders().get("Date"), "/me");

            Log.e(TAG, "sendRequest: requestString: " + requestString);
            String signedRequest = signRequest(requestString);
            String authValue = "bread " + new String(KeyStoreManager.getToken(ctx)) + ":" + signedRequest;
            req.getHeaders().put("Authorization", authValue);
            Log.e(TAG, "sendRequest: authValue: " + authValue);
        }
        try {
            URL url = new URL(req.getUrl());

            conn = (HttpURLConnection) url.openConnection();
            conn.setRequestMethod(req.getMethod());
            conn.setDoOutput(req.isDoOutput());
            conn.setDoInput(req.isDoInput());
            conn.setConnectTimeout(5000);
            conn.setReadTimeout(10000);
            if (req.getHeaders() != null) {
                Set set = req.getHeaders().entrySet();
                Iterator iterator = set.iterator();
                while (iterator.hasNext()) {
                    Map.Entry entries = (Map.Entry) iterator.next();
                    conn.setRequestProperty(entries.getKey().toString(), entries.getValue().toString());
                    Log.e(TAG, "sendRequest: SetHeader: " + entries.getKey().toString() + ":" + entries.getValue().toString());
                }
            }
            if (req.getMessage() != null) {
                OutputStream os = conn.getOutputStream();
                os.write(req.getMessage().getBytes());
                os.flush();
            }
            System.out.println("sendRequest: getResponseMessage: " + conn.getResponseMessage());
            System.out.println("sendRequest: getResponseCode: " + conn.getResponseCode());
            responseCode = conn.getResponseCode();
            String aux = null;
            bufferedReader = new BufferedReader(new InputStreamReader(
                    (conn.getInputStream())));

            while ((aux = bufferedReader.readLine()) != null) {
                builder.append(aux);
            }
            System.out.println(conn.getURL());
            result = builder.toString();
        } catch (IOException e) {
            e.printStackTrace();
            BufferedReader bufferedReaderErr = new BufferedReader(new InputStreamReader(
                    (conn.getErrorStream())));
            StringBuilder err = new StringBuilder();
            String temp;
            try {
                while ((temp = bufferedReaderErr.readLine()) != null) {
                    err.append(temp);
                }
                Log.e(TAG, "sendRequest: ERROR STREAM: " + err.toString());
            } catch (IOException e1) {
                e1.printStackTrace();
            }
        } finally {
            if (conn != null)
                conn.disconnect();
        }

        return result.isEmpty() ? String.valueOf(responseCode) : result;
    }

}
