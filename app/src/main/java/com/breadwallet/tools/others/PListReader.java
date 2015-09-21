package com.breadwallet.tools.others;

import android.content.Context;
import android.content.res.AssetManager;
import android.util.Log;

import com.breadwallet.R;

import java.io.BufferedReader;
import java.io.IOException;
import java.io.InputStream;
import java.io.InputStreamReader;
import java.util.ArrayList;
import java.util.List;

public class PListReader {

    public static final String TAG = PListReader.class.getName();
    public static final int WORD_LIST_SIZE = 2048;

    public static List<String> getWordList(Context context) throws IOException {

        String languageCode = context.getString(R.string.lang);
        Log.e(TAG, "The language is: " + languageCode);
        String fileName = "words/" + languageCode + "-BIP39Words.txt";
        List<String> wordList = new ArrayList<>();
        BufferedReader reader = null;
        try {
            AssetManager assetManager = context.getResources().getAssets();
            InputStream inputStream = assetManager.open(fileName);
            reader = new BufferedReader(new InputStreamReader(inputStream));
            String line;
            while ((line = reader.readLine()) != null) {
                wordList.add(line);
            }
        } catch (Exception ex) {
            ex.printStackTrace();

        } finally {
            reader.close();
        }
        if (wordList.size() != WORD_LIST_SIZE)
            throw new IllegalArgumentException("The list should have " + WORD_LIST_SIZE + " items");
        return wordList;

    }

}
