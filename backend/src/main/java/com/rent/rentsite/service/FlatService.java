package com.rent.rentsite.service;

public class FlatService {

    public boolean canBeRented(Flat flat) {
    return flat != null
            && flat.getAddress() != null
            && !flat.isRented();
    } 
}
