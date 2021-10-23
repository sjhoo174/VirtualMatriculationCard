package com.example.dipnfcbackend;

import io.flutter.embedding.android.FlutterActivity;
import io.flutter.embedding.engine.FlutterEngine;
import io.flutter.plugin.common.MethodChannel;

import android.app.PendingIntent;
import android.content.Intent;
import android.content.IntentFilter;
import android.nfc.NfcAdapter;
import android.nfc.Tag;
import android.nfc.tech.IsoDep;
import android.nfc.tech.MifareUltralight;
import android.nfc.tech.NfcA;
import android.nfc.tech.NfcB;
import android.nfc.tech.NfcF;
import android.nfc.tech.NfcV;
import android.os.Build;
import android.os.Bundle;
import android.util.Log;

import androidx.annotation.NonNull;
import androidx.annotation.Nullable;
import androidx.annotation.RequiresApi;

import java.io.IOException;

public class MainActivity extends FlutterActivity {

    private static final String TAG = "ERROR: ";
    private static final String CHANNEL = "readNFC";
    private String message = "";
    private NfcAdapter adapter;
    private PendingIntent pendingIntent;
    private IntentFilter[] mFilters;
    private String[][] mTechLists;

    @RequiresApi(api = Build.VERSION_CODES.KITKAT)
    @Override
    protected void onCreate(@Nullable Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);
        int flags = NfcAdapter.FLAG_READER_SKIP_NDEF_CHECK;
        flags |= NfcAdapter.FLAG_READER_NFC_A;

        Bundle opts = new Bundle();
        Intent intent = getIntent();

        NfcAdapter.getDefaultAdapter(this).enableReaderMode(this, new NfcAdapter.ReaderCallback() {

            @Override
            public void onTagDiscovered(Tag tag) {
                message = readTag(tag);
                System.out.println(message);
                System.out.println("IM HEREEEE");


            }
        }, flags, opts);
        
    }

    @Override
    protected void onResume() {
        super.onResume();
        // adapter.enableForegroundDispatch(this, pendingIntent, mFilters, mTechLists);

    }

    @RequiresApi(api = Build.VERSION_CODES.KITKAT)
    @Override
    protected void onNewIntent(@NonNull Intent intent) {
        super.onNewIntent(intent);
        int flags = NfcAdapter.FLAG_READER_SKIP_NDEF_CHECK;
        flags |= NfcAdapter.FLAG_READER_NFC_A;

        Bundle opts = new Bundle();

        NfcAdapter.getDefaultAdapter(this).enableReaderMode(this, new NfcAdapter.ReaderCallback() {

            @Override
            public void onTagDiscovered(Tag tag) {
                String action = intent.getAction();
                message = readTag(tag);

            }
        }, flags, opts);
    }

    @Override
    public void configureFlutterEngine(@NonNull FlutterEngine flutterEngine) {
        super.configureFlutterEngine(flutterEngine);
        new MethodChannel(flutterEngine.getDartExecutor().getBinaryMessenger(), CHANNEL)
                .setMethodCallHandler(
                        (call, result) -> {

                           if (call.method.equals("readNFC")) {
                                result.success(message);

                            }
                           
                        }
                );
    }
    public String readTag(Tag tag) {
        byte[] SELECT = {
            (byte) 0x00, // CLA Class
            (byte) 0xA4, // INS Instruction
            (byte) 0x04, // P1  Parameter 1
            (byte) 0x00, // P2  Parameter 2
            (byte) 0x06,
            (byte) 0xF0,
            (byte) 0x01,
            (byte) 0x02,
            (byte) 0x03,
            (byte) 0x04,
            (byte) 0x05,
            (byte) 0x00
//            (byte) 0x00,
        };

        IsoDep t = IsoDep.get(tag);

        try {
            t.connect();
        } catch (IOException e) {
            return "Connect";
        }
        byte[] result = new byte[10];
        try {
            result = t.transceive(SELECT);
            StringBuilder sb = new StringBuilder();
            for (byte b : result) {
                if ((char) b == '@') {
                    break;
                }
                sb.append(String.format("%s", (char)b ));
            }
            return sb.toString();

            // if (sb.toString().substring(0,5).equals("90 00")) {
            //     byte[] RESPONSE = {
                    
            //         (byte) 0x00,
            //         (byte) 0x86,
            //         (byte) 0x00,
            //         (byte) 0x00,
            //         (byte) 0x00,
            //     };
                
            //     result = t.transceive(RESPONSE);
            //     sb = new StringBuilder();
            //     for (byte b : result) {
            //         sb.append(String.format("%02X ", b));
            //     }
            //     return sb.toString();
            // } else {
            //     return sb.toString().substring(0,5);
            // }
        } catch (IOException e) {
            return "transceive";
        }
        
    
       
        
    }

}




