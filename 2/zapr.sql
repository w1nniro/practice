WITH product_material_cost AS (
    SELECT 
        p.id AS product_id,
        SUM(s.quantity * m.cost_price) AS material_cost_per_unit
    FROM products p
    LEFT JOIN specification s ON s.product_id = p.id
    LEFT JOIN materials m ON m.id = s.material_id
    GROUP BY p.id
),
order_details AS (
    SELECT 
        o.id AS order_id,
        o.doc_number,
        o.doc_date,
        oc.product_id,
        oc.quantity AS order_quantity,
        oc.price AS sale_price_per_unit,
        oc.amount AS order_line_total,
        pmc.material_cost_per_unit,
        (oc.quantity * COALESCE(pmc.material_cost_per_unit, 0)) AS total_material_cost_for_line
    FROM orders o
    JOIN Order_contents oc ON oc.order_id = o.id
    LEFT JOIN product_material_cost pmc ON pmc.product_id = oc.product_id
)
SELECT 
    order_id,
    doc_number,
    doc_date,
    SUM(order_line_total) AS total_sale_amount,
    SUM(total_material_cost_for_line) AS total_material_cost,
    SUM(order_line_total) - SUM(total_material_cost_for_line) AS gross_profit
FROM order_details
GROUP BY order_id, doc_number, doc_date
ORDER BY order_id;