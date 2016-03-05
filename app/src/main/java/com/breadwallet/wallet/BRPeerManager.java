package com.breadwallet.wallet;

import android.content.Context;
import android.util.Log;
import android.view.View;

import com.breadwallet.presenter.activities.MainActivity;
import com.breadwallet.tools.sqlite.SQLiteManager;

import java.text.DecimalFormat;

/**
 * BreadWallet
 * <p/>
 * Created by Mihail on 12/10/15.
 * Copyright (c) 2015 Mihail Gutan <mihail@breadwallet.com>
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
public class BRPeerManager {
    public static final String TAG = BRPeerManager.class.getName();
    private static BRPeerManager instance;
    private static SyncProgressTask syncTask;
    private static Context ctx;

    private BRPeerManager() {
        syncTask = new SyncProgressTask();
    }

    public static synchronized BRPeerManager getInstance(Context context) {
        ctx = context;
        if (instance == null) {
            instance = new BRPeerManager();
        }
        return instance;
    }

    public native void connect(long earliestKeyTime, long blockCount, long peerCount);

    public native void putPeer(byte[] peerAddress, byte[] peerPort, byte[] peerTimeStamp);

    public native void createPeerArrayWithCount(int count);

    public native void putBlock(byte[] block);

    public native void createBlockArrayWithCount(int count);

    public native double syncProgress();

    /**
     * void BRPeerManagerSetCallbacks(BRPeerManager *manager, void *info,
     * void (*syncStarted)(void *info),
     * void (*syncSucceeded)(void *info),
     * void (*syncFailed)(void *info, BRPeerManagerError error),
     * void (*txStatusUpdate)(void *info),
     * void (*saveBlocks)(void *info, const BRMerkleBlock blocks[], size_t count),
     * void (*savePeers)(void *info, const BRPeer peers[], size_t count),
     * int (*networkIsReachable)(void *info))
     */

    public static synchronized void syncStarted() {
        Log.e(TAG, "syncStarted");
        try {
            if (syncTask != null) {
                if (!syncTask.isAlive()) {
                    syncTask.start();
                }

            }
        } catch (IllegalThreadStateException ex) {
            ex.printStackTrace();
        }

    }

    public static synchronized void syncSucceded() {
        Log.e(TAG, "syncSucceeded");
        try {
            if (syncTask != null) {
                syncTask.interrupt();
            }
        } catch (Exception ex) {
            ex.printStackTrace();
        }
    }

    public static synchronized void syncFailed() {
        Log.e(TAG, "syncFailed");
        try {
            if (syncTask != null) {
                syncTask.interrupt();
            }
        } catch (Exception ex) {
            ex.printStackTrace();
        }

    }

    public static synchronized void txStatusUpdate() {
        Log.e(TAG, "txStatusUpdate");
    }

    public static synchronized void txRejected(int rescanRecommended) {
        Log.e(TAG, "txStatusUpdate");
    }

    public static synchronized void saveBlocks(byte[] block) {
        Log.e(TAG, "saveBlocks");
        SQLiteManager.getInstance(ctx).insertMerkleBlock(block);
    }

    public static synchronized void savePeers(byte[] peerAddress, byte[] peerPort, byte[] peerTimeStamp) {
        Log.e(TAG, "savePeers");
        SQLiteManager.getInstance(ctx).insertPeer(peerAddress, peerPort, peerTimeStamp);
    }

    public static synchronized void networkIsReachable() {
        Log.e(TAG, "networkIsReachable");
    }

    private class SyncProgressTask extends Thread {

        public boolean running = true;
        public double progressStatus = 0;

        @Override
        public void run() {
            final MainActivity app = MainActivity.app;
            progressStatus = 0;
            if (app != null) {
                app.runOnUiThread(new Runnable() {
                    @Override
                    public void run() {
                        progressStatus = syncProgress();
                        app.syncProgressText.setVisibility(View.VISIBLE);
                        app.syncProgressBar.setVisibility(View.VISIBLE);
                        app.syncProgressBar.setProgress((int) (progressStatus * 100));
                        app.syncProgressText.setText(new DecimalFormat("#.##").format(progressStatus * 100) + "%");
                    }
                });

                while (running) {
                    app.runOnUiThread(new Runnable() {
                        @Override
                        public void run() {
                            progressStatus = syncProgress();
                            app.syncProgressBar.setProgress((int) (progressStatus * 100));
                            app.syncProgressText.setText(new DecimalFormat("#.##").format(progressStatus * 100) + "%");

                        }
                    });
                    if (progressStatus >= 1) {
                        app.runOnUiThread(new Runnable() {
                            @Override
                            public void run() {
                                progressStatus = 0;
                                app.syncProgressText.setVisibility(View.GONE);
                                app.syncProgressBar.setVisibility(View.GONE);
                            }
                        });
                        running = false;
                    }
                    try {
                        Thread.sleep(500);
                    } catch (InterruptedException e) {
                        e.printStackTrace();
                    }
                }
            }

        }
    }

}
