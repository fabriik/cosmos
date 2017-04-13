package com.breadwallet.presenter.activities;

import android.app.Activity;
import android.app.FragmentTransaction;
import android.content.Intent;
import android.content.pm.PackageManager;
import android.graphics.Point;
import android.net.Uri;
import android.os.Bundle;
import android.os.Handler;
import android.support.annotation.NonNull;
import android.support.constraint.ConstraintLayout;
import android.support.v7.app.AppCompatActivity;
import android.support.v7.widget.LinearLayoutManager;
import android.support.v7.widget.RecyclerView;
import android.support.v7.widget.Toolbar;
import android.util.Log;
import android.view.View;
import android.view.Window;
import android.view.WindowManager;
import android.widget.LinearLayout;
import android.widget.ProgressBar;
import android.widget.RelativeLayout;
import android.widget.TextView;

import com.breadwallet.R;
import com.breadwallet.presenter.entities.TransactionListItem;
import com.breadwallet.presenter.fragments.FragmentMenu;
import com.breadwallet.tools.adapter.TransactionListAdapter;
import com.breadwallet.tools.animation.BRAnimator;
import com.breadwallet.tools.animation.SpringAnimator;
import com.breadwallet.tools.listeners.RecyclerItemClickListener;
import com.breadwallet.tools.manager.CurrencyFetchManager;
import com.breadwallet.tools.manager.SharedPreferencesManager;
import com.breadwallet.tools.security.BitcoinUrlHandler;
import com.breadwallet.tools.security.PostAuthenticationProcessor;
import com.breadwallet.tools.sqlite.TransactionDataSource;
import com.breadwallet.tools.util.BRConstants;
import com.breadwallet.tools.util.BRCurrency;
import com.breadwallet.tools.util.BRExchange;
import com.breadwallet.wallet.BRPeerManager;
import com.breadwallet.wallet.BRWalletManager;
import com.platform.APIClient;

import java.math.BigDecimal;
import java.util.Arrays;

import static com.breadwallet.presenter.activities.IntroActivity.introActivity;
import static com.breadwallet.presenter.activities.IntroReEnterPinActivity.introReEnterPinActivity;
import static com.breadwallet.presenter.activities.IntroSetPitActivity.introSetPitActivity;
import static com.breadwallet.tools.util.BRConstants.PLATFORM_ON;

/**
 * BreadWallet
 * <p/>
 * Created by Mihail Gutan <mihail@breadwallet.com> on 8/4/15.
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

public class BreadActivity extends AppCompatActivity implements BRWalletManager.OnBalanceChanged,
        BRPeerManager.OnTxStatusUpdate, SharedPreferencesManager.OnIsoChangedListener, TransactionDataSource.OnTxAddedListener {

    private static final String TAG = BreadActivity.class.getName();

    private LinearLayout sendButton;
    private LinearLayout receiveButton;
    private LinearLayout menuButton;
    private static BreadActivity app;
    public static final Point screenParametersPoint = new Point();

    private TextView primaryPrice;
    private TextView secondaryPrice;
    private TextView emptyTip;
    private TextView syncLabel;
    public TextView syncDate;
    private ProgressBar loadProgressBar;
    public ProgressBar syncProgressBar;
    private ConstraintLayout walletProgressLayout;
    private RecyclerView txList;
    private TransactionListAdapter adapter;
    private RelativeLayout mainLayout;
    private LinearLayout toolbarLayout;
    private ConstraintLayout syncingLayout;
    private LinearLayout recyclerLayout;
    private Toolbar toolBar;
    private int progress = 0;
    public static boolean appInBackground = false;

    public static BreadActivity getApp() {
        return app;
    }

    static {
        System.loadLibrary("core");
    }

    @Override
    protected void onCreate(Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);

        setContentView(R.layout.activity_bread);
        BRWalletManager.getInstance().addBalanceChangedListener(this);
        BRPeerManager.getInstance().addStatusUpdateListener(this);
        SharedPreferencesManager.addIsoChangedListener(this);

        app = this;
        getWindowManager().getDefaultDisplay().getSize(screenParametersPoint);
        // Always cast your custom Toolbar here, and set it as the ActionBar.
        toolBar = (Toolbar) findViewById(R.id.bread_bar);
        setSupportActionBar(toolBar);

        initializeViews();

        setListeners();

        setWalletLoading();

        updateUI();

        if(introSetPitActivity != null) introSetPitActivity.finish();
        if(introActivity != null) introActivity.finish();
        if(introReEnterPinActivity != null) introReEnterPinActivity.finish();

    }

    @Override
    protected void onSaveInstanceState(Bundle outState) {
    }

    private void updateTxList() {
        final TransactionListItem[] arr = BRWalletManager.getInstance().getTransactions();
        Log.e(TAG, "updateTxList: arr.size: " + Arrays.toString(arr));
        runOnUiThread(new Runnable() {
            @Override
            public void run() {
                if (arr == null) {
                    txList.setVisibility(View.GONE);
                    emptyTip.setVisibility(View.VISIBLE);
                } else {
                    txList.setVisibility(View.VISIBLE);
                    emptyTip.setVisibility(View.GONE);
                    adapter = new TransactionListAdapter(BreadActivity.this, Arrays.asList(arr));
                    txList.setAdapter(adapter);
                    adapter.notifyDataSetChanged();
                }
            }
        });

    }

    private void setStatusBarColor() {
        Window window = getWindow();
        window.clearFlags(WindowManager.LayoutParams.FLAG_TRANSLUCENT_STATUS);
        window.addFlags(WindowManager.LayoutParams.FLAG_DRAWS_SYSTEM_BAR_BACKGROUNDS);
        window.setStatusBarColor(getColor(R.color.status_bar));
    }

    private void setUrlHandler(Intent intent) {
        Uri data = intent.getData();
        if (data == null) return;
        String scheme = data.getScheme();
        if (scheme != null && (scheme.startsWith("bitcoin") || scheme.startsWith("bitid"))) {
            String str = intent.getDataString();
            BitcoinUrlHandler.processRequest(this, str);
        }
    }

    @Override
    protected void onNewIntent(Intent intent) {
        super.onNewIntent(intent);
        setUrlHandler(intent);

    }

    private void setListeners() {
        sendButton.setOnClickListener(new View.OnClickListener() {
            @Override
            public void onClick(View v) {

                if (!BRAnimator.isClickAllowed()) return;
                SpringAnimator.showAnimation(v);
                BRAnimator.showSendFragment(BreadActivity.this, null);

            }
        });

        receiveButton.setOnClickListener(new View.OnClickListener() {
            @Override
            public void onClick(View v) {
                if (!BRAnimator.isClickAllowed()) return;
                SpringAnimator.showAnimation(v);
                BRAnimator.showReceiveFragment(BreadActivity.this, true);
            }
        });

        menuButton.setOnClickListener(new View.OnClickListener() {
            @Override
            public void onClick(View v) {
                if (!BRAnimator.isClickAllowed()) return;
                SpringAnimator.showAnimation(v);
                FragmentTransaction transaction = getFragmentManager().beginTransaction();
                transaction.setCustomAnimations(0, 0, 0, R.animator.plain_300);
                transaction.add(android.R.id.content, new FragmentMenu(), FragmentMenu.class.getName());
                transaction.addToBackStack(null);
                transaction.commit();
            }
        });
        primaryPrice.setOnClickListener(new View.OnClickListener() {
            @Override
            public void onClick(View v) {
                if (!BRAnimator.isClickAllowed()) return;
                togglePriceTexts();
            }
        });
        secondaryPrice.setOnClickListener(new View.OnClickListener() {
            @Override
            public void onClick(View v) {
                if (!BRAnimator.isClickAllowed()) return;
                togglePriceTexts();
            }
        });

        txList.setLayoutManager(new LinearLayoutManager(this));
        txList.addOnItemTouchListener(new RecyclerItemClickListener(this,
                txList, new RecyclerItemClickListener.OnItemClickListener() {
            @Override
            public void onItemClick(View view, int position, float x, float y) {
                Log.e(TAG, "onItemClick: " + position);

                BRAnimator.showTransactionPager(BreadActivity.this, adapter.getItems(),position);
            }

            @Override
            public void onLongItemClick(View view, int position) {
            }
        }));
    }

    @Override
    protected void onRestart() {
        super.onRestart();
        app = this;
    }

    @Override
    protected void onResume() {
        super.onResume();
        appInBackground = false;
        app = this;

        CurrencyFetchManager currencyManager = CurrencyFetchManager.getInstance(this);
        currencyManager.startTimer();

        if (!BRWalletManager.getInstance().isCreated()) {
            new Thread(new Runnable() {
                @Override
                public void run() {
                    BRWalletManager.getInstance().setUpTheWallet(BreadActivity.this);
                }
            }).start();

        }
        new Thread(new Runnable() {
            @Override
            public void run() {
                updateTxList();
                double progress = BRPeerManager.syncProgress(SharedPreferencesManager.getStartHeight(BreadActivity.this));
                if (progress <= 0 || progress >= 1)
                    BreadActivity.this.runOnUiThread(new Runnable() {
                        @Override
                        public void run() {
                            showSyncing(false);
                        }
                    });

            }
        }).start();
    }

    @Override
    protected void onPause() {
        super.onPause();
        appInBackground = true;
        CurrencyFetchManager.getInstance(this).stopTimerTask();
    }

    @Override
    protected void onStop() {
        super.onStop();

    }

    @Override
    protected void onDestroy() {
        super.onDestroy();

        //sync the kv stores

        if (PLATFORM_ON) {
            new Thread(new Runnable() {
                @Override
                public void run() {
                    APIClient.getInstance(BreadActivity.this).syncKvStore();
                }
            }).start();

        }

    }

    private void initializeViews() {
        sendButton = (LinearLayout) findViewById(R.id.send_layout);
        receiveButton = (LinearLayout) findViewById(R.id.receive_layout);
        menuButton = (LinearLayout) findViewById(R.id.menu_layout);
        primaryPrice = (TextView) findViewById(R.id.primary_price);
        secondaryPrice = (TextView) findViewById(R.id.secondary_price);
        emptyTip = (TextView) findViewById(R.id.empty_tx_tip);
        syncLabel = (TextView) findViewById(R.id.syncing_label);
        syncDate = (TextView) findViewById(R.id.sync_date);
        loadProgressBar = (ProgressBar) findViewById(R.id.load_wallet_progress);
        syncProgressBar = (ProgressBar) findViewById(R.id.sync_progress);
        walletProgressLayout = (ConstraintLayout) findViewById(R.id.loading_wallet_layout);
        txList = (RecyclerView) findViewById(R.id.tx_list);
        mainLayout = (RelativeLayout) findViewById(R.id.main_layout);
        toolbarLayout = (LinearLayout) findViewById(R.id.toolbar_layout);
        syncingLayout = (ConstraintLayout) findViewById(R.id.syncing_layout);
        recyclerLayout = (LinearLayout) findViewById(R.id.recycler_layout);
    }

    private void togglePriceTexts() {
        SharedPreferencesManager.putPreferredBTC(this, !SharedPreferencesManager.getPreferredBTC(this));
        new Handler().postDelayed(new Runnable() {
            @Override
            public void run() {
                updateUI();
                updateTxList();

            }
        }, 100);
    }

    //returns x-pos relative to root layout
    private float getRelativeX(View myView) {
        if (myView.getParent() == myView.getRootView())
            return myView.getX();
        else
            return myView.getX() + getRelativeX((View) myView.getParent());
    }

    //returns y-pos relative to root layout
    private float getRelativeY(View myView) {
        if (myView.getParent() == myView.getRootView())
            return myView.getY();
        else
            return myView.getY() + getRelativeY((View) myView.getParent());
    }

    //0 crypto is left, 1 crypto is right
    private int getSwapPosition() {
        if (primaryPrice == null || secondaryPrice == null) {
            return 0;
        }
        return getRelativeX(primaryPrice) < getRelativeX(secondaryPrice) ? 0 : 1;
    }

    @Override
    public void onBalanceChanged(final long balance) {
        Log.e(TAG, "onBalanceChanged: " + balance);
        updateUI();
        updateTxList();

    }

    public void updateUI() {
        new Thread(new Runnable() {
            @Override
            public void run() {
                //sleep a little in order to make sure all the commits are finished (like SharePreferences commits)
                try {
                    Thread.sleep(100);
                } catch (InterruptedException e) {
                    e.printStackTrace();
                }
                String iso = SharedPreferencesManager.getIso(BreadActivity.this);

                //current amount in satoshis
                final BigDecimal amount = new BigDecimal(SharedPreferencesManager.getBalance(BreadActivity.this));

                //amount in BTC units
                BigDecimal btcAmount = BRExchange.getBitcoinForSatoshis(BreadActivity.this, amount);
                final String formattedBTCAmount = BRCurrency.getFormattedCurrencyString(BreadActivity.this, "BTC", btcAmount);

                //amount in currency units
                BigDecimal curAmount = BRExchange.getAmountFromSatoshis(BreadActivity.this, iso, amount);
                final String formattedCurAmount = BRCurrency.getFormattedCurrencyString(BreadActivity.this, iso, curAmount);

                runOnUiThread(new Runnable() {
                    @Override
                    public void run() {
                        boolean preferredBtc = SharedPreferencesManager.getPreferredBTC(BreadActivity.this);
                        primaryPrice.setText(preferredBtc ? formattedBTCAmount : formattedCurAmount);
                        secondaryPrice.setText(preferredBtc ? formattedCurAmount : formattedBTCAmount);
                        SpringAnimator.showAnimation(primaryPrice);
                        SpringAnimator.showAnimation(secondaryPrice);

                    }
                });
            }
        }).start();

    }

    @Override
    protected void onActivityResult(int requestCode, int resultCode, final Intent data) {

        // 123 is the qrCode result
        switch (requestCode) {
            case 123:
                if (resultCode == Activity.RESULT_OK) {
                    new Handler().postDelayed(new Runnable() {
                        @Override
                        public void run() {
                            String result = data.getStringExtra("result");
                            BitcoinUrlHandler.processRequest(BreadActivity.this, result);
                        }
                    }, 500);

                }
                break;

            case BRConstants.PAY_REQUEST_CODE:
                if (resultCode == RESULT_OK) {
                    PostAuthenticationProcessor.getInstance().onPublishTxAuth(this, true);
                }
                break;
        }
    }

    @Override
    public void onStatusUpdate() {
        updateTxList();
    }

    @Override
    public void onIsoChanged(String iso) {
        updateUI();
        updateTxList();
    }

    @Override
    public void onTxAdded() {
        updateTxList();
    }

    private void setWalletLoading() {
        loadProgressBar.setProgress(progress);

        new Thread(new Runnable() {

            @Override
            public void run() {
                while (loadProgressBar.getProgress() < 100) {
                    try {
                        Thread.sleep(100);
                    } catch (InterruptedException e) {
                        e.printStackTrace();
                    }
                    loadProgressBar.post(new Runnable() {
                        @Override
                        public void run() {
                            progress += 5;
                            loadProgressBar.setProgress(progress);
                        }
                    });

                }
                walletProgressLayout.post(new Runnable() {
                    @Override
                    public void run() {
                        toolbarLayout.removeView(walletProgressLayout);
                    }
                });
            }
        }).start();
    }

    public void showSyncing(boolean show) {
        try {
            if (show) {
                recyclerLayout.addView(syncingLayout, 0);
            } else {
                recyclerLayout.removeView(syncingLayout);
            }
        } catch (Exception e) {
            e.printStackTrace();
        }
    }

    @Override
    public void onRequestPermissionsResult(int requestCode, @NonNull String[] permissions, @NonNull int[] grantResults) {
        super.onRequestPermissionsResult(requestCode, permissions, grantResults);

        switch (requestCode) {
            case BRConstants.CAMERA_REQUEST_ID: {
                // If request is cancelled, the result arrays are empty.
                if (grantResults.length > 0
                        && grantResults[0] == PackageManager.PERMISSION_GRANTED) {
                    BRAnimator.openCamera(this);
                    // permission was granted, yay! Do the
                    // contacts-related task you need to do.

                } else {

                    // permission denied, boo! Disable the
                    // functionality that depends on this permission.
                }
                return;
            }

            // other 'case' lines to check for other
            // permissions this app might request
        }
    }
}