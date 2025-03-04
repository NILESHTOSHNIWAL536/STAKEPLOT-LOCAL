-dontwarn org.bouncycastle.jsse.BCSSLParameters
-dontwarn org.bouncycastle.jsse.BCSSLSocket
-dontwarn org.bouncycastle.jsse.provider.BouncyCastleJsseProvider
-dontwarn org.conscrypt.Conscrypt$Version
-dontwarn org.conscrypt.Conscrypt
-dontwarn org.conscrypt.ConscryptHostnameVerifier
-dontwarn org.openjsse.javax.net.ssl.SSLParameters
-dontwarn org.openjsse.javax.net.ssl.SSLSocket
-dontwarn org.openjsse.net.ssl.OpenJSSE

-keep class com.finvu.android.publicInterface.** { <fields>; }
-keep class com.finvu.android.models.** { <fields>; }
-keep class com.finvu.android.types.** { <fields>; }
-keepattributes Annotation

-keepattributes Signature
-keep class com.google.gson.reflect.**
-keep class * extends com.google.gson.reflect.**