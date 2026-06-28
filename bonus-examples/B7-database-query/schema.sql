-- Bonus B7 — minimal Customer Product DB for the live Postgres reference.
-- Create the table, load the four sample products, and make a READ-ONLY user
-- for n8n to connect as (least privilege — n8n never needs INSERT/UPDATE here).

CREATE TABLE IF NOT EXISTS products (
  product_code     TEXT PRIMARY KEY,
  description      TEXT        NOT NULL,
  uom              TEXT        NOT NULL,
  currency         TEXT        NOT NULL DEFAULT 'SGD',
  list_unit_price  NUMERIC(10,2) NOT NULL,
  min_order_qty    INTEGER     NOT NULL DEFAULT 1,
  lead_time_days   INTEGER     NOT NULL DEFAULT 0,
  bulk_tiers       JSONB       NOT NULL DEFAULT '[]'  -- [{ "min_qty": 100, "discount_pct": 12 }, ...]
);

INSERT INTO products (product_code, description, uom, currency, list_unit_price, min_order_qty, lead_time_days, bulk_tiers) VALUES
  ('ABC1233-019', 'Industrial-grade PVC conduit, 25mm x 3m, grey', 'length', 'SGD', 12.50, 10, 14,
     '[{"min_qty":50,"discount_pct":8},{"min_qty":100,"discount_pct":12},{"min_qty":500,"discount_pct":18}]'),
  ('ABC1233-021', 'Industrial-grade PVC conduit, 32mm x 3m, grey', 'length', 'SGD', 15.80, 10, 14,
     '[{"min_qty":50,"discount_pct":7},{"min_qty":100,"discount_pct":11},{"min_qty":500,"discount_pct":16}]'),
  ('XLR8810-004', 'Cable gland brass M20, IP68, pack of 10', 'pack', 'SGD', 9.20, 5, 7,
     '[{"min_qty":25,"discount_pct":5},{"min_qty":100,"discount_pct":10},{"min_qty":250,"discount_pct":15}]'),
  ('DLT7702-100', 'Junction box, 4-way, weatherproof, IP66', 'each', 'SGD', 6.40, 20, 21,
     '[{"min_qty":100,"discount_pct":9},{"min_qty":500,"discount_pct":14},{"min_qty":1000,"discount_pct":20}]')
ON CONFLICT (product_code) DO NOTHING;

-- Least-privilege role for n8n. Pricing reads only — no write grants.
-- (Run as a DB admin; then store these creds in n8n's Postgres credential.)
CREATE ROLE n8n_readonly LOGIN PASSWORD 'change-me-in-a-real-deployment';
GRANT CONNECT ON DATABASE postgres TO n8n_readonly;     -- adjust DB name
GRANT USAGE ON SCHEMA public TO n8n_readonly;
GRANT SELECT ON products TO n8n_readonly;               -- SELECT only, this table only
