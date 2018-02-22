package com.breadwallet.tools.adapter;

import android.app.Activity;
import android.content.Context;
import android.support.constraint.ConstraintLayout;
import android.support.v7.widget.RecyclerView;
import android.util.Log;
import android.view.LayoutInflater;
import android.view.View;
import android.view.ViewGroup;
import android.widget.ImageButton;
import android.widget.ImageView;
import android.widget.ProgressBar;
import android.widget.RelativeLayout;
import android.widget.TextView;

import com.breadwallet.R;
import com.breadwallet.presenter.customviews.BRText;
import com.breadwallet.presenter.entities.TxUiHolder;
import com.breadwallet.tools.manager.BRSharedPrefs;
import com.breadwallet.tools.manager.TxManager;
import com.breadwallet.tools.threads.BRExecutor;
import com.breadwallet.tools.util.BRDateUtil;
import com.breadwallet.tools.util.CurrencyUtils;
import com.breadwallet.tools.util.Utils;
import com.breadwallet.wallet.WalletsMaster;
import com.breadwallet.wallet.abstracts.BaseWalletManager;
import com.platform.tools.KVStoreManager;

import java.math.BigDecimal;
import java.util.ArrayList;
import java.util.Date;
import java.util.List;


/**
 * BreadWallet
 * <p>
 * Created by Mihail Gutan <mihail@breadwallet.com> on 7/27/15.
 * Copyright (c) 2016 breadwallet LLC
 * <p>
 * Permission is hereby granted, free of charge, to any person obtaining a copy
 * of this software and associated documentation files (the "Software"), to deal
 * in the Software without restriction, including without limitation the rights
 * to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
 * copies of the Software, and to permit persons to whom the Software is
 * furnished to do so, subject to the following conditions:
 * <p>
 * The above copyright notice and this permission notice shall be included in
 * all copies or substantial portions of the Software.
 * <p>
 * THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
 * IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
 * FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
 * AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
 * LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
 * OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
 * THE SOFTWARE.
 */

public class TransactionListAdapter extends RecyclerView.Adapter<RecyclerView.ViewHolder> {
    public static final String TAG = TransactionListAdapter.class.getName();

    private final Context mContext;
    private final int txResId;
    private final int promptResId;
    private List<TxUiHolder> backUpFeed;
    private List<TxUiHolder> itemFeed;
    //    private Map<String, TxMetaData> mds;

    private final int txType = 0;
    private final int promptType = 1;
    private boolean updatingReverseTxHash;
    private boolean updatingData;

//    private boolean updatingMetadata;

    public TransactionListAdapter(Context mContext, List<TxUiHolder> items) {
        this.txResId = R.layout.wallet_tx_item;
        this.promptResId = R.layout.prompt_item;
        this.mContext = mContext;
        items = new ArrayList<>();
        init(items);
//        updateMetadata();
    }

    public void setItems(List<TxUiHolder> items) {
        init(items);
    }

    private void init(List<TxUiHolder> items) {
        if (items == null) items = new ArrayList<>();
        if (itemFeed == null) itemFeed = new ArrayList<>();
        if (backUpFeed == null) backUpFeed = new ArrayList<>();
//        if (mds == null) mds = new HashMap<>();
//        boolean updateMetadata = items.size() != 0 && backUpFeed.size() != items.size() && BRSharedPrefs.getAllowSpend(mContext);
        this.itemFeed = items;
        this.backUpFeed = items;
//        if (updateMetadata)
//            updateMetadata();
    }

    public void updateData() {
        if (updatingData) return;
        BRExecutor.getInstance().forLightWeightBackgroundTasks().execute(new Runnable() {
            @Override
            public void run() {
                long s = System.currentTimeMillis();
                List<TxUiHolder> newItems = new ArrayList<>(itemFeed);
                TxUiHolder item;
                for (int i = 0; i < newItems.size(); i++) {
                    item = newItems.get(i);
                    item.metaData = KVStoreManager.getInstance().getTxMetaData(mContext, item.getTxHash());
                    item.txReversed = Utils.reverseHex(Utils.bytesToHex(item.getTxHash()));

                }
                backUpFeed = newItems;
                String log = String.format("newItems: %d, took: %d", newItems.size(), (System.currentTimeMillis() - s));
                Log.e(TAG, "updateData: " + log);
                updatingData = false;
            }
        });

    }


    public List<TxUiHolder> getItems() {
        return itemFeed;
    }

    @Override
    public RecyclerView.ViewHolder onCreateViewHolder(ViewGroup parent, int viewType) {
        // inflate the layout
        LayoutInflater inflater = ((Activity) mContext).getLayoutInflater();
        if (viewType == txType)
            return new TxHolder(inflater.inflate(txResId, parent, false));
        else if (viewType == promptType)
            return new PromptHolder(inflater.inflate(promptResId, parent, false));
        return null;
    }

    @Override
    public void onBindViewHolder(RecyclerView.ViewHolder holder, int position) {
        switch (holder.getItemViewType()) {
            case txType:
                setTexts((TxHolder) holder, position);
                break;
            case promptType:
                setPrompt((PromptHolder) holder);
                break;
        }

    }

    @Override
    public int getItemViewType(int position) {
        if (position == 0 && TxManager.getInstance().currentPrompt != null) {
            return promptType;
        } else {
            return txType;
        }
    }

    @Override
    public int getItemCount() {
        return TxManager.getInstance().currentPrompt == null ? itemFeed.size() : itemFeed.size() + 1;
    }

    private void setTexts(final TxHolder convertView, int position) {
        BaseWalletManager wallet = WalletsMaster.getInstance(mContext).getCurrentWallet(mContext);
        TxUiHolder item = itemFeed.get(TxManager.getInstance().currentPrompt == null ? position : position - 1);
        item.metaData = KVStoreManager.getInstance().getTxMetaData(mContext, item.getTxHash());
        //String commentString = (item.metaData == null || item.metaData.comment == null) ? "" : item.metaData.comment;
        //convertView.comment.setText(commentString);
       /* if (commentString.isEmpty()) {
            convertView.constraintLayout.removeView(convertView.comment);
            ConstraintSet set = new ConstraintSet();
            set.clone(convertView.constraintLayout);
            int px = (int) TypedValue.applyDimension(TypedValue.COMPLEX_UNIT_DIP, 8, mContext.getResources().getDisplayMetrics());
            set.connect(R.id.status, ConstraintSet.TOP, convertView.toFrom.getId(), ConstraintSet.BOTTOM, px);
            // Apply the changes
            set.applyTo(convertView.constraintLayout);
        } else {
            if (convertView.constraintLayout.indexOfChild(convertView.comment) == -1)
                convertView.constraintLayout.addView(convertView.comment);
            ConstraintSet set = new ConstraintSet();
            set.clone(convertView.constraintLayout);
            int px = (int) TypedValue.applyDimension(TypedValue.COMPLEX_UNIT_DIP, 8, mContext.getResources().getDisplayMetrics());
            set.connect(R.id.status, ConstraintSet.TOP, convertView.comment.getId(), ConstraintSet.BOTTOM, px);
            // Apply the changes
            set.applyTo(convertView.constraintLayout);
            convertView.comment.requestLayout();
        }*/

        boolean received = item.getSent() == 0;
        //convertView.arrowIcon.setImageResource(received ? R.drawable.arrow_down_bold_circle : R.drawable.arrow_up_bold_circle);
        //convertView.mainLayout.setBackgroundResource(getResourceByPos(position));

        String txAction;
        if (received) {
            txAction = "received via " + item.getFrom()[0];
            convertView.transactionAmount.setTextColor(mContext.getResources().getColor(R.color.transaction_amount_received_color, null));
        } else {

            txAction = "sent to " + item.getTo()[0];
        }

        convertView.transactionDetail.setText(txAction);

        // Set transaction amount
        long transactionAmount = item.getAmount();
        long satoshisAmount = received ? item.getReceived() : (item.getSent() - item.getReceived());
        String iso = BRSharedPrefs.getPreferredFiatIso(mContext);


        if (received) {
            convertView.transactionAmount.setText(CurrencyUtils.getFormattedAmount(mContext, iso, WalletsMaster.getInstance(mContext).getCurrentWallet(mContext).getFiatForSmallestCrypto(mContext, new BigDecimal(satoshisAmount))));
        } else {
            convertView.transactionAmount.setText("-" + CurrencyUtils.getFormattedAmount(mContext, iso, WalletsMaster.getInstance(mContext).getCurrentWallet(mContext).getFiatForSmallestCrypto(mContext, new BigDecimal(satoshisAmount))));

        }

        //convertView.sentReceived.setText(received ? mContext.getString(R.string.TransactionDetails_received, "") : mContext.getString(R.string.TransactionDetails_sent, ""));
        //convertView.toFrom.setText(received ? String.format(mContext.getString(R.string.TransactionDetails_from), "") : String.format(mContext.getString(R.string.TransactionDetails_to), ""));
//        final String addr = position == 1? "1HB5XMLmzFVj8ALj6mfBsbifRoD4miY36v" : "35SwXe97aPRUsoaUTH1Dr3SB7JptH39pDZ"; //testing
        final String addr = item.getTo()[0];
        //convertView.account.setText(addr);
        int blockHeight = item.getBlockHeight();
        int confirms = blockHeight == Integer.MAX_VALUE ? 0 : BRSharedPrefs.getLastBlockHeight(mContext, wallet.getIso(mContext)) - blockHeight + 1;

        int level = 0;
        if (confirms <= 0) {
            long relayCount = wallet.getPeerManager().getRelayCount(item.getTxHash());
            if (relayCount <= 0)
                level = 0;
            else if (relayCount == 1)
                level = 1;
            else
                level = 2;
        } else {
            if (confirms == 1)
                level = 3;
            else if (confirms == 2)
                level = 4;
            else if (confirms == 3)
                level = 5;
            else
                level = 6;
        }
        boolean availableForSpend = false;
        String sentReceived = received ? "Receiving" : "Sending";
        String percentage = "";
        switch (level) {
            case 0:
                percentage = "0%";
                break;
            case 1:
                percentage = "20%";
                break;
            case 2:
                percentage = "40%";
                availableForSpend = true;
                break;
            case 3:
                percentage = "60%";
                availableForSpend = true;
                break;
            case 4:
                percentage = "80%";
                availableForSpend = true;
                break;
            case 5:
                percentage = "100%";
                availableForSpend = true;
                break;
        }
        if (availableForSpend && received) {
            //convertView.status_2.setText(mContext.getString(R.string.Transaction_available));
        } else {
            //convertView.constraintLayout.removeView(convertView.status_2);
            //ConstraintSet set = new ConstraintSet();
//            set.clone(convertView.constraintLayout);
//            int px = (int) TypedValue.applyDimension(TypedValue.COMPLEX_UNIT_DIP, 16, mContext.getResources().getDisplayMetrics());
//
//            set.connect(R.id.status, ConstraintSet.BOTTOM, convertView.constraintLayout.getId(), ConstraintSet.BOTTOM, px);
//            // Apply the changes
//            set.applyTo(convertView.constraintLayout);
        }
        if (level == 6) {
            //convertView.status.setText(mContext.getString(R.string.Transaction_complete));
        } else {
            //convertView.status.setText(String.format("%s - %s", sentReceived, percentage));
        }

        //if (!item.isValid())
        //convertView.status.setText(mContext.getString(R.string.Transaction_invalid));


        boolean isCryptoPreferred = BRSharedPrefs.isCryptoPreferred(mContext);
        //iso = isCryptoPreferred ? wallet.getIso(mContext) : BRSharedPrefs.getPreferredFiatIso(mContext);
        String amountText = CurrencyUtils.getFormattedAmount(mContext, iso, isCryptoPreferred ?
                new BigDecimal(satoshisAmount) : wallet.getFiatForSmallestCrypto(mContext, new BigDecimal(satoshisAmount)));

        convertView.transactionAmount.setText(amountText);


        //if it's 0 we use the current time.
        long timeStamp = item.getTimeStamp() == 0 ? System.currentTimeMillis() : item.getTimeStamp() * 1000;
        CharSequence timeSpan = BRDateUtil.getCustomSpan(new Date(timeStamp));

        Log.d(TAG, "Tx timestamp final -> " + timeStamp);
        Log.d(TAG, "Tx timestamp original -> " + item.getTimeStamp());

        String shortDate = BRDateUtil.getShortDate(timeStamp);


        convertView.transactionDate.setText(shortDate);

    }

    private void setPrompt(final PromptHolder prompt) {
        Log.d(TAG, "setPrompt: " + TxManager.getInstance().promptInfo.title);
        if (TxManager.getInstance().promptInfo == null) {
            throw new RuntimeException("can't happen, showing prompt with null PromptInfo");
        }

        prompt.mainLayout.setOnClickListener(TxManager.getInstance().promptInfo.listener);
        prompt.mainLayout.setBackgroundResource(R.drawable.tx_rounded);
        prompt.title.setText(TxManager.getInstance().promptInfo.title);
        prompt.description.setText(TxManager.getInstance().promptInfo.description);

    }

    private int getResourceByPos(int pos) {
        if (TxManager.getInstance().currentPrompt != null) pos--;
        if (itemFeed != null && itemFeed.size() == 1) {
            return R.drawable.tx_rounded;
        } else if (pos == 0) {
            return R.drawable.tx_rounded_up;
        } else if (itemFeed != null && pos == itemFeed.size() - 1) {
            return R.drawable.tx_rounded_down;
        } else {
            return R.drawable.tx_not_rounded;
        }
    }


    public void filterBy(String query, boolean[] switches) {
        filter(query, switches);
    }

    public void resetFilter() {
        itemFeed = backUpFeed;
        notifyDataSetChanged();
    }

    private void filter(final String query, final boolean[] switches) {
        long start = System.currentTimeMillis();
        String lowerQuery = query.toLowerCase().trim();
        if (Utils.isNullOrEmpty(lowerQuery) && !switches[0] && !switches[1] && !switches[2] && !switches[3])
            return;
        int switchesON = 0;
        for (boolean i : switches) if (i) switchesON++;

        final List<TxUiHolder> filteredList = new ArrayList<>();
        TxUiHolder item;
        for (int i = 0; i < backUpFeed.size(); i++) {
            item = backUpFeed.get(i);
            boolean matchesHash = item.getTxHashHexReversed() != null && item.getTxHashHexReversed().contains(lowerQuery);
            boolean matchesAddress = item.getFrom()[0].contains(lowerQuery) || item.getTo()[0].contains(lowerQuery);
            boolean matchesMemo = item.metaData != null && item.metaData.comment != null && item.metaData.comment.toLowerCase().contains(lowerQuery);
            if (matchesHash || matchesAddress || matchesMemo) {
                if (switchesON == 0) {
                    filteredList.add(item);
                } else {
                    boolean willAdd = true;
                    //filter by sent and this is received
                    if (switches[0] && (item.getSent() - item.getReceived() <= 0)) {
                        willAdd = false;
                    }
                    //filter by received and this is sent
                    if (switches[1] && (item.getSent() - item.getReceived() > 0)) {
                        willAdd = false;
                    }
                    BaseWalletManager wallet = WalletsMaster.getInstance(mContext).getCurrentWallet(mContext);

                    int confirms = item.getBlockHeight() ==
                            Integer.MAX_VALUE ? 0
                            : BRSharedPrefs.getLastBlockHeight(mContext, wallet.getIso(mContext)) - item.getBlockHeight() + 1;
                    //complete
                    if (switches[2] && confirms >= 6) {
                        willAdd = false;
                    }

                    //pending
                    if (switches[3] && confirms < 6) {
                        willAdd = false;
                    }

                    if (willAdd) filteredList.add(item);
                }

            }

        }
        itemFeed = filteredList;
        notifyDataSetChanged();

        Log.e(TAG, "filter: " + query + " took: " + (System.currentTimeMillis() - start));
    }

    private class TxHolder extends RecyclerView.ViewHolder {
        public RelativeLayout mainLayout;
        public ConstraintLayout constraintLayout;
        public TextView sentReceived;
        public TextView amount;
        public TextView toFrom;
        public TextView account;
        public TextView status;
        public TextView status_2;
        public TextView timestamp;
        public TextView comment;
        public ImageView arrowIcon;

        public BRText transactionDate;
        public BRText transactionAmount;
        public BRText transactionDetail;

        public TxHolder(View view) {
            super(view);
            /*mainLayout = (RelativeLayout) view.findViewById(R.id.main_layout);
            constraintLayout = (ConstraintLayout) view.findViewById(R.id.constraintLayout);
            sentReceived = (TextView) view.findViewById(R.id.sent_received);
            amount = (TextView) view.findViewById(R.id.amount);
            toFrom = (TextView) view.findViewById(R.id.to_from);
            account = (TextView) view.findViewById(R.id.account);
            status = (TextView) view.findViewById(R.id.status);
            status_2 = (TextView) view.findViewById(R.id.status_2);
            timestamp = (TextView) view.findViewById(R.id.timestamp);
            comment = (TextView) view.findViewById(R.id.comment);
            arrowIcon = (ImageView) view.findViewById(R.id.arrow_icon);*/

            transactionDate = view.findViewById(R.id.tx_date);
            transactionAmount = view.findViewById(R.id.tx_amount);
            transactionDetail = view.findViewById(R.id.tx_description);
        }
    }

    public class PromptHolder extends RecyclerView.ViewHolder {
        public RelativeLayout mainLayout;
        public ConstraintLayout constraintLayout;
        public BRText title;
        public BRText description;
        public ImageButton close;
        public ProgressBar sendProgress;

        public PromptHolder(View view) {
            super(view);
            mainLayout = (RelativeLayout) view.findViewById(R.id.main_layout);
            constraintLayout = (ConstraintLayout) view.findViewById(R.id.prompt_layout);
            title = (BRText) view.findViewById(R.id.info_title);
            description = (BRText) view.findViewById(R.id.info_description);
            close = (ImageButton) view.findViewById(R.id.info_close_button);
            sendProgress = view.findViewById(R.id.send_progress);

        }
    }


}