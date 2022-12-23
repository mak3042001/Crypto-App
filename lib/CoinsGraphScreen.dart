import 'dart:convert';
import 'package:crypto_currency_app/coinsDetailsModel.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'AppTheme.dart';

// ignore: must_be_immutable
class CoinsGraphScreen extends StatefulWidget {
  CoinsDetailsModel coinsDetailsModel;

  CoinsGraphScreen({Key? key, required this.coinsDetailsModel})
      : super(key: key);

  @override
  State<CoinsGraphScreen> createState() => _CoinsGraphScreenState();
}

class _CoinsGraphScreenState extends State<CoinsGraphScreen> {
  bool isLoading = true , isFirst=true;
  List<FlSpot> flSpotList = [];
  double minX=0.0,minY=0.0,maxX=0.0,maxY=0.0;
  @override
  void initState() {
    super.initState();
    // TODO: implement initState
    getChartDetails("1");
  }

    void getChartDetails(String days) async {
    if(isFirst){
      isFirst=false;
    }else{
      setState(() {
        isLoading=true;
      });
    }
    String apiUrl = "https://api.coingecko.com/api/v3/coins/${widget.coinsDetailsModel.id}/market_chart?vs_currency=inr&days=$days";
    Uri uri = Uri.parse(apiUrl);
    final response = await http.get(uri);
    if(response.statusCode==200 || response.statusCode==201){
    Map<String,dynamic> result = json.decode(response.body);
    List rowList = result['prices'];
    List<List> chartData = rowList.map((e) => e as List).toList();
    List<PriceAndTime> priceAndTime = chartData.map((e) => PriceAndTime(time: e[0] as int, price: e[1] as double)).toList();
    flSpotList=[];
    for(var e in priceAndTime){
      flSpotList.add(FlSpot(e.time.toDouble(), e.price));
    }
    setState(() {
      isLoading = false;
    });

    minX = flSpotList.first.x.toDouble();
    maxX = flSpotList.last.x.toDouble();
    priceAndTime.sort((a,b) => a.price.compareTo(b.price));
    minY = flSpotList.first.y;
    maxY = flSpotList.last.y;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.isDarkModeEnable ? Colors.black : Colors.white,
      appBar: AppBar(
        elevation: 0.0,
        leading: IconButton(
          onPressed: () {
            Navigator.pop(context);
          },
          icon: Icon(
            Icons.arrow_back_ios,
            color: AppTheme.isDarkModeEnable ? Colors.white : Colors.black,
          ),
        ),
        backgroundColor:
            AppTheme.isDarkModeEnable ? Colors.black : Colors.white,
        title: Text(
          "${widget.coinsDetailsModel.name}",
          style: TextStyle(
            color: AppTheme.isDarkModeEnable ? Colors.white : Colors.black,
          ),
        ),
        centerTitle: true,
      ),
      body: isLoading == false? SizedBox(
        width: double.infinity,
        child: Column(
          children: [
            Padding(
              padding:
                  const EdgeInsets.symmetric(vertical: 10.0, horizontal: 20.0),
              child: Align(
                alignment: Alignment.centerLeft,
                child: RichText(
                  text: TextSpan(
                      text: "${widget.coinsDetailsModel.name} price \n ",
                      style: TextStyle(
                        color: AppTheme.isDarkModeEnable
                            ? Colors.white
                            : Colors.black,
                        fontSize: 18,
                      ),
                    children: [
                      TextSpan(
                  text: "Rs.${widget.coinsDetailsModel.currentPrice}\n ",
                      style: TextStyle(
                        color: AppTheme.isDarkModeEnable
                            ? Colors.white
                            : Colors.black,
                        fontSize: 30,
                        fontWeight: FontWeight.w500,
                      ),
                  ),
                      TextSpan(
                        text: "${widget.coinsDetailsModel.priceChangePercentage_24h}%\n ",
                        style: const TextStyle(
                        color: Colors.red,
                      ),
                  ),
                      TextSpan(
                        text: "Rs.$maxY\n ",
                        style: TextStyle(
                          color: AppTheme.isDarkModeEnable
                              ? Colors.white
                              : Colors.black,
                          fontSize: 18,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ]
                  ),
                ),
              ),
            ),
            const SizedBox(
              height: 250,
            ),
            SizedBox(
              height: 100,
              width: double.infinity,
              child: LineChart(
                LineChartData(
                  minX: minX,
                  minY: minY,
                  maxX: maxX,
                  maxY: maxY,
                  borderData: FlBorderData(
                    show: false,
                  ),
                  titlesData: FlTitlesData(
                    show: false,
                  ),
                  gridData: FlGridData(
                    getDrawingHorizontalLine: (value) {
                      return FlLine(
                        strokeWidth: 0.0,
                      );
                    },
                    getDrawingVerticalLine: (value) {
                      return FlLine(
                        strokeWidth: 0.0,
                      );
                    },
                  ),
                  lineBarsData:[ LineChartBarData(
                    dotData: FlDotData(
                      show: false,
                    ),
                    spots: flSpotList
                  )
                  ]
                )
              ),
            ),
            Expanded(child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                ElevatedButton(onPressed: (){
                  getChartDetails("1");
                }, child: const Text("1 d")),
                ElevatedButton(onPressed: (){
                  getChartDetails("15");
                }, child: const Text("15 d")),
                ElevatedButton(onPressed: (){
                  getChartDetails("30");
                }, child: const Text("30 d")),
              ],
            ))
          ],
        ),
      ):const Center(child: CircularProgressIndicator()),
    );

  }
}

class PriceAndTime{
  late int time;
  late double price;

  PriceAndTime({required this.time, required this.price});
}
