'use strict';

// ============================================================
//  BSD Info - Frida Agent
//  Affiche le tag (#XXXXXX) des joueurs adverses en game
//  Hook SSL_read → scan protobuf → overlay Android
// ============================================================

const BS_TAG_RE = /#[0289PYLQGRJCUV]{3,9}/g;
const foundTags  = new Set();
let   overlayRef = null;

// ---- Attente que libg.so et libssl.so soient chargés ----
function waitForModule(name, cb) {
    const mod = Process.findModuleByName(name);
    if (mod) { cb(mod); return; }
    const id = setInterval(function () {
        const m = Process.findModuleByName(name);
        if (m) { clearInterval(id); cb(m); }
    }, 500);
}

// ---- Overlay flottant (s'affiche par-dessus le jeu) ----
function buildOverlay() {
    Java.perform(function () {
        try {
            const ctx = Java.use('android.app.ActivityThread')
                .currentApplication()
                .getApplicationContext();

            const WM      = ctx.getSystemService('window');
            const LP      = Java.use('android.view.WindowManager$LayoutParams');
            const TV      = Java.use('android.widget.TextView');
            const LL      = Java.use('android.widget.LinearLayout');
            const Color   = Java.use('android.graphics.Color');
            const Gravity = Java.use('android.view.Gravity');
            const Typeface = Java.use('android.graphics.Typeface');

            const layout = LL.$new(ctx);
            layout.setOrientation(1); // VERTICAL
            layout.setPadding(16, 12, 16, 12);
            layout.setBackgroundColor(Color.parseColor('#CC000000'));

            // Titre
            const title = TV.$new(ctx);
            title.setText('ℹ Players');
            title.setTextColor(Color.parseColor('#FFFFFF'));
            title.setTextSize(11);
            title.setTypeface(Typeface.DEFAULT_BOLD);
            layout.addView(title);

            overlayRef = { layout: layout, context: ctx };

            const params = LP.$new(
                LP.TYPE_APPLICATION_OVERLAY.value,
                LP.FLAG_NOT_FOCUSABLE.value | LP.FLAG_NOT_TOUCH_MODAL.value,
                -3 // PixelFormat.TRANSLUCENT
            );
            params.gravity.value = Gravity.TOP.value | Gravity.LEFT.value;
            params.x.value = 10;
            params.y.value = 80;
            params.width.value  = LP.WRAP_CONTENT.value;
            params.height.value = LP.WRAP_CONTENT.value;

            Java.scheduleOnMainThread(function () {
                WM.addView(layout, params);
            });
        } catch (e) {
            send('[BSD] overlay error: ' + e);
        }
    });
}

// ---- Ajoute un tag dans l'overlay ----
function addTagToOverlay(tag) {
    if (foundTags.has(tag)) return;
    foundTags.add(tag);
    send('[BSD] tag trouvé : ' + tag);

    if (!overlayRef) return;
    Java.perform(function () {
        try {
            const TV     = Java.use('android.widget.TextView');
            const Color  = Java.use('android.graphics.Color');
            const row    = TV.$new(overlayRef.context);
            row.setText(tag);
            row.setTextColor(Color.parseColor('#FFE082')); // jaune BS
            row.setTextSize(10);
            Java.scheduleOnMainThread(function () {
                overlayRef.layout.addView(row);
            });
        } catch (e) {}
    });
}

// ---- Vider l'overlay entre les games ----
function clearOverlay() {
    foundTags.clear();
    if (!overlayRef) return;
    Java.perform(function () {
        Java.scheduleOnMainThread(function () {
            overlayRef.layout.removeAllViews();
        });
    });
}

// ---- Hook SSL_read (libssl ou libboringssl) ----
function hookSSL(mod) {
    const sslRead = mod.findExportByName('SSL_read');
    if (!sslRead) { send('[BSD] SSL_read introuvable dans ' + mod.name); return; }

    Interceptor.attach(sslRead, {
        onEnter: function (args) {
            this.buf  = args[1];
            this.size = args[2].toInt32();
        },
        onLeave: function (retval) {
            const n = retval.toInt32();
            if (n <= 0 || !this.buf) return;
            try {
                const bytes = Memory.readByteArray(this.buf, Math.min(n, 4096));
                const text  = String.fromCharCode.apply(null, new Uint8Array(bytes));
                const hits  = text.match(BS_TAG_RE);
                if (hits) hits.forEach(addTagToOverlay);
            } catch (_) {}
        }
    });
    send('[BSD] SSL_read hooké sur ' + mod.name);
}

// ---- Hook libg.so : scan mémoire pour tags (backup si SSL chiffré) ----
function scanLibgForTags(mod) {
    // On scanne le segment .data de libg.so toutes les 5 secondes
    // Cherche le pattern de tag BS en mémoire vive
    const scanLoop = setInterval(function () {
        try {
            Process.enumerateRanges('r--').forEach(function (range) {
                if (range.size > 4 * 1024 * 1024) return; // skip très grosses pages
                Memory.scan(range.base, range.size, '23 ?? ?? ?? ?? ?? ?? ?? 00', {
                    // '23' = '#' en ASCII
                    onMatch: function (addr) {
                        try {
                            const s = Memory.readUtf8String(addr, 12);
                            if (BS_TAG_RE.test(s)) {
                                BS_TAG_RE.lastIndex = 0;
                                addTagToOverlay(s.match(BS_TAG_RE)[0]);
                            }
                        } catch (_) {}
                    },
                    onComplete: function () {}
                });
            });
        } catch (_) {}
    }, 5000);
}

// ---- Point d'entrée ----
buildOverlay();

// SSL (BoringSSL embarqué dans libg.so pour BS)
waitForModule('libg.so', function (mod) {
    // BS n'utilise pas libssl.so séparé : BoringSSL est linké statiquement
    // On hook via le nom de symbole exporté ou par signature
    const bsslRead = mod.findExportByName('SSL_read');
    if (bsslRead) {
        Interceptor.attach(bsslRead, {
            onEnter: function (args) {
                this.buf  = args[1];
                this.size = args[2].toInt32();
            },
            onLeave: function (retval) {
                const n = retval.toInt32();
                if (n <= 0 || !this.buf) return;
                try {
                    const bytes = Memory.readByteArray(this.buf, Math.min(n, 2048));
                    const text  = String.fromCharCode.apply(null, new Uint8Array(bytes));
                    const hits  = text.match(BS_TAG_RE);
                    if (hits) hits.forEach(addTagToOverlay);
                } catch (_) {}
            }
        });
        send('[BSD] SSL_read hooké dans libg.so');
    } else {
        send('[BSD] SSL_read non exporté — fallback scan mémoire');
        scanLibgForTags(mod);
    }
});

// Libssl séparé (fallback)
waitForModule('libssl.so', hookSSL);

// Reset entre les parties : écoute un signal de l'app
recv('reset', function () { clearOverlay(); });

send('[BSD] agent chargé');
