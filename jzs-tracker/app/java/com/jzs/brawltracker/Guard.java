package com.jzs.brawltracker;

import android.content.Context;
import android.content.pm.PackageInfo;
import android.content.pm.PackageManager;
import android.content.pm.Signature;
import android.content.pm.SigningInfo;
import android.os.Build;
import android.util.Base64;

import java.security.MessageDigest;

/**
 * Refuses to run a tampered copy.
 *
 * The build embeds the SHA-256 of its signing certificate. Anyone who
 * decompiles, edits and repackages the app must re-sign it with their own key,
 * which changes that hash; the mismatch is caught here and the app stops.
 *
 * It cannot stop someone who also patches this check out — nothing running on
 * the same device can — but it turns "unzip, edit, re-sign" into real work.
 */
final class Guard {

    private Guard() {
    }

    static boolean intact(Context context) {
        String expected = Secrets.CERT_SHA256;
        if (expected == null || expected.isEmpty()) {
            return true;
        }
        for (String actual : signatureHashes(context)) {
            if (expected.equals(actual)) {
                return true;
            }
        }
        return false;
    }

    private static String[] signatureHashes(Context context) {
        try {
            Signature[] sigs;
            PackageManager pm = context.getPackageManager();
            String pkg = context.getPackageName();

            if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.P) {
                PackageInfo info = pm.getPackageInfo(pkg, PackageManager.GET_SIGNING_CERTIFICATES);
                SigningInfo signing = info.signingInfo;
                sigs = signing.hasMultipleSigners()
                        ? signing.getApkContentsSigners()
                        : signing.getSigningCertificateHistory();
            } else {
                @SuppressWarnings("deprecation")
                PackageInfo info = pm.getPackageInfo(pkg, PackageManager.GET_SIGNATURES);
                @SuppressWarnings("deprecation")
                Signature[] legacy = info.signatures;
                sigs = legacy;
            }

            String[] out = new String[sigs.length];
            MessageDigest md = MessageDigest.getInstance("SHA-256");
            for (int i = 0; i < sigs.length; i++) {
                byte[] digest = md.digest(sigs[i].toByteArray());
                out[i] = Base64.encodeToString(digest, Base64.NO_WRAP);
            }
            return out;
        } catch (Exception e) {
            return new String[0];
        }
    }
}
