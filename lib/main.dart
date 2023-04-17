import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_shop_app/providers/auth.dart';
import 'package:flutter_shop_app/providers/cart.dart';
import 'package:flutter_shop_app/providers/orders.dart';
import 'package:flutter_shop_app/providers/products.dart';
import 'package:flutter_shop_app/screens/auth_screen.dart';
import 'package:flutter_shop_app/screens/cart_screen.dart';
import 'package:flutter_shop_app/screens/edit_product_screen.dart';
import 'package:flutter_shop_app/screens/orders_screen.dart';
import 'package:flutter_shop_app/screens/product_detail_screen.dart';
import 'package:flutter_shop_app/screens/product_overview_screen.dart';
import 'package:flutter_shop_app/screens/splash_screen.dart';
import 'package:flutter_shop_app/screens/user_product_screen.dart';
import 'package:provider/provider.dart';

void main() => runApp(MyApp());

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MultiProvider(providers: [
      ChangeNotifierProvider(create: (_) => Auth()),
      ChangeNotifierProxyProvider<Auth, Products>(
          create: (ctx) => Products.empty(""),
          update: (ctx, auth, previousProducts) => Products(auth.token!, previousProducts == null ? [] : previousProducts.items)),
      ChangeNotifierProvider(create: (_) => Cart()),
      ChangeNotifierProvider(create: (_) => Orders(),)
    ],
      child:
        Consumer<Auth>(builder:(ctx, auth, _) => MaterialApp(
          title: 'MyShop',
          theme: ThemeData(

            //primarySwatch: Colors.blue,
              scaffoldBackgroundColor:  Colors.blue// const Color(0xff242E42)
            /*elevatedButtonTheme: ElevatedButtonThemeData(
                style: ElevatedButton.styleFrom(
                  onPrimary: Colors.yellow,
                )),*/
          ),
          home: MyHomePage(),
        ),
    ));
  }
}

class MyHomePage extends StatefulWidget {
  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  /*Future<void> _configureAmplify() async {
    try {
      final auth = AmplifyAuthCognito();
      await Amplify.addPlugin(auth);

      // call Amplify.configure to use the initialized categories in your app
      await Amplify.configure(amplifyconfig);
      print("Amplify confiured correclty");
    } on Exception catch (e) {
      safePrint('An error occurred configuring Amplify: $e');
    }
  }*/

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    //_configureAmplify();
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<Auth>(builder:(ctx, auth, _) => MaterialApp(
      title: "MyShop",
      theme: ThemeData(
        primarySwatch:Colors.purple,
        accentColor: Colors.deepOrange,
        fontFamily: "Lato",
        backgroundColor: const Color(0xff242E42)
      ),
      home: auth.isAuth != null
          ? ProductOverviewScreen()
          : FutureBuilder(
        future: auth.tryAutoLogin(),
        builder: (ctx, authResult) => authResult.connectionState == ConnectionState.waiting ? SplashScreen( ): AuthScreen(), ),
      routes: {
        ProductDetailScreen.route_name: (ctx) => ProductDetailScreen(),
        CartScreen.routeName: (ctx) => CartScreen(),
        OrdersScreen.ROUTE_NAME: (ctx) => OrdersScreen(),
        UserProductScreen.routeName: (ctx) => UserProductScreen(),
        EditProductScreen.routeName: (ctx) => EditProductScreen(),
      },
    ),
    );
  }
}
