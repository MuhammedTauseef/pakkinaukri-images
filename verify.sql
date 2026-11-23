-- ReplyPilot 62-article migration — post-import verification (READ-ONLY)
-- Run AFTER all import chunks and repair-gyms.sql, in the Supabase SQL Editor (project uacklzmreepbketabiig).

-- Q1: total published posts — expect 129 (67 existing + 62 imported)
SELECT count(*) AS published_count FROM blog_posts WHERE published;

-- Q2: imported rows present — expect 62
SELECT count(*) AS imported_present FROM blog_posts WHERE slug IN ('whatsapp-automation-clothing-boutiques', 'ai-chatbot-bakeries', 'ai-chatbot-wedding-planners', 'whatsapp-automation-flower-shops', 'ai-chatbot-pet-groomers', 'ai-chatbot-tutoring-businesses', 'whatsapp-automation-guesthouses', 'ai-chatbot-car-detailing', 'ai-chatbot-interior-designers', 'ai-chatbot-law-firms', 'ai-chatbot-car-rental-services', 'ai-chatbot-barbershops', 'whatsapp-automation-pharmacies', 'ai-chatbot-travel-agencies', 'whatsapp-automation-furniture-stores', 'ai-chatbot-language-schools', 'ai-chatbot-coffee-shops', 'ai-chatbot-veterinary-clinics', 'ai-chatbot-yoga-studios', 'ai-chatbot-home-cleaning-services', 'ai-chatbot-physiotherapy-clinics', 'whatsapp-automation-car-wash', 'whatsapp-automation-juice-bars', 'whatsapp-automation-laundry-services', 'whatsapp-automation-pizza-restaurants', 'whatsapp-automation-tailoring-shops', 'instagram-dm-automation-dance-studios', 'instagram-dm-automation-dog-trainers', 'instagram-dm-automation-makeup-artists', 'instagram-dm-automation-nail-salons', 'instagram-dm-automation-tattoo-studios', 'ai-phone-receptionist-small-business', 'whatsapp-business-api-setup-guide', 'best-ai-chatbots-small-business-2026', 'n8n-whatsapp-automation-tutorial', 'whatsapp-broadcast-marketing-playbook', 'whatsapp-automation-bridal-shops', 'whatsapp-automation-dry-cleaners', 'whatsapp-automation-food-trucks', 'whatsapp-automation-moving-companies', 'whatsapp-automation-music-schools', 'ai-chatbot-car-wash-business', 'ai-chatbot-furniture-stores', 'ai-chatbot-gift-shops', 'whatsapp-automation-daycare', 'whatsapp-automation-print-shops', 'ai-chatbot-bookstores', 'ai-chatbot-driving-schools', 'ai-chatbot-opticians', 'ai-chatbot-pharmacies', 'whatsapp-automation-tax-preparers', 'ai-chatbot-mortgage-brokers', 'whatsapp-automation-auto-repair-shops', 'whatsapp-automation-grocery-stores', 'whatsapp-automation-caterers', 'whatsapp-automation-pest-control-companies', 'ai-chatbot-recruitment-agencies', 'ai-chatbot-spa-appointment-booking', 'whatsapp-automation-carpenters', 'whatsapp-automation-home-inspectors', 'whatsapp-automation-ice-cream-parlors', 'whatsapp-automation-house-painters');

-- Q3: per-slug comparison — every row must show match = true.
-- blocks and jsonb_text_len are recomputed server-side from the stored JSONB (independent checks:
-- jsonb_text_len = length(content::text); the expected value is the local JSON.stringify length plus
-- one space per structural ':' / ',' separator, which is how Postgres renders jsonb as text).
-- content_chars / word_count are the stored metric columns, compared with the values the import
-- wrote (computed from the static source with the exact lib/blog-meta.ts formulas).
-- md5_fingerprint is recorded for the run log. The decisive end-to-end content check is the
-- PostgREST re-read described in execution-notes.md.
WITH expected(slug, blocks, content_chars, word_count, jsonb_text_len) AS (VALUES
  ('whatsapp-automation-clothing-boutiques', 83, 21681, 3223, 22024),
  ('ai-chatbot-bakeries', 86, 23698, 3697, 24059),
  ('ai-chatbot-wedding-planners', 71, 18724, 2809, 19018),
  ('whatsapp-automation-flower-shops', 82, 22738, 3489, 23089),
  ('ai-chatbot-pet-groomers', 78, 22098, 3457, 22433),
  ('ai-chatbot-tutoring-businesses', 70, 20129, 3117, 20423),
  ('whatsapp-automation-guesthouses', 71, 21633, 3259, 21940),
  ('ai-chatbot-car-detailing', 76, 20502, 3247, 20824),
  ('ai-chatbot-interior-designers', 72, 21726, 3370, 22039),
  ('ai-chatbot-law-firms', 82, 23337, 3535, 23685),
  ('ai-chatbot-car-rental-services', 59, 19645, 3110, 19892),
  ('ai-chatbot-barbershops', 54, 19856, 3135, 20083),
  ('whatsapp-automation-pharmacies', 53, 19085, 2864, 19308),
  ('ai-chatbot-travel-agencies', 54, 20090, 3036, 20313),
  ('whatsapp-automation-furniture-stores', 55, 19931, 2999, 20162),
  ('ai-chatbot-language-schools', 55, 20243, 2998, 20474),
  ('ai-chatbot-coffee-shops', 80, 28455, 4552, 28807),
  ('ai-chatbot-veterinary-clinics', 74, 27913, 4291, 28243),
  ('ai-chatbot-yoga-studios', 75, 26964, 4165, 27297),
  ('ai-chatbot-home-cleaning-services', 70, 26901, 4141, 27224),
  ('ai-chatbot-physiotherapy-clinics', 67, 28202, 4264, 28509),
  ('whatsapp-automation-car-wash', 78, 26122, 4202, 26467),
  ('whatsapp-automation-juice-bars', 82, 27232, 4244, 27589),
  ('whatsapp-automation-laundry-services', 84, 26824, 4090, 27187),
  ('whatsapp-automation-pizza-restaurants', 82, 27065, 4252, 27429),
  ('whatsapp-automation-tailoring-shops', 83, 27155, 4080, 27511),
  ('instagram-dm-automation-dance-studios', 61, 24263, 3715, 24527),
  ('instagram-dm-automation-dog-trainers', 56, 25027, 3784, 25271),
  ('instagram-dm-automation-makeup-artists', 62, 24274, 3706, 24542),
  ('instagram-dm-automation-nail-salons', 59, 25482, 4066, 25738),
  ('instagram-dm-automation-tattoo-studios', 60, 24665, 3925, 24930),
  ('ai-phone-receptionist-small-business', 55, 22400, 3465, 22623),
  ('whatsapp-business-api-setup-guide', 46, 17258, 2635, 17445),
  ('best-ai-chatbots-small-business-2026', 56, 20992, 3118, 21225),
  ('n8n-whatsapp-automation-tutorial', 64, 20343, 3173, 20602),
  ('whatsapp-broadcast-marketing-playbook', 55, 19743, 2915, 19966),
  ('whatsapp-automation-bridal-shops', 69, 22057, 3406, 22346),
  ('whatsapp-automation-dry-cleaners', 71, 21213, 3219, 21510),
  ('whatsapp-automation-food-trucks', 67, 20738, 3164, 21019),
  ('whatsapp-automation-moving-companies', 68, 20894, 3173, 21179),
  ('whatsapp-automation-music-schools', 69, 21661, 3170, 21950),
  ('ai-chatbot-car-wash-business', 70, 23682, 3640, 23990),
  ('ai-chatbot-furniture-stores', 61, 21198, 3219, 21456),
  ('ai-chatbot-gift-shops', 73, 22928, 3560, 23236),
  ('whatsapp-automation-daycare', 59, 20553, 3161, 20803),
  ('whatsapp-automation-print-shops', 62, 20785, 3206, 21047),
  ('ai-chatbot-bookstores', 62, 20560, 3200, 20818),
  ('ai-chatbot-driving-schools', 61, 20951, 3131, 21202),
  ('ai-chatbot-opticians', 61, 20564, 3093, 20815),
  ('ai-chatbot-pharmacies', 62, 20892, 3074, 21149),
  ('whatsapp-automation-tax-preparers', 58, 20066, 3044, 20305),
  ('ai-chatbot-mortgage-brokers', 70, 21904, 3332, 22201),
  ('whatsapp-automation-auto-repair-shops', 75, 21412, 3306, 21730),
  ('whatsapp-automation-grocery-stores', 83, 21976, 3280, 22328),
  ('whatsapp-automation-caterers', 64, 22268, 3389, 22545),
  ('whatsapp-automation-pest-control-companies', 60, 20472, 3155, 20729),
  ('ai-chatbot-recruitment-agencies', 55, 21027, 3383, 21255),
  ('ai-chatbot-spa-appointment-booking', 51, 19625, 3185, 19839),
  ('whatsapp-automation-carpenters', 63, 19294, 3132, 19555),
  ('whatsapp-automation-home-inspectors', 59, 22915, 3753, 23174),
  ('whatsapp-automation-ice-cream-parlors', 44, 20369, 3350, 20554),
  ('whatsapp-automation-house-painters', 67, 17660, 2828, 17940)
)
SELECT e.slug, e.blocks AS expected_blocks, jsonb_array_length(b.content) AS actual_blocks,
       e.jsonb_text_len AS expected_jsonb_text_len, length(b.content::text) AS actual_jsonb_text_len,
       e.content_chars AS expected_content_chars, b.content_chars AS actual_content_chars,
       e.word_count AS expected_word_count, b.word_count AS actual_word_count,
       md5(b.content::text) AS md5_fingerprint,
       (jsonb_array_length(b.content) = e.blocks AND length(b.content::text) = e.jsonb_text_len AND b.content_chars = e.content_chars AND b.word_count = e.word_count) AS match
FROM expected e LEFT JOIN blog_posts b ON b.slug = e.slug
ORDER BY e.slug;

-- Q4: gyms twin after repair — expect blocks = 65, content_chars = 18738
SELECT slug, jsonb_array_length(content) AS blocks, content_chars, word_count FROM blog_posts WHERE slug = 'ai-chatbot-gyms-fitness-studios';

-- Q5: the 16 pre-existing twins untouched — expect 16
SELECT count(*) AS twins_still_present FROM blog_posts WHERE published AND slug IN ('whatsapp-automation-restaurants', 'instagram-dm-automation-salons', 'ai-chatbots-dental-clinics', 'ecommerce-store-assistants', 'lead-capture-automation', 'n8n-workflow-automation-small-business', 'ai-chatbot-real-estate-agents', 'ai-chatbot-plumbers-home-services', 'whatsapp-automation-car-dealerships', 'ai-chatbot-gyms-fitness-studios', 'ai-chatbot-photographers', 'ai-chatbot-insurance-agents', 'ai-chatbot-solar-companies', 'whatsapp-automation-electricians', 'whatsapp-automation-locksmiths', 'ai-chatbot-roofing-companies');
