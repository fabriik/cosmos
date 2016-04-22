package com.breadwallet.presenter.activities;

import android.annotation.TargetApi;
import android.app.AlertDialog;
import android.app.Service;
import android.content.BroadcastReceiver;
import android.content.Context;
import android.content.DialogInterface;
import android.content.Intent;
import android.content.IntentFilter;
import android.content.SharedPreferences;
import android.content.pm.ApplicationInfo;
import android.content.pm.PackageManager;
import android.graphics.Point;
import android.hardware.fingerprint.FingerprintManager;
import android.os.Build;
import android.os.Bundle;
import android.os.Handler;
import android.os.PersistableBundle;
import android.provider.Settings;
import android.support.annotation.NonNull;
import android.support.v4.app.FragmentActivity;
import android.transition.TransitionManager;
import android.util.Log;
import android.view.KeyEvent;
import android.view.View;
import android.view.animation.Animation;
import android.view.animation.ScaleAnimation;
import android.view.inputmethod.InputMethodInfo;
import android.view.inputmethod.InputMethodManager;
import android.widget.Button;
import android.widget.ImageView;
import android.widget.ProgressBar;
import android.widget.RelativeLayout;
import android.widget.TextView;
import android.widget.Toast;
import android.widget.ViewFlipper;

import com.breadwallet.R;
import com.breadwallet.presenter.BreadWalletApp;
import com.breadwallet.presenter.bubbleview.BubbleTextVew;
import com.breadwallet.presenter.entities.BRMerkleBlockEntity;
import com.breadwallet.presenter.entities.BRPeerEntity;
import com.breadwallet.presenter.entities.BRTransactionEntity;
import com.breadwallet.presenter.entities.PaymentRequestEntity;
import com.breadwallet.presenter.fragments.FragmentCurrency;
import com.breadwallet.presenter.fragments.FragmentScanResult;
import com.breadwallet.presenter.fragments.FragmentSettings;
import com.breadwallet.presenter.fragments.FragmentSettingsAll;
import com.breadwallet.tools.BRConstants;
import com.breadwallet.tools.CurrencyManager;
import com.breadwallet.tools.NetworkChangeReceiver;
import com.breadwallet.tools.security.PostAuthenticationProcessor;
import com.breadwallet.tools.security.RootUtil;
import com.breadwallet.tools.SoftKeyboard;
import com.breadwallet.tools.adapter.AmountAdapter;
import com.breadwallet.tools.adapter.CustomPagerAdapter;
import com.breadwallet.tools.adapter.MiddleViewAdapter;
import com.breadwallet.tools.adapter.ParallaxViewPager;
import com.breadwallet.tools.animation.FragmentAnimator;
import com.breadwallet.tools.animation.SpringAnimator;
import com.breadwallet.tools.security.KeyStoreManager;
import com.breadwallet.tools.sqlite.SQLiteManager;
import com.breadwallet.tools.threads.PassCodeTask;
import com.breadwallet.tools.threads.ToastBlockShowTask;
import com.breadwallet.wallet.BRPeerManager;
import com.breadwallet.wallet.BRWalletManager;

import java.math.BigDecimal;
import java.util.HashMap;
import java.util.List;
import java.util.Locale;
import java.util.Map;
import java.util.Observable;
import java.util.Observer;

/**
 * BreadWallet
 * <p/>
 * Created by Mihail Gutan on 8/4/15.
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

public class MainActivity extends FragmentActivity implements Observer {
    private static final String TAG = MainActivity.class.getName();
    public static final String PREFS_NAME = "MyPrefsFile";
    public static final int BURGER = 0;
    public static final int CLOSE = 1;
    public static final int BACK = 2;
    private static final int DEBUG = 1;
    private static final int RELEASE = 2;
    private static final float PAGE_INDICATOR_SCALE_UP = 1.3f;

    public static MainActivity app;
    public static boolean decoderFragmentOn;
    public static boolean scanResultFragmentOn;
    public static RelativeLayout pageIndicator;
    private ImageView pageIndicatorLeft;
    private ImageView pageIndicatorRight;
    private Map<String, Integer> burgerButtonMap;
    private Button burgerButton;
    public Button lockerButton;
    public TextView pay;
    public ProgressBar syncProgressBar;
    public TextView syncProgressText;
    private static ParallaxViewPager parallaxViewPager;
    private boolean doubleBackToExitPressedOnce;
    public static boolean beenThroughSavedInstanceMethod = false;
    public ViewFlipper viewFlipper;
    public ViewFlipper lockerPayFlipper;
    private RelativeLayout networkErrorBar;
    private final NetworkChangeReceiver receiver = new NetworkChangeReceiver();
    public static final Point screenParametersPoint = new Point();
    private int middleViewState = 0;
    private BroadcastReceiver mPowerKeyReceiver = null;
    private int middleBubbleBlocksCount = 0;
    private static int MODE = RELEASE;
    private TextView testnet;
    public SoftKeyboard softKeyboard;
    private RelativeLayout mainLayout;
    private FingerprintManager fingerprintManager;
    private ToastBlockShowTask toastBlockShowTask;
    private int runCount = 0;
    boolean deleteTxs = false;
    private BubbleTextVew middleBubble1;
    private BubbleTextVew middleBubble2;
    private BubbleTextVew middleBubbleBlocks;
    public BubbleTextVew qrBubble1;
    public BubbleTextVew qrBubble2;
    private ToastUpdater toastUpdater;

    public static boolean appInBackground = false;

    @Override
    public void onSaveInstanceState(Bundle outState, PersistableBundle outPersistentState) {
        beenThroughSavedInstanceMethod = true;
    }

    @Override
    protected void onCreate(Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);
        setContentView(R.layout.activity_main);

        //loading the native library

        app = this;
        initializeViews();

        printPhoneSpecs();

        new Thread(new Runnable() {
            @Override
            public void run() {
                setUpTheWallet();
            }
        }).start();

        registerScreenLockReceiver();

        getWindowManager().getDefaultDisplay().getSize(screenParametersPoint);

        checkDeviceRooted();

        new Thread(new Runnable() {
            @Override
            public void run() {
                if (isUsingCustomInputMethod())
                    runOnUiThread(new Runnable() {
                        @Override
                        public void run() {
                            ((BreadWalletApp) getApplication()).showCustomToast(app, "CUSTOM INPUT TYPE!", 300, Toast.LENGTH_LONG, 0);
                        }
                    });
            }
        }).start();

        if (((BreadWalletApp) getApplication()).isEmulatorOrDebug()) {
            MODE = DEBUG;
            Log.e(TAG, "DEBUG MODE!!!!!!");
        }
        testnet.setVisibility(MODE == DEBUG ? View.VISIBLE : View.GONE);

        InputMethodManager im = (InputMethodManager) getSystemService(Service.INPUT_METHOD_SERVICE);
        softKeyboard = new SoftKeyboard(mainLayout, im);

        pay.setOnClickListener(new View.OnClickListener() {
            @Override
            public void onClick(View v) {
                hideAllBubbles();
                String amountHolder = FragmentScanResult.currentCurrencyPosition == FragmentScanResult.BITCOIN_RIGHT ?
                        AmountAdapter.getRightValue() : AmountAdapter.getLeftValue();
                String addressHolder = FragmentScanResult.address;
                pay(addressHolder, amountHolder);
            }
        });

        viewFlipper.setOnClickListener(new View.OnClickListener() {
            @Override
            public void onClick(View v) {

                if (MiddleViewAdapter.getSyncing() && FragmentAnimator.level == 0) {
                    hideAllBubbles();
                    if (middleBubbleBlocksCount == 0) {
                        middleBubbleBlocksCount = 1;
                        middleBubbleBlocks.setVisibility(View.VISIBLE);
                        SpringAnimator.showBubbleAnimation(middleBubbleBlocks);
                        if (toastUpdater != null) {
                            toastUpdater.interrupt();
                        }
                        toastUpdater = null;
                        toastUpdater = new ToastUpdater();
                        toastUpdater.start();
                    } else {
                        middleBubbleBlocksCount = 0;
                        middleBubbleBlocks.setVisibility(View.GONE);
                    }
                    return;
                }
                if (FragmentAnimator.level == 0 && BreadWalletApp.unlocked) {
                    hideAllBubbles();
                    if (middleViewState == 0) {
                        middleBubble2.setVisibility(View.GONE);
                        middleBubble1.setVisibility(View.VISIBLE);
                        SpringAnimator.showBubbleAnimation(middleBubble1);
                        middleViewState++;
                    } else if (middleViewState == 1) {
                        middleBubble2.setVisibility(View.VISIBLE);
                        SpringAnimator.showBubbleAnimation(middleBubble2);
                        middleBubble1.setVisibility(View.GONE);
                        middleViewState++;
                    } else {
                        hideAllBubbles();
                        middleViewState = 0;
                    }

                }
            }
        });

        burgerButton.setOnClickListener(new View.OnClickListener() {
            @Override
            public void onClick(View v) {
                hideAllBubbles();
                Log.d(TAG, "Testing burger button_regular_blue! should work");
                SpringAnimator.showAnimation(burgerButton);
                if (FragmentAnimator.level > 1 || scanResultFragmentOn || decoderFragmentOn) {
                    Log.e(TAG, "CHECK:Should press back!");
                    onBackPressed();
                } else {
                    //check multi pressing availability here, because method onBackPressed does the checking as well.
                    if (FragmentAnimator.checkTheMultipressingAvailability()) {
                        FragmentAnimator.pressMenuButton(app, new FragmentSettingsAll());
                        Log.e(TAG, "CHECK:Should press menu");
                    }
                }
            }
        });
        lockerButton.setOnClickListener(new View.OnClickListener() {
            @TargetApi(Build.VERSION_CODES.LOLLIPOP)
            @Override
            public void onClick(View v) {
                SpringAnimator.showAnimation(lockerButton);
//                passwordDialogFragment.show(fm, TAG);
                if (KeyStoreManager.getPassCode(app) != 0)
                    ((BreadWalletApp) getApplication()).promptForAuthentication(app, BRConstants.AUTH_FOR_GENERAL, null);

            }
        });
        scaleView(pageIndicatorLeft, 1f, PAGE_INDICATOR_SCALE_UP, 1f, PAGE_INDICATOR_SCALE_UP);

        //check the txAdded callback functionality
//        BRWalletManager m = BRWalletManager.getInstance(app);
//        m.testWalletCallbacks();
//        Log.e(TAG, "the pubkey length is: " + m.getPublicKeyBuff().length);
//                Log.e(TAG, "FROM KEYSTORE PUBKEY: " + KeyStoreManager.getMasterPublicKey(app));
//                Log.e(TAG, "FROM KEYSTORE PHRASE: " + KeyStoreManager.getKeyStoreString(app));
//                Log.e(TAG, "FROM KEYSTORE CREATION TIME: " + KeyStoreManager.getWalletCreationTime(app));
//        createInvisibleLayoutTips();
    }

    private void checkDeviceRooted() {
        boolean hasBitcoin = CurrencyManager.getInstance(this).getBALANCE() > 0;
        if (RootUtil.isDeviceRooted()) {
            AlertDialog.Builder builder = new AlertDialog.Builder(this);
            builder.setTitle("DEVICE SECURITY COMPROMISED")
                    .setMessage("On a \'rooted\' device, any app can access any other app\'s keystore data (and steal your bitcoins)."
                            + (hasBitcoin ? "\nWipe this wallet immediately and restore on a secure device." : ""))
                    .setCancelable(false)
                    .setNegativeButton(getString(R.string.ok_button), new DialogInterface.OnClickListener() {
                        @Override
                        public void onClick(DialogInterface dialog, int which) {
                            dialog.cancel();
                        }
                    });
            AlertDialog alert = builder.create();
            alert.show();
        }
    }

    @Override
    protected void onRestart() {
        super.onRestart();  // Always call the superclass method first
        app = this;
        // Activity being restarted from stopped state
    }

    @Override
    protected void onResume() {
        super.onResume();
        appInBackground = false;
        middleViewState = 0;
        middleBubbleBlocksCount = 0;
        app = this;
        CurrencyManager currencyManager = CurrencyManager.getInstance(this);
        currencyManager.startTimer();
        currencyManager.deleteObservers();
        currencyManager.addObserver(this);
        MiddleViewAdapter.resetMiddleView(this, null);
        boolean isNetworkAvailable = CurrencyManager.getInstance(this).isNetworkAvailable(this);
        Log.e(TAG, "isNetworkAvailable: " + isNetworkAvailable);
        networkErrorBar.setVisibility(isNetworkAvailable ? View.GONE : View.VISIBLE);
        startStopReceiver(true);
        double currentSyncProgress = BRPeerManager.syncProgress();
        if (currentSyncProgress > 0 && currentSyncProgress < 1) {
            Log.e(TAG, "Worked! restarted the syncing!");
            BRPeerManager.startSyncingProgressThread();
        }
        askForPasscode();
    }

    @Override
    protected void onPause() {
        super.onPause();
        appInBackground = true;
        Log.e(TAG, "Activity onPause");
        startStopReceiver(false);
    }

    @Override
    protected void onStop() {
        super.onStop();
        CurrencyManager.getInstance(this).stopTimerTask();

    }

    @Override
    protected void onDestroy() {
        super.onDestroy();
        finish();
        FragmentAnimator.level = 0;
        CurrencyManager.getInstance(this).stopTimerTask();
        Log.e(TAG, "Activity Destroyed!");
        softKeyboard.unRegisterSoftKeyboardCallback();
        unregisterScreenLockReceiver();

    }

    /**
     * Initializes all the views and components
     */

    private void initializeViews() {
        pay = (TextView) findViewById(R.id.main_button_pay);
        mainLayout = (RelativeLayout) findViewById(R.id.main_layout);
        testnet = (TextView) findViewById(R.id.testnet);
        networkErrorBar = (RelativeLayout) findViewById(R.id.main_internet_status_bar);
        burgerButton = (Button) findViewById(R.id.main_button_burger);
        lockerPayFlipper = (ViewFlipper) findViewById(R.id.locker_pay_flipper);
        viewFlipper = (ViewFlipper) MainActivity.app.findViewById(R.id.middle_view_flipper);
        lockerButton = (Button) findViewById(R.id.main_button_locker);
        pageIndicator = (RelativeLayout) findViewById(R.id.main_pager_indicator);
        pageIndicatorLeft = (ImageView) findViewById(R.id.circle_indicator_left);
        syncProgressBar = (ProgressBar) findViewById(R.id.sync_progress_bar);
        syncProgressText = (TextView) findViewById(R.id.sync_progress_text);
//        middleView = findViewById(R.id.main_label_breadwallet);
        pageIndicatorRight = (ImageView) findViewById(R.id.circle_indicator_right);
        CustomPagerAdapter pagerAdapter = new CustomPagerAdapter(getFragmentManager());
        burgerButtonMap = new HashMap<>();
        parallaxViewPager = ((ParallaxViewPager) findViewById(R.id.main_viewpager));
        parallaxViewPager.setOverlapPercentage(0.99f).setAdapter(pagerAdapter);
        parallaxViewPager.setBackgroundResource(R.drawable.backgroundmain);
        burgerButtonMap.put("burger", R.drawable.burger);
        burgerButtonMap.put("close", R.drawable.x);
        burgerButtonMap.put("back", R.drawable.navigationback);
        middleBubble1 = (BubbleTextVew) findViewById(R.id.middle_bubble_tip1);
        middleBubble2 = (BubbleTextVew) findViewById(R.id.middle_bubble_tip2);
        middleBubbleBlocks = (BubbleTextVew) findViewById(R.id.middle_bubble_blocks);
        qrBubble1 = (BubbleTextVew) findViewById(R.id.qr_bubble1);
        qrBubble2 = (BubbleTextVew) findViewById(R.id.qr_bubble2);
//        myClipboard = (ClipboardManager) getSystemService(CLIPBOARD_SERVICE);

    }

    @Override
    public boolean onKeyDown(int keyCode, KeyEvent event) {
        if (keyCode == KeyEvent.KEYCODE_MENU) {
            if (FragmentAnimator.level > 1 || scanResultFragmentOn || decoderFragmentOn) {
                this.onBackPressed();
            } else if (FragmentAnimator.checkTheMultipressingAvailability()) {
                FragmentAnimator.pressMenuButton(app, new FragmentSettingsAll());
            }
        }
        // let the system handle all other key events
        return super.onKeyDown(keyCode, event);
    }

    @Override
    public void onBackPressed() {
        if (FragmentAnimator.checkTheMultipressingAvailability()) {
            Log.e(TAG, "onBackPressed!");
            if (FragmentAnimator.wipeWalletOpen) {
                FragmentAnimator.pressWipeWallet(this, new FragmentSettings());
                activityButtonsEnable(true);
                return;
            }
            //switch the level of fragments creation.
            switch (FragmentAnimator.level) {
                case 0:
                    if (doubleBackToExitPressedOnce) {
                        super.onBackPressed();
                        break;
                    }
                    if (decoderFragmentOn) {
                        FragmentAnimator.hideDecoderFragment();
                        break;
                    }
                    if (scanResultFragmentOn) {
                        FragmentAnimator.hideScanResultFragment();
                        break;
                    }
                    this.doubleBackToExitPressedOnce = true;
                    ((BreadWalletApp) getApplicationContext()).showCustomToast(this,
                            getResources().getString(R.string.mainactivity_press_back_again), 140,
                            Toast.LENGTH_SHORT, 0);
                    makeDoubleBackToExitPressedOnce();
                    break;
                case 1:
                    FragmentAnimator.pressMenuButton(this, new FragmentSettingsAll());
                    FragmentAnimator.hideDecoderFragment();
                    break;
                default:
                    FragmentAnimator.animateSlideToRight(this);
                    break;
            }
        }

    }

    /**
     * Sets the little circle indicator to the selected page
     *
     * @patam x The page for the indicator to be shown
     */

    public void setPagerIndicator(int x) {
        if (x == 0) {
            Log.d(TAG, "Left Indicator changed");
            pageIndicatorLeft.setImageResource(R.drawable.circle_indicator_active);
            pageIndicatorRight.setImageResource(R.drawable.circle_indicator);
            scaleView(pageIndicatorLeft, 1f, PAGE_INDICATOR_SCALE_UP, 1f, PAGE_INDICATOR_SCALE_UP);
            scaleView(pageIndicatorRight, PAGE_INDICATOR_SCALE_UP, 1f, PAGE_INDICATOR_SCALE_UP, 1f);
        } else if (x == 1) {
            Log.d(TAG, "Right Indicator changed");
            pageIndicatorLeft.setImageResource(R.drawable.circle_indicator);
            pageIndicatorRight.setImageResource(R.drawable.circle_indicator_active);
            scaleView(pageIndicatorRight, 1f, PAGE_INDICATOR_SCALE_UP, 1f, PAGE_INDICATOR_SCALE_UP);
            scaleView(pageIndicatorLeft, PAGE_INDICATOR_SCALE_UP, 1f, PAGE_INDICATOR_SCALE_UP, 1f);
        } else {
            Log.e(TAG, "Something went wrong setting the circle pageIndicator");
        }
    }

    public void setBurgerButtonImage(int x) {
        String item = null;
        switch (x) {
            case 0:
                item = "burger";
                break;
            case 1:
                item = "close";
                break;
            case 2:
                item = "back";
                break;
        }
        if (item != null && item.length() > 0)
            burgerButton.setBackgroundResource(burgerButtonMap.get(item));
    }

    public void activityButtonsEnable(final boolean b) {
        runOnUiThread(new Runnable() {
            @Override
            public void run() {
                if (!BreadWalletApp.unlocked) {
                    lockerButton.setVisibility(b ? View.VISIBLE : View.INVISIBLE);
                    lockerButton.setClickable(b);
                } else {
                    lockerButton.setVisibility(View.INVISIBLE);
                    lockerButton.setClickable(false);
                }
                parallaxViewPager.setClickable(b);
                viewFlipper.setVisibility(b ? View.VISIBLE : View.INVISIBLE);
                burgerButton.setVisibility(b ? View.VISIBLE : View.INVISIBLE);
                burgerButton.setClickable(b);
            }
        });

    }

    private void scaleView(View v, float startScaleX, float endScaleX, float startScaleY, float endScaleY) {
        Animation anim = new ScaleAnimation(
                startScaleX, endScaleX, // Start and end values for the X axis scaling
                startScaleY, endScaleY, // Start and end values for the Y axis scaling
                Animation.RELATIVE_TO_SELF, 0.5f, // Pivot point of X scaling
                Animation.RELATIVE_TO_SELF, 0.5f); // Pivot point of Y scaling
        anim.setFillAfter(true); // Needed to keep the result of the animation
        v.startAnimation(anim);
    }

    private void makeDoubleBackToExitPressedOnce() {
        new Handler().postDelayed(new Runnable() {
            @Override
            public void run() {
                doubleBackToExitPressedOnce = false;
            }
        }, 1000);
    }

    private void startStopReceiver(boolean b) {
        if (b) {
            this.registerReceiver(receiver, new IntentFilter("android.net.conn.CONNECTIVITY_CHANGE"));
        } else {
            this.unregisterReceiver(receiver);
        }
    }

    public void pay(final String addressHolder, String amountHolder) {
        if (addressHolder == null || amountHolder == null) return;
        if (addressHolder.length() < 20) return;
        final Double amountAsDouble = Double.parseDouble(amountHolder);
        if (amountAsDouble <= 0) return;
        Log.e(TAG, "*********Sending: " + amountHolder + " to: " + addressHolder);
        final CurrencyManager cm = CurrencyManager.getInstance(this);

        if (cm.isNetworkAvailable(this)) {
            final BRWalletManager m = BRWalletManager.getInstance(this);
            byte[] tmpTx = m.tryTransaction(addressHolder, cm.getSatoshisFromBits(Math.round(amountAsDouble)));
            double feeForTx = cm.getBitsFromSatoshi(m.feeForTransaction(addressHolder, cm.getSatoshisFromBits(Math.round(amountAsDouble))));
            if (tmpTx == null && amountAsDouble <= cm.getBitsFromSatoshi(cm.getBALANCE()) && amountAsDouble > 0) {

                final double maxAmountDouble = cm.getBitsFromSatoshi(m.getMaxOutputAmount());
                Log.e(TAG, "maxAmountDouble: " + maxAmountDouble);
                final double amountToReduce = amountAsDouble - maxAmountDouble;
//                String strToReduce = String.valueOf(amountToReduce);
                final AlertDialog.Builder builder = new AlertDialog.Builder(this);

                builder.setMessage(String.format("reduce payment amount by %s to accommodate the bitcoin network fee?", cm.getFormattedCurrencyString("BTC", String.valueOf(amountToReduce))))
                        .setTitle("insufficient funds for bitcoin network fee")
                        .setCancelable(false)
                        .setNegativeButton(getString(R.string.cancel), new DialogInterface.OnClickListener() {
                            @Override
                            public void onClick(DialogInterface dialog, int which) {
                                dialog.cancel();
                            }
                        })
                        .setPositiveButton("confirm", new DialogInterface.OnClickListener() {
                            public void onClick(DialogInterface dialog, int id) {
                                byte[] tmpTx2 = m.tryTransaction(addressHolder, cm.getSatoshisFromBits(Math.round(amountAsDouble)));
                                if (tmpTx2 != null) {
                                    PostAuthenticationProcessor.getInstance().setTmpTx(tmpTx2);
                                    confirmPay(new PaymentRequestEntity(new String[]{addressHolder}, Math.round(amountAsDouble - amountToReduce), null));
                                } else {
                                    Log.e(TAG, "tmpTxObject2 is null!!!");
                                }
                            }
                        });
                AlertDialog alert = builder.create();
                alert.show();
                return;
            }
            PostAuthenticationProcessor.getInstance().setTmpTx(tmpTx);
            Log.e(TAG, "pay >>>> feeForTx: " + feeForTx + ", amountAsDouble: " + amountAsDouble +
                    ", CurrencyManager.getInstance(this).getBALANCE(): " + cm.getBitsFromSatoshi(cm.getBALANCE()));
            if (feeForTx != 0 && amountAsDouble + feeForTx < cm.getBitsFromSatoshi(cm.getBALANCE())) {

                confirmPay(new PaymentRequestEntity(new String[]{addressHolder}, Math.round(amountAsDouble), null));
            } else {
                AlertDialog.Builder builder = new AlertDialog.Builder(this);
                builder.setMessage(String.format(Locale.getDefault(), "insufficient funds to send: %s", cm.getFormattedCurrencyString("BTC", String.valueOf(amountAsDouble))))
                        .setCancelable(false)
                        .setPositiveButton("ok", new DialogInterface.OnClickListener() {
                            public void onClick(DialogInterface dialog, int id) {
                                dialog.cancel();
                            }
                        });
                AlertDialog alert = builder.create();
                alert.show();
            }
        } else {
            AlertDialog.Builder builder = new AlertDialog.Builder(this);
            builder.setMessage("No internet connection!")
                    .setCancelable(false)
                    .setPositiveButton("ok", new DialogInterface.OnClickListener() {
                        public void onClick(DialogInterface dialog, int id) {
                            dialog.cancel();
                        }
                    });
            AlertDialog alert = builder.create();
            alert.show();
        }

    }

    public void request(View view) {
        SpringAnimator.showAnimation(view);
        Intent intent;
        String tempAmount = FragmentScanResult.currentCurrencyPosition == FragmentScanResult.BITCOIN_RIGHT ?
                AmountAdapter.getRightValue() : AmountAdapter.getLeftValue();
        BRWalletManager m = BRWalletManager.getInstance(this);
        double minAmount = CurrencyManager.getInstance(this).getBitsFromSatoshi(m.getMinOutputAmount());
        if (Double.valueOf(tempAmount) < minAmount) {
            ((BreadWalletApp) getApplication()).showCustomDialog(getString(R.string.warning), "The amount cannot be less than ƀ" + minAmount, getString(R.string.ok));
            return;
        }
        String strAmount = String.valueOf(new BigDecimal(tempAmount).divide(new BigDecimal("1000000")));
        SharedPreferences prefs = getSharedPreferences(PREFS_NAME, Context.MODE_PRIVATE);
        String testTemp = prefs.getString(PREFS_NAME, "");

        intent = new Intent(this, RequestQRActivity.class);
        intent.putExtra(BRConstants.INTENT_EXTRA_REQUEST_AMOUNT, strAmount);
        intent.putExtra(BRConstants.INTENT_EXTRA_REQUEST_ADDRESS, testTemp);
        startActivity(intent);
        overridePendingTransition(R.anim.fade_in, R.anim.fade_out);
        FragmentAnimator.hideScanResultFragment();
    }

    @Override
    protected void onActivityResult(int requestCode, int resultCode, Intent data) {
        switch (requestCode) {
            case BRConstants.SHOW_PHRASE_REQUEST_CODE:
                if (resultCode == RESULT_OK) {
                    PostAuthenticationProcessor.getInstance().onShowPhraseAuth(this);
                } else {
                    KeyStoreManager.showAuthenticationScreen(this, requestCode);
                }
                break;

            case BRConstants.PAY_REQUEST_CODE:
                if (resultCode == RESULT_OK) {
                    PostAuthenticationProcessor.getInstance().onPublishTxAuth(this);
                } else {
                    KeyStoreManager.showAuthenticationScreen(this, requestCode);
                }
                break;
        }
    }

    @Override
    public void onRequestPermissionsResult(int requestCode, @NonNull String[] permissions, @NonNull int[] grantResults) {
        Log.e(TAG, "********************** onActivityResult >>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>> " + requestCode);
        switch (requestCode) {
            case BRConstants.CAMERA_REQUEST_ID: {
                // If request is cancelled, the result arrays are empty.
                if (grantResults.length > 0
                        && grantResults[0] == PackageManager.PERMISSION_GRANTED) {

                    FragmentAnimator.animateDecoderFragment();
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
        super.onRequestPermissionsResult(requestCode, permissions, grantResults);

    }

    public boolean isSoftKeyboardShown() {
        int[] location = new int[2];
        viewFlipper.getLocationOnScreen(location);
        boolean isShown = location[1] < 0;
        Log.e(TAG, "The keyboard is shown: " + isShown + " y location: " + location[1]);
        return isShown;
    }

    public void confirmPay(final PaymentRequestEntity request) {
        SharedPreferences settings;
        boolean certified = false;
        if (request.cn != null && request.cn.length() != 0) {
            certified = true;
        }
        StringBuilder allAddresses = new StringBuilder();
        for (String s : request.addresses) {
            allAddresses.append(s + ", ");
        }
        allAddresses.delete(allAddresses.length() - 2, allAddresses.length());
        String certification = "";
        if (certified) {
            certification = "certified: " + request.cn + "\n";
            allAddresses = new StringBuilder();
        }

        //DecimalFormat decimalFormat = new DecimalFormat("0.00");
        settings = getSharedPreferences(MainActivity.PREFS_NAME, 0);
        String iso = settings.getString(FragmentCurrency.CURRENT_CURRENCY, "USD");
        float rate = settings.getFloat(FragmentCurrency.RATE, 1.0f);
        String amount = String.valueOf(request.amount);
        CurrencyManager cm = CurrencyManager.getInstance(this);
        BRWalletManager m = BRWalletManager.getInstance(this);
        final double feeForTx = cm.getBitsFromSatoshi(m.feeForTransaction(request.addresses[0], cm.getSatoshisFromBits(request.amount)));
        final double total = Long.valueOf(amount) + feeForTx;
        final String message = certification + allAddresses.toString() + "\n\n" + "amount: " + cm.getFormattedCurrencyString("BTC", String.valueOf(request.amount))
                + " (" + cm.getExchangeForAmount(rate, iso, amount) + ")" + "\nnetwork fee: +" + cm.getFormattedCurrencyString("BTC", String.valueOf(feeForTx))
                + " (" + cm.getExchangeForAmount(rate, iso, String.valueOf(feeForTx)) + ")" + "\ntotal: " + cm.getFormattedCurrencyString("BTC", String.valueOf(total))
                + " (" + cm.getExchangeForAmount(rate, iso, String.valueOf(total)) + ")";

//        ((BreadWalletApp) getApplication()).showCustomDialog("payment info", certification + allAddresses.toString() +
//                "\n\n" + "amount " + CurrencyManager.getInstance(this).getFormattedCurrencyString("BTC", String.valueOf(request.amount / 100))
//                + " (" + CurrencyManager.getInstance(this).getFormattedCurrencyString(iso, amount) + ")", "send");
        double minOutput = BRWalletManager.getInstance(this).getMinOutputAmount() / 100d;
        if (request.amount < minOutput) {
            final String bitcoinMinMessage = String.format("bitcoin payments can't be less than ƀ%.2f", minOutput);
            runOnUiThread(new Runnable() {
                @Override
                public void run() {
                    new android.app.AlertDialog.Builder(app)
                            .setTitle(getString(R.string.payment_failed))
                            .setMessage(bitcoinMinMessage)
                            .setPositiveButton(getString(R.string.ok), new DialogInterface.OnClickListener() {
                                public void onClick(DialogInterface dialog, int which) {
                                    dialog.dismiss();
                                }
                            })
                            .setIcon(android.R.drawable.ic_dialog_alert)
                            .show();
                }
            });

            return;
        }

        runOnUiThread(new Runnable() {
            @Override
            public void run() {
                new android.app.AlertDialog.Builder(app)
                        .setTitle(getString(R.string.payment_info))
                        .setMessage(message)
                        .setPositiveButton(getString(R.string.send), new DialogInterface.OnClickListener() {
                            public void onClick(DialogInterface dialog, int which) {
                                ((BreadWalletApp) getApplicationContext()).promptForAuthentication(app, BRConstants.AUTH_FOR_PAY, request);
                            }
                        })
                        .setIcon(android.R.drawable.ic_dialog_alert)
                        .show();
            }
        });
    }

    @Override
    public void update(Observable observable, Object data) {
        MiddleViewAdapter.resetMiddleView(this, null);
    }


    private void setUpTheWallet() {

        BRWalletManager m = BRWalletManager.getInstance(this);
        final BRPeerManager pm = BRPeerManager.getInstance(this);

//        String phrase = KeyStoreManager.getKeyStoreString(this);
//        if (phrase == null) return;
//        String normalizedPhrase = Normalizer.normalize(phrase, Normalizer.Form.NFKD);
//        m.getMasterPubKey(normalizedPhrase);

        SQLiteManager sqLiteManager = SQLiteManager.getInstance(this);

//        CustomLogger.LogThis("setUpTheWallet: number of transactions from sqlite: ",
//                String.valueOf(transactions.size()),
//                " transactionCount: ", String.valueOf(transactionsCount), " blocksCount: ",
//                String.valueOf(blocksCount), " peersCount: ", String.valueOf(peersCount));

        if (!m.isCreated()) {
            List<BRTransactionEntity> transactions = sqLiteManager.getTransactions();
            int transactionsCount = transactions.size();
            if (transactionsCount > 0) {
                m.createTxArrayWithCount(transactionsCount);
                for (BRTransactionEntity entity : transactions) {
                    m.putTransaction(entity.getBuff(), entity.getBlockheight(), entity.getTimestamp());
                }
            }

            byte[] pubkeyEncoded = KeyStoreManager.getMasterPublicKey(this);
//            pubkeyEncoded = null;
            //todo TEST THAT
            if (pubkeyEncoded == null || pubkeyEncoded.length == 0) {
                ((BreadWalletApp) getApplication()).showCustomToast(this, "The KeyStore is temporary unavailable, please try again later",
                        screenParametersPoint.y / 2, Toast.LENGTH_LONG, 0);
                runOnUiThread(new Runnable() {
                    @Override
                    public void run() {
                        new Handler().postDelayed(new Runnable() {
                            @Override
                            public void run() {
                                finish();
                            }
                        }, 3500);
                    }
                });

                return;
            }
            //Save the first address for future check
            m.createWallet(transactionsCount, pubkeyEncoded);
            String firstAddress = BRWalletManager.getFirstAddress(pubkeyEncoded);
            SharedPreferences prefs = getSharedPreferences(MainActivity.PREFS_NAME, Context.MODE_PRIVATE);
            SharedPreferences.Editor editor = prefs.edit();
            editor.putString(BRConstants.FIRST_ADDRESS, firstAddress);
            editor.apply();
        }

        if (!pm.isCreated()) {
            List<BRMerkleBlockEntity> blocks = sqLiteManager.getBlocks();
            List<BRPeerEntity> peers = sqLiteManager.getPeers();
            final int blocksCount = blocks.size();
            final int peersCount = peers.size();
            if (blocksCount > 0) {
                pm.createBlockArrayWithCount(blocksCount);
                for (BRMerkleBlockEntity entity : blocks) {
                    pm.putBlock(entity.getBuff(), entity.getBlockHeight());
                }
            }

            if (peersCount > 0) {
                pm.createPeerArrayWithCount(peersCount);
                for (BRPeerEntity entity : peers) {
                    pm.putPeer(entity.getAddress(), entity.getPort(), entity.getTimeStamp());
                }
            }

            Log.e(TAG, "blocksCount before connecting: " + blocksCount);
            Log.e(TAG, "peersCount before connecting: " + peersCount);

            int walletTimeString = KeyStoreManager.getWalletCreationTime(this);
            final int earliestKeyTime = walletTimeString != 0 ? walletTimeString : 0;
            //TODO take off
//            final long tempTime = 1454736431;
            Log.e(TAG, "earliestKeyTime before connecting: " + earliestKeyTime);
            pm.createAndConnect(earliestKeyTime > 0 ? earliestKeyTime : 0, blocksCount, peersCount);
            Log.e(TAG, "some");
        }
    }

    private void registerScreenLockReceiver() {
        final IntentFilter theFilter = new IntentFilter();
        /** System Defined Broadcast */
        theFilter.addAction(Intent.ACTION_SCREEN_ON);
        theFilter.addAction(Intent.ACTION_SCREEN_OFF);

        mPowerKeyReceiver = new BroadcastReceiver() {
            @Override
            public void onReceive(Context context, Intent intent) {
                String strAction = intent.getAction();

                if (strAction.equals(Intent.ACTION_SCREEN_OFF)) {
                    ((BreadWalletApp) getApplicationContext()).setUnlocked(false);
                    Log.e(TAG, ">>>>>>>>onReceive>>>>>>>>> the screen is locked!");
                }
            }
        };

        getApplicationContext().registerReceiver(mPowerKeyReceiver, theFilter);
    }

    private void unregisterScreenLockReceiver() {
        int apiLevel = Build.VERSION.SDK_INT;

        if (apiLevel >= 7) {
            try {
                getApplicationContext().unregisterReceiver(mPowerKeyReceiver);
            } catch (IllegalArgumentException e) {
                mPowerKeyReceiver = null;
            }
        } else {
            getApplicationContext().unregisterReceiver(mPowerKeyReceiver);
            mPowerKeyReceiver = null;
        }
    }

    private void askForPasscode() {
        final int pass = KeyStoreManager.getPassCode(app);
        if (pass == 0) {
            new Handler().post(new Runnable() {
                @Override
                public void run() {
                    if (app != null) {
                        Log.e(TAG, "PASSCODE: " + pass);
                        new PassCodeTask(app).start();
                    }
                }
            });
        }

    }

    public void hideAllBubbles() {

        if (middleBubble1 != null)
            middleBubble1.setVisibility(View.GONE);
        if (middleBubble2 != null)
            middleBubble2.setVisibility(View.GONE);
        if (middleBubbleBlocks != null)
            middleBubbleBlocks.setVisibility(View.GONE);
        if (qrBubble2 != null)
            qrBubble2.setVisibility(View.GONE);
        if (qrBubble1 != null)
            qrBubble1.setVisibility(View.GONE);

    }

    public void showHideSyncProgressViews(boolean b) {
        syncProgressBar.setVisibility(b ? View.VISIBLE : View.GONE);
        syncProgressText.setVisibility(b ? View.VISIBLE : View.GONE);
    }

//    private native void cTests();
//
//    private void createInvisibleLayoutTips() {
//        // Creating a new RelativeLayout
//        final RelativeLayout mask = new RelativeLayout(this);
//
//        // Defining the RelativeLayout layout parameters.
//        // In this case I want to fill its parent
//        RelativeLayout.LayoutParams rlp = new RelativeLayout.LayoutParams(
//                RelativeLayout.LayoutParams.MATCH_PARENT,
//                RelativeLayout.LayoutParams.MATCH_PARENT);
//
//        // Adding the TextView to the RelativeLayout as a child
//        mask.setLayoutParams(rlp);
//        int position = 0;  // position of the tab you want
//        CustomPagerAdapter.adapter.getItem()
//        showTip();
//
//        mask.setOnClickListener(new View.OnClickListener() {
//            @Override
//            public void onClick(View v) {
//                if (tipsCount >= 6) {
//                    mainLayout.removeView(mask);
//                }
//                showTip();
//            }
//        });
//        mainLayout.addView(mask);
//
//    }
//
//    private void showTip() {
//        if (tipsCount == 0)
//            ((BreadWalletApp) getApplicationContext()).showCustomToast(this, getString(R.string.middle_view_tip_first),
//                    MainActivity.screenParametersPoint.y / 5, Toast.LENGTH_LONG, 0);
//        if (tipsCount == 1)
//            ((BreadWalletApp) getApplicationContext()).showCustomToast(this, getString(R.string.middle_view_tip_second),
//                    MainActivity.screenParametersPoint.y / 4, Toast.LENGTH_LONG, 0);
//        if (tipsCount == 2)
//            ((BreadWalletApp) getApplicationContext()).showCustomToast(this, getString(R.string.toast_qr_tip),
//                    MainActivity.screenParametersPoint.y / 3, Toast.LENGTH_LONG, 0);
//        if (tipsCount == 3)
//            ((BreadWalletApp) getApplicationContext()).showCustomToast(this, getString(R.string.toast_address_tip),
//                    MainActivity.screenParametersPoint.y / 2, Toast.LENGTH_LONG, 0);
//        if (tipsCount == 4)
//            ((BreadWalletApp) getApplicationContext()).showCustomToast(this, getString(R.string.scan_qr_code_tip),
//                    MainActivity.screenParametersPoint.y, Toast.LENGTH_LONG, 0);
//        if (tipsCount == 5)
//            ((BreadWalletApp) getApplicationContext()).showCustomToast(this, getString(R.string.clipboard_tip),
//                    MainActivity.screenParametersPoint.y / 5, Toast.LENGTH_LONG, 0);
//        tipsCount++;
//    }

    private void printPhoneSpecs() {
        String specsTag = "PHONE SPECS";
        Log.e(specsTag, "");
        Log.e(specsTag, "***************************PHONE SPECS***************************");

        Log.e(specsTag, "* screen X: " + screenParametersPoint.x + " , screen Y: " + screenParametersPoint.y);

        Log.e(specsTag, "* Build.CPU_ABI: " + Build.CPU_ABI);

        Runtime rt = Runtime.getRuntime();
        long maxMemory = rt.maxMemory();
        Log.e(specsTag, "* maxMemory:" + Long.toString(maxMemory));
        Log.e(specsTag, "----------------------------PHONE SPECS----------------------------");
        Log.e(specsTag, "");
    }

    public class ToastUpdater extends Thread {
        public void run() {
            while (middleBubbleBlocks.getVisibility() == View.VISIBLE) {
                runOnUiThread(new Runnable() {
                    @Override
                    public void run() {
                        android.os.Process.setThreadPriority(android.os.Process.THREAD_PRIORITY_BACKGROUND);
                        String currBlock = String.valueOf(BRPeerManager.getCurrentBlockHeight());
                        String latestBlockKnown = String.valueOf(BRPeerManager.getEstimatedBlockHeight());
                        String formattedBlockInfo = String.format("block #%s of %s", currBlock, latestBlockKnown);
                        middleBubbleBlocks.setText(formattedBlockInfo);
                    }
                });
                try {
                    Thread.sleep(500);
                } catch (InterruptedException e) {
                    e.printStackTrace();
                }
            }
        }
    }

    public boolean isUsingCustomInputMethod() {
        InputMethodManager imm = (InputMethodManager) getSystemService(
                Context.INPUT_METHOD_SERVICE);
        List<InputMethodInfo> mInputMethodProperties = imm.getEnabledInputMethodList();
        final int N = mInputMethodProperties.size();
        for (int i = 0; i < N; i++) {
            InputMethodInfo imi = mInputMethodProperties.get(i);
            if (imi.getId().equals(
                    Settings.Secure.getString(getContentResolver(),
                            Settings.Secure.DEFAULT_INPUT_METHOD))) {
                if ((imi.getServiceInfo().applicationInfo.flags &
                        ApplicationInfo.FLAG_SYSTEM) == 0) {
                    return true;
                }
            }
        }
        return false;
    }

}