class CoinsDetailsModel{
  late String id;
  late String symbol;
  late String name;
  late String image;
  late double currentPrice;
  late double priceChangePercentage_24h;

  CoinsDetailsModel(this.id, this.symbol, this.name, this.image,
      this.currentPrice, this.priceChangePercentage_24h);

   CoinsDetailsModel.fromJson(Map<String, dynamic> json) {
      id = json["id"];
      symbol = json["symbol"];
      name = json["name"];
      image = json["image"];
      currentPrice = json["current_price"].toDouble();
      priceChangePercentage_24h = json["price_change_percentage_24h"];
  }
}