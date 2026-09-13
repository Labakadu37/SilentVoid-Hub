import java.nio.file.Files;
import java.nio.file.Paths;
import java.security.SecureRandom;
import java.util.Base64;

import javax.crypto.Cipher;
import javax.crypto.spec.IvParameterSpec;
import javax.crypto.spec.SecretKeySpec;

/**
 * Build-time secret packer.
 *
 * Encrypts the API token with a fresh random AES key and emits Secrets.java,
 * which carries the ciphertext, the key split into XOR-masked parts, and the
 * expected signing-certificate hash. The runtime uses the same JCE primitives,
 * so the two always agree.
 *
 * This is obfuscation, not a vault: the key ships inside the app and can be
 * recovered by someone who reverses the decrypt path. It defeats casual
 * extraction (a plaintext token is grep-able in seconds), not a determined
 * analyst.
 *
 * Usage: java Enc <token.txt> <cert.der> <out/Secrets.java>
 *
 * The certificate hash is computed here, the same way Guard does at runtime
 * (SHA-256 of the DER bytes, standard Base64), so the two cannot drift.
 */
public final class Enc {

    public static void main(String[] args) throws Exception {
        String token = new String(Files.readAllBytes(Paths.get(args[0]))).trim();
        byte[] certDer = Files.readAllBytes(Paths.get(args[1]));
        String outPath = args[2];

        String certHash = Base64.getEncoder().encodeToString(
                java.security.MessageDigest.getInstance("SHA-256").digest(certDer));

        SecureRandom rng = new SecureRandom();
        byte[] key = new byte[16];
        byte[] iv = new byte[16];
        byte[] mask = new byte[16];
        rng.nextBytes(key);
        rng.nextBytes(iv);
        rng.nextBytes(mask);

        Cipher c = Cipher.getInstance("AES/CBC/PKCS5Padding");
        c.init(Cipher.ENCRYPT_MODE, new SecretKeySpec(key, "AES"),
                new IvParameterSpec(iv));
        String ct = Base64.getEncoder().encodeToString(c.doFinal(token.getBytes("UTF-8")));

        // The key is never stored directly; it is XOR-masked and reassembled.
        byte[] masked = new byte[16];
        for (int i = 0; i < 16; i++) {
            masked[i] = (byte) (key[i] ^ mask[i]);
        }

        StringBuilder sb = new StringBuilder();
        sb.append("package com.jzs.brawltracker;\n\n");
        sb.append("import android.util.Base64;\n");
        sb.append("import javax.crypto.Cipher;\n");
        sb.append("import javax.crypto.spec.IvParameterSpec;\n");
        sb.append("import javax.crypto.spec.SecretKeySpec;\n\n");
        sb.append("/** Generated at build time. Do not edit; do not commit. */\n");
        sb.append("final class Secrets {\n\n");
        sb.append("    static final String CERT_SHA256 = \"").append(certHash).append("\";\n\n");
        sb.append(bytesField("A", masked));
        sb.append(bytesField("B", mask));
        sb.append(bytesField("C", iv));
        sb.append("    private static final String D = \"").append(ct).append("\";\n\n");
        sb.append("    static String token() {\n");
        sb.append("        try {\n");
        sb.append("            byte[] k = new byte[16];\n");
        sb.append("            for (int i = 0; i < 16; i++) { k[i] = (byte) (A[i] ^ B[i]); }\n");
        sb.append("            Cipher c = Cipher.getInstance(\"AES/CBC/PKCS5Padding\");\n");
        sb.append("            c.init(Cipher.DECRYPT_MODE, new SecretKeySpec(k, \"AES\"),\n");
        sb.append("                    new IvParameterSpec(C));\n");
        sb.append("            return new String(c.doFinal(Base64.decode(D, Base64.DEFAULT)), \"UTF-8\");\n");
        sb.append("        } catch (Exception e) {\n");
        sb.append("            return \"\";\n");
        sb.append("        }\n");
        sb.append("    }\n\n");
        sb.append("    private Secrets() {\n    }\n");
        sb.append("}\n");

        Files.write(Paths.get(outPath), sb.toString().getBytes("UTF-8"));
        System.out.println("      secrets packed");
    }

    private static String bytesField(String name, byte[] data) {
        StringBuilder sb = new StringBuilder();
        sb.append("    private static final byte[] ").append(name).append(" = {");
        for (int i = 0; i < data.length; i++) {
            if (i > 0) {
                sb.append(",");
            }
            sb.append(data[i]);
        }
        sb.append("};\n");
        return sb.toString();
    }
}
