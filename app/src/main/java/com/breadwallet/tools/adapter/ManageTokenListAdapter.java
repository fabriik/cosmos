package com.breadwallet.tools.adapter;

import android.app.Activity;
import android.content.Context;
import android.graphics.Typeface;
import android.support.annotation.NonNull;
import android.support.v4.view.MotionEventCompat;
import android.support.v7.widget.RecyclerView;
import android.util.Log;
import android.view.LayoutInflater;
import android.view.MotionEvent;
import android.view.View;
import android.view.ViewGroup;
import android.widget.Button;
import android.widget.ImageButton;
import android.widget.ImageView;

import com.breadwallet.R;
import com.breadwallet.presenter.customviews.BRText;
import com.breadwallet.presenter.entities.TokenItem;
import com.breadwallet.tools.animation.ItemTouchHelperAdapter;
import com.breadwallet.tools.animation.ItemTouchHelperViewHolder;
import com.breadwallet.tools.listeners.OnStartDragListener;
import com.breadwallet.wallet.wallets.ethereum.WalletEthManager;
import com.breadwallet.wallet.wallets.ethereum.WalletTokenManager;
import com.platform.entities.TokenListMetaData;
import com.platform.tools.KVStoreManager;

import java.math.BigDecimal;
import java.util.ArrayList;
import java.util.Collections;

public class ManageTokenListAdapter extends RecyclerView.Adapter<ManageTokenListAdapter.ManageTokenItemViewHolder> implements ItemTouchHelperAdapter {

    private static final String TAG = ManageTokenListAdapter.class.getSimpleName();
    private Context mContext;
    private ArrayList<TokenItem> mTokens;
    private OnTokenShowOrHideListener mListener;
    private OnStartDragListener mStartDragListener;

    public interface OnTokenShowOrHideListener {

        void onShowToken(TokenItem item);

        void onHideToken(TokenItem item);
    }

    public ManageTokenListAdapter(Context context, ArrayList<TokenItem> tokens, OnTokenShowOrHideListener listener, OnStartDragListener dragListener) {
        this.mContext = context;
        this.mTokens = tokens;
        this.mListener = listener;
        this.mStartDragListener = dragListener;
    }

    @Override
    public void onBindViewHolder(@NonNull final ManageTokenListAdapter.ManageTokenItemViewHolder holder, int position) {

        final TokenItem item = mTokens.get(position);
        String tickerName = item.symbol.toLowerCase();

        if (tickerName.equals("1st")) {
            tickerName = "first";
        }

        String iconResourceName = tickerName;
        int iconResourceId = mContext.getResources().getIdentifier(tickerName, "drawable", mContext.getPackageName());

        holder.tokenName.setText(mTokens.get(position).name);
        holder.tokenTicker.setText(mTokens.get(position).symbol);
        try {
            holder.tokenIcon.setBackground(mContext.getDrawable(iconResourceId));
        } catch (Exception e) {
            e.printStackTrace();
            Log.d(TAG, "Error finding icon for -> " + iconResourceName);
        }

        boolean isHidden = KVStoreManager.getInstance().getTokenListMetaData(mContext).isCurrencyHidden(item.symbol);

        holder.showHide.setBackground(mContext.getDrawable(isHidden ? R.drawable.add_wallet_button : R.drawable.remove_wallet_button));
        holder.showHide.setText(isHidden ? mContext.getString(R.string.TokenList_show) : mContext.getString(R.string.TokenList_hide));
        holder.showHide.setTextColor(mContext.getColor(isHidden ? R.color.dialog_button_positive : R.color.red));

        holder.showHide.setOnClickListener(new View.OnClickListener() {
            @Override
            public void onClick(View v) {
                // If token is already hidden, show it
                if (KVStoreManager.getInstance().getTokenListMetaData(mContext).isCurrencyHidden(item.symbol)) {
                    mListener.onShowToken(item);
                    // If token is already showing, hide it
                } else {
                    mListener.onHideToken(item);
                }
            }
        });

        BigDecimal tokenBalance;
        String iso = item.symbol.toUpperCase();
        WalletEthManager ethManager = WalletEthManager.getInstance(mContext);
        WalletTokenManager tokenManager = WalletTokenManager.getTokenWalletByIso(mContext, ethManager, item.symbol);

        if (tokenManager != null) {
            tokenBalance = tokenManager.getCachedBalance(mContext);
            if (tokenBalance.compareTo(BigDecimal.ZERO) == 0) {
                holder.tokenBalance.setText("");
            } else {
                holder.tokenBalance.setText(tokenBalance.toPlainString() + iso);
            }

        }

        holder.dragHandle.setOnTouchListener(new View.OnTouchListener() {
            @Override
            public boolean onTouch(View v, MotionEvent event) {
                if (MotionEventCompat.getActionMasked(event) ==
                        MotionEvent.ACTION_DOWN) {
                    mStartDragListener.onStartDrag(holder);
                }
                return false;
            }
        });

    }

    @NonNull
    @Override
    public ManageTokenListAdapter.ManageTokenItemViewHolder onCreateViewHolder(@NonNull ViewGroup parent, int viewType) {

        LayoutInflater inflater = ((Activity) mContext).getLayoutInflater();
        View convertView = inflater.inflate(R.layout.manage_wallets_list_item, parent, false);
        return new ManageTokenItemViewHolder(convertView);
    }

    @Override
    public int getItemCount() {
        return mTokens.size();
    }


    public class ManageTokenItemViewHolder extends RecyclerView.ViewHolder implements ItemTouchHelperViewHolder {

        private ImageButton dragHandle;
        private BRText tokenTicker;
        private BRText tokenName;
        private BRText tokenBalance;
        private Button showHide;
        private ImageView tokenIcon;

        public ManageTokenItemViewHolder(View view) {
            super(view);

            dragHandle = view.findViewById(R.id.drag_icon);
            tokenTicker = view.findViewById(R.id.token_ticker);
            tokenName = view.findViewById(R.id.token_name);
            tokenBalance = view.findViewById(R.id.token_balance);
            showHide = view.findViewById(R.id.show_hide_button);
            tokenIcon = view.findViewById(R.id.token_icon);

            Typeface typeface = Typeface.createFromAsset(mContext.getAssets(), "fonts/CircularPro-Book.otf");
            showHide.setTypeface(typeface);
        }

        @Override
        public void onItemClear() {

        }

        @Override
        public void onItemSelected() {

        }

        public void setDragHandle(ImageButton dragHandle) {
            this.dragHandle = dragHandle;
        }
    }

    @Override
    public void onItemDismiss(int position) {

    }

    @Override
    public void onItemMove(int fromPosition, int toPosition) {
        notifyItemMoved(fromPosition, toPosition);

        TokenListMetaData currentMd = KVStoreManager.getInstance().getTokenListMetaData(mContext);

        Collections.swap(currentMd.enabledCurrencies, fromPosition, toPosition);
        Collections.swap(mTokens, fromPosition, toPosition);

        KVStoreManager.getInstance().putTokenListMetaData(mContext, currentMd);

    }
}
