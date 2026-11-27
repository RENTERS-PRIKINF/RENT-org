package com.rent.rentsite.service;

import com.rent.rentsite.entity.*;
import com.rent.rentsite.repository.*;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.math.BigDecimal;

@Service
public class PaymentService {

    private final PaymentRepository paymentRepository;
    private final FlatRepository flatRepository;

    public PaymentService(PaymentRepository paymentRepository,
                          FlatRepository flatRepository) {
        this.paymentRepository = paymentRepository;
        this.flatRepository = flatRepository;
    }

    @Transactional(rollbackFor = Exception.class)
    public void registerRentPaymentAndUpdateStatus(Long rentId, Long flatId, BigDecimal amount) {
        if (amount == null || amount.compareTo(BigDecimal.ZERO) <= 0) {
            throw new IllegalArgumentException("Сумма платежа должна быть положительной.");
        }

        Flat flat = flatRepository.findById(flatId)
                .orElseThrow(() -> new RuntimeException("Квартира с ID " + flatId + " не найдена"));

        Payment payment = new Payment(
                rentId,
                amount,
                PaymentType.rent,
                PaymentDirection.income,
                "Оплата аренды по договору"
        );
        paymentRepository.save(payment);

        if (flat.getStatus() == FlatStatus.AVAILABLE) {
            flat.setStatus(FlatStatus.RENTED);
            flatRepository.save(flat);
        }
    }

    @Transactional(rollbackFor = Exception.class)
    public void registerInvalidPayment(Long rentId, BigDecimal negativeAmount) {
        Payment payment = new Payment(
                rentId,
                negativeAmount,
                PaymentType.penalty,
                PaymentDirection.income,
                "Штраф"
        );
        
        paymentRepository.save(payment);
    }

    @Transactional(rollbackFor = Exception.class)
    public void registerPaymentWithBusinessRollback(Long rentId, BigDecimal amount) {
        boolean isValidRent = rentId != null && rentId > 0;

        if (!isValidRent) {
            throw new RuntimeException("Бизнес-ошибка: Неверный ID аренды. Транзакция будет откачена.");
        }

        Payment payment = new Payment(
                rentId,
                amount,
                PaymentType.rent,
                PaymentDirection.income,
                "Оплата с бизнес-валидацией"
        );
        paymentRepository.save(payment);
    }
}