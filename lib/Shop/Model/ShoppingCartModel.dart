class ShoppingCartModel {

  String ShopCartNumber;
  List<ShoppingCartItem> items;

}

class ShoppingCartItem {
  String bookName;
  String price;
  String orderNumber;

  bool isSelected;
}