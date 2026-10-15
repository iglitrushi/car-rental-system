package model;

import java.util.Date;

public class ReservationCalendar {

    private int carId;
    private String nameOfBrand;  
    private String model;
    private String transmission;
    private String fuel;
    private int price;
    private Date startDate;
    private Date endDate;

    public ReservationCalendar(int carId, String nameOfBrand, String model, String transmission, String fuel, int price, Date startDate, Date endDate) {
        this.carId = carId;
        this.nameOfBrand = nameOfBrand;
        this.model = model;
        this.transmission = transmission;
        this.fuel = fuel;
        this.price = price;
        this.startDate = startDate;
        this.endDate = endDate;
    }

    public int getCarId() {
        return carId;
    }

    public void setCarId(int carId) {
        this.carId = carId;
    }

    public String getNameOfBrand() {
        return nameOfBrand;
    }

    public void setNameOfBrand(String nameOfBrand){
        this.nameOfBrand = nameOfBrand;
    }

    public String getModel() {
        return model;
    }

    public void setModel(String model) {
        this.model = model;
    }

    public String getTransmission() {
        return transmission;
    }

    public void setTransmission(String transmission) {
        this.transmission = transmission;
    }

    public String getFuel() {
        return fuel;
    }

    public void setFuel(String fuel){
        this.fuel = fuel;
    }

    public int getPrice(){
        return price;
    }

    public void setPrice(int price){
        this.price = price;
    }

    public Date getStartDate() {
        return startDate;
    }

    public void setStartDate(Date startDate) {
        this.startDate = startDate;
    }

    public Date getEndDate() {
        return endDate;
    }

    public void setEndDate(Date endDate) {
        this.endDate = endDate;
    }
}
