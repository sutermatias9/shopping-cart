public with sharing class ProductWrapper {
  public Integer id;
  public String title;
  public Double price;
  public String description;
  public String category;
  public String image;
  public Rating rating;

  public class Rating {
    public Double rate;
    public Integer count;
  }

  public static List<ProductWrapper> parse(String json) {
    return (List<ProductWrapper>) System.JSON.deserialize(
      json,
      List<ProductWrapper>.class
    );
  }
}
