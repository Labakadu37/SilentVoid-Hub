package com.jzs.brawltracker;

/**
 * Build-time configuration.
 *
 * The API token no longer lives here: it is encrypted into Secrets at build
 * time from the gitignored token.txt, and the app has no way to enter one, so
 * a build without it cannot reach the API.
 */
final class Config {

    /**
     * Endpoint returning {"online":N,"total":M} for the member banner, called
     * with an ?id= per install. Empty means the banner shows no counts, since
     * nothing else can know them.
     */
    static final String MEMBERS_URL = "";

    private Config() {
    }
}
