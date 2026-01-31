# 🔄 Pruebas de Replicación - GlobalShop

Documentación de las pruebas de replicación bidireccional entre PostgreSQL (América) y MySQL (Europa).

---

## ✅ Prueba 1: América → Europa (Cliente Replicado)

**Inserción en PostgreSQL (América):**
```sql
INSERT INTO customers (customer_id, email, full_name, country, is_premium) 
VALUES ('CUSTOMER-FINAL-TEST', 'final@test.com', 'Final Test', 'USA', false);
```

**Resultado en MySQL (Europa):**
```
customer_id          | email        | full_name
CUSTOMER-FINAL-TEST  | final@test.com | Final Test
```

✅ **EXITOSO** - Replicado en 15-25 segundos

---

## ✅ Prueba 2: Europa → América (Producto Replicado)

**Inserción en MySQL (Europa):**
```sql
INSERT INTO products (product_id, product_name, category, base_price, is_active) 
VALUES ('PROD-EUROPE-TEST', 'Product from Europe', 'Test', 199.99, 1);
```

**Resultado en PostgreSQL (América):**
```
product_id        | product_name        | base_price
PROD-EUROPE-TEST  | Product from Europe | 199.99
```

✅ **EXITOSO** - Replicado en 15-25 segundos

---

## 📊 Resumen

| Prueba | Origen | Destino | Estado |
|--------|--------|---------|--------|
| Cliente | PostgreSQL | MySQL | ✅ Replicado |
| Producto | MySQL | PostgreSQL | ✅ Replicado |

**Replicación Bidireccional**: ✅ **100% OPERACIONAL**

**Última actualización**: 30 de enero de 2026

