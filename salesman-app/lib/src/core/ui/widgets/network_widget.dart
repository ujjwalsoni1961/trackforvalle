// import 'package:connectivity_plus/connectivity_plus.dart';
// import 'package:flutter/material.dart';
// import 'package:provider/provider.dart';
// import 'package:track/src/core/network/network_status.dart';
// import 'package:track/src/core/ui/res/app_colors.dart';

// class NetworkWidget extends StatefulWidget {
//   const NetworkWidget({super.key});

//   @override
//   NetworkWidgetState createState() => NetworkWidgetState();
// }

// class NetworkWidgetState extends State<NetworkWidget> {
//   @override
//   Widget build(BuildContext context) {
//     return Consumer<NetworkStatus>(
//       builder: (context, networkStatus, child) {
//         bool isConnected = networkStatus.connectionStatus
//                 .contains(ConnectivityResult.wifi) ||
//             networkStatus.connectionStatus.contains(ConnectivityResult.mobile);
//         return AnimatedContainer(
//           height: !isConnected ? 24 : 0,
//           duration: const Duration(milliseconds: 200),
//           child: Container(
//             height: 12.0,
//             color: AppColors.red,
//             alignment: Alignment.center,
//             child: !isConnected
//                 ? const Text(
//                     'No Network Connection',
//                     style: TextStyle(
//                       color: Colors.white,
//                       fontSize: 10,
//                       fontWeight: FontWeight.bold,
//                     ),
//                   )
//                 : const SizedBox(),
//           ),
//         );
//       },
//     );
//   }
// }
