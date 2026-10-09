CREATE TABLE price_observation (
    id BIGSERIAL PRIMARY KEY,
    observed_date DATE NOT NULL,
    price_type_code VARCHAR(20),
    price_type_name VARCHAR(50),
    category_code VARCHAR(30),
    category_name VARCHAR(100),
    item_code VARCHAR(30),
    item_name VARCHAR(100) NOT NULL,
    variety_code VARCHAR(30),
    variety_name VARCHAR(100),
    grade_code VARCHAR(30),
    grade_name VARCHAR(100),
    region_code VARCHAR(30),
    region_name VARCHAR(100),
    market_code VARCHAR(30),
    market_name VARCHAR(100),
    unit_name VARCHAR(50),
    unit_size NUMERIC,
    price NUMERIC(15,2) NOT NULL,
    price_per_kg NUMERIC(15,2),
    source_registered_at TIMESTAMP,
    created_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP
);

CREATE TABLE price_alert (
    id BIGSERIAL PRIMARY KEY,
    price_observation_id BIGINT NOT NULL REFERENCES price_observation(id),
    previous_observation_id BIGINT REFERENCES price_observation(id),
    alert_type VARCHAR(30) NOT NULL,
    previous_price NUMERIC(15,2),
    current_price NUMERIC(15,2) NOT NULL,
    change_rate NUMERIC(8,2),
    threshold NUMERIC(8,2) NOT NULL,
    created_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP
);

CREATE TABLE sync_history (
    id BIGSERIAL PRIMARY KEY,
    started_at TIMESTAMP NOT NULL,
    ended_at TIMESTAMP,
    status VARCHAR(20) NOT NULL,
    requested_count INT NOT NULL DEFAULT 0,
    inserted_count INT NOT NULL DEFAULT 0,
    skipped_count INT NOT NULL DEFAULT 0,
    error_message TEXT
);

CREATE INDEX idx_price_observation_item_date ON price_observation(item_name, observed_date);
CREATE INDEX idx_price_alert_created_at ON price_alert(created_at);

-- 실제 aT API 응답을 확인한 뒤 natural key를 확정하여 UNIQUE constraint를 추가한다.
