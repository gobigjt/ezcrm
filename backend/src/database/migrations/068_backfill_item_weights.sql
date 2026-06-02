UPDATE quotation_items qi
SET unit_weight = COALESCE(p.weight, 0),
    line_weight = COALESCE(p.weight, 0) * qi.quantity
FROM products p
WHERE qi.product_id = p.id AND qi.unit_weight = 0 AND p.weight > 0;

UPDATE sales_order_items oi
SET unit_weight = COALESCE(p.weight, 0),
    line_weight = COALESCE(p.weight, 0) * oi.quantity
FROM products p
WHERE oi.product_id = p.id AND oi.unit_weight = 0 AND p.weight > 0;

UPDATE invoice_items ii
SET unit_weight = COALESCE(p.weight, 0),
    line_weight = COALESCE(p.weight, 0) * ii.quantity
FROM products p
WHERE ii.product_id = p.id AND ii.unit_weight = 0 AND p.weight > 0;
