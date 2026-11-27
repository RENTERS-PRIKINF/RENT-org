package com.rent.rentsite.repository;

import com.rent.rentsite.entity.Payment;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.stereotype.Repository;

import java.util.List;

@Repository
public interface PaymentRepository extends JpaRepository<Payment, Long> {
    
    List<Payment> findByRentId(Long rentId);
    
    List<Payment> findByDirection(String direction);
}