-- Trigger types regeneration
-- This comment ensures the types file syncs with the current database schema
COMMENT ON TABLE public.moods IS 'Stores user mood entries for tracking mental health';
COMMENT ON TABLE public.alerts IS 'Stores alerts generated from suspicious content detection';