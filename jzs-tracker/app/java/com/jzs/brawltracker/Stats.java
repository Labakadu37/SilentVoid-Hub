package com.jzs.brawltracker;

import org.json.JSONArray;
import org.json.JSONObject;

import java.util.HashSet;
import java.util.Set;

/**
 * Aggregates a battle log into the numbers shown in the tracking panel.
 *
 * The official API only exposes the most recent battles, so every figure here
 * describes that window rather than an all-time total.
 */
final class Stats {

    int battles;
    int wins;
    int losses;
    int draws;
    int starPlayer;
    int trophiesWon;
    int trophiesLost;
    int streak;
    final Set<String> brawlersUsed = new HashSet<>();

    int winRate() {
        int decided = wins + losses;
        return decided == 0 ? 0 : Math.round(wins * 100f / decided);
    }

    long trophyNet() {
        return (long) trophiesWon - trophiesLost;
    }

    static Stats from(JSONArray items, String playerTag) {
        Stats s = new Stats();
        if (items == null) {
            return s;
        }
        String me = BrawlApi.normalizeTag(playerTag);
        boolean streakOpen = true;

        for (int i = 0; i < items.length(); i++) {
            JSONObject entry = items.optJSONObject(i);
            JSONObject battle = entry == null ? null : entry.optJSONObject("battle");
            if (battle == null) {
                continue;
            }
            s.battles++;

            boolean won = false;
            boolean decided = true;
            if (battle.has("result")) {
                String r = battle.optString("result");
                if ("victory".equals(r)) {
                    s.wins++;
                    won = true;
                } else if ("defeat".equals(r)) {
                    s.losses++;
                } else {
                    s.draws++;
                    decided = false;
                }
            } else if (battle.has("rank")) {
                // Showdown: top half of the lobby counts as a win.
                int rank = battle.optInt("rank");
                int cut = battle.optJSONArray("players") != null
                        && battle.optJSONArray("players").length() > 6 ? 4 : 2;
                if (rank <= cut) {
                    s.wins++;
                    won = true;
                } else {
                    s.losses++;
                }
            } else {
                s.battles--;
                continue;
            }

            // Battles arrive newest first, so the streak runs until the first loss.
            if (streakOpen && decided) {
                if (won) {
                    s.streak++;
                } else {
                    streakOpen = false;
                }
            }

            int change = battle.optInt("trophyChange");
            if (change > 0) {
                s.trophiesWon += change;
            } else if (change < 0) {
                s.trophiesLost += -change;
            }

            JSONObject mine = findSelf(battle, me);
            if (mine != null) {
                JSONObject brawler = mine.optJSONObject("brawler");
                if (brawler != null) {
                    s.brawlersUsed.add(brawler.optString("name", ""));
                }
            }
            JSONObject star = battle.optJSONObject("starPlayer");
            if (star != null && me.equals(BrawlApi.normalizeTag(star.optString("tag")))) {
                s.starPlayer++;
            }
        }
        return s;
    }

    /** Finds this player among the battle's teams, or its flat player list. */
    private static JSONObject findSelf(JSONObject battle, String me) {
        JSONArray teams = battle.optJSONArray("teams");
        if (teams != null) {
            for (int t = 0; t < teams.length(); t++) {
                JSONArray team = teams.optJSONArray(t);
                JSONObject hit = scan(team, me);
                if (hit != null) {
                    return hit;
                }
            }
        }
        return scan(battle.optJSONArray("players"), me);
    }

    private static JSONObject scan(JSONArray players, String me) {
        if (players == null) {
            return null;
        }
        for (int i = 0; i < players.length(); i++) {
            JSONObject p = players.optJSONObject(i);
            if (p != null && me.equals(BrawlApi.normalizeTag(p.optString("tag")))) {
                return p;
            }
        }
        return null;
    }
}
