-- Ambiguous SQL - basic portable syntax without strong dialect keywords
CREATE TABLE users (
    id INT PRIMARY KEY,
    name VARCHAR(100),
    email VARCHAR(100),
    age INT,
    active BOOLEAN,
    created_at TIMESTAMP
);

INSERT INTO users (id, name, email, age, active) VALUES (1, 'John Doe', 'john@example.com', 30, true);
INSERT INTO users (id, name, email, age, active) VALUES (2, 'Jane Smith', 'jane@example.com', 25, true);

SELECT * FROM users WHERE age > 25;

CREATE VIEW active_users AS
SELECT id, name, email FROM users WHERE active = true;

UPDATE users SET active = false WHERE id = 1;

DELETE FROM users WHERE age < 18;

CREATE INDEX idx_email ON users(email);
CREATE INDEX idx_active ON users(active);
