package com.rent.rentsite;

import com.rent.rentsite.service.PaymentService;
import org.springframework.boot.CommandLineRunner;
import org.springframework.stereotype.Component;
import java.math.BigDecimal;

@Component
public class TestRunner implements CommandLineRunner {

    private final PaymentService paymentService;

    public TestRunner(PaymentService paymentService) {
        this.paymentService = paymentService;
    }

    @Override
    public void run(String... args) throws Exception {
        System.out.println("=== ТЕСТ ТРАНЗАКЦИИ В JAVA ===");
        
        // Опыт 1 (Успешный)
        paymentService.registerRentPaymentAndUpdateStatus(1L, 1L, new BigDecimal("15000.00"));
        System.out.println("Успешный платеж проведен!");

        // Опыт 3 (Ошибка CHECK в БД, Spring сделает Rollback)
        try {
            paymentService.registerInvalidPayment(1L, new BigDecimal("-50.00"));
        } catch (Exception e) {
            System.out.println("Ожидаемая ошибка БД: " + e.getMessage());
        }
    }
}