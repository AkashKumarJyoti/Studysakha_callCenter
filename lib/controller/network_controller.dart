import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:get/get.dart';
import 'package:flutter/material.dart';
import '../user_data/navigation_bar.dart';

class NetworkController extends GetxController {
  final Connectivity _connectivity = Connectivity();

  @override
  void onInit(){
    super.onInit();
    _connectivity.onConnectivityChanged.listen(_updateConnectionStatus);

  }
  void _updateConnectionStatus(ConnectivityResult connectivityResult) {
    if (connectivityResult == ConnectivityResult.none) {
      Get.off(() => const NoInternetScreen());
      Get.rawSnackbar(
          messageText: const Text('PLEASE CONNECT TO THE INTERNET', style: TextStyle(
              color: Colors.white,
              fontSize: 14
          )),
          isDismissible: false,
          duration: const Duration(days: 1),
          backgroundColor: Colors.red[400]!,
          icon: const Icon(Icons.wifi_off, color: Colors.white, size: 35),
          margin: EdgeInsets.zero,
          snackStyle: SnackStyle.FLOATING
      );
    }
    else {
      if(Get.isSnackbarOpen) {
        Get.closeCurrentSnackbar();
      }
      Get.off(() => const MyNavigationBar());
    }
  }
}

class NoInternetScreen extends StatelessWidget {
  const NoInternetScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('No Internet'),
      ),
      body: const Center(
        child: Text('Please connect to the internet.'),
      ),
    );
  }
}