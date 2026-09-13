package com.jzs.brawltracker;

import android.app.Activity;
import android.content.Context;
import android.content.SharedPreferences;
import android.graphics.Typeface;
import android.os.Bundle;
import android.text.InputType;
import android.view.Gravity;
import android.view.View;
import android.view.ViewGroup;
import android.view.inputmethod.InputMethodManager;
import android.widget.EditText;
import android.widget.ImageView;
import android.widget.LinearLayout;
import android.widget.ScrollView;
import android.widget.TextView;

import org.json.JSONArray;
import org.json.JSONObject;

import java.util.ArrayList;
import java.util.Collections;
import java.util.Comparator;
import java.util.LinkedHashSet;
import java.util.List;
import java.util.Map;

public class MainActivity extends Activity {

    private static final String PREFS = "jzs";
    private static final String KEY_LAST_TAG = "last_tag";
    private static final String KEY_RECENT = "recent_tags";
    private static final int MAX_RECENT = 8;

    private static final int TAB_HOME = 0;
    private static final int TAB_BRAWLERS = 1;
    private static final int TAB_EVENTS = 2;
    private static final int TAB_CLUB = 3;
    private static final int TAB_RANKINGS = 4;
    private static final String[] TAB_NAMES = {"Home", "Brawlers", "Events", "Club", "Top"};
    private static final int[] TAB_ICONS = {
            R.drawable.ic_home, R.drawable.ic_brawlers, R.drawable.ic_events,
            R.drawable.ic_club, R.drawable.ic_top};

    private static final int MODE_PLAYER = 0;
    private static final int MODE_CLUB = 1;

    private static final int SORT_TROPHIES = 0;
    private static final int SORT_RANK = 1;
    private static final int SORT_POWER = 2;
    private static final int SORT_NAME = 3;
    private static final String[] SORT_NAMES = {"Trophees", "Rang", "Puissance", "Nom"};

    private SharedPreferences prefs;
    private EditText tagInput;
    private TextView status;
    private LinearLayout content;
    private LinearLayout navBar;
    private TextView[] modeTabs;
    private View searchRow;
    private View modeRow;

    private int searchMode = MODE_PLAYER;
    private int tab = TAB_HOME;
    private int brawlerSort = SORT_TROPHIES;
    private int rankKind = MODE_PLAYER;
    private String region = "global";

    private String tag = "";
    private JSONObject player;
    private JSONArray battles;
    private JSONObject club;
    private JSONArray rankings;
    private JSONArray events;
    private JSONObject detail;

    // Rendering a tab triggers its fetch, so these stop a response that does
    // not populate its field from starting the same request over and over.
    private boolean loadingRankings;
    private boolean loadingEvents;
    private boolean loadingClub;

    // Negative until the server answers, so the banner can tell "none yet"
    // apart from a genuine zero.
    private int memberOnline = -1;
    private int memberTotal = -1;

    @Override
    protected void onCreate(Bundle saved) {
        super.onCreate(saved);

        if (!Guard.intact(this)) {
            setContentView(tamperScreen());
            return;
        }

        prefs = getSharedPreferences(PREFS, MODE_PRIVATE);
        setContentView(buildRoot());

        Members.fetch(prefs, new Members.Callback() {
            @Override
            public void onCounts(int online, int total) {
                memberOnline = online;
                memberTotal = total;
                if (player == null && tab == TAB_HOME) {
                    render();
                }
            }
        });

        String last = prefs.getString(KEY_LAST_TAG, "");
        if (!last.isEmpty()) {
            tagInput.setText(last);
            search();
        } else {
            render();
        }
    }

    @Override
    public void onBackPressed() {
        if (detail != null) {
            detail = null;
            render();
            return;
        }
        if (tab != TAB_HOME) {
            selectTab(TAB_HOME);
            return;
        }
        super.onBackPressed();
    }

    // ---------------------------------------------------------------- chrome

    private View buildRoot() {
        LinearLayout root = Ui.column(this);
        root.setBackgroundColor(Ui.BG);

        root.addView(buildTopBar());
        searchRow = buildSearchRow();
        root.addView(searchRow);
        modeRow = buildModeRow();
        root.addView(modeRow);

        status = Ui.text(this, "", 13, Ui.MUTED);
        status.setPadding(Ui.dp(this, 14), Ui.dp(this, 9), Ui.dp(this, 14), 0);
        status.setVisibility(View.GONE);
        root.addView(status);

        content = Ui.column(this);
        int p = Ui.dp(this, 14);
        content.setPadding(p, Ui.dp(this, 12), p, Ui.dp(this, 18));

        ScrollView scroll = new ScrollView(this);
        scroll.setVerticalScrollBarEnabled(false);
        scroll.addView(content);
        scroll.setLayoutParams(new LinearLayout.LayoutParams(
                ViewGroup.LayoutParams.MATCH_PARENT, 0, 1f));
        root.addView(scroll);

        navBar = buildNav();
        root.addView(navBar);
        return root;
    }

    private View buildTopBar() {
        LinearLayout bar = Ui.row(this);
        bar.setPadding(Ui.dp(this, 14), Ui.dp(this, 24), Ui.dp(this, 14), Ui.dp(this, 6));

        bar.addView(Ui.icon(this, R.drawable.logo, 28, 9));

        TextView logo = Ui.heavy(this, getString(R.string.brand), 22, Ui.LIME);
        logo.setLetterSpacing(0.01f);
        bar.addView(logo, new LinearLayout.LayoutParams(
                0, ViewGroup.LayoutParams.WRAP_CONTENT, 1f));

        TextView refresh = Ui.chip(this, "REFRESH", Ui.MUTED, Ui.CARD);
        refresh.setOnClickListener(new View.OnClickListener() {
            @Override
            public void onClick(View v) {
                reload();
            }
        });
        bar.addView(refresh);

        return bar;
    }

    private View buildSearchRow() {
        LinearLayout row = Ui.row(this);
        row.setPadding(Ui.dp(this, 14), Ui.dp(this, 4), Ui.dp(this, 14), Ui.dp(this, 4));

        tagInput = new EditText(this);
        tagInput.setHint("#2Y0VLQR9");
        tagInput.setSingleLine(true);
        tagInput.setTextColor(Ui.WHITE);
        tagInput.setHintTextColor(Ui.MUTED);
        tagInput.setTextSize(15);
        tagInput.setTypeface(Typeface.create("sans-serif-medium", Typeface.BOLD));
        tagInput.setInputType(InputType.TYPE_TEXT_FLAG_CAP_CHARACTERS);
        tagInput.setBackground(Ui.panel(this, Ui.CARD, Ui.STROKE, 3));
        int p = Ui.dp(this, 12);
        tagInput.setPadding(p, p, p, p);
        row.addView(tagInput, new LinearLayout.LayoutParams(
                0, ViewGroup.LayoutParams.WRAP_CONTENT, 1f));

        TextView go = Ui.heavy(this, "GO", 15, Ui.BG);
        go.setBackground(Ui.round(Ui.LIME, Ui.dp(this, 3)));
        go.setPadding(Ui.dp(this, 18), p, Ui.dp(this, 18), p);
        LinearLayout.LayoutParams lp = new LinearLayout.LayoutParams(
                ViewGroup.LayoutParams.WRAP_CONTENT, ViewGroup.LayoutParams.WRAP_CONTENT);
        lp.leftMargin = Ui.dp(this, 7);
        go.setLayoutParams(lp);
        go.setOnClickListener(new View.OnClickListener() {
            @Override
            public void onClick(View v) {
                search();
            }
        });
        row.addView(go);
        return row;
    }

    /** Players / Clubs selector, so a club tag can be looked up on its own. */
    private View buildModeRow() {
        LinearLayout row = Ui.row(this);
        row.setPadding(Ui.dp(this, 14), Ui.dp(this, 4), Ui.dp(this, 14), Ui.dp(this, 2));
        modeTabs = new TextView[]{
                modeTab("JOUEURS", MODE_PLAYER), modeTab("CLUBS", MODE_CLUB)};
        for (TextView t : modeTabs) {
            row.addView(t);
        }
        refreshModeTabs();
        return row;
    }

    private TextView modeTab(String title, final int mode) {
        TextView t = Ui.bold(this, title, 11, Ui.MUTED);
        t.setGravity(Gravity.CENTER);
        t.setLetterSpacing(0.1f);
        t.setPadding(0, Ui.dp(this, 8), 0, Ui.dp(this, 8));
        LinearLayout.LayoutParams lp = new LinearLayout.LayoutParams(
                0, ViewGroup.LayoutParams.WRAP_CONTENT, 1f);
        lp.rightMargin = Ui.dp(this, 7);
        t.setLayoutParams(lp);
        t.setOnClickListener(new View.OnClickListener() {
            @Override
            public void onClick(View v) {
                searchMode = mode;
                refreshModeTabs();
                tagInput.setHint(mode == MODE_CLUB ? "#2LRGVQC0" : "#2Y0VLQR9");
            }
        });
        return t;
    }

    private void refreshModeTabs() {
        for (int i = 0; i < modeTabs.length; i++) {
            boolean active = i == searchMode;
            modeTabs[i].setTextColor(active ? Ui.BG : Ui.MUTED);
            modeTabs[i].setBackground(active
                    ? Ui.round(Ui.LIME, Ui.dp(this, 3))
                    : Ui.panel(this, Ui.CARD, Ui.STROKE, 3));
        }
    }

    private LinearLayout buildNav() {
        LinearLayout nav = Ui.row(this);
        nav.setBackgroundColor(Ui.CARD);
        int p = Ui.dp(this, 5);
        nav.setPadding(p, p, p, p);
        for (int i = 0; i < TAB_NAMES.length; i++) {
            nav.addView(navItem(i));
        }
        return nav;
    }

    private View navItem(final int index) {
        LinearLayout item = Ui.column(this);
        item.setGravity(Gravity.CENTER);
        item.setPadding(0, Ui.dp(this, 8), 0, Ui.dp(this, 7));
        item.setLayoutParams(new LinearLayout.LayoutParams(
                0, ViewGroup.LayoutParams.WRAP_CONTENT, 1f));

        ImageView glyph = new ImageView(this);
        glyph.setImageResource(TAB_ICONS[index]);
        glyph.setScaleType(ImageView.ScaleType.FIT_CENTER);
        glyph.setLayoutParams(new LinearLayout.LayoutParams(
                Ui.dp(this, 21), Ui.dp(this, 21)));
        item.addView(glyph);

        TextView caption = Ui.bold(this, TAB_NAMES[index], 10, Ui.MUTED);
        caption.setGravity(Gravity.CENTER);
        caption.setPadding(0, Ui.dp(this, 4), 0, 0);
        item.addView(caption);

        item.setOnClickListener(new View.OnClickListener() {
            @Override
            public void onClick(View v) {
                selectTab(index);
            }
        });
        return item;
    }

    private void refreshNav() {
        for (int i = 0; i < navBar.getChildCount(); i++) {
            LinearLayout item = (LinearLayout) navBar.getChildAt(i);
            boolean active = i == tab;
            int colour = active ? Ui.LIME : Ui.MUTED;
            ((ImageView) item.getChildAt(0)).setColorFilter(colour);
            ((TextView) item.getChildAt(1)).setTextColor(colour);
            item.setBackground(active ? Ui.round(Ui.CARD_SOFT, Ui.dp(this, 3)) : null);
        }
    }

    private void selectTab(int index) {
        tab = index;
        detail = null;
        render();
    }

    /**
     * Events and rankings take no tag, and only the home and club screens act
     * on the players/clubs choice, so neither control is shown where it would
     * do nothing.
     */
    private void refreshChrome() {
        boolean wantsSearch = detail == null
                && (tab == TAB_HOME || tab == TAB_BRAWLERS || tab == TAB_CLUB);
        boolean wantsMode = wantsSearch && tab != TAB_BRAWLERS;
        searchRow.setVisibility(wantsSearch ? View.VISIBLE : View.GONE);
        modeRow.setVisibility(wantsMode ? View.VISIBLE : View.GONE);
    }

    // ----------------------------------------------------------------- token

    /** Decrypted from the packed secrets; nobody is asked to supply a key. */
    private String token() {
        return Secrets.token().trim();
    }

    /** Shown instead of the app when the signing certificate does not match. */
    private View tamperScreen() {
        LinearLayout screen = Ui.column(this);
        screen.setBackgroundColor(Ui.BG);
        screen.setGravity(Gravity.CENTER);
        int p = Ui.dp(this, 32);
        screen.setPadding(p, p, p, p);

        screen.addView(Ui.icon(this, R.drawable.skull, 72, 0));
        screen.addView(Ui.spacer(this, 18));
        TextView title = Ui.heavy(this, "FICHIER MODIFIE", 22, Ui.LOSS);
        title.setGravity(Gravity.CENTER);
        screen.addView(title);
        screen.addView(Ui.spacer(this, 10));
        TextView body = Ui.text(this,
                "Cette copie de BrawlBee a ete alteree et ne peut pas demarrer. "
                        + "Telecharge la version officielle.", 14, Ui.MUTED);
        body.setGravity(Gravity.CENTER);
        screen.addView(body);
        return screen;
    }

    // -------------------------------------------------------- recent profiles

    private List<String> recentTags() {
        String raw = prefs.getString(KEY_RECENT, "");
        List<String> out = new ArrayList<>();
        for (String s : raw.split(",")) {
            if (!s.trim().isEmpty()) {
                out.add(s.trim());
            }
        }
        return out;
    }

    private void rememberTag(String value) {
        LinkedHashSet<String> ordered = new LinkedHashSet<>();
        ordered.add(value);
        ordered.addAll(recentTags());

        List<String> keep = new ArrayList<>(ordered);
        if (keep.size() > MAX_RECENT) {
            keep = keep.subList(0, MAX_RECENT);
        }
        StringBuilder sb = new StringBuilder();
        for (String s : keep) {
            if (sb.length() > 0) {
                sb.append(',');
            }
            sb.append(s);
        }
        prefs.edit().putString(KEY_RECENT, sb.toString()).apply();
    }

    // ---------------------------------------------------------------- search

    private void search() {
        String wanted = BrawlApi.normalizeTag(tagInput.getText().toString());
        if (wanted.isEmpty()) {
            setStatus("Entre un tag.", Ui.LOSS);
            return;
        }
        if (token().isEmpty()) {
            setStatus("Service indisponible.", Ui.LOSS);
            return;
        }
        hideKeyboard();
        if (searchMode == MODE_CLUB) {
            searchClub(wanted);
        } else {
            searchPlayer(wanted);
        }
    }

    private void searchPlayer(String wanted) {
        searchPlayer(wanted, TAB_HOME);
    }

    /** landOn lets an empty tab load a profile without throwing you back home. */
    private void searchPlayer(final String wanted, int landOn) {
        prefs.edit().putString(KEY_LAST_TAG, wanted).apply();
        tag = wanted;
        player = null;
        battles = null;
        club = null;
        detail = null;
        tab = landOn;
        content.removeAllViews();
        setStatus("Chargement...", Ui.MUTED);

        final BrawlApi api = new BrawlApi(token());
        api.player(wanted, new BrawlApi.Callback() {
            @Override
            public void onSuccess(JSONObject body) {
                player = body;
                rememberTag(wanted);
                setStatus("", Ui.MUTED);
                render();
                api.battlelog(tag, new BrawlApi.Callback() {
                    @Override
                    public void onSuccess(JSONObject log) {
                        battles = log.optJSONArray("items");
                        render();
                    }

                    @Override
                    public void onError(String message) {
                        render();
                    }
                });
            }

            @Override
            public void onError(String message) {
                content.removeAllViews();
                setStatus(message, Ui.LOSS);
            }
        });
    }

    private void searchClub(String clubTag) {
        club = null;
        detail = null;
        tab = TAB_CLUB;
        content.removeAllViews();
        setStatus("Chargement...", Ui.MUTED);

        new BrawlApi(token()).club(clubTag, new BrawlApi.Callback() {
            @Override
            public void onSuccess(JSONObject body) {
                club = body;
                setStatus("", Ui.MUTED);
                render();
            }

            @Override
            public void onError(String message) {
                content.removeAllViews();
                setStatus(message, Ui.LOSS);
            }
        });
    }

    private void reload() {
        if (tab == TAB_EVENTS) {
            events = null;
        } else if (tab == TAB_RANKINGS) {
            rankings = null;
        } else if (tab == TAB_CLUB) {
            club = null;
        } else if (!tag.isEmpty()) {
            searchPlayer(tag);
            return;
        }
        render();
    }

    private void loadClub() {
        JSONObject c = player == null ? null : player.optJSONObject("club");
        String clubTag = c == null ? "" : c.optString("tag", "");
        if (clubTag.isEmpty() || loadingClub) {
            return;
        }
        loadingClub = true;
        new BrawlApi(token()).club(clubTag, new BrawlApi.Callback() {
            @Override
            public void onSuccess(JSONObject body) {
                loadingClub = false;
                club = body;
                if (tab == TAB_CLUB) {
                    render();
                }
            }

            @Override
            public void onError(String message) {
                loadingClub = false;
                setStatus(message, Ui.LOSS);
            }
        });
    }

    private void loadRankings() {
        if (loadingRankings) {
            return;
        }
        loadingRankings = true;
        BrawlApi.Callback cb = new BrawlApi.Callback() {
            @Override
            public void onSuccess(JSONObject body) {
                loadingRankings = false;
                JSONArray items = body.optJSONArray("items");
                rankings = items == null ? new JSONArray() : items;
                if (tab == TAB_RANKINGS) {
                    render();
                }
            }

            @Override
            public void onError(String message) {
                loadingRankings = false;
                rankings = new JSONArray();
                setStatus(message, Ui.LOSS);
            }
        };
        if (rankKind == MODE_CLUB) {
            new BrawlApi(token()).rankedClubs(region, cb);
        } else {
            new BrawlApi(token()).rankedPlayers(region, cb);
        }
    }

    private void loadEvents() {
        if (loadingEvents) {
            return;
        }
        loadingEvents = true;
        new BrawlApi(token()).events(new BrawlApi.Callback() {
            @Override
            public void onSuccess(JSONObject body) {
                loadingEvents = false;
                JSONArray items = body.optJSONArray("items");
                events = items == null ? new JSONArray() : items;
                // The landing screen previews the rotation too, so redraw
                // whichever screen is showing rather than only the events tab.
                render();
            }

            @Override
            public void onError(String message) {
                loadingEvents = false;
                events = new JSONArray();
                setStatus(message, Ui.LOSS);
                render();
            }
        });
    }

    // ---------------------------------------------------------------- render

    private void render() {
        content.removeAllViews();
        refreshNav();
        refreshChrome();
        Ui.enter(content);

        if (detail != null) {
            renderBrawlerDetail(detail);
            return;
        }
        switch (tab) {
            case TAB_EVENTS:
                renderEventsTab();
                return;
            case TAB_RANKINGS:
                renderRankingsTab();
                return;
            case TAB_CLUB:
                renderClubTab();
                return;
            case TAB_BRAWLERS:
                if (player == null) {
                    content.addView(needPlayerCard("Brawlers"));
                    return;
                }
                renderBrawlersTab();
                return;
            default:
                if (player == null) {
                    renderWelcome();
                    return;
                }
                renderHomeTab();
        }
    }

    /** Gold banner: the build, and how many people are on it. */
    private View memberBanner() {
        LinearLayout card = Ui.card(this);

        ShimmerText title = new ShimmerText(this);
        title.setText("BrawlBee V1.0");
        title.setTextSize(android.util.TypedValue.COMPLEX_UNIT_SP, 30);
        title.setTypeface(Typeface.create("sans-serif-black", Typeface.NORMAL));
        title.setTextColor(Ui.GOLD);
        title.setLetterSpacing(-0.01f);
        card.addView(title);
        card.addView(Ui.spacer(this, 12));

        String online = memberOnline < 0 ? "—" : Ui.num(memberOnline);
        String total = memberTotal < 0 ? "—" : Ui.num(memberTotal);

        card.addView(memberLine("Member Only", online, "en ligne maintenant", Ui.LIME));
        card.addView(Ui.spacer(this, 8));
        card.addView(memberLine("Member", total, "ont installe l'app", Ui.GOLD));

        if (!Members.configured()) {
            card.addView(Ui.spacer(this, 12));
            card.addView(Ui.text(this,
                    "Compteurs en attente du serveur.", 11, Ui.MUTED));
        }
        return card;
    }

    private View memberLine(String label, String value, String detail, int colour) {
        LinearLayout row = Ui.row(this);

        View pip = new View(this);
        pip.setBackground(Ui.round(colour, Ui.dp(this, 2)));
        LinearLayout.LayoutParams pl = new LinearLayout.LayoutParams(
                Ui.dp(this, 7), Ui.dp(this, 7));
        pl.rightMargin = Ui.dp(this, 9);
        pip.setLayoutParams(pl);
        row.addView(pip);

        LinearLayout words = Ui.column(this);
        words.addView(Ui.bold(this, label, 14, Ui.WHITE));
        words.addView(Ui.text(this, detail, 11, Ui.MUTED));
        row.addView(Ui.weighted(words, 1f));

        row.addView(Ui.heavy(this, value, 20, colour));
        return row;
    }

    private void renderWelcome() {
        content.addView(memberBanner());

        LinearLayout hero = Ui.row(this);
        hero.setPadding(0, Ui.dp(this, 6), 0, 0);

        LinearLayout words = Ui.column(this);
        words.addView(Ui.display(this, "Suis ta\npartie", 34, Ui.WHITE));
        hero.addView(Ui.weighted(words, 1f));
        hero.addView(Ui.icon(this, R.drawable.brawl, 96, 0));
        content.addView(hero);
        content.addView(Ui.spacer(this, 12));

        TextView pitch = Ui.text(this,
                "Stats en direct, events du moment et suivi complet "
                        + "pour chaque joueur et chaque club.", 15, Ui.MUTED);
        pitch.setLineSpacing(0f, 1.25f);
        content.addView(pitch);
        content.addView(Ui.spacer(this, 18));

        TextView cta = Ui.action(this, "Voir mes stats  →");
        cta.setOnClickListener(new View.OnClickListener() {
            @Override
            public void onClick(View v) {
                tagInput.requestFocus();
                InputMethodManager imm = (InputMethodManager)
                        getSystemService(Context.INPUT_METHOD_SERVICE);
                if (imm != null) {
                    imm.showSoftInput(tagInput, InputMethodManager.SHOW_IMPLICIT);
                }
            }
        });
        content.addView(cta);

        LinearLayout legend = Ui.card(this);
        legend.addView(Ui.heading(this, "Ce que tu suis", null));
        legend.addView(Ui.spacer(this, 4));
        legend.addView(Ui.legendItem(this, R.drawable.trophy,
                "Trophees et classements", "Progression, records, top mondial et FR"));
        legend.addView(Ui.legendItem(this, R.drawable.brawl,
                "Stats brawlers", "Rang, puissance, star powers, gadgets, gears"));
        legend.addView(Ui.legendItem(this, R.drawable.skull,
                "Battle log", "Win rate par mode, series, star player"));
        content.addView(legend);

        List<String> recent = recentTags();
        if (!recent.isEmpty()) {
            LinearLayout card = Ui.card(this);
            card.addView(Ui.heading(this, "Recents",
                    Ui.chip(this, String.valueOf(recent.size()), Ui.BG, Ui.LIME)));
            card.addView(Ui.spacer(this, 4));
            for (final String t : recent) {
                LinearLayout row = Ui.row(this);
                row.setPadding(0, Ui.dp(this, 10), 0, Ui.dp(this, 10));
                row.addView(Ui.icon(this, R.drawable.brawl, 24, 10));
                row.addView(Ui.weighted(Ui.wrap(this,
                        Ui.bold(this, "#" + t, 15, Ui.WHITE)), 1f));
                row.addView(Ui.bold(this, "›", 20, Ui.MUTED));
                row.setOnClickListener(new View.OnClickListener() {
                    @Override
                    public void onClick(View v) {
                        tagInput.setText(t);
                        searchMode = MODE_PLAYER;
                        refreshModeTabs();
                        searchPlayer(t);
                    }
                });
                card.addView(row);
            }
            content.addView(card);
        }

        content.addView(eventsPreviewCard());
    }

    private View needPlayerCard(String section) {
        LinearLayout card = Ui.card(this);
        card.addView(Ui.heading(this, R.drawable.brawl, section, null));
        card.addView(Ui.spacer(this, 14));

        LinearLayout hero = Ui.row(this);
        hero.addView(Ui.icon(this, R.drawable.brawl, 72, 14));
        LinearLayout words = Ui.column(this);
        words.addView(Ui.heavy(this, "AUCUN PROFIL", 19, Ui.WHITE));
        words.addView(Ui.spacer(this, 6));
        words.addView(Ui.text(this,
                "Entre un tag de joueur ci-dessus pour voir ses brawlers, "
                        + "leur rang, leur puissance et leurs deblocages.",
                13, Ui.MUTED));
        hero.addView(Ui.weighted(words, 1f));
        card.addView(hero);

        List<String> recent = recentTags();
        if (!recent.isEmpty()) {
            card.addView(Ui.divider(this));
            card.addView(Ui.label(this, "Reprendre", Ui.MUTED));
            for (final String t : recent) {
                LinearLayout row = Ui.row(this);
                row.setPadding(0, Ui.dp(this, 10), 0, Ui.dp(this, 10));
                row.addView(Ui.weighted(Ui.wrap(this,
                        Ui.bold(this, "#" + t, 15, Ui.WHITE)), 1f));
                row.addView(Ui.bold(this, "›", 20, Ui.LIME));
                row.setOnClickListener(new View.OnClickListener() {
                    @Override
                    public void onClick(View v) {
                        tagInput.setText(t);
                        searchPlayer(t, TAB_BRAWLERS);
                    }
                });
                card.addView(row);
            }
        }
        return card;
    }

    // ------------------------------------------------------------- home tab

    private void renderHomeTab() {
        content.addView(profileCard());
        if (battles != null) {
            Stats s = Stats.from(battles, tag);
            content.addView(trendCard());
            content.addView(trackingCard(s));
            content.addView(modesCard(s));
        }
        JSONObject top = topBrawler();
        if (top != null) {
            content.addView(heroBrawlerCard(top));
        }
        if (battles != null) {
            content.addView(battlesCard());
        }
    }

    private View profileCard() {
        LinearLayout card = Ui.card(this);

        LinearLayout head = Ui.row(this);
        ImageView avatar = new ImageView(this);
        avatar.setScaleType(ImageView.ScaleType.FIT_CENTER);
        LinearLayout.LayoutParams al = new LinearLayout.LayoutParams(
                Ui.dp(this, 50), Ui.dp(this, 50));
        al.rightMargin = Ui.dp(this, 11);
        avatar.setLayoutParams(al);
        JSONObject icon = player.optJSONObject("icon");
        ImageLoader.profileIcon(avatar, icon == null ? 0 : icon.optInt("id"));
        head.addView(avatar);

        LinearLayout names = Ui.column(this);
        names.addView(Ui.heavy(this,
                player.optString("name", "?").toUpperCase(), 21, Ui.WHITE));
        names.addView(Ui.text(this, player.optString("tag", ""), 12, Ui.MUTED));
        head.addView(Ui.weighted(names, 1f));

        LinearLayout trophyBox = Ui.column(this);
        trophyBox.setGravity(Gravity.END);
        trophyBox.addView(Ui.trophy(this, player.optLong("trophies"), 20, Ui.GOLD));
        TextView max = Ui.text(this,
                "max " + Ui.num(player.optLong("highestTrophies")), 11, Ui.MUTED);
        max.setGravity(Gravity.END);
        trophyBox.addView(max);
        head.addView(trophyBox);
        card.addView(head);

        JSONObject c = player.optJSONObject("club");
        String clubName = c == null ? "" : c.optString("name", "");
        if (!clubName.isEmpty()) {
            TextView clubRow = Ui.bold(this, clubName, 13, Ui.LIME);
            clubRow.setPadding(0, Ui.dp(this, 10), 0, 0);
            card.addView(clubRow);
        }

        card.addView(Ui.tileRow(this,
                Ui.tile(this, "Niveau", String.valueOf(player.optInt("expLevel")), Ui.WHITE),
                Ui.tile(this, "Brawlers", String.valueOf(brawlerList().size()), Ui.WHITE),
                Ui.tile(this, "3v3", Ui.num(player.optLong("3vs3Victories")), Ui.WIN)));
        card.addView(Ui.tileRow(this,
                Ui.tile(this, "Solo", Ui.num(player.optLong("soloVictories")), Ui.WIN),
                Ui.tile(this, "Duo", Ui.num(player.optLong("duoVictories")), Ui.WIN),
                Ui.tile(this, "Record", Ui.num(player.optLong("highestTrophies")), Ui.GOLD)));
        return card;
    }

    /**
     * Trophy movement over the battle log. Battles arrive newest first, so the
     * deltas are reversed to read left to right as time passes.
     */
    private View trendCard() {
        int n = battles.length();
        int[] deltas = new int[n];
        int[] form = new int[n];
        boolean anyTrophies = false;

        for (int i = 0; i < n; i++) {
            JSONObject entry = battles.optJSONObject(n - 1 - i);
            JSONObject battle = entry == null ? null : entry.optJSONObject("battle");
            deltas[i] = battle == null ? 0 : battle.optInt("trophyChange");
            anyTrophies |= deltas[i] != 0;
            form[i] = outcomeSign(battle);
        }

        // Ranked play reports no trophy change at all, so those players get a
        // win-loss curve rather than a flat line at zero.
        int[] series = anyTrophies ? deltas : form;
        String title = anyTrophies ? "Tendance trophees" : "Forme recente";
        String unit = anyTrophies ? "" : " combats";

        int total = 0;
        int high = 0;
        int low = 0;
        for (int v : series) {
            total += v;
            high = Math.max(high, total);
            low = Math.min(low, total);
        }

        LinearLayout card = Ui.card(this);
        card.addView(Ui.heading(this, R.drawable.trophy, title,
                Ui.chip(this, Ui.signed(total) + unit, Ui.BG,
                        total >= 0 ? Ui.WIN : Ui.LOSS)));

        if (high == 0 && low == 0) {
            card.addView(Ui.spacer(this, 10));
            card.addView(Ui.text(this, "Pas assez de combats pour tracer une courbe.",
                    13, Ui.MUTED));
            return card;
        }

        card.addView(Ui.spacer(this, 14));
        TrendChart chart = new TrendChart(this);
        chart.setDeltas(series);
        chart.setLayoutParams(new LinearLayout.LayoutParams(
                ViewGroup.LayoutParams.MATCH_PARENT, Ui.dp(this, 110)));
        card.addView(chart);

        card.addView(Ui.spacer(this, 12));
        LinearLayout foot = Ui.row(this);
        foot.addView(Ui.weighted(Ui.wrap(this,
                Ui.text(this, n + " combats", 12, Ui.MUTED)), 1f));
        foot.addView(Ui.bold(this, "haut " + Ui.signed(high), 12, Ui.WIN));
        foot.addView(Ui.bold(this, "   bas " + Ui.signed(low), 12, Ui.LOSS));
        card.addView(foot);
        return card;
    }

    /** +1 for a win, -1 for a loss, 0 for a draw or an unreadable battle. */
    private static int outcomeSign(JSONObject battle) {
        if (battle == null) {
            return 0;
        }
        if (battle.has("result")) {
            String r = battle.optString("result");
            return "victory".equals(r) ? 1 : "defeat".equals(r) ? -1 : 0;
        }
        if (battle.has("rank")) {
            JSONArray players = battle.optJSONArray("players");
            int cut = players != null && players.length() > 6 ? 4 : 2;
            return battle.optInt("rank") <= cut ? 1 : -1;
        }
        return 0;
    }

    private View trackingCard(Stats s) {
        LinearLayout card = Ui.card(this);
        card.addView(Ui.heading(this, R.drawable.trophy, "Tracking",
                Ui.chip(this, s.battles + " COMBATS", Ui.MUTED, Ui.CARD_SOFT)));

        card.addView(Ui.spacer(this, 12));
        LinearLayout rateRow = Ui.row(this);
        rateRow.addView(Ui.weighted(Ui.wrap(this,
                Ui.label(this, "Win rate", Ui.MUTED)), 1f));
        rateRow.addView(Ui.heavy(this, s.winRate() + "%", 20,
                s.winRate() >= 50 ? Ui.WIN : Ui.LOSS));
        card.addView(rateRow);
        card.addView(Ui.meter(this, s.winRate() / 100f,
                s.winRate() >= 50 ? Ui.WIN : Ui.LOSS));

        card.addView(Ui.tileRow(this,
                Ui.tile(this, "Victoires", String.valueOf(s.wins), Ui.WIN),
                Ui.tile(this, "Defaites", String.valueOf(s.losses), Ui.LOSS),
                Ui.tile(this, "Nuls", String.valueOf(s.draws), Ui.MUTED)));
        card.addView(Ui.tileRow(this,
                Ui.tile(this, "Star player", String.valueOf(s.starPlayer), Ui.GOLD),
                Ui.tile(this, "Brawlers", String.valueOf(s.brawlersUsed.size()), Ui.WHITE),
                Ui.tile(this, "Serie", s.streak + "V", Ui.LIME)));
        card.addView(Ui.tileRow(this,
                Ui.tile(this, "Gagnes", Ui.signed(s.trophiesWon), Ui.WIN),
                Ui.tile(this, "Perdus", "-" + Ui.num(s.trophiesLost), Ui.LOSS),
                Ui.tile(this, "Bilan", Ui.signed(s.trophyNet()),
                        s.trophyNet() >= 0 ? Ui.WIN : Ui.LOSS)));
        return card;
    }

    /** Win rate split per game mode, which the raw battle list does not show. */
    private View modesCard(Stats s) {
        LinearLayout card = Ui.card(this);
        card.addView(Ui.heading(this, R.drawable.skull, "Par mode", null));
        card.addView(Ui.spacer(this, 6));

        if (s.byMode.isEmpty()) {
            card.addView(Ui.text(this, "Aucun combat classe.", 13, Ui.MUTED));
            return card;
        }
        List<Map.Entry<String, int[]>> modes = new ArrayList<>(s.byMode.entrySet());
        Collections.sort(modes, new Comparator<Map.Entry<String, int[]>>() {
            @Override
            public int compare(Map.Entry<String, int[]> a, Map.Entry<String, int[]> b) {
                return (b.getValue()[0] + b.getValue()[1])
                        - (a.getValue()[0] + a.getValue()[1]);
            }
        });

        for (Map.Entry<String, int[]> e : modes) {
            int[] rec = e.getValue();
            int rate = Stats.rateOf(rec);
            LinearLayout block = Ui.column(this);
            block.setPadding(0, Ui.dp(this, 8), 0, Ui.dp(this, 8));

            LinearLayout line = Ui.row(this);
            ImageView glyph = new ImageView(this);
            glyph.setScaleType(ImageView.ScaleType.FIT_CENTER);
            LinearLayout.LayoutParams gl = new LinearLayout.LayoutParams(
                    Ui.dp(this, 26), Ui.dp(this, 26));
            gl.rightMargin = Ui.dp(this, 9);
            glyph.setLayoutParams(gl);
            ImageLoader.gameMode(glyph, rec.length > 2 ? rec[2] : -1);
            line.addView(glyph);

            line.addView(Ui.weighted(Ui.wrap(this,
                    Ui.bold(this, pretty(e.getKey()), 14, Ui.WHITE)), 1f));
            line.addView(Ui.bold(this, rec[0] + "V " + rec[1] + "D", 12, Ui.MUTED));
            TextView pct = Ui.heavy(this, "  " + rate + "%", 14,
                    rate >= 50 ? Ui.WIN : Ui.LOSS);
            line.addView(pct);
            block.addView(line);
            block.addView(Ui.meter(this, rate / 100f, rate >= 50 ? Ui.WIN : Ui.LOSS));
            card.addView(block);
        }
        return card;
    }

    private View heroBrawlerCard(final JSONObject b) {
        LinearLayout card = Ui.card(this);
        card.addView(Ui.heading(this, R.drawable.brawl, "Meilleur brawler",
                Ui.chip(this, "DETAIL", Ui.BG, Ui.LIME)));
        card.addView(Ui.spacer(this, 12));
        card.addView(brawlerHeader(b, 58));

        card.addView(Ui.spacer(this, 14));
        LinearLayout slots = Ui.row(this);
        slots.addView(slotStrip(b.optJSONArray("starPowers"), 2, KIND_STAR_POWER));
        slots.addView(Ui.spacer(this, 1));
        slots.addView(slotStrip(b.optJSONArray("gadgets"), 2, KIND_GADGET));
        slots.addView(Ui.spacer(this, 1));
        slots.addView(slotStrip(b.optJSONArray("gears"), 6, KIND_GEAR));
        card.addView(slots);

        card.setOnClickListener(new View.OnClickListener() {
            @Override
            public void onClick(View v) {
                detail = b;
                render();
            }
        });
        return card;
    }

    // ---------------------------------------------------------- brawlers tab

    private void renderBrawlersTab() {
        List<JSONObject> list = brawlerList();

        LinearLayout header = Ui.card(this);
        header.addView(Ui.heading(this, R.drawable.brawl, "Brawlers",
                Ui.chip(this, String.valueOf(list.size()), Ui.BG, Ui.LIME)));
        header.addView(Ui.spacer(this, 10));

        LinearLayout sorts = Ui.row(this);
        for (int i = 0; i < SORT_NAMES.length; i++) {
            sorts.addView(sortChip(i));
        }
        header.addView(sorts);
        content.addView(header);

        for (final JSONObject b : list) {
            LinearLayout card = Ui.card(this);
            card.setPadding(Ui.dp(this, 12), Ui.dp(this, 10),
                    Ui.dp(this, 12), Ui.dp(this, 10));
            card.addView(brawlerHeader(b, 42));
            card.setOnClickListener(new View.OnClickListener() {
                @Override
                public void onClick(View v) {
                    detail = b;
                    render();
                }
            });
            content.addView(card);
        }
    }

    private View sortChip(final int sort) {
        boolean active = sort == brawlerSort;
        TextView t = Ui.chip(this, SORT_NAMES[sort].toUpperCase(),
                active ? Ui.BG : Ui.MUTED, active ? Ui.LIME : Ui.CARD_SOFT);
        LinearLayout.LayoutParams lp = new LinearLayout.LayoutParams(
                ViewGroup.LayoutParams.WRAP_CONTENT, ViewGroup.LayoutParams.WRAP_CONTENT);
        lp.rightMargin = Ui.dp(this, 6);
        t.setLayoutParams(lp);
        t.setOnClickListener(new View.OnClickListener() {
            @Override
            public void onClick(View v) {
                brawlerSort = sort;
                render();
            }
        });
        return t;
    }

    private View brawlerHeader(JSONObject b, int portraitDp) {
        LinearLayout row = Ui.row(this);

        ImageView portrait = new ImageView(this);
        portrait.setScaleType(ImageView.ScaleType.FIT_CENTER);
        LinearLayout.LayoutParams ip = new LinearLayout.LayoutParams(
                Ui.dp(this, portraitDp), Ui.dp(this, portraitDp));
        ip.rightMargin = Ui.dp(this, 11);
        portrait.setLayoutParams(ip);
        portrait.setBackground(Ui.panel(this, Ui.CARD_SOFT, Ui.STROKE, 3));
        ImageLoader.brawler(portrait, b.optInt("id"));
        row.addView(portrait);

        LinearLayout info = Ui.column(this);
        LinearLayout nameRow = Ui.row(this);
        nameRow.addView(Ui.heavy(this, b.optString("name", "?").toUpperCase(),
                portraitDp >= 58 ? 19 : 16, Ui.WHITE));
        TextView power = Ui.chip(this, "P" + b.optInt("power"), Ui.BG, Ui.LIME);
        LinearLayout.LayoutParams pl = new LinearLayout.LayoutParams(
                ViewGroup.LayoutParams.WRAP_CONTENT, ViewGroup.LayoutParams.WRAP_CONTENT);
        pl.leftMargin = Ui.dp(this, 7);
        power.setLayoutParams(pl);
        nameRow.addView(power);
        info.addView(nameRow);

        JSONObject skin = b.optJSONObject("skin");
        String skinName = skin == null ? "" : skin.optString("name", "");
        LinearLayout sub = Ui.row(this);
        if (!skinName.isEmpty()) {
            sub.addView(Ui.bold(this, pretty(skinName), 11, Ui.LIME));
            sub.addView(Ui.text(this, "  •  ", 11, Ui.MUTED));
        }
        sub.addView(Ui.text(this, "Rang " + b.optInt("rank"), 11, Ui.MUTED));
        info.addView(sub);
        row.addView(Ui.weighted(info, 1f));

        LinearLayout right = Ui.column(this);
        right.setGravity(Gravity.END);
        right.addView(Ui.trophy(this, b.optLong("trophies"),
                portraitDp >= 58 ? 17 : 15, Ui.GOLD));
        TextView max = Ui.text(this,
                "max " + Ui.num(b.optLong("highestTrophies")), 10, Ui.MUTED);
        max.setGravity(Gravity.END);
        right.addView(max);
        row.addView(right);
        return row;
    }

    // ------------------------------------------------------- brawler detail

    private void renderBrawlerDetail(JSONObject b) {
        LinearLayout back = Ui.card(this);
        back.setPadding(Ui.dp(this, 12), Ui.dp(this, 11),
                Ui.dp(this, 12), Ui.dp(this, 11));
        back.addView(Ui.bold(this, "< Retour aux brawlers", 14, Ui.LIME));
        back.setOnClickListener(new View.OnClickListener() {
            @Override
            public void onClick(View v) {
                detail = null;
                render();
            }
        });
        content.addView(back);

        LinearLayout card = Ui.card(this);
        card.addView(brawlerHeader(b, 66));
        card.addView(Ui.tileRow(this,
                Ui.tile(this, "Rang", String.valueOf(b.optInt("rank")), Ui.WHITE),
                Ui.tile(this, "Puissance", String.valueOf(b.optInt("power")), Ui.LIME),
                Ui.tile(this, "Prestige", String.valueOf(b.optInt("prestigeLevel")), Ui.WHITE)));

        int current = b.optInt("currentWinStreak");
        int best = Math.max(b.optInt("maxWinStreak"), 1);
        card.addView(Ui.spacer(this, 14));
        LinearLayout streakRow = Ui.row(this);
        streakRow.addView(Ui.weighted(Ui.wrap(this,
                Ui.label(this, "Serie en cours", Ui.MUTED)), 1f));
        streakRow.addView(Ui.heavy(this, current + " / " + best, 15, Ui.GOLD));
        card.addView(streakRow);
        card.addView(Ui.meter(this, current / (float) best, Ui.GOLD));
        content.addView(card);

        content.addView(unlockCard("Star powers", b.optJSONArray("starPowers"),
                2, Ui.GOLD, KIND_STAR_POWER));
        content.addView(unlockCard("Gadgets", b.optJSONArray("gadgets"),
                2, Ui.WIN, KIND_GADGET));
        content.addView(unlockCard("Gears", b.optJSONArray("gears"),
                6, Ui.LIME, KIND_GEAR));
    }

    /** Lists owned unlocks by name, then how many slots are still empty. */
    private View unlockCard(String title, JSONArray items, int total, int color, int kind) {
        LinearLayout card = Ui.card(this);
        int owned = count(items);
        card.addView(Ui.heading(this, title,
                Ui.chip(this, owned + "/" + total, owned > 0 ? Ui.BG : Ui.MUTED,
                        owned > 0 ? color : Ui.CARD_SOFT)));
        card.addView(Ui.spacer(this, 10));
        card.addView(slotStrip(items, total, kind));

        if (owned == 0) {
            card.addView(Ui.spacer(this, 10));
            card.addView(Ui.text(this, "Aucun debloque.", 13, Ui.MUTED));
            return card;
        }
        card.addView(Ui.spacer(this, 4));
        for (int i = 0; i < items.length(); i++) {
            JSONObject it = items.optJSONObject(i);
            if (it == null) {
                continue;
            }
            LinearLayout row = Ui.row(this);
            row.setPadding(0, Ui.dp(this, 8), 0, Ui.dp(this, 8));

            ImageView art = new ImageView(this);
            art.setScaleType(ImageView.ScaleType.FIT_CENTER);
            LinearLayout.LayoutParams al = new LinearLayout.LayoutParams(
                    Ui.dp(this, 26), Ui.dp(this, 26));
            al.rightMargin = Ui.dp(this, 10);
            art.setLayoutParams(al);
            int id = it.optInt("id");
            if (kind == KIND_STAR_POWER) {
                ImageLoader.starPower(art, id);
            } else if (kind == KIND_GADGET) {
                ImageLoader.gadget(art, id);
            } else {
                ImageLoader.gear(art, id);
            }
            row.addView(art);

            row.addView(Ui.weighted(Ui.wrap(this,
                    Ui.bold(this, pretty(it.optString("name", "?")), 14, Ui.WHITE)), 1f));
            if (it.has("level")) {
                row.addView(Ui.chip(this, "NIV " + it.optInt("level"), color, Ui.CARD_SOFT));
            }
            card.addView(row);
        }
        return card;
    }

    // --------------------------------------------------------------- battles

    private View battlesCard() {
        LinearLayout card = Ui.card(this);
        Stats s = Stats.from(battles, tag);

        LinearLayout counts = Ui.row(this);
        counts.addView(Ui.heavy(this, s.wins + "V", 14, Ui.WIN));
        counts.addView(Ui.heavy(this, "  " + s.losses + "D", 14, Ui.LOSS));
        card.addView(Ui.heading(this, R.drawable.skull, "Combats", counts));
        card.addView(Ui.spacer(this, 4));

        int limit = Math.min(battles.length(), 25);
        for (int i = 0; i < limit; i++) {
            JSONObject entry = battles.optJSONObject(i);
            if (entry != null) {
                card.addView(battleRow(entry));
            }
        }
        return card;
    }

    private View battleRow(JSONObject entry) {
        JSONObject battle = entry.optJSONObject("battle");
        JSONObject event = entry.optJSONObject("event");

        String mode = pretty(event != null && !event.optString("mode").isEmpty()
                ? event.optString("mode")
                : (battle == null ? "?" : battle.optString("mode", "?")));
        String map = event == null ? "" : event.optString("map", "");

        String outcome = "-";
        int outcomeColor = Ui.MUTED;
        if (battle != null) {
            if (battle.has("result")) {
                String r = battle.optString("result");
                if ("victory".equals(r)) {
                    outcome = "Victoire";
                    outcomeColor = Ui.WIN;
                } else if ("defeat".equals(r)) {
                    outcome = "Defaite";
                    outcomeColor = Ui.LOSS;
                } else {
                    outcome = "Nul";
                    outcomeColor = Ui.DRAW;
                }
            } else if (battle.has("rank")) {
                int rank = battle.optInt("rank");
                outcome = "Rang " + rank;
                outcomeColor = rank <= 4 ? Ui.WIN : Ui.LOSS;
            }
        }

        LinearLayout row = Ui.row(this);
        row.setPadding(0, Ui.dp(this, 8), 0, Ui.dp(this, 8));

        ImageView modeIcon = new ImageView(this);
        modeIcon.setScaleType(ImageView.ScaleType.FIT_CENTER);
        LinearLayout.LayoutParams ml = new LinearLayout.LayoutParams(
                Ui.dp(this, 30), Ui.dp(this, 30));
        ml.rightMargin = Ui.dp(this, 10);
        modeIcon.setLayoutParams(ml);
        ImageLoader.gameMode(modeIcon, event == null ? -1 : event.optInt("modeId", -1));
        row.addView(modeIcon);

        LinearLayout left = Ui.column(this);
        left.addView(Ui.bold(this, mode, 14, Ui.WHITE));
        if (!map.isEmpty()) {
            left.addView(Ui.text(this, map, 11, Ui.MUTED));
        }
        row.addView(Ui.weighted(left, 1f));

        LinearLayout right = Ui.column(this);
        right.setGravity(Gravity.END);
        right.addView(Ui.bold(this, outcome, 13, outcomeColor));
        int change = battle == null ? 0 : battle.optInt("trophyChange");
        if (change != 0) {
            TextView delta = Ui.heavy(this, Ui.signed(change), 11,
                    change > 0 ? Ui.WIN : Ui.LOSS);
            delta.setGravity(Gravity.END);
            right.addView(delta);
        }
        row.addView(right);
        return row;
    }

    // ------------------------------------------------------------ events tab

    private void renderEventsTab() {
        if (events == null) {
            content.addView(loadingCard("Events"));
            loadEvents();
            return;
        }
        LinearLayout header = Ui.card(this);
        header.addView(Ui.heading(this, "Events en cours",
                Ui.chip(this, String.valueOf(events.length()), Ui.BG, Ui.LIME)));
        content.addView(header);

        for (int i = 0; i < events.length(); i++) {
            JSONObject slot = events.optJSONObject(i);
            if (slot != null) {
                content.addView(eventCard(slot));
            }
        }
    }

    private View eventCard(JSONObject slot) {
        JSONObject event = slot.optJSONObject("event");
        if (event == null) {
            return new View(this);
        }
        LinearLayout card = Ui.card(this);
        card.setPadding(Ui.dp(this, 12), Ui.dp(this, 11),
                Ui.dp(this, 12), Ui.dp(this, 11));

        LinearLayout row = Ui.row(this);

        ImageView glyph = new ImageView(this);
        glyph.setScaleType(ImageView.ScaleType.FIT_CENTER);
        LinearLayout.LayoutParams gl = new LinearLayout.LayoutParams(
                Ui.dp(this, 38), Ui.dp(this, 38));
        gl.rightMargin = Ui.dp(this, 9);
        glyph.setLayoutParams(gl);
        ImageLoader.gameMode(glyph, event.optInt("modeId", -1));
        row.addView(glyph);

        ImageView art = new ImageView(this);
        art.setScaleType(ImageView.ScaleType.CENTER_CROP);
        LinearLayout.LayoutParams al = new LinearLayout.LayoutParams(
                Ui.dp(this, 56), Ui.dp(this, 42));
        al.rightMargin = Ui.dp(this, 11);
        art.setLayoutParams(al);
        art.setBackground(Ui.panel(this, Ui.CARD_SOFT, Ui.STROKE, 3));
        art.setClipToOutline(true);
        ImageLoader.map(art, event.optInt("id"));
        row.addView(art);

        LinearLayout info = Ui.column(this);
        info.addView(Ui.heavy(this,
                pretty(event.optString("mode", "?")).toUpperCase(), 15, Ui.WHITE));
        info.addView(Ui.text(this, event.optString("map", ""), 12, Ui.MUTED));
        row.addView(Ui.weighted(info, 1f));

        String left = remaining(slot.optString("endTime", ""));
        LinearLayout right = Ui.column(this);
        right.setGravity(Gravity.END);
        right.addView(Ui.label(this, "Reste", Ui.MUTED));
        TextView time = Ui.heavy(this, left, 15, left.equals("termine") ? Ui.MUTED : Ui.LIME);
        time.setGravity(Gravity.END);
        right.addView(time);
        row.addView(right);

        card.addView(row);
        return card;
    }

    /** A live taste of the rotation, so the landing screen carries real data. */
    private View eventsPreviewCard() {
        LinearLayout card = Ui.card(this);
        card.addView(Ui.heading(this, "Events en cours",
                Ui.chip(this, "TOUT VOIR", Ui.BG, Ui.LIME)));
        card.addView(Ui.spacer(this, 4));

        if (events == null) {
            card.addView(Ui.text(this, "Chargement...", 13, Ui.MUTED));
            loadEvents();
        } else if (events.length() == 0) {
            card.addView(Ui.text(this, "Rotation indisponible.", 13, Ui.MUTED));
        } else {
            int limit = Math.min(events.length(), 3);
            for (int i = 0; i < limit; i++) {
                JSONObject slot = events.optJSONObject(i);
                JSONObject event = slot == null ? null : slot.optJSONObject("event");
                if (event == null) {
                    continue;
                }
                LinearLayout row = Ui.row(this);
                row.setPadding(0, Ui.dp(this, 8), 0, Ui.dp(this, 8));

                ImageView glyph = new ImageView(this);
                glyph.setScaleType(ImageView.ScaleType.FIT_CENTER);
                LinearLayout.LayoutParams gl = new LinearLayout.LayoutParams(
                        Ui.dp(this, 32), Ui.dp(this, 32));
                gl.rightMargin = Ui.dp(this, 10);
                glyph.setLayoutParams(gl);
                ImageLoader.gameMode(glyph, event.optInt("modeId", -1));
                row.addView(glyph);

                LinearLayout info = Ui.column(this);
                info.addView(Ui.bold(this, pretty(event.optString("mode", "?")),
                        14, Ui.WHITE));
                info.addView(Ui.text(this, event.optString("map", ""), 11, Ui.MUTED));
                row.addView(Ui.weighted(info, 1f));

                row.addView(Ui.bold(this, remaining(slot.optString("endTime", "")),
                        12, Ui.LIME));
                card.addView(row);
            }
        }

        card.setOnClickListener(new View.OnClickListener() {
            @Override
            public void onClick(View v) {
                selectTab(TAB_EVENTS);
            }
        });
        return card;
    }

    /**
     * Time left before a slot rotates, from an API timestamp such as
     * "20260913T080000.000Z".
     */
    private static String remaining(String endTime) {
        if (endTime.length() < 15) {
            return "?";
        }
        try {
            java.util.Calendar cal = java.util.Calendar.getInstance(
                    java.util.TimeZone.getTimeZone("UTC"));
            cal.clear();
            cal.set(Integer.parseInt(endTime.substring(0, 4)),
                    Integer.parseInt(endTime.substring(4, 6)) - 1,
                    Integer.parseInt(endTime.substring(6, 8)),
                    Integer.parseInt(endTime.substring(9, 11)),
                    Integer.parseInt(endTime.substring(11, 13)),
                    Integer.parseInt(endTime.substring(13, 15)));

            long ms = cal.getTimeInMillis() - System.currentTimeMillis();
            if (ms <= 0) {
                return "termine";
            }
            long minutes = ms / 60000;
            long hours = minutes / 60;
            if (hours >= 24) {
                return (hours / 24) + "j " + (hours % 24) + "h";
            }
            return hours > 0 ? hours + "h " + (minutes % 60) + "m" : minutes + "m";
        } catch (NumberFormatException e) {
            return "?";
        }
    }

    // -------------------------------------------------------------- club tab

    private void renderClubTab() {
        if (club == null) {
            JSONObject c = player == null ? null : player.optJSONObject("club");
            String clubTag = c == null ? "" : c.optString("tag", "");
            if (clubTag.isEmpty()) {
                LinearLayout card = Ui.card(this);
                card.addView(Ui.heading(this, "Club", null));
                card.addView(Ui.spacer(this, 10));
                card.addView(Ui.text(this, player == null
                        ? "Choisis CLUBS en haut et entre un tag de club, "
                        + "ou cherche d'abord un joueur."
                        : "Ce joueur n'est dans aucun club.", 14, Ui.MUTED));
                content.addView(card);
                return;
            }
            content.addView(loadingCard(c.optString("name", "Club")));
            loadClub();
            return;
        }

        LinearLayout card = Ui.card(this);
        LinearLayout head = Ui.row(this);
        ImageView badge = new ImageView(this);
        badge.setScaleType(ImageView.ScaleType.FIT_CENTER);
        LinearLayout.LayoutParams bl = new LinearLayout.LayoutParams(
                Ui.dp(this, 50), Ui.dp(this, 50));
        bl.rightMargin = Ui.dp(this, 11);
        badge.setLayoutParams(bl);
        ImageLoader.clubBadge(badge, club.optInt("badgeId"));
        head.addView(badge);

        LinearLayout titles = Ui.column(this);
        titles.addView(Ui.heavy(this,
                club.optString("name", "?").toUpperCase(), 20, Ui.WHITE));
        titles.addView(Ui.text(this, club.optString("tag", ""), 12, Ui.MUTED));
        head.addView(Ui.weighted(titles, 1f));
        card.addView(head);

        String desc = club.optString("description", "");
        if (!desc.isEmpty()) {
            TextView d = Ui.text(this, desc, 13, Ui.MUTED);
            d.setPadding(0, Ui.dp(this, 10), 0, 0);
            card.addView(d);
        }
        JSONArray members = club.optJSONArray("members");
        card.addView(Ui.tileRow(this,
                Ui.tile(this, "Trophees", Ui.num(club.optLong("trophies")), Ui.GOLD),
                Ui.tile(this, "Requis", Ui.num(club.optLong("requiredTrophies")), Ui.WHITE),
                Ui.tile(this, "Membres",
                        (members == null ? 0 : members.length()) + "/30", Ui.WHITE)));
        content.addView(card);

        if (members == null) {
            return;
        }
        LinearLayout list = Ui.card(this);
        list.addView(Ui.heading(this, "Membres", null));
        list.addView(Ui.spacer(this, 4));
        for (int i = 0; i < members.length(); i++) {
            JSONObject m = members.optJSONObject(i);
            if (m == null) {
                continue;
            }
            LinearLayout row = Ui.row(this);
            row.setPadding(0, Ui.dp(this, 8), 0, Ui.dp(this, 8));

            TextView pos = Ui.heavy(this, String.valueOf(i + 1), 13, Ui.MUTED);
            pos.setWidth(Ui.dp(this, 28));
            row.addView(pos);

            LinearLayout info = Ui.column(this);
            info.addView(Ui.bold(this, m.optString("name", "?"), 14, Ui.WHITE));
            info.addView(Ui.text(this, pretty(m.optString("role", "")), 11, Ui.MUTED));
            row.addView(Ui.weighted(info, 1f));

            row.addView(Ui.trophy(this, m.optLong("trophies"), 13, Ui.GOLD));
            list.addView(row);
        }
        content.addView(list);
    }

    // ---------------------------------------------------------- rankings tab

    private void renderRankingsTab() {
        LinearLayout header = Ui.card(this);
        header.addView(Ui.heading(this, R.drawable.trophy, "Classement", null));
        header.addView(Ui.spacer(this, 10));

        LinearLayout controls = Ui.row(this);
        controls.addView(rankChip("JOUEURS", rankKind == MODE_PLAYER, new Runnable() {
            @Override
            public void run() {
                rankKind = MODE_PLAYER;
                rankings = null;
            }
        }));
        controls.addView(rankChip("CLUBS", rankKind == MODE_CLUB, new Runnable() {
            @Override
            public void run() {
                rankKind = MODE_CLUB;
                rankings = null;
            }
        }));
        controls.addView(rankChip("MONDE", "global".equals(region), new Runnable() {
            @Override
            public void run() {
                region = "global";
                rankings = null;
            }
        }));
        controls.addView(rankChip("FR", "fr".equals(region), new Runnable() {
            @Override
            public void run() {
                region = "fr";
                rankings = null;
            }
        }));
        header.addView(controls);
        content.addView(header);

        if (rankings == null) {
            content.addView(loadingCard("Chargement"));
            loadRankings();
            return;
        }

        LinearLayout card = Ui.card(this);
        for (int i = 0; i < rankings.length(); i++) {
            JSONObject p = rankings.optJSONObject(i);
            if (p == null) {
                continue;
            }
            LinearLayout row = Ui.row(this);
            row.setPadding(0, Ui.dp(this, 8), 0, Ui.dp(this, 8));

            int rank = p.optInt("rank", i + 1);
            TextView pos = Ui.heavy(this, String.valueOf(rank), 14,
                    rank <= 3 ? Ui.GOLD : Ui.MUTED);
            pos.setWidth(Ui.dp(this, 30));
            row.addView(pos);

            ImageView art = new ImageView(this);
            art.setScaleType(ImageView.ScaleType.FIT_CENTER);
            LinearLayout.LayoutParams il = new LinearLayout.LayoutParams(
                    Ui.dp(this, 30), Ui.dp(this, 30));
            il.rightMargin = Ui.dp(this, 9);
            art.setLayoutParams(il);
            if (rankKind == MODE_CLUB) {
                ImageLoader.clubBadge(art, p.optInt("badgeId"));
            } else {
                JSONObject ic = p.optJSONObject("icon");
                ImageLoader.profileIcon(art, ic == null ? 0 : ic.optInt("id"));
            }
            row.addView(art);

            LinearLayout info = Ui.column(this);
            info.addView(Ui.bold(this, p.optString("name", "?"), 14, Ui.WHITE));
            String sub;
            if (rankKind == MODE_CLUB) {
                sub = p.optInt("memberCount") + " membres";
            } else {
                JSONObject pc = p.optJSONObject("club");
                String cn = pc == null ? "" : pc.optString("name", "");
                sub = cn.isEmpty() ? p.optString("tag", "") : cn;
            }
            info.addView(Ui.text(this, sub, 11, Ui.MUTED));
            row.addView(Ui.weighted(info, 1f));

            row.addView(Ui.trophy(this, p.optLong("trophies"), 13, Ui.GOLD));
            card.addView(row);
        }
        content.addView(card);
    }

    private View rankChip(String title, boolean active, final Runnable action) {
        TextView t = Ui.chip(this, title, active ? Ui.BG : Ui.MUTED,
                active ? Ui.LIME : Ui.CARD_SOFT);
        LinearLayout.LayoutParams lp = new LinearLayout.LayoutParams(
                ViewGroup.LayoutParams.WRAP_CONTENT, ViewGroup.LayoutParams.WRAP_CONTENT);
        lp.rightMargin = Ui.dp(this, 6);
        t.setLayoutParams(lp);
        t.setOnClickListener(new View.OnClickListener() {
            @Override
            public void onClick(View v) {
                action.run();
                render();
            }
        });
        return t;
    }

    // --------------------------------------------------------------- helpers

    private View loadingCard(String title) {
        LinearLayout card = Ui.card(this);
        card.addView(Ui.heading(this, title, null));
        card.addView(Ui.spacer(this, 10));
        card.addView(Ui.text(this, "Chargement...", 14, Ui.MUTED));
        return card;
    }

    private static int count(JSONArray a) {
        return a == null ? 0 : a.length();
    }

    private static final int KIND_STAR_POWER = 0;
    private static final int KIND_GADGET = 1;
    private static final int KIND_GEAR = 2;

    /**
     * One slot per possible unlock: owned ones show the game's own artwork,
     * the rest a dimmed padlock, so what is missing is visible at a glance.
     */
    private View slotStrip(JSONArray items, int total, int kind) {
        LinearLayout strip = Ui.row(this);
        int owned = count(items);

        for (int i = 0; i < total; i++) {
            ImageView slot = new ImageView(this);
            slot.setScaleType(ImageView.ScaleType.FIT_CENTER);
            LinearLayout.LayoutParams lp = new LinearLayout.LayoutParams(
                    Ui.dp(this, 29), Ui.dp(this, 29));
            lp.rightMargin = Ui.dp(this, 4);
            slot.setLayoutParams(lp);

            if (i < owned) {
                JSONObject it = items.optJSONObject(i);
                int id = it == null ? 0 : it.optInt("id");
                if (kind == KIND_STAR_POWER) {
                    ImageLoader.starPower(slot, id);
                } else if (kind == KIND_GADGET) {
                    ImageLoader.gadget(slot, id);
                } else {
                    ImageLoader.gear(slot, id);
                }
            } else {
                int pad = Ui.dp(this, 6);
                slot.setPadding(pad, pad, pad, pad);
                slot.setImageResource(R.drawable.ic_lock);
                slot.setColorFilter(Ui.MUTED);
                slot.setAlpha(0.5f);
                slot.setBackground(Ui.panel(this, Ui.CARD_SOFT, Ui.STROKE, 3));
            }
            strip.addView(slot);
        }
        return strip;
    }

    private List<JSONObject> brawlerList() {
        List<JSONObject> list = new ArrayList<>();
        JSONArray arr = player == null ? null : player.optJSONArray("brawlers");
        if (arr == null) {
            return list;
        }
        for (int i = 0; i < arr.length(); i++) {
            JSONObject b = arr.optJSONObject(i);
            if (b != null) {
                list.add(b);
            }
        }
        Collections.sort(list, new Comparator<JSONObject>() {
            @Override
            public int compare(JSONObject a, JSONObject b) {
                switch (brawlerSort) {
                    case SORT_RANK:
                        return b.optInt("rank") - a.optInt("rank");
                    case SORT_POWER:
                        return b.optInt("power") - a.optInt("power");
                    case SORT_NAME:
                        return a.optString("name").compareTo(b.optString("name"));
                    default:
                        return b.optInt("trophies") - a.optInt("trophies");
                }
            }
        });
        return list;
    }

    private JSONObject topBrawler() {
        JSONArray arr = player == null ? null : player.optJSONArray("brawlers");
        if (arr == null) {
            return null;
        }
        JSONObject best = null;
        for (int i = 0; i < arr.length(); i++) {
            JSONObject b = arr.optJSONObject(i);
            if (b != null && (best == null
                    || b.optInt("trophies") > best.optInt("trophies"))) {
                best = b;
            }
        }
        return best;
    }

    /** "gemGrab" -> "Gem Grab", "SHELLY" -> "Shelly". */
    static String pretty(String raw) {
        if (raw == null || raw.isEmpty()) {
            return "";
        }
        String s = raw.replace('_', ' ');
        StringBuilder out = new StringBuilder();
        boolean newWord = true;
        for (int i = 0; i < s.length(); i++) {
            char ch = s.charAt(i);
            boolean boundary = i > 0 && Character.isUpperCase(ch)
                    && Character.isLowerCase(s.charAt(i - 1));
            if (boundary) {
                out.append(' ');
                newWord = true;
            }
            if (ch == ' ') {
                out.append(ch);
                newWord = true;
            } else {
                out.append(newWord ? Character.toUpperCase(ch) : Character.toLowerCase(ch));
                newWord = false;
            }
        }
        return out.toString();
    }

    private void setStatus(String message, int color) {
        if (message == null || message.isEmpty()) {
            status.setVisibility(View.GONE);
            return;
        }
        status.setText(message);
        status.setTextColor(color);
        status.setVisibility(View.VISIBLE);
    }

    private void hideKeyboard() {
        InputMethodManager imm =
                (InputMethodManager) getSystemService(Context.INPUT_METHOD_SERVICE);
        if (imm != null && getCurrentFocus() != null) {
            imm.hideSoftInputFromWindow(getCurrentFocus().getWindowToken(), 0);
        }
    }
}
