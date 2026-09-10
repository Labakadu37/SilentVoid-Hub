import com.reandroid.apk.ApkBundle;
import com.reandroid.apk.ApkModule;
import com.reandroid.apk.APKLogger;
import java.io.File;

// Merge tous les split APKs d'un dossier en un APK universel unique
// (fusionne resources.arsc, libs, assets — comme le fait Play à l'install)
public class Merge {
    public static void main(String[] args) throws Exception {
        File dir = new File(args[0]);   // dossier contenant tous les splits
        File out = new File(args[1]);   // APK universel de sortie

        ApkBundle bundle = new ApkBundle();
        bundle.setAPKLogger(new APKLogger() {
            public void logMessage(String msg) { System.out.println("[i] " + msg); }
            public void logError(String msg, Throwable tr) {
                System.out.println("[!] " + msg + (tr != null ? " : " + tr.getMessage() : ""));
            }
            public void logVerbose(String msg) { }
        });

        System.out.println("Chargement des splits depuis : " + dir);
        bundle.loadApkDirectory(dir);
        System.out.println("Modules charges : " + bundle.listModuleNames());

        ApkModule merged = bundle.mergeModules();
        System.out.println("Merge OK. Ecriture vers : " + out);
        merged.writeApk(out);
        bundle.close();
        System.out.println("TERMINE : " + out + " (" + (out.length()/1024/1024) + " Mo)");
    }
}
