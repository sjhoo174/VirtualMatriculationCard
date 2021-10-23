package com.example.dipproject;

import io.flutter.embedding.android.FlutterActivity;
import io.flutter.embedding.engine.FlutterEngine;
import io.flutter.plugin.common.MethodChannel;

import android.content.Intent;
import android.os.Bundle;

import androidx.annotation.NonNull;
import androidx.annotation.Nullable;

public class MainActivity extends FlutterActivity {

    private static final String CHANNEL = "HceService";

    @Override
    protected void onCreate(@Nullable Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);
        Intent intent = getIntent();
        String action = intent.getAction();

    }

    @Override
    public void configureFlutterEngine(@NonNull FlutterEngine flutterEngine) {
        super.configureFlutterEngine(flutterEngine);
        new MethodChannel(flutterEngine.getDartExecutor().getBinaryMessenger(), CHANNEL)
            .setMethodCallHandler(
                (call, result) -> {

                    if (call.method.equals("HceService")) {
                        String email = call.argument("email");
                        System.out.print(email);
                        Intent intent = new Intent(this, MyHostApduService.class);
                        intent.putExtra("email", email.getBytes());
                        startService(intent);
                        result.success("1");

                    }
                    
                }
            );
    }
    
        

}




