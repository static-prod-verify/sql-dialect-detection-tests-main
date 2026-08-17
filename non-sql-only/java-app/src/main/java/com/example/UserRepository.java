package com.example;

import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.stereotype.Repository;

/**
 * User Repository - uses JPA/Hibernate ORM, no direct SQL.
 * This demonstrates a typical enterprise application pattern where
 * SQL is managed by the ORM layer, not by explicit SQL files.
 */
@Repository
public interface UserRepository extends JpaRepository<User, Long> {
    User findByEmail(String email);
}
