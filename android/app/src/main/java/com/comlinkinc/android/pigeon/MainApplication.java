package com.comlinkinc.android.pigeon;

import android.app.Application;
import android.content.Context;
import android.content.pm.PackageManager;
import android.util.Log;
import android.widget.Toast;

import androidx.annotation.Nullable;
import androidx.core.app.ActivityCompat;
import androidx.core.content.ContextCompat;

import com.comlinkinc.android.pigeon.generated.BasePackageList;
import com.comlinkinc.android.pigeon.networking.SSLPinningPackage;
import com.facebook.react.PackageList;
import com.facebook.react.ReactApplication;
import com.facebook.react.ReactNativeHost;
import com.facebook.react.ReactPackage;
import com.facebook.soloader.SoLoader;
import com.google.firebase.FirebaseApp;
import com.nozbe.watermelondb.WatermelonDBPackage;
import com.reactnativecommunity.viewpager.RNCViewPagerPackage;
import com.ssg.autostart.AutostartPackage;
import com.toyberman.drawOverlay.RNDrawOverlayPackage;

import org.unimodules.adapters.react.ModuleRegistryAdapter;
import org.unimodules.adapters.react.ReactModuleRegistryProvider;

import java.util.Arrays;
import java.util.List;

import static android.Manifest.permission.WRITE_EXTERNAL_STORAGE;

public class MainApplication extends Application implements ReactApplication {

  private final ReactModuleRegistryProvider mModuleRegistryProvider = new ReactModuleRegistryProvider(new BasePackageList().getPackageList(), null);
  private static Context context;

  private final ReactNativeHost mReactNativeHost = new ReactNativeHost(this) {
    @Override
    public boolean getUseDeveloperSupport() {
      return BuildConfig.DEBUG;
    }

    @Override
    protected List<ReactPackage> getPackages() {
      @SuppressWarnings("UnnecessaryLocalVariable")
      List<ReactPackage> packages = new PackageList(this).getPackages();
      packages.add(new WatermelonDBPackage());
      packages.add(new RNCViewPagerPackage());
      packages.add(new SSLPinningPackage());
      packages.add(new NotificationSettingsPackage());
      packages.add(new SdkPackage());
//      packages.add(new RNDrawOverlayPackage());
//      packages.add(new AutostartPackage());
      List<ReactPackage> unimodules = Arrays.<ReactPackage>asList(
        new ModuleRegistryAdapter(mModuleRegistryProvider)
      );
      packages.addAll(unimodules);
      List<ReactPackage> additionalModules = new AdditionalModules().getAdditionalModules(MainApplication.this);
      packages.addAll(additionalModules);
      return packages;
    }

    @Override
    protected String getJSMainModuleName() {
      return "index";
    }

    @Override
    protected @Nullable String getBundleAssetName() {
      return "app.bundle";
    }
  };

  @Override
  public ReactNativeHost getReactNativeHost() {
    return mReactNativeHost;
  }

  @Override
  public void onCreate() {
    super.onCreate();
    MainApplication.context = getApplicationContext();
    FirebaseApp.initializeApp(this);
    SoLoader.init(this, /* native exopackage */ false);

    loadLibrary();
  }

  public static Context getAppContext() {
    return MainApplication.context;
  }

  public static void loadLibrary() {
    try {
      System.loadLibrary("ccomsdk-jni-0.99.9-4");
      Log.d("LIB_LOAD_SUCCESS", "Load library success");

      try {
//                CallManager.stopDialer();
//                CallManager.startDialer(getAppContext());
        Log.d("DILER_start_Application", "DILER_startDialer");

        if (ContextCompat.checkSelfPermission(MainApplication.getAppContext(), WRITE_EXTERNAL_STORAGE) == PackageManager.PERMISSION_GRANTED) {
          try {
            CallManager.copyRingtoneToPhoneStorage(MainApplication.getAppContext());
          } catch (Exception e) {
          }
        } else {
          Toast.makeText(MainApplication.getAppContext(), "Enable storage aaccess permission", Toast.LENGTH_SHORT).show();
//          ActivityCompat.requestPermissions(MainApplication.getAppContext(), new String[]{WRITE_EXTERNAL_STORAGE}, 1);
        }
      } catch (Exception e) {
        Log.d("DILER_Error_Application", e.getMessage().toString());
      }

    } catch (UnsatisfiedLinkError e) {
      Log.d("LIB_LOAD_FAIL", e.getMessage());
    }
  }
}
