# ─────────────────────────────────────────────────────────────────────────────
#  Native.smali — pont vers libJZS.so
#  Charge la lib native au chargement de la classe et expose nGetBuild().
# ─────────────────────────────────────────────────────────────────────────────

.class public Lcom/jzsbrawl/Native;
.super Ljava/lang/Object;

# Charge libJZS.so quand la classe est initialisée
.method static constructor <clinit>()V
    .locals 1
    const-string v0, "JZS"
    invoke-static {v0}, Ljava/lang/System;->loadLibrary(Ljava/lang/String;)V
    return-void
.end method

.method public constructor <init>()V
    .locals 0
    invoke-direct {p0}, Ljava/lang/Object;-><init>()V
    return-void
.end method

# int nGetBuild() — implémentée dans libJZS.so, renvoie 69230 si la lib tourne
.method public static native nGetBuild()I
.end method
