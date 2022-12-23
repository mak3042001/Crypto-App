import 'dart:convert';
import 'package:crypto_currency_app/AppTheme.dart';
import 'package:crypto_currency_app/CoinsGraphScreen.dart';
import 'package:crypto_currency_app/coinsDetailsModel.dart';
import 'package:crypto_currency_app/profilePage.dart';
import 'package:http/http.dart' as http;
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class HomePage extends StatefulWidget {
  const HomePage({Key? key}) : super(key: key);

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  bool isFirstAcceses = true;
  String name = "", email = "", age = "";
  String url =
      "https://api.coingecko.com/api/v3/coins/markets?vs_currency=inr&order=market_cap_desc&per_page=100&page=1&sparkline=false";
  GlobalKey<ScaffoldState> scaffoldKey = GlobalKey<ScaffoldState>();
  List<CoinsDetailsModel> coinsDetailsList = [];
  late Future<List<CoinsDetailsModel>> coinsDetailsFuture;

  // bool isDarkMode = AppTheme.isDarkModeEnable;

  @override
  void initState() {
    super.initState();
    getDetails();
    coinsDetailsFuture = getCoinsDetails();
  }

  Future<List<CoinsDetailsModel>> getCoinsDetails() async {
    Uri uri = Uri.parse(url);

    final response = await http.get(uri);

    if (response.statusCode == 200 || response.statusCode == 201) {
      List coinsData = json.decode(response.body);

      List<CoinsDetailsModel> data =
          coinsData.map((e) => CoinsDetailsModel.fromJson(e)).toList();

      return data;
    } else {
      return <CoinsDetailsModel>[];
    }
  }

  void getDetails() async {
    SharedPreferences sharedPreferences = await SharedPreferences.getInstance();
    setState(() {
      name = sharedPreferences.getString("name") ?? "";
      email = sharedPreferences.getString("email") ?? "";
      age = sharedPreferences.getString("age") ?? "";
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: scaffoldKey,
      backgroundColor: AppTheme.isDarkModeEnable ? Colors.black : Colors.white,
      appBar: AppBar(
        centerTitle: true,
        elevation: 0.0,
        leading: IconButton(
          onPressed: () {
            scaffoldKey.currentState!.openDrawer();
          },
          icon: Icon(
            Icons.menu,
            color: AppTheme.isDarkModeEnable ? Colors.white : Colors.black,
          ),
        ),
        backgroundColor:
            AppTheme.isDarkModeEnable ? Colors.black : Colors.white,
        title: Text(
          "CryptoCurrency App",
          style: TextStyle(
            color: AppTheme.isDarkModeEnable ? Colors.white : Colors.black,
          ),
        ),
      ),
      drawer: Drawer(
        backgroundColor:
            AppTheme.isDarkModeEnable ? Colors.black : Colors.white,
        child: Column(
          children: [
            UserAccountsDrawerHeader(
              currentAccountPicture: const Icon(
                Icons.account_circle,
                size: 70,
                color: Colors.white,
              ),
              accountName: Text(
                name,
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w500,
                ),
              ),
              accountEmail: Column(
                children: [
                  Text(
                    email,
                    style: const TextStyle(
                      fontSize: 17,
                    ),
                  ),
                  Text(
                    age,
                    style: const TextStyle(
                      fontSize: 17,
                    ),
                  ),
                ],
              ),
            ),
            ListTile(
              leading: Icon(
                Icons.account_box,
                color: AppTheme.isDarkModeEnable ? Colors.white : Colors.black,
              ),
              onTap: () {
                Navigator.push(context,
                    MaterialPageRoute(builder: (context) => ProfilePage()));
              },
              title: Text(
                "Update Profile",
                style: TextStyle(
                  color:
                      AppTheme.isDarkModeEnable ? Colors.white : Colors.black,
                  fontSize: 17,
                ),
              ),
            ),
            ListTile(
              leading: Icon(
                AppTheme.isDarkModeEnable ? Icons.light_mode : Icons.dark_mode,
                color: AppTheme.isDarkModeEnable ? Colors.white : Colors.black,
              ),
              onTap: () async {
                SharedPreferences shpr = await SharedPreferences.getInstance();

                setState(() {
                  AppTheme.isDarkModeEnable = !AppTheme.isDarkModeEnable;
                });
                // AppTheme.isDarkModeEnable = AppTheme.isDarkModeEnable;
                await shpr.setBool('isDark', AppTheme.isDarkModeEnable);
              },
              title: Text(
                AppTheme.isDarkModeEnable ? "Light Mode" : "Dark Mode",
                style: TextStyle(
                  color:
                      AppTheme.isDarkModeEnable ? Colors.white : Colors.black,
                  fontSize: 17,
                ),
              ),
            ),
          ],
        ),
      ),
      body: FutureBuilder(
        future: coinsDetailsFuture,
        builder: (context, AsyncSnapshot<List<CoinsDetailsModel>> snapshot) {
          if (snapshot.hasData) {
            if (isFirstAcceses) {
              coinsDetailsList = snapshot.data!;
              isFirstAcceses = false;
            }
            return Column(
              children: [
                Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 15,
                    vertical: 20,
                  ),
                  child: TextField(
                    onChanged: (query) {
                      List<CoinsDetailsModel> searchResult =
                          snapshot.data!.where((element) {
                        String coinName = element.name;

                        bool isItemFound = coinName.contains(query);

                        return isItemFound;
                      }).toList();

                      setState(() {
                        coinsDetailsList = searchResult;
                      });
                    },
                    decoration: InputDecoration(
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(30),
                        borderSide: BorderSide(
                          color: AppTheme.isDarkModeEnable ? Colors.white : Colors.grey,
                        )
                      ),
                        prefixIcon: Icon(
                          Icons.search,
                          color: AppTheme.isDarkModeEnable
                              ? Colors.white
                              : Colors.black,
                        ),
                        hintText: "Search",
                        hintStyle: TextStyle(
                          color: AppTheme.isDarkModeEnable ? Colors.white : Colors.grey,
                        ),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(20),
                        )),
                  ),
                ),
                Expanded(
                  child: coinsDetailsList.isEmpty
                      ? const Center(child: Text("No Coins Found"))
                      : ListView.builder(
                          physics: const BouncingScrollPhysics(),
                          itemCount: coinsDetailsList.length,
                          itemBuilder: (context, index) {
                            return coinsModel(coinsDetailsList[index]);
                          }),
                ),
              ],
            );
          } else {
            return const Center(child: CircularProgressIndicator());
          }
        },
      ),
    );
  }

  Widget coinsModel(CoinsDetailsModel model) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 10.0),
      child: ListTile(
        onTap: (){
          Navigator.push(context, MaterialPageRoute(builder: (context) => CoinsGraphScreen(coinsDetailsModel: model,)));
        },
        leading: SizedBox(
          height: 50,
          width: 50,
          child: Image.network(
            model.image,
          ),
        ),
        title: Text(
          "${model.name} \n ${model.symbol}",
          style: TextStyle(
            fontSize: 17,
            fontWeight: FontWeight.w500,
            color: AppTheme.isDarkModeEnable ? Colors.white : Colors.black,
          ),
        ),
        trailing: RichText(
          textAlign: TextAlign.end,
          text: TextSpan(
            text: "Rs.${model.currentPrice}\n ",
            style: TextStyle(
              fontSize: 17,
              fontWeight: FontWeight.w500,
              color: AppTheme.isDarkModeEnable ? Colors.white : Colors.black,
            ),
            children: [
              TextSpan(
                text: "${model.priceChangePercentage_24h}",
                style: const TextStyle(
                  fontSize: 17,
                  fontWeight: FontWeight.w500,
                  color: Colors.red,
                ),
              )
            ],
          ),
        ),
      ),
    );
  }
}
