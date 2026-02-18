-- Create Site Settings Table
CREATE TABLE IF NOT EXISTS site_settings (
    id INT PRIMARY KEY DEFAULT 1,
    site_logo_text TEXT DEFAULT 'Khelun ar jitun',
    site_logo_url TEXT,
    welcome_bonus NUMERIC DEFAULT 0,
    referral_bonus NUMERIC DEFAULT 0,
    vip_popup_text TEXT, /* General fallback */
    vip_bronze_text TEXT,
    vip_silver_text TEXT,
    vip_gold_text TEXT,
    vip_platinum_text TEXT,
    vip_diamond_text TEXT,
    visitor_text TEXT,
    bkash_number TEXT,
    nagad_number TEXT,
    rocket_number TEXT,
    usdt_address TEXT,
    telegram_link TEXT,
    whatsapp_link TEXT,
    currency_symbol TEXT DEFAULT '৳',
    support_email TEXT DEFAULT 'support@example.com',
    facebook_link TEXT,
    livechat_link TEXT,
    timer_popup_enabled BOOLEAN DEFAULT FALSE,
    timer_popup_duration NUMERIC DEFAULT 1,
    timer_popup_title TEXT,
    timer_popup_message TEXT,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    CONSTRAINT single_row CHECK (id = 1)
);

-- Insert default row if not exists
INSERT INTO site_settings (id) VALUES (1) ON CONFLICT (id) DO NOTHING;

-- Enable RLS for site_settings
ALTER TABLE site_settings ENABLE ROW LEVEL SECURITY;
DROP POLICY IF EXISTS "Public read access" ON site_settings;
DROP POLICY IF EXISTS "Public full access" ON site_settings;
CREATE POLICY "Public read access" ON site_settings FOR SELECT USING (true);
CREATE POLICY "Public full access" ON site_settings FOR ALL USING (true);


-- Create Games Table
CREATE TABLE IF NOT EXISTS games (
    id UUID DEFAULT gen_random_uuid() PRIMARY KEY,
    name TEXT NOT NULL,
    category TEXT NOT NULL,
    image_url TEXT,
    play_url TEXT,
    vip_level_required TEXT DEFAULT 'Bronze',
    is_active BOOLEAN DEFAULT true,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- Enable RLS for games
ALTER TABLE games ENABLE ROW LEVEL SECURITY;
DROP POLICY IF EXISTS "Public read access" ON games;
DROP POLICY IF EXISTS "Public manage games" ON games;
CREATE POLICY "Public read access" ON games FOR SELECT USING (true);
CREATE POLICY "Public manage games" ON games FOR ALL USING (true);


-- Create Carousel Items Table
CREATE TABLE IF NOT EXISTS carousel_items (
    id UUID DEFAULT gen_random_uuid() PRIMARY KEY,
    image_url TEXT NOT NULL,
    link_url TEXT,
    display_order SERIAL,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- Enable RLS for carousel
ALTER TABLE carousel_items ENABLE ROW LEVEL SECURITY;
DROP POLICY IF EXISTS "Public read access" ON carousel_items;
DROP POLICY IF EXISTS "Public manage carousel" ON carousel_items;
CREATE POLICY "Public read access" ON carousel_items FOR SELECT USING (true);
CREATE POLICY "Public manage carousel" ON carousel_items FOR ALL USING (true);


-- Create Profiles Table
CREATE TABLE IF NOT EXISTS profiles (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    username TEXT UNIQUE,
    mobile TEXT,
    password TEXT,
    email TEXT,
    balance NUMERIC DEFAULT 0,
    vip_level TEXT DEFAULT 'Bronze',
    member_since TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    referral_code TEXT UNIQUE,
    loyalty_points NUMERIC DEFAULT 0,
    is_admin BOOLEAN DEFAULT FALSE,
    role TEXT DEFAULT 'member',
    status TEXT DEFAULT 'active',
    friends_referred INT DEFAULT 0,
    total_earnings NUMERIC DEFAULT 0,
    active_friends INT DEFAULT 0,
    pending_bonus NUMERIC DEFAULT 0,
    referrer_id UUID REFERENCES profiles(id),
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- Ensure all columns exist for existing tables
DO $$ 
BEGIN 
    IF NOT EXISTS (SELECT 1 FROM information_schema.columns WHERE table_name = 'profiles' AND column_name = 'created_at') THEN 
        ALTER TABLE profiles ADD COLUMN created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(); 
    END IF;
    IF NOT EXISTS (SELECT 1 FROM information_schema.columns WHERE table_name = 'profiles' AND column_name = 'role') THEN 
        ALTER TABLE profiles ADD COLUMN role TEXT DEFAULT 'member';
    END IF; 
    IF NOT EXISTS (SELECT 1 FROM information_schema.columns WHERE table_name = 'profiles' AND column_name = 'status') THEN 
        ALTER TABLE profiles ADD COLUMN status TEXT DEFAULT 'active';
    END IF; 
    IF NOT EXISTS (SELECT 1 FROM information_schema.columns WHERE table_name = 'profiles' AND column_name = 'friends_referred') THEN 
        ALTER TABLE profiles ADD COLUMN friends_referred INT DEFAULT 0;
    END IF;
END $$;

-- Enable RLS on profiles
ALTER TABLE profiles ENABLE ROW LEVEL SECURITY;
DROP POLICY IF EXISTS "Public profiles full" ON profiles;
CREATE POLICY "Public profiles full" ON profiles FOR ALL USING (true);


-- Create Transactions Table
CREATE TABLE IF NOT EXISTS transactions (
    id UUID DEFAULT gen_random_uuid() PRIMARY KEY,
    user_id UUID REFERENCES profiles(id),
    username TEXT, -- Flat username for quick display
    type TEXT NOT NULL, -- 'deposit', 'withdraw', 'bonus'
    amount NUMERIC NOT NULL,
    description TEXT,
    status TEXT DEFAULT 'pending', -- 'pending', 'completed', 'rejected'
    receipt_url TEXT,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- Enable RLS for transactions
ALTER TABLE transactions ENABLE ROW LEVEL SECURITY;
DROP POLICY IF EXISTS "Public full access transactions" ON transactions;
CREATE POLICY "Public full access transactions" ON transactions FOR ALL USING (true);


-- Create available_bonuses table
CREATE TABLE IF NOT EXISTS available_bonuses (
    id UUID DEFAULT gen_random_uuid() PRIMARY KEY,
    bonus_name TEXT NOT NULL,
    bonus_type TEXT NOT NULL,
    amount NUMERIC NOT NULL,
    description TEXT,
    max_claims_per_user INT DEFAULT 1,
    auto_unlock BOOLEAN DEFAULT FALSE,
    is_active BOOLEAN DEFAULT TRUE,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- Enable RLS for available_bonuses
ALTER TABLE available_bonuses ENABLE ROW LEVEL SECURITY;
DROP POLICY IF EXISTS "Public full access available_bonuses" ON available_bonuses;
CREATE POLICY "Public full access available_bonuses" ON available_bonuses FOR ALL USING (true);


-- Create user_bonuses table (track claims)
CREATE TABLE IF NOT EXISTS user_bonuses (
    id UUID DEFAULT gen_random_uuid() PRIMARY KEY,
    user_id UUID REFERENCES profiles(id),
    bonus_type TEXT NOT NULL,
    amount NUMERIC NOT NULL,
    description TEXT,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- Enable RLS for user_bonuses
ALTER TABLE user_bonuses ENABLE ROW LEVEL SECURITY;
DROP POLICY IF EXISTS "Public full access user_bonuses" ON user_bonuses;
CREATE POLICY "Public full access user_bonuses" ON user_bonuses FOR ALL USING (true);


-- Create user_bonus_eligibility table
CREATE TABLE IF NOT EXISTS user_bonus_eligibility (
    id UUID DEFAULT gen_random_uuid() PRIMARY KEY,
    user_id UUID REFERENCES profiles(id),
    bonus_type TEXT NOT NULL,
    amount NUMERIC NOT NULL,
    is_available BOOLEAN DEFAULT TRUE,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- Enable RLS for user_bonus_eligibility
ALTER TABLE user_bonus_eligibility ENABLE ROW LEVEL SECURITY;
DROP POLICY IF EXISTS "Public full access bonus_eligibility" ON user_bonus_eligibility;
CREATE POLICY "Public full access bonus_eligibility" ON user_bonus_eligibility FOR ALL USING (true);


-- Storage Bucket Setup
INSERT INTO storage.buckets (id, name, public) VALUES ('site-assets', 'site-assets', true) ON CONFLICT (id) DO NOTHING;

-- Storage Policies
DROP POLICY IF EXISTS "Public Upload" ON storage.objects;
DROP POLICY IF EXISTS "Public Select" ON storage.objects;
DROP POLICY IF EXISTS "Public Update" ON storage.objects;
DROP POLICY IF EXISTS "Public Delete" ON storage.objects;
CREATE POLICY "Public Upload" ON storage.objects FOR INSERT WITH CHECK (bucket_id = 'site-assets');
CREATE POLICY "Public Select" ON storage.objects FOR SELECT USING (bucket_id = 'site-assets');
CREATE POLICY "Public Update" ON storage.objects FOR UPDATE USING (bucket_id = 'site-assets');
CREATE POLICY "Public Delete" ON storage.objects FOR DELETE USING (bucket_id = 'site-assets');
