SELECT qi.unit_weight, qi.line_weight, p.weight, qi.quantity FROM quotation_items qi JOIN products p ON p.id=qi.product_id LIMIT 5;
