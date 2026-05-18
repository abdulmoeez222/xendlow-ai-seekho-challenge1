import os
import random
from dotenv import load_dotenv
load_dotenv()

from services.supabase_client import get_supabase

def seed_database():
    db = get_supabase()
    
    print("Seeding Campaigns...")
    campaigns = []
    regions = ["Lahore", "Karachi", "Islamabad", "Faisalabad", "Rawalpindi"]
    for i in range(50):
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
    for i in range(100):
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
    for i in range(75):
        notifications.append({
            "channel": random.choice(channels),
            "recipient_count": random.randint(100, 10000),
            "message_body": f"Historical alert for {random.choice(channels)} audience"
        })
    db.table("notifications").insert(notifications).execute()

    print("Database seeding completed successfully!")

if __name__ == "__main__":
    seed_database()
