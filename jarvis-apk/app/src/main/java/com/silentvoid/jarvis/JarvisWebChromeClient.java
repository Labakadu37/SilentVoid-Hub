package com.silentvoid.jarvis;

import android.webkit.PermissionRequest;
import android.webkit.WebChromeClient;

public class JarvisWebChromeClient extends WebChromeClient {
    @Override
    public void onPermissionRequest(PermissionRequest request) {
        request.grant(request.getResources());
    }
}
