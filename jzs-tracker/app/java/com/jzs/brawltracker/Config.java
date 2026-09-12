package com.jzs.brawltracker;

/**
 * Build-time configuration.
 *
 * Put a token in DEFAULT_TOKEN to ship an APK that works with no setup; leave
 * it empty and each user supplies their own from the "Cle API" button. A token
 * baked in here is readable by anyone who unpacks the APK, so only bake in one
 * you are willing to rotate.
 */
final class Config {

    static final String DEFAULT_TOKEN = "";

    private Config() {
    }
}
