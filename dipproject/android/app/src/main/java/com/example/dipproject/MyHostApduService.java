package com.example.dipproject;
import android.content.Intent;
import android.media.AudioManager;
import android.media.ToneGenerator;
import android.nfc.cardemulation.HostApduService;
import android.os.Build;
import android.os.Bundle;
import androidx.annotation.RequiresApi;

@RequiresApi(api = Build.VERSION_CODES.KITKAT)
public class MyHostApduService extends HostApduService {
    byte[] data;

    @Override
    public int onStartCommand(Intent intent, int flags, int startId) {
        data = (byte[]) intent.getExtras().get("email");
        System.out.println(intent.getExtras().get("email"));
        System.out.println(data);
        return START_NOT_STICKY;
//        return super.onStartCommand(intent, flags, startId);
    }


    @Override
    public byte[] processCommandApdu(byte[] apdu, Bundle extras) {
        sendResponseApdu(data);
        ToneGenerator toneGen1 = new ToneGenerator(AudioManager.STREAM_MUSIC, 100);
        toneGen1.startTone(ToneGenerator.TONE_CDMA_PIP,150);
        return data;
    }
    @Override
    public void onDeactivated(int reason) {
        System.out.println("Deactivated.");
        stopSelf();
    }
}