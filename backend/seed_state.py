import os
import random
from dotenv import load_dotenv
load_dotenv()

from services.supabase_client import get_supabase

def seed_database():
    db = get_supabase()

    print("Seeding Shopify Products...")
    products = [
        {"sku": "SKU-001", "name": "Smart Watch Pro", "current_price": 28000.0, "cost_of_goods": 13720.0, "profit_margin": 0.51, "stock_level": 3, "status": "At Risk"},
        {"sku": "SKU-002", "name": "Premium Headphones", "current_price": 15000.0, "cost_of_goods": 8700.0, "profit_margin": 0.42, "stock_level": 12, "status": "Active"},
        {"sku": "SKU-003", "name": "Wireless Charger", "current_price": 3500.0, "cost_of_goods": 2170.0, "profit_margin": 0.38, "stock_level": 45, "status": "Active"},
        {"sku": "SKU-004", "name": "Phone Case Bundle", "current_price": 1200.0, "cost_of_goods": 420.0, "profit_margin": 0.65, "stock_level": 89, "status": "Active"},
        {"sku": "SKU-005", "name": "Laptop Stand", "current_price": 4800.0, "cost_of_goods": 2688.0, "profit_margin": 0.44, "stock_level": 15, "status": "Active"}
    ]
    for p in products:
        db.table("shopify_products").upsert(p, on_conflict="sku").execute()

    print("Seeding Marketing Campaigns...")
    marketing_campaigns = [
        {"network": "meta", "campaign_name": "Summer Sale", "spend": 45000.0, "clicks": 8420, "conversions": 312, "roas": 3.2, "active": True},
        {"network": "google", "campaign_name": "Retargeting", "spend": 22000.0, "clicks": 3150, "conversions": 87, "roas": 1.8, "active": True},
        {"network": "meta", "campaign_name": "Brand Awareness", "spend": 15000.0, "clicks": 12340, "conversions": 198, "roas": 4.1, "active": True},
        {"network": "google", "campaign_name": "Flash Sale", "spend": 8000.0, "clicks": 1890, "conversions": 64, "roas": 2.4, "active": False}
    ]
    for mc in marketing_campaigns:
        db.table("marketing_campaigns").upsert(mc, on_conflict="campaign_name").execute()

    print("Seeding Competitor Prices...")
    competitors = [
        {"product_name": "Smart Watch Pro", "competitor_name": "TechMart", "price": 22400.0},
        {"product_name": "Premium Headphones", "competitor_name": "TechMart", "price": 14500.0},
        {"product_name": "Wireless Charger", "competitor_name": "TechMart", "price": 3400.0}
    ]
    for c in competitors:
        db.table("competitor_prices").insert(c).execute()

    print("Seeding Logistics Rates...")
    logistics = [
        {"city": "Lahore", "carrier": "TCS", "base_shipping_fee": 250.0},
        {"city": "Karachi", "carrier": "Leopards", "base_shipping_fee": 280.0},
        {"city": "Islamabad", "carrier": "TCS", "base_shipping_fee": 260.0}
    ]
    for l in logistics:
        db.table("logistics_rates").insert(l).execute()

    print("Seeding Campaigns...")
    campaigns = []
    regions = ["Lahore", "Karachi", "Islamabad", "Faisalabad", "Rawalpindi"]
    for i in range(10):
        campaigns.append({
            "name": f"Flash Sale {i}",
            "region": random.choice(regions),
            "discount_pct": random.randint(5, 30),
            "projected_reach": random.randint(1000, 50000)
        })
    db.table("campaigns").insert(campaigns).execute()

    print("Seeding Pricing Logs...")
    pricing_logs = []
    items = ["AC", "TV", "Laptop", "Refrigerator", "Washing Machine"]
    for i in range(10):
        base_price = random.randint(30000, 250000)
        pricing_logs.append({
            "item_name": random.choice(items),
            "before_value": base_price,
            "after_value": base_price - random.randint(1000, 10000)
        })
    db.table("pricing_log").insert(pricing_logs).execute()

    print("Seeding Notifications...")
    notifications = []
    channels = ["SMS", "Email", "Push", "In-App"]
    for i in range(10):
        notifications.append({
            "channel": random.choice(channels),
            "recipient_count": random.randint(100, 10000),
            "message_body": f"Historical alert for {random.choice(channels)} audience"
        })
    db.table("notifications").insert(notifications).execute()

    print("Database seeding completed successfully!")

if __name__ == "__main__":
    seed_database()
