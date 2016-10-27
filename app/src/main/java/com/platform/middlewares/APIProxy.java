package com.platform.middlewares;

import android.util.Log;

import com.breadwallet.presenter.activities.MainActivity;
import com.platform.APIClient;
import com.platform.interfaces.Middleware;
import org.apache.commons.io.IOUtils;
import org.json.JSONException;
import org.json.JSONObject;

import java.io.IOException;
import java.util.Enumeration;

import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;

import okhttp3.Request;
import okhttp3.RequestBody;
import okhttp3.Response;
import okhttp3.ResponseBody;

import static android.R.attr.path;
import static com.breadwallet.R.string.request;


/**
 * BreadWallet
 * <p/>
 * Created by Mihail Gutan on <mihail@breadwallet.com> 10/19/16.
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
public class APIProxy implements Middleware {
    public static final String TAG = APIProxy.class.getName();

    private APIClient apiInstance;
    private static final String MOUNT_POINT = "/_api";
    private final String SHOULD_VERIFY_HEADER = "x-should-verify";
    private final String SHOULD_AUTHENTICATE = "x-should-authenticate";
    private final String[] bannedSendHeaders = new String[]{
            SHOULD_VERIFY_HEADER,
            SHOULD_AUTHENTICATE,
            "connection",
            "authorization",
            "host",
            "user-agent"};

    private final String[] bannedReceiveHeaders = new String[]{
            "content-length",
            "content-encoding",
            "connection"};

    public APIProxy() {
        apiInstance = APIClient.getInstance(MainActivity.app);
    }

    @Override
    public boolean handle(String target, org.eclipse.jetty.server.Request baseRequest, HttpServletRequest request, HttpServletResponse response) {
        if (!target.startsWith(MOUNT_POINT)) return false;

        String path = target.substring(MOUNT_POINT.length());
        Log.e(TAG, "handle: path: " + path);
        String queryString = baseRequest.getQueryString();
        if (queryString != null && queryString.length() > 0)
            path += "?" + queryString;
        Log.e(TAG, "handle: path with queryString: " + path);
        boolean auth = false;
        Request req = mapToOkhttpRequest(baseRequest, path, request);
        if (baseRequest.getHeader(SHOULD_AUTHENTICATE).toLowerCase().equals("yes")) auth = true;
        Response res = apiInstance.sendRequest(req, auth);
        Log.e(TAG, "handle: res: " + res.code());
        ResponseBody body = res.body();
        String cType = body.contentType().toString();


        String resString = null;
        try {
            resString = body.string();
            Log.e(TAG, "handle: body: " + resString + ", at url: " + req.url());
                JSONObject obj = new JSONObject(resString);
            Log.e(TAG, "handle: obj: " + obj.toString());
        } catch (IOException | JSONException e) {
            e.printStackTrace();
        }
        if (res.isSuccessful() && resString != null) {
            try {
                response.setContentType(cType);
                response.setStatus(HttpServletResponse.SC_OK);
                Log.e(TAG, "responseString: " + resString + "\ncType: " + cType);
                response.getWriter().write(resString);
                baseRequest.setHandled(true);
            } catch (IOException e) {
                e.printStackTrace();
            }

            return true;
        }

        return false;
    }

    private Request mapToOkhttpRequest(org.eclipse.jetty.server.Request baseRequest, String path, HttpServletRequest request){
        Request req;
        Request.Builder builder = new Request.Builder()
                .url(apiInstance.buildUrl(path));

        Enumeration<String> headerNames = baseRequest.getHeaderNames();
        while (headerNames.hasMoreElements()) {
            String hName = headerNames.nextElement();
            builder.addHeader(hName, baseRequest.getHeader(hName));
        }
        switch (baseRequest.getMethod()) {
            case "GET":
                builder.get();
                break;
            case "DELETE":
                builder.delete();
                break;
            case "POST":
                byte[] postBodyText = new byte[0];
                try {
                    postBodyText = IOUtils.toByteArray(request.getInputStream());
                } catch (IOException e) {
                    e.printStackTrace();
                }
                RequestBody postReqBody = RequestBody.create(null, postBodyText);
                builder.post(postReqBody);
                break;
            case "PUT":
                byte[] putBodyText = new byte[0];
                try {
                    putBodyText = IOUtils.toByteArray(request.getInputStream());
                } catch (IOException e) {
                    e.printStackTrace();
                }
                RequestBody putReqBody = RequestBody.create(null, putBodyText);
                builder.put(putReqBody);
                break;
        }

        req = builder.build();
        return req;
    }
}
