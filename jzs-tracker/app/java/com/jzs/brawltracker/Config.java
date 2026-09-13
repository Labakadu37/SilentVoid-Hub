package com.jzs.brawltracker;

/**
 * Build-time configuration.
 *
 * DEFAULT_TOKEN is the key every copy of the app uses; build.sh fills it in
 * from the gitignored token.txt. The app offers no way to enter a key, so a
 * build without one cannot reach the API. A baked-in key is readable by
 * anyone who unpacks the APK, so only ship one you are willing to rotate.
 */
final class Config {

    static final String DEFAULT_TOKEN = "";

    /**
     * Endpoint returning {"online":N,"total":M} for the member banner, called
     * with an ?id= per install. Empty means the banner shows no counts, since
     * nothing else can know them.
     */
    static final String MEMBERS_URL = "";

    private Config() {
    }
}
